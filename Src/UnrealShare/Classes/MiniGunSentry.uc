//=============================================================================
// MiniGunSentry.
//=============================================================================
Class MiniGunSentry extends Pickup;

#exec TEXTURE IMPORT NAME=I_Sentry FILE=Textures\I_Sentry.pcx GROUP="Icons"
#exec TEXTURE IMPORT NAME=Sentry1 FILE=Models\Sentrytex.pcx GROUP="Skins"

#exec MESH IMPORT MESH=SentryM ANIVFILE=Models\sentry_a.3D DATAFILE=Models\sentry_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SentryM X=-90 Y=90 Z=-80 YAW=64
#exec MESH SEQUENCE MESH=SentryM SEQ=All    STARTFRAME=0  NUMFRAMES=46
#exec MESH SEQUENCE MESH=SentryM SEQ=Up     STARTFRAME=0  NUMFRAMES=5
#exec MESH SEQUENCE MESH=SentryM SEQ=Still  STARTFRAME=5  NUMFRAMES=1
#exec MESH SEQUENCE MESH=SentryM SEQ=WarmUp STARTFRAME=6  NUMFRAMES=14
#exec MESH SEQUENCE MESH=SentryM SEQ=Fire   STARTFRAME=20 NUMFRAMES=4
#exec MESH SEQUENCE MESH=SentryM SEQ=Down   STARTFRAME=24  NUMFRAMES=21
#exec OBJ LOAD FILE=Textures\fireeffect8.utx  PACKAGE=UnrealShare.Effect8
#exec MESHMAP SCALE MESHMAP=SentryM X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=SentryM NUM=1 TEXTURE=Sentry1
#exec MESHMAP SETTEXTURE MESHMAP=SentryM NUM=0 TEXTURE=FireEffect8

#exec MESH NOTIFY MESH=SentryM SEQ=Fire TIME=0.3 FUNCTION=GenerateBullet
#exec MESH NOTIFY MESH=SentryM SEQ=Fire TIME=0.8 FUNCTION=GenerateBullet

#exec AUDIO IMPORT FILE="Sounds\sentrywind.WAV" NAME="SentryWind" GROUP="Sentry"
#exec AUDIO IMPORT FILE="Sounds\sentryunwind.WAV" NAME="SentryUnWind" GROUP="Sentry"
#exec AUDIO IMPORT FILE="Sounds\sentryfire.WAV" NAME="SentryFire" GROUP="Sentry"

var Pawn TargetPawn;
var vector ForwardDir;

function Pawn FindNewTarget()
{
	local Pawn P;
	local vector Dummy;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if ( P.bCollideActors && P.Health>0 && VSize(P.Location-Location)<6000 && IsEnemyWith(P) && (Normal(P.Location-Location) dot ForwardDir)>0.95
		 && FastTrace(P.Location,Location) )
			return P;
	}
	P = Pawn(Trace(Dummy,Dummy,ForwardDir*200+Location,Location,true));
	if ( P!=None && P.Health>0 && IsEnemyWith(P) )
		return P;
	return None;
}
final function bool IsEnemyWith( Pawn Other )
{
	if ( Instigator==None )
		return true;
	return !(Instigator==Other || (Level.Game.bTeamGame && Other.GetTeamNum()==Instigator.GetTeamNum())
			 || (!Level.Game.bDeathMatch && Other.bIsPlayer && Instigator.bIsPlayer));
}
function bool TargetIsValid( Pawn Other )
{
	return (Other.Health>0 && !Other.bDeleteMe && VSize(Other.Location-Location)<7000
			&& (Normal(Other.Location-Location) dot ForwardDir)>0.85 && FastTrace(Other.Location,Location));
}

state Activated  // Delete from inventory and toss in front of player.
{
	function Timer()
	{
		BecomePickup();
	}
	function HitWall (vector HitNormal, actor Wall)
	{
		local rotator R;

		Velocity = 0.56*MirrorVectorByNormal(Velocity,HitNormal); // Reflect off Wall w/damping
		If (VSize(Velocity) < 20)
		{
			R.Yaw = Rotation.Yaw;
			SetRotation(R);
			bBounce = False;
			SetPhysics(PHYS_None);
			GoToState('Monitor');
		}
	}
	function AdjustPosition()
	{
		local vector X,Y,Z;

		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		bCollideWorld = true;
		SetCollision(False,False,False);
		SetPhysics(PHYS_Falling);
		SetRotation(Owner.Rotation);
		Velocity = Owner.Velocity + Vector(Owner.Rotation) * 90.0 + Owner.Velocity*0.4;
		Velocity.z += 100;
		SetTimer(0.3,false);
		SetLocation(Owner.Location+Y*10-Z*20+X*15);
		RotationRate = rot(0,0,0);
	}
Begin:
	AdjustPosition();
	Instigator = Pawn(Owner);
	Pawn(Owner).DeleteInventory(Self);
	bBounce = True;
}

////////////////////////////////////////////////////////////////////
//
// Monitor path in front of Sentry.  If pawn is found, start firing
//
state Monitor
{
	function Timer()
	{
		TargetPawn = FindNewTarget();
		if ( TargetPawn!=None )
			GoToState('Firing');
	}
Begin:
	ForwardDir = vector(Rotation);
	SetOwner(None);
	PlayAnim('Up',0.2);
	FinishAnim();
	SetTimer(0.35,True);
	goto'Timing';
Begin2:
	PlaySound(Sound'SentryUnWind');
	TweenAnim('Still',0.4);
	Sleep(0.4);
	SetTimer(0.25,True);
Timing:
	while ( true )
	{
		Sleep(1.5);
		if ( --Charge<=0 ) // Handle time-charge.
			GoToState('Depleted','NoSound');
	}
}

Function GenerateBullet()
{
	local vector Dir,HitLocation,HitNorm;
	local Actor Other;

	Charge--;
	if (Charge <= 0) GoToState('Depleted');

	PlaySound(Sound'SentryFire',SLOT_Misc);
	if ( Instigator!=None )
		MakeNoise(1.0);
	if ( TargetPawn!=None )
	{
		Dir = Normal(TargetPawn.Location-Location);
		if ( VSize(Dir-ForwardDir)>0.3 )
			Dir = Normal(ForwardDir+Dir*0.7);
	}
	else Dir = ForwardDir;
	Dir = Normal(Dir+VRand()*0.04);
	Other = Trace(HitLocation, HitNorm, Location + 10000 * Dir,Location,True);

	if ( Other==Level )  // Hit a wall
		spawn(class'WallHitEffect',,,HitLocation+HitNorm*5,rotator(HitNorm));
	else if ( Other!=None )
	{
		if ( !Other.bIsPawn && Carcass(Other)==None )
			spawn(class'WallHitEffect',,,HitLocation+HitNorm*5,rotator(HitNorm));
		Other.TakeDamage(6+Rand(5), Instigator, HitLocation, 13000.0*Dir, 'shot');
	}
}

//
// Fire until ammo used up or nothing is in front of sentry
//
state Firing
{
	function Timer()
	{
		if ( TargetPawn==None || !TargetIsValid(TargetPawn) )
			GoToState('Monitor','Begin2');
	}
	function EndState()
	{
		LightType = LT_None;
	}
Begin:
	SetTimer(0.8,True);
	PlaySound(Sound'SentryWind');
	PlayAnim('WarmUp',1.5);
	FinishAnim();
	LightType = LT_Strobe;
	LoopAnim('Fire',0.7,0.0);
}

//
// Ammo Gone, shut down and destroy.
//
state Depleted
{
Ignores Timer;

Begin:
	PlaySound(Sound'SentryUnWind');
NoSound:
	PlayAnim('Down',0.2);
	FinishAnim();
	Spawn(class'BallExplosion');
	Sleep(0.2);
	Destroy();
}

// AI:
function PickupFunction(Pawn Other)
{
	if ( PlayerPawn(Other)==None )
		SetTimer(1+4*FRand(),false);
}
function Timer()
{
	if ( FastTrace(Owner.Location+vector(Owner.Rotation)*800,Owner.Location) )
		Activate(); // Make sure theres open space ahead before throwing it.
	else SetTimer(1+FRand(),false);
}

defaultproperties
{
	Mesh=Mesh'SentryM'
	bNoSmooth=false
	PickupViewMesh=Mesh'SentryM'
	PickupMessage="You got an Automatic Sentry Gun"
	bDisplayableInv=true
	bActivatable=true
	ItemName="Minigun Sentry"
	Charge=200
	Icon=Texture'I_Sentry'
	CollisionHeight=23
	PickupSound=Sound'GenPickSnd'
	MaxDesireability=2.2
	bCanActivate=true
	RespawnTime=65
	M_Activated=" deployed."
	TransientSoundVolume=1.5
	LightBrightness=200
	LightSaturation=64
	LightHue=36
	LightRadius=7
}
