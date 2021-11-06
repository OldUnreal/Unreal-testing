//=============================================================================
// Stinger.
//=============================================================================
class Stinger extends Weapon;

#exec MESH IMPORT MESH=StingerM ANIVFILE=Models\aniv51.3d DATAFILE=Models\data51.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=StingerM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=StingerM SEQ=All  STARTFRAME=0  NUMFRAMES=44
#exec MESH SEQUENCE MESH=StingerM SEQ=Select  STARTFRAME=0  NUMFRAMES=21 GROUP=Select
#exec MESH SEQUENCE MESH=StingerM SEQ=Still STARTFRAME=21  NUMFRAMES=1
#exec MESH SEQUENCE MESH=StingerM SEQ=Down  STARTFRAME=22  NUMFRAMES=11
#exec MESH SEQUENCE MESH=StingerM SEQ=FireOne STARTFRAME=33  NUMFRAMES=3
#exec MESH SEQUENCE MESH=StingerM SEQ=FireThree STARTFRAME=36  NUMFRAMES=7

#exec TEXTURE IMPORT NAME=SpikHand1 FILE=Models\Spikegun.pcx GROUP="Skins"
#exec OBJ LOAD FILE=Textures\FireEffect18.utx PACKAGE=UnrealShare.Effect18
#exec MESHMAP SCALE MESHMAP=StingerM X=0.005 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=StingerM NUM=1 TEXTURE=SpikHand1
#exec MESHMAP SETTEXTURE MESHMAP=StingerM NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

#exec MESH IMPORT MESH=StingerPickup ANIVFILE=Models\aniv55.3d DATAFILE=Models\data55.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=StingerPickup X=100 Y=-100 Z=0 YAW=0 PITCH=0
#exec MESH SEQUENCE MESH=StingerPickup SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=StingerPickup SEQ=Still STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Sting1 FILE=Models\spikegun.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=StingerPickup X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=StingerPickup NUM=1 TEXTURE=Sting1

#exec MESH IMPORT MESH=Stinger3rd ANIVFILE=Models\Sting3_a.3d DATAFILE=Models\Sting3_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Stinger3rd X=0 Y=320 Z=-50 YAW=-64 ROLL=119 PITCH=128
#exec MESH SEQUENCE MESH=Stinger3rd SEQ=All  STARTFRAME=0  NUMFRAMES=6
#exec MESH SEQUENCE MESH=Stinger3rd SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Stinger3rd SEQ=FireOne  STARTFRAME=1  NUMFRAMES=5
#exec TEXTURE IMPORT NAME=JSting2 FILE=Models\sting3.pcx GROUP="Skins"
#exec OBJ LOAD FILE=Textures\FireEffect18.utx PACKAGE=UnrealShare.Effect18
#exec MESHMAP SCALE MESHMAP=Stinger3rd X=0.035 Y=0.035 Z=0.07
#exec MESHMAP SETTEXTURE MESHMAP=Stinger3rd NUM=1 TEXTURE=JSting2
#exec MESHMAP SETTEXTURE MESHMAP=Stinger3rd NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

#exec AUDIO IMPORT FILE="Sounds\Stinger\sshot10d.wav" NAME="StingerFire" GROUP="Stinger"
#exec AUDIO IMPORT FILE="Sounds\Stinger\sshot20d.wav" NAME="StingerTwoFire" GROUP="Stinger"
#exec AUDIO IMPORT FILE="Sounds\Stinger\saltf1.wav" NAME="StingerAltFire" GROUP="Stinger"
#exec AUDIO IMPORT FILE="Sounds\Stinger\load1.wav" NAME="StingerLoad" GROUP="Stinger"
#exec AUDIO IMPORT FILE="Sounds\Stinger\Ends1.wav" NAME="EndFire" GROUP="Stinger"

var bool bAlreadyFiring;

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;
	if ( Pawn(Owner).Enemy == None )
	{
		bUseAltMode = 0;
		return AIRating;
	}

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	bUseAltMode = int( 600 * FRand() > EnemyDist - 140 );
	return AIRating;
}

function PlayFiring()
{
	if ( bAlreadyFiring )
	{
		AmbientSound = sound'StingerTwoFire';
		SoundVolume = Pawn(Owner).SoundDampening*255;
		LoopAnim( 'FireOne', 0.7);
	}
	else
	{
		Owner.PlaySound(FireSound, SLOT_Misc,2.0*Pawn(Owner).SoundDampening);
		PlayAnim( 'FireOne', 0.7 );
	}
	bAlreadyFiring = true;
	bWarnTarget = (FRand() < 0.2);
}

function PlayAltFiring()
{
	Owner.PlaySound(AltFireSound, SLOT_Misc,2.0*Pawn(Owner).SoundDampening);
	PlayAnim( 'FireOne', 0.6 );
}

///////////////////////////////////////////////////////
state NormalFire
{

	function Tick( float DeltaTime )
	{
		if (Owner==None) AmbientSound=None;
		else
			SetLocation(Owner.Location);
	}

	function EndState()
	{
		if (AmbientSound!=None && Owner!=None) Owner.PlaySound(Misc1Sound, SLOT_Misc,2.0*Pawn(Owner).SoundDampening);
		AmbientSound = None;
		bAlreadyFiring = false;
		Super.EndState();
	}

Begin:
	Sleep(0.2);
	SetLocation(Owner.Location);
	Finish();
}

///////////////////////////////////////////////////////////////
state AltFiring
{
	function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
	{
		local Projectile S;
		local int i;
		local vector Start,X,Y,Z;
		local Rotator StartRot, AltRotation;

		S = Global.ProjectileFire(ProjClass, ProjSpeed, bWarn);
		StartRot = S.Rotation;
		Start = S.Location;
		GetAxes(StartRot,X,Y,Z);
		for (i = 0; i< 4; i++)
		{
			if (AmmoType.UseAmmo(1))
			{
				if( Level.Game.bUseClassicBalance )
				{
					AltRotation = StartRot;
					AltRotation.Pitch += RandIntRange(-1500,1500);
					AltRotation.Yaw += RandIntRange(-1500,1500);
					AltRotation.Roll += RandIntRange(-4500,4500);	
				}
				else AltRotation = rotator(X+Y*RandRange(-0.13,0.13)+Z*RandRange(-0.13,0.13));
				S = Spawn(AltProjectileClass,,, Start - 2.f * VRand(), AltRotation);
			}
		}
		if ( StingerProjectile(S) )
			StingerProjectile(S).bLighting = True;
		Return S;
	}

Begin:
	FinishAnim();
	PlayAnim('Still');
	Sleep(1.0);
	Finish();
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	PlayAnim('Still');
}

defaultproperties
{
	itemname="Stinger"
	ProjectileClass=class'UnrealShare.StingerProjectile'
	AltProjectileClass=class'UnrealShare.StingerProjectile'
	AmmoName=Class'UnrealShare.StingerAmmo'
	PickupAmmoCount=40
	bAltWarnTarget=True
	FireOffset=(X=12.000000,Y=-10.000000,Z=-15.000000)
	shakemag=120.000000
	AIRating=0.400000
	RefireRate=0.800000
	FireSound=Sound'UnrealShare.Stinger.StingerFire'
	AltFireSound=Sound'UnrealShare.Stinger.StingerAltFire'
	SelectSound=Sound'UnrealShare.Stinger.StingerLoad'
	Misc1Sound=Sound'UnrealShare.Stinger.EndFire'
	AutoSwitchPriority=3
	InventoryGroup=3
	PickupMessage="You picked up the Stinger"
	PlayerViewOffset=(X=4.200000,Y=-3.000000,Z=-4.000000)
	PlayerViewMesh=Mesh'UnrealShare.StingerM'
	PlayerViewScale=1.700000
	PickupViewMesh=Mesh'UnrealShare.StingerPickup'
	ThirdPersonMesh=Mesh'UnrealShare.Stinger3rd'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Mesh=Mesh'UnrealShare.StingerPickup'
	bNoSmooth=False
	bMeshCurvy=False
	SoundRadius=64
	SoundVolume=255
	CollisionRadius=27.000000
	CollisionHeight=8.000000
	DeathMessage="%o was perforated by %k's %w."
	MyDamageType="Shot"
	FiringSpeed=3.5
}
