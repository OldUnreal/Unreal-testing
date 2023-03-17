//=============================================================================
// Decoration.
//=============================================================================
class Decoration extends Actor
	abstract
	native;

var() bool bPushable; // Decoration can be pushed around.
var() bool bOnlyTriggerable; // Spawn no fragments when destroyed.
var() bool bOrientToGround; // Orient to ground direction when landing.
var bool bSplash;
var bool bBobbing;
var bool bWasCarried;
var bool bPushSoundPlaying;

var() class<actor> EffectWhenDestroyed; // If set, the pyrotechnic or explosion when item is damaged.
var() sound PushSound; // Ambient sound while pushing.
var const int	 numLandings; // Used by engine physics.
var() class<Actor> contents; // Main contents of this deco.
var() class<Actor> content2; // 30 % random content.
var() class<Actor> content3; // +30 % random content.
var() sound EndPushSound; // Sound effect to be played after done pushing.

// shadow decal
var transient Actor Shadow;

simulated function BeginPlay()
{
	Super.BeginPlay();
}

function PostLoadGame()
{
	ShadowModeChange();
}

// Called by C++ codes BeginPlay.
simulated function ShadowModeChange()
{
	if( !bNoDynamicShadowCast )
	{
		if( !Class'GameInfo'.Default.bCastShadow || !Class'GameInfo'.Default.bDecoShadows || Style==STY_Translucent || Style==STY_Modulated )
		{
			if( Shadow )
			{
				Shadow.Destroy();
				Shadow = None;
			}
		}
		else if( !Shadow )
		{
			if( bStatic )
				Shadow = Spawn(Class'DecoShadowStatic',Self);
			else Shadow = Spawn(Class'DecoShadow',Self);
		}
	}
}

simulated event OnSubLevelChange( LevelInfo PrevLevel )
{
	if( Shadow )
		Shadow.SendToLevel(Level, Location);
}

simulated function FollowHolder(Actor Other);

function Landed(vector HitNormal)
{
	local vector X,Y;
	local rotator R;

	if ( bWasCarried && !SetLocation(Location) && !bStatic )
	{
		if ( Instigator!=None && (VSize(Instigator.Location - Location) < CollisionRadius + Instigator.CollisionRadius) )
			SetLocation(Instigator.Location);
		TakeDamage( 1000, Instigator, Location, Vect(0,0,1)*900,'exploded' );
	}
	else
	{
		SetPhysics(PHYS_None);
		
		if( bOrientToGround )
		{
			R.Yaw = Rotation.Yaw;
			Y = Normal(HitNormal Cross vector(R));
			X = Normal(Y Cross HitNormal);
			R = OrthoRotation(X,Y,HitNormal);
			R.Yaw = Rotation.Yaw;
			SetRotation(R);
		}
	}
	bWasCarried = false;
	bBobbing = false;
}

singular function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if ( NewZone.bWaterZone )
	{
		if ( bSplash && !Region.Zone.bWaterZone && Mass<=Buoyancy
				&& ((Abs(Velocity.Z) < 100) || (Mass == 0)) && (FRand() < 0.05) && !PlayerCanSeeMe() )
		{
			bSplash = false;
			SetPhysics(PHYS_None);
		}
		else if ( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// Else play a splash.
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 3.0 );
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor);
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
		bSplash = true;
	}
	else if ( Region.Zone.bWaterZone && (Buoyancy > Mass) )
	{
		bBobbing = true;
		if ( Buoyancy > 1.1 * Mass )
			Buoyancy = 0.95 * Buoyancy; // waterlog
		else if ( Buoyancy > 1.03 * Mass )
			Buoyancy = 0.99 * Buoyancy;
	}

	if ( NewZone.bPainZone && (NewZone.DamagePerSec > 0) )
		TakeDamage(100, None, location, vect(0,0,0), NewZone.DamageType);
}

function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	if (!bStatic)
		TakeDamage( 1000, Instigator, Location, Vect(0,0,1)*900,'exploded' );
}

singular function BaseChange()
{
	local float decorMass, decorMass2;

	if (bDeleteme)
		return;
	if (bStatic)
	{
		SetPhysics(PHYS_None);
		return;
	}
	decormass= FMax(1, Mass);
	bBobbing = false;
	if ( Velocity.Z < -500 )
		TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , 'crushed');

	if ( (base == None) && (bPushable || IsA('Carcass')) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if ( (Pawn(base) != None) && (Pawn(Base).CarriedDecoration != self) )
	{
		if (!IsA('Carcass') && !Base.bDeleteme && Pawn(base).Health > 0 )
			Base.TakeDamage( (1-Velocity.Z/400)* decormass/Base.Mass,Instigator,Location,0.5 * Velocity , 'crushed');
		Velocity.Z = 200;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else if ( Decoration(Base)!=None )
	{
		If(  Velocity.Z<-500)
		{
			decorMass2 = FMax(Base.Mass, 1);
			if (!Base.bDeleteme)
				Base.TakeDamage((1 - decorMass/decorMass2 * Velocity.Z/30), Instigator, Location, 0.2 * Velocity, 'stomped');
			Velocity.Z = 100;
			if (FRand() < 0.5)
				Velocity.X += 70;
			else
				Velocity.Y += 70;
			SetPhysics(PHYS_Falling);
		}
		if ( Decoration(Base)!=None && Base.Base==none && Decoration(Base).bPushable && !Base.bStatic && Base.Physics==PHYS_None )
			Base.SetPhysics(PHYS_Falling);
	}
	else
		instigator = None;
}

function Destroyed()
{
	local actor dropped;
	local class<Actor> tempClass;

	if ( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) )
		Pawn(Base).DropDecoration();
	if ( (Contents!=None) && !Level.bStartup )
	{
		tempClass = Contents;
		if(Content2!=None && FRand()<0.3) tempClass = Content2;
		if(Content3!=None && FRand()<0.3) tempClass = Content3;
		dropped = Spawn(tempClass);

		if( dropped!=none && !dropped.bdeleteme )
		{
			if( dropped.Physics!=PHYS_Falling && dropped.Physics!=PHYS_RigidBody )
				dropped.SetPhysics(PHYS_Falling);
			if ( inventory(dropped) != None )
			{
				dropped.RemoteRole = ROLE_DumbProxy;
				dropped.bCollideWorld = true;
				dropped.GotoState('Pickup', 'Dropped');
			}
		}
	}

	TriggerEvent(Event,Self,None);
	Super.Destroyed();
}

simulated function skinnedFrag(class<fragment> FragType, texture FragSkin, vector Momentum, float DSize, int NumFrags)
{
	local int i;
	local Fragment s;

	if( bStatic )
		return;
	if( bOnlyTriggerable )
		return;
	TriggerEvent(Event,Self,Instigator);
	if ( Region.Zone.bDestructive )
	{
		Destroy();
		return;
	}
	for (i=0 ; i<NumFrags ; i++)
	{
		s = Spawn( FragType );
		If (s!=none && !s.bdeleteme)
		{
			s.CalcVelocity(Momentum/100,0);
			s.Skin = FragSkin;
			s.DrawScale = DSize*0.5+0.7*DSize*FRand();
		}
	}

	Destroy();
}

simulated function Frag(class<fragment> FragType, vector Momentum, float DSize, int NumFrags)
{
	local int i;
	local Fragment s;

	if (bStatic)
		return;
	if ( bOnlyTriggerable )
		return;
	TriggerEvent(Event,Self,Instigator);
	if ( Region.Zone.bDestructive )
	{
		Destroy();
		return;
	}
	for (i=0 ; i<NumFrags ; i++)
	{
		s = Spawn( FragType );
		If (s!=none && !s.bdeleteme)
		{
			s.CalcVelocity(Momentum,0);
			s.DrawScale = DSize*0.5+0.7*DSize*FRand();
		}
	}

	Destroy();
}

function Timer()
{
	if( default.AmbientSound )
	{
		AmbientSound = default.AmbientSound;
		SoundRadius = default.SoundRadius;
		SoundVolume = default.SoundVolume;
		SoundPitch = default.SoundPitch;
	}
	else AmbientSound = none;
	PlaySound(EndPushSound, SLOT_Misc,0.25);
}

function Bump( actor Other )
{
	local float speed, oldZ;
	local vector othervel;

	if (bStatic || bDeleteme)
		return;

	if ( bPushable && Other.bIsPawn && (Other.Mass > 40) )
	{
		othervel=Other.Velocity;
		if (othervel== Vect(0,0,0))
			othervel=normal(location-Other.location);
		bBobbing = false;
		oldZ = Velocity.Z;
		speed = VSize(othervel);
		Velocity = othervel * FMin(120.0, 20 + speed)/FMax(speed,1);
		if ( Physics == PHYS_None )
		{
			Velocity.Z = 25;
			if( PushSound )
			{
				AmbientSound=PushSound;
				SoundRadius=32;
				SoundVolume=128;
				SoundPitch=64;
			}
		}
		else
			Velocity.Z = oldZ;
		SetPhysics(PHYS_Falling);
		SetTimer(0.3,False);
		Instigator = Pawn(Other);
	}
}

function EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	bCollideWorld = false;
	SetLocation(HitLocation+HitNormal*CollisionHeight, rotator(HitNormal)-rotang(90,0,0));
	bCollideWorld = Default.bCollideWorld;
}

function GrabbedBy( Pawn Other )
{
	if( Other.CarriedDecoration==Self )
	{
		bWasCarried = true;
		SetBase(None);
		SetPhysics(PHYS_Falling);
		Velocity = Other.Velocity + 10 * VRand();
		Instigator = Other;
		Other.CarriedDecoration = None;
		if (!SetLocation(Location))
			SetLocation(Other.Location);
	}
	else if( (!Other.Weapon || Other.Weapon.Mass<20) && bPushable && Mass<=40 && !HasStackedObjects() && SetLocation(Other.GrabbedDecorationPos(self)) )
	{
		Other.CarriedDecoration = Self;
		SetPhysics(PHYS_None);
		SetBase(Other);
	}
}

simulated function ClientSyncPosition( PlayerPawn Other, vector MoveDelta )
{
	SetLocation(Location + MoveDelta);
	SetPhysics(PHYS_None);
	SetBase(self);
}

// Check if prop is still infront of player.
function bool IsStillCarrying( Pawn Other )
{
	local rotator carried;

	if( Base!=Other )
		return false;
	carried = Rotator(Location - Other.Location);
	carried.Yaw = (carried.Yaw - Other.Rotation.Yaw) & 65535;
	return ((carried.Yaw < 3072) || (carried.Yaw > 62463));
}

// Return true to prevent firing weapon.
function bool CarrierFired( Pawn Other, bool bAlt )
{
	Other.DropDecoration();
	return true;
}

// Get total weight of objects stacked ontop of this one.
final function float GetStandingWeight()
{
	local float M;
	local Pawn P;
	
	foreach BasedActors(class'Pawn',P)
		M+=P.Mass;
	return M;
}

// Check if this decoration has other objects stacked ontop of this or if they are emitters/details attached to it.
final function bool HasStackedObjects()
{
	local Actor A;
	
	if( StandingCount )
	{
		foreach BasedActors(class'Actor',A)
			if( !A.bHardAttach && A.bCollideActors && (A.bBlockActors || A.bBlockPlayers || A.bProjTarget) )
				return true;
	}
	return false;
}

defaultproperties
{
	bStatic=True
	bStasis=True
	Texture=None
	Mass=0.000000
	CollisionFlag=COLLISIONFLAG_Decoration
	bNetInitExactLocation=true
}