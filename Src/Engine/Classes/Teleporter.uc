///=============================================================================
// Teleports actors either between different teleporters within a level
// or to matching teleporters on other levels, or to general Internet URLs.
//=============================================================================
class Teleporter extends NavigationPoint
	native;

#exec Texture Import File=Textures\Teleport.pcx Name=S_Teleport Mips=Off Flags=2

cpptext
{
	ATeleporter() {}
	void Serialize( FArchive& Ar );
}

//-----------------------------------------------------------------------------
// Teleporter URL can be one of the following forms:
//
// TeleporterName
//		Teleports to a named teleporter in this level.
//		if none, acts only as a teleporter destination
//
// LevelName/TeleporterName
//     Teleports to a different level on this server.
//
// Unreal://Server.domain.com/LevelName/TeleporterName
//     Teleports to a different server on the net.
//
var() string URL;

//-----------------------------------------------------------------------------
// Product the user must have installed in order to enter the teleporter (now really, isnt it obvious its 'Unreal' only?).
var() name ProductRequired;

//-----------------------------------------------------------------------------
// Teleporter destination flags.
var() bool    bChangesVelocity; // Set velocity to TargetVelocity.
var() bool    bChangesYaw;      // Sets yaw to teleporter's Rotation.Yaw (defaults to True in UT maps)
var() bool    bReversesX;       // Reverses X-component of velocity.
var() bool    bReversesY;       // Reverses Y-component of velocity.
var() bool    bReversesZ;       // Reverses Z-component of velocity.

// Teleporter flags
var() bool	  bEnabled;			// Teleporter is turned on;
var() bool    bUTRotationMode;	// 227j: bChangesYaw functions like in UT (defaults to True in UT maps).

//-----------------------------------------------------------------------------
// Teleporter destination directions.
var() vector  TargetVelocity;   // If bChangesVelocity, set target's velocity to this.

var() name TargetLevelID; // 227j: Target Sub-level name to send player to.

// AI related
var Actor TriggerActor;		//used to tell AI how to trigger me
var Actor TriggerActor2;

var transient float LastUdpTime;
var transient byte TeleportCount;
var bool bBackup_Enabled;

//-----------------------------------------------------------------------------
// Teleporter destination functions.

function PostBeginPlay()
{
	local LevelInfo L;
	local Teleporter T;

	if (URL ~= "")
		SetCollision(false, false, false); //destination only

	bBackup_Enabled = bEnabled;
	if ( !bEnabled )
		FindTriggerActor();
	Super.PostBeginPlay();
	
	if( TargetLevelID!='' )
	{
		L = Level.FindLevel(TargetLevelID);
		if( L==None || L==Level )
			return;
			
		foreach L.AllActors(class'Teleporter',T)
			if ( string(T.Tag)~=URL && T!=Self )
				AddReachSpec(GenReachSpec(Self, T, 100, 256, 256, R_SPECIAL),T);
	}
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	if ( Tag=='' )
		Return;
	ForEach AllActors(class'Actor',A,,Tag)
	{
		if (TriggerActor == None)
			TriggerActor = A.GetTriggerActor();
		else
		{
			TriggerActor2 = A.GetTriggerActor();
			return;
		}
	}
}

// Accept an actor that has teleported in.
function bool Accept( actor Incoming )
{
	local rotator NewRot, OldRot;
	local float mag;
	local vector oldDir;
	local pawn P;

	// Move the actor here.
	Disable('Touch');
	//log("Move Actor here "$tag);
	NewRot = Incoming.Rotation;
	if (bChangesYaw)
	{
		OldRot = Incoming.Rotation;
		NewRot.Yaw = Rotation.Yaw;
		if ( bUTRotationMode && Target )
			NewRot.Yaw += (32768 + Incoming.Rotation.Yaw - Target.Rotation.Yaw);
	}

	if ( Incoming.bIsPawn )
	{
		//tell enemies about teleport
		foreach Incoming.Level.AllActors(class'Pawn',P)
			if (P.Enemy == Incoming)
				P.LastSeenPos = Incoming.Location;
		
		if( Incoming.Level!=Level )
		{
			if( !Incoming.SendToLevel(Level,Location,newRot) )
			{
				Enable('Touch');
				return false;
			}
		}
		else if( !Incoming.SetLocation(Location,newRot) )
		{
			Enable('Touch');
			return false;
		}
		Pawn(Incoming).ClientSetRotation(newRot);
		Pawn(Incoming).ViewRotation = newRot;
		Pawn(Incoming).MoveTimer = -1.0;
		Pawn(Incoming).MoveTarget = self;

		if( bChangesVelocity && (Incoming.Physics==PHYS_Walking || Incoming.Physics==PHYS_None) && !Incoming.Region.Zone.bWaterZone )
			Incoming.SetPhysics(PHYS_Falling);
	}
	else
	{
		if( Incoming.Level!=Level )
		{
			if( !Incoming.SendToLevel(Level,Location) )
			{
				Enable('Touch');
				return false;
			}
		}
		else if ( !Incoming.SetLocation(Location) )
		{
			Enable('Touch');
			return false;
		}
		if ( bChangesYaw )
			Incoming.SetRotation(newRot);
	}

	Enable('Touch');

	if (bChangesVelocity)
		Incoming.Velocity = TargetVelocity;
	else
	{
		if ( bChangesYaw )
		{
			if ( Incoming.Physics == PHYS_Walking )
				OldRot.Pitch = 0;
			oldDir = vector(OldRot);
			mag = Incoming.Velocity Dot oldDir;
			Incoming.Velocity = Incoming.Velocity - mag * oldDir + mag * vector(Incoming.Rotation);
		}
		if ( bReversesX )
			Incoming.Velocity.X *= -1.0;
		if ( bReversesY )
			Incoming.Velocity.Y *= -1.0;
		if ( bReversesZ )
			Incoming.Velocity.Z *= -1.0;
	}

	// Play teleport-in effect.
	PlayTeleportEffect(Incoming, true);
	Incoming.PostTeleport(Self);
	return true;
}

function PlayTeleportEffect(actor Incoming, bool bOut)
{
	if ( Incoming.bIsPawn )
	{
		Incoming.MakeNoise(1.0);
		Level.Game.PlayTeleportEffect(Incoming, bOut, true);
	}
}

//-----------------------------------------------------------------------------
// Teleporter functions.

function Trigger( actor Other, pawn EventInstigator )
{
	local Actor A;

	bEnabled = !bEnabled;
	if ( bEnabled ) //teleport any pawns already in my radius
		foreach TouchingActors(Class'Actor',A)
			Touch(A);
}

// Teleporter was touched by an actor.
function Touch( actor Other )
{
	if ( !bEnabled )
		return;

	/* 227f: Avoid some random inf. loops from happening */
	if ( LastUdpTime==Level.TimeSeconds )
	{
		if ( TeleportCount>5 )
			return;
		else TeleportCount++;
	}
	else
	{
		TeleportCount = 0;
		LastUdpTime = Level.TimeSeconds;
	}

	if ( Other.bCanTeleport && !Other.PreTeleport(Self) )
	{
		if ( (InStr( URL, "/" ) >= 0) || (InStr( URL, "#" ) >= 0) )
		{
			// Teleport to a level on the net.
			if ( PlayerPawn(Other) != None )
				Level.Game.SendPlayer(PlayerPawn(Other), URL);
		}
		else SetPendingTouch(Other); // 227j, use PostTouch for Velocity change to work correctly.
	}
}
function PostTouch( actor Other )
{
	local Teleporter Dest;
	local array<Teleporter> TList;
	local LevelInfo L;

	Other.bCanTeleport = false;
	// Teleport to a random teleporter in this local level, if more than one pick random.
	if( TargetLevelID!='' )
	{
		L = Level.FindLevel(TargetLevelID);
		if( L==None )
		{
			if( Other.bIsPawn )
				Pawn(Other).ClientMessage( "Teleport destination level '"$TargetLevelID$"' not found!" );
			return;
		}
		foreach L.AllActors( class 'Teleporter', Dest )
			if ( string(Dest.Tag)~=URL && Dest!=Self )
				TList.Add(Dest);
	}
	else
	{
		foreach AllActors( class 'Teleporter', Dest )
			if ( string(Dest.Tag)~=URL && Dest!=Self )
				TList.Add(Dest);
	}
	if ( TList.Size()>0 )
		Dest = TList[Rand(TList.Size())];
	if ( Dest != None )
	{
		// Teleport the actor into the other teleporter.
		PlayTeleportEffect(Other, false);
		Dest.Target = Self;
		if ( Dest.Accept(Other) && Other.bIsPawn )
		{
			TriggerEvent(Event,Other,Other.Instigator);
			if( L!=None && L!=Level )
				L.TriggerEvent(Event,Other,Other.Instigator);
		}
	}
	else if( Other.bIsPawn )
		Pawn(Other).ClientMessage( "Teleport destination '"$URL$"' not found!" );
	Other.bCanTeleport = true;
}

/* SpecialHandling is called by the navigation code when the next path has been found.
It gives that path an opportunity to modify the result based on any special considerations
*/

function Actor SpecialHandling(Pawn Other)
{
	local Pawn P;

	if ( bEnabled )
	{
		foreach TouchingActors(Class'Pawn',P)
			if( P==Other )
			{
				Touch(Other);
				break;
			}
		return self;
	}

	if (TriggerActor == None)
	{
		FindTriggerActor();
		if (TriggerActor == None)
			return None;
	}

	if ( (TriggerActor2 != None)
			&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
		return TriggerActor2;

	return TriggerActor;
}

function Reset()
{
	bEnabled = bBackup_Enabled; /* Resetting game state */
}

// Teleporter is forced to be bound with other sides.
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	if( Teleporter(End)!=None && string(End.Tag)~=URL && TargetLevelID=='' )
	{
		ForcedDistance = 100;
		return PATHING_Special;
	}
	return Super.EdPathBuildExec(End,ForcedDistance);
}

defaultproperties
{
	bEnabled=True
	bDirectional=True
	Texture=Texture'S_Teleport'
	SoundVolume=128
	CollisionRadius=18.000000
	CollisionHeight=40.000000
	bCollideActors=True
	bNoStrafeTo=true
}