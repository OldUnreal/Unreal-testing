//=============================================================================
// razorjack
//=============================================================================
class RazorJack extends Weapon;

#exec MESH IMPORT MESH=Razor ANIVFILE=Models\razor_a.3d DATAFILE=Models\razor_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Razor X=0 Y=0 Z=0 YAW=-64 ROLL=-8
#exec MESH SEQUENCE MESH=razor SEQ=All     STARTFRAME=0   NUMFRAMES=100
#exec MESH SEQUENCE MESH=razor SEQ=Select  STARTFRAME=0   NUMFRAMES=30  RATE=24 GROUP=Select
#exec MESH SEQUENCE MESH=razor SEQ=Fire    STARTFRAME=30  NUMFRAMES=10
#exec MESH SEQUENCE MESH=razor SEQ=Load    STARTFRAME=36  NUMFRAMES=4
#exec MESH SEQUENCE MESH=razor SEQ=Idle    STARTFRAME=40  NUMFRAMES=31
#exec MESH SEQUENCE MESH=razor SEQ=AltFire1 STARTFRAME=71  NUMFRAMES=12 RATE=24
#exec MESH SEQUENCE MESH=razor SEQ=AltFire2 STARTFRAME=83  NUMFRAMES=5 RATE=24
#exec MESH SEQUENCE MESH=razor SEQ=AltFire3 STARTFRAME=88  NUMFRAMES=4 RATE=24
#exec MESH SEQUENCE MESH=razor SEQ=Down    STARTFRAME=92  NUMFRAMES=8

#exec TEXTURE IMPORT NAME=JRazor1 FILE=Models\razor.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=razor X=0.005 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=razor NUM=1 TEXTURE=Jrazor1

#exec MESH IMPORT MESH=RazPick ANIVFILE=Models\rapick_a.3d DATAFILE=Models\rapick_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RazPick X=0 Y=0 Z=0 YAW=-64 ROLL=-8
#exec MESH SEQUENCE MESH=RazPick SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=RazPick SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JRazor1 FILE=Models\razor.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=RazPick X=0.025 Y=0.025 Z=0.05
#exec MESHMAP SETTEXTURE MESHMAP=RazPick NUM=1 TEXTURE=Jrazor1

#exec MESH IMPORT MESH=Razor3rd ANIVFILE=Models\Razor3_a.3d DATAFILE=Models\Razor3_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Razor3rd X=0 Y=-180 Z=-95 YAW=-64 ROLL=6
#exec MESH SEQUENCE MESH=Razor3rd SEQ=All  STARTFRAME=0  NUMFRAMES=20
#exec MESH SEQUENCE MESH=Razor3rd SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Razor3rd SEQ=Fire  STARTFRAME=1  NUMFRAMES=9
#exec MESH SEQUENCE MESH=Razor3rd SEQ=AltFire2  STARTFRAME=1  NUMFRAMES=9
#exec MESH SEQUENCE MESH=Razor3rd SEQ=Idle  STARTFRAME=10  NUMFRAMES=10
#exec TEXTURE IMPORT NAME=Jrazor1 FILE=Models\razor.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=Razor3rd X=0.035 Y=0.035 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=Razor3rd NUM=1 TEXTURE=JRazor1

#exec AUDIO IMPORT FILE="Sounds\Razor\beam.wav" NAME="beam" GROUP="RazorJack"

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Vector Start, X,Y,Z;

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(500, 0, 650));
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z;
	AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
	return Spawn(ProjClass,,, Start,AdjustedAim);
}

function PlayFiring()
{
	PlayAnim( 'Fire', 0.7,0.05 );
}

function PlayAltFiring()
{
	PlayAnim('AltFire1', 0.9,0.05);
}

function AltFire( float Value )
{
	if (AmmoType.UseAmmo(1))
	{
		if ( Owner.bHidden )
			CheckVisibility();
		bPointing=True;
		PlayAltFiring();
		GotoState('AltFiring');
	}
}

///////////////////////////////////////////////////////////
state AltFiring
{
	function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
	{
		local Vector Start, X,Y,Z;

		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
		AdjustedAim.Roll += 12768;
		Return Spawn(ProjClass,,, Start,AdjustedAim);
	}
	function bool ForcePutDown()
	{
		GoToState('DownWeapon');
		Global.ForcePutDown();
		return true;
	}

Begin:
	FinishAnim();
Repeater:
	if ( !bRapidFire && (FiringSpeed > 0) )
		Pawn(Owner).PlayRecoil(FiringSpeed*1.2);
	ProjectileFire(AltProjectileClass,AltProjectileSpeed,bAltWarnTarget);
	PlayAnim('AltFire2', 0.4,0.05);
	FinishAnim();
	if ( PlayerPawn(Owner) == None )
	{
		if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		{
			Pawn(Owner).StopFiring();
			Pawn(Owner).SwitchToBestWeapon();
		}
		else if ( (Pawn(Owner).bAltFire == 0) || (FRand() > AltRefireRate) )
		{
			Pawn(Owner).StopFiring();
			GotoState('Idle');
		}
	}
	if ( (Pawn(Owner).bAltFire!=0) && (Pawn(Owner).Weapon==Self) && AmmoType.UseAmmo(1))
	{
		goto 'Repeater';
	}
	PlayAnim('AltFire3', 0.9,0.05);
	FinishAnim();
	PlayAnim('Load',0.2,0.05);
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( Pawn(Owner).bFire!=0 && Pawn(Owner).Weapon==Self && (AmmoType==None || AmmoType.AmmoAmount>0) )
		Global.Fire(0);
	else
		GotoState('Idle');
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	LoopAnim('Idle', 0.4);
}

defaultproperties
{
	itemname="Razorjack"
	ProjectileClass=class'UnrealI.RazorBlade'
			AltProjectileClass=class'UnrealI.RazorBladeAlt'
				AmmoName=Class'UnrealI.RazorAmmo'
				PickupAmmoCount=15
				FireOffset=(X=16.000000,Y=0.000000,Z=-15.000000)
				shakemag=120.000000
				AIRating=0.500000
				RefireRate=0.830000
				AltRefireRate=0.830000
				SelectSound=Sound'UnrealI.Razorjack.beam'
				AutoSwitchPriority=7
				InventoryGroup=7
				PickupMessage="You got the RazorJack"
				PlayerViewOffset=(X=2.000000,Z=-0.900000)
				PlayerViewMesh=Mesh'UnrealI.Razor'
				BobDamping=0.970000
				PickupViewMesh=Mesh'UnrealI.RazPick'
				ThirdPersonMesh=Mesh'UnrealI.Razor3rd'
				PickupSound=Sound'UnrealI.Pickups.WeaponPickup'
				Mesh=Mesh'UnrealI.RazPick'
			bNoSmooth=False
		bMeshCurvy=False
	CollisionRadius=28.000000
	CollisionHeight=7.000000
	Mass=17.000000
	DeathMessage="%k took a bloody chunk out of %o with the %w."
	MyDamageType="shredded"
	AltDamageType="decapitated"
	FiringSpeed=1.8
}
