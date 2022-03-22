// Written by .:..:
// A jump pad with bot support.
// The jumper itself (starting point).
Class UJumpPad extends UJumpPadEnd;

var() sound JumpSound;
var() vector JumpVelocityModifier;
var() float JumpZHeightModifier;
var() const bool bForceFullAccurancy; // Always jump perfectly into the Dest point, but is a little bit more CPU intensive and may variate the velocity a little bit.
var() bool bAllowMonsters,bAllowPlayers; // Whatever if monsters or players/bots can use this jump pad.
var vector BackUp_Velocity,JumpVelocity;
var nowarn Pawn PendingTouch; //unused, for older version compat only.
var UJumpDest MyDest;

var bool BACKUP_Enabled;

replication
{
	// Replicate Jump velocity to client to keep them better in sync with server.
	reliable if ( Role==ROLE_Authority )
		JumpVelocity;
}

function PostBeginPlay()
{
	local byte i;
	local Actor St,En;
	local int RF,D;

	For( i=0; i<ArrayCount(Paths); i++ )
	{
		if ( Paths[i]==-1 )
			Continue;
		describeSpec(Paths[i],St,En,RF,D);
		if ( UJumpDest(En) )
		{
			MyDest = UJumpDest(En);
			if ( bForceFullAccurancy )
				JumpVelocity = MyDest.Location+JumpVelocityModifier;
			else JumpVelocity = CalcThrowVelocity(Location,En.Location);
			Break;
		}
	}
	if( !MyDest )
		JumpVelocity = JumpVelocityModifier;
	BackUp_Velocity = JumpVelocity;
	BACKUP_Enabled = bCollideActors;
	bSpecialCost = !(bCollideActors && bAllowMonsters && bAllowPlayers);
}
function Reset()
{
	JumpVelocity = BackUp_Velocity;
	SetCollision(BACKUP_Enabled);
	bSpecialCost = !(bCollideActors && bAllowMonsters && bAllowPlayers);
	bForceNetUpdate = true;
}
simulated function Touch( Actor Other )
{
	if ( Other.bIsPawn && Pawn(Other).Health>0 && (Pawn(Other).bIsPlayer ? bAllowPlayers : bAllowMonsters) )
		SetPendingTouch(Other);
}
simulated function PostTouch( Actor Other )
{
	if ( !Other.bDeleteMe && Other.bIsPawn )
	{
		if ( !Other.bIsPlayerPawn )
		{
			Pawn(Other).PlayInAir(); // Make sure this pawn plays falling animation.
			Other.Acceleration = vect(0,0,0);
			if ( MyDest )
				Pawn(Other).MoveTarget = MyDest.SpecialHandling(Pawn(Other));
		}
		// Only set the physics on server OR net owner.
		if ( Other.Role>=ROLE_AutonomousProxy && Other.Physics!=PHYS_Falling && Other.Physics!=PHYS_Flying )
			Other.SetPhysics(PHYS_Falling);
		if ( bForceFullAccurancy )
			Other.Velocity = CalcThrowVelocity(Other.Location,JumpVelocity);
		else Other.Velocity = JumpVelocity;
		
		if( Level.NetMode!=NM_Client )
		{
			if ( JumpSound )
				MakeJumpNoise();
			if( Event!='' )
				TriggerEvent(Event,Self,Pawn(Other));
		}
	}
}
function MakeJumpNoise()
{
	PlaySound(JumpSound);
}
simulated final function float CalcRequiredZHeight( float DestZ, float StartZ, float GravZ )
{
	local int LCount;

	if ( GravZ>=0 )
		GravZ = -100;
	DestZ-=StartZ;
	StartZ = 0;
	while ( DestZ>0 && LCount<8000 ) // Due to the inaccurate Unreal Engine physics code we need to do this.
	{
		StartZ+=GravZ*0.05f;
		DestZ+=StartZ*0.05f;
		LCount++;
	}
	return Abs(StartZ) + JumpZHeightModifier;
}
simulated final function vector CalcThrowVelocity( vector Start, vector End )
{
	return SuggestFallVelocity(Start,End,0.f,VSize2D(End-Start),CalcRequiredZHeight(End.Z,Start.Z,Region.Zone.ZoneGravity.Z)) + JumpVelocityModifier;
}

// Use original behaviour.
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	return Super(LiftExit).EdPathBuildExec(End,ForcedDistance);
}

// Draw trajectory.
function DrawEditorSelection( Canvas C )
{
	local color Color;
	local vector V,P,G;
	local byte i;
	local UJumpDest Dest;

	foreach AllActors(Class'UJumpDest',Dest)
		if( Dest.LiftTag==LiftTag )
			break;
	if( Dest )
	{
		if ( bForceFullAccurancy )
			V = CalcThrowVelocity(Location,Dest.Location+JumpVelocityModifier);
		else V = CalcThrowVelocity(Location,Dest.Location);
	}
	else if ( bForceFullAccurancy )
		V = CalcThrowVelocity(Location,JumpVelocityModifier);
	else V = JumpVelocityModifier;

	Color = MakeColor(255,255,0);
	G = Region.Zone.ZoneGravity*Square(0.05f);
	V*=0.05f;
	P = Location;
	for( i=0; i<200; ++i )
	{
		V+=G;
		C.Draw3DLine(Color,P,P+V);
		if( !FastTrace(P+V,P) )
			break;
		P+=V;
	}
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	bSkipActorReplication = false; // Enable replication for bCollideActors.
	SetCollision(!bCollideActors);
	bForceNetUpdate = true;
	if( bCollideActors )
	{
		bSpecialCost = !(bAllowMonsters && bAllowPlayers);
		CheckEncroachments();
	}
	else bSpecialCost = true;
}

function int SpecialCost(Pawn Seeker)
{
	if( bCollideActors && (Seeker.bIsPlayer ? bAllowPlayers : bAllowMonsters) )
		return 0;
	return -1;
}

simulated function OnMirrorMode()
{
	JumpVelocityModifier.Y *= -1.f;
}

defaultproperties
{
	bEditorSelectRender=True
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bSkipActorReplication=True
	bCollideActors=True
	NetPriority=7.000000
	NetUpdateFrequency=5
	bOnlyDirtyReplication=true
	bAllowMonsters=true
	bAllowPlayers=true
	bSpecialCost=true
}
