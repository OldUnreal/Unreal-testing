//=============================================================================
// Rifle.
//=============================================================================
class Rifle extends Weapon;

#exec MESH IMPORT MESH=RifleM ANIVFILE=Models\Rifle_a.3d DATAFILE=Models\Rifle_d.3d X=0 Y=0 Z=0 unmirror=1
#exec MESH ORIGIN MESH=RifleM X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=RifleM SEQ=All         STARTFRAME=0   NUMFRAMES=101
#exec MESH SEQUENCE MESH=RifleM SEQ=Select      STARTFRAME=0   NUMFRAMES=20 RATE=27 GROUP=Select
#exec MESH SEQUENCE MESH=RifleM SEQ=Still       STARTFRAME=20  NUMFRAMES=1
#exec MESH SEQUENCE MESH=RifleM SEQ=Fire        STARTFRAME=21  NUMFRAMES=10 RATE=24
#exec MESH SEQUENCE MESH=RifleM SEQ=ScopeFire   STARTFRAME=31  NUMFRAMES=10
#exec MESH SEQUENCE MESH=RifleM SEQ=ScopeUp     STARTFRAME=41  NUMFRAMES=14
#exec MESH SEQUENCE MESH=RifleM SEQ=StillScope  STARTFRAME=55  NUMFRAMES=1
#exec MESH SEQUENCE MESH=RifleM SEQ=DownWScope  STARTFRAME=56  NUMFRAMES=15
#exec MESH SEQUENCE MESH=RifleM SEQ=Down        STARTFRAME=71  NUMFRAMES=15
#exec MESH SEQUENCE MESH=RifleM SEQ=ScopeDown   STARTFRAME=86  NUMFRAMES=15
#exec TEXTURE IMPORT NAME=JRifle1 FILE=Models\Rifle.pcx GROUP=Skins
#exec OBJ LOAD FILE=..\UnrealShare\Textures\FireEffect18.utx PACKAGE=UnrealShare.Effect18
#exec MESHMAP SCALE MESHMAP=RifleM X=0.005 Y=0.004 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=RifleM NUM=1 TEXTURE=JRifle1
#exec MESHMAP SETTEXTURE MESHMAP=RifleM NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

#exec MESH IMPORT MESH=RiPick ANIVFILE=Models\RiPick_a.3d DATAFILE=Models\RiPick_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=RiPick X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=RiPick SEQ=All         STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=RiPick SEQ=Still       STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JRifle1 FILE=Models\Rifle.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=RiPick X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=RiPick NUM=1 TEXTURE=JRifle1

#exec MESH IMPORT MESH=Rifle3rd ANIVFILE=Models\Rifle3_a.3d DATAFILE=Models\Rifle3_d.3d X=0 Y=0 Z=0 unmirror=1
#exec MESH ORIGIN MESH=Rifle3rd X=0 Y=-550 Z=-45 YAW=-64 ROLL=9
#exec MESH SEQUENCE MESH=Rifle3rd SEQ=All  STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=Rifle3rd SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Rifle3rd SEQ=Fire  STARTFRAME=1  NUMFRAMES=9
#exec MESHMAP SCALE MESHMAP=Rifle3rd X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=Rifle3rd NUM=1 TEXTURE=JRifle1
#exec MESHMAP SETTEXTURE MESHMAP=Rifle3rd NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

#exec AUDIO IMPORT FILE="Sounds\Rifle\RPICKUP1.wav" NAME="RiflePickup" GROUP="Rifle"
#exec AUDIO IMPORT FILE="Sounds\Rifle\RSHOT9.wav" NAME="RifleShot" GROUP="Rifle"

var int NumFire;

function float RateSelf( out int bUseAltMode )
{
	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	bUseAltMode = 0;
	return AIRating;

}

function AltFire( float Value )
{
	GoToState('AltFiring');
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Fire(float F)
	{
	}

	function AltFire(float F)
	{
	}

Begin:
	FinishAnim();
	Finish();
}

function Timer()
{
	local actor targ;
	local float bestAim, bestDist;
	local vector FireDir;

	bestAim = 0.95;
	if ( Pawn(Owner) == None )
	{
		GotoState('');
		return;
	}
	FireDir = vector(Pawn(Owner).ViewRotation);
	targ = Pawn(Owner).PickTarget(bestAim, bestDist, FireDir, Owner.Location);
	if ( Pawn(targ) != None )
	{
		SetTimer(1 + 4 * FRand(), false);
		bPointing = true;
		Pawn(targ).WarnTarget(Pawn(Owner), 200, FireDir);
	}
	else
	{
		SetTimer(0.4 + 1.6 * FRand(), false);
		bPointing = false;
	}
}

function PlayAltFiring()
{
	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).shakeview(ShakeTime, ShakeMag, ShakeVert);
	Owner.PlaySound(FireSound, SLOT_None,Pawn(Owner).SoundDampening*3.0,,,0.9 + 0.2 * FRand());
	PlayAnim('Fire', 2.0,0.05);
}

function PlayFiring()
{
	Owner.PlaySound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	PlayAnim('Fire', 0.7,0.05);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local shellcase s;
	local vector StartT;
	local byte HitCount;
	local ZoneInfo HitZone;
	local Actor A;

	if ( PlayerPawn(Owner)!=None )
		PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));

	s = Spawn(class'ShellCase',Pawn(Owner), '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
	if ( s != None )
	{
		s.DrawScale = 2.0;
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	}
	A = Self;

	/* Check if were passing through zoneportals */
	if ( Other!=None )
	{
		HitZone = Level.GetLocZone(HitLocation+HitNormal).Zone;
		while ( WarpZoneInfo(HitZone)!=None && WarpZoneInfo(HitZone).OtherSideActor!=None && HitCount++<5 )
		{
			StartT = HitLocation;
			WarpZoneInfo(HitZone).WarpBothCoords(StartT,X);
			A = WarpZoneInfo(HitZone).OtherSideActor;
			Z = StartT+X*10000;
			Other = A.Trace(HitLocation,HitNormal,Z,StartT,True); // We dont use owner pawn trace here because we could hit ourselves.
			while ( Other && Other.bIsPawn && !Pawn(Other).AdjustHitLocation(HitLocation, Z - StartT) )
			{
				StartT = HitLocation;
				Other = Other.Trace(HitLocation,HitNormal,Z,StartT,True);
			}
			if ( !Other )
				Break;
			HitZone = A.Level.GetLocZone(HitLocation+HitNormal).Zone;
		}
	}

	if ( Other && (Other == A.Level || Other.bWorldGeometry))
		A.Spawn(class'HeavyWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
	else if ( Other && Other!=Self )
	{
		if ( Other.bIsPawn && (instigator.IsA('PlayerPawn') || (instigator.skill > 1)) && Pawn(Other).IsHeadShot(HitLocation,X) )
			Other.TakeDamage(100, Pawn(Owner), HitLocation, 35000 * X, 'decapitated');
		else
			Other.TakeDamage(45,  Pawn(Owner), HitLocation, 30000.0*X, 'shot');
		if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
			A.Spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
		if ( Other.IsA('Brush') )
			A.Spawn(class'HeavyWallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
	}
}

function Finish()
{
	//bMuzzleFlash = 0;
	if ( ((Pawn(Owner).bFire!=0) || (Pawn(Owner).bAltFire!=0)) && (FRand() < 0.6) )
		Timer();
	Super.Finish();
}

state Idle
{

	function AltFire( float Value )
	{
		GoToState('AltFiring');
	}

	function Fire( float Value )
	{
		if (AmmoType.UseAmmo(1))
		{
			GotoState('NormalFire');
			if ( PlayerPawn(Owner) != None )
				PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
			bPointing=True;
			TraceFire(0.0);
			PlayFiring();
			CheckVisibility();
		}
	}


	function BeginState()
	{
		if (Pawn(Owner).bFire!=0) Fire(0.0);
		bPointing = false;
		SetTimer(0.4 + 1.6 * FRand(), false);
		Super.BeginState();
	}

	function EndState()
	{
		SetTimer(0.0, false);
		Super.EndState();
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	Disable('AnimEnd');
	PlayIdleAnim();
}

///////////////////////////////////////////////////////
state AltFiring
{
	function Timer()
	{
		if ( bChangeWeapon )
			GotoState('DownWeapon');
		else if (Pawn(Owner).bAltFire == 0)
		{
			if (PlayerPawn(Owner) != None)
				PlayerPawn(Owner).StopZoom();
			SetTimer(0.0,False);
			GoToState('Idle');
		}
	}

Begin:
	if ( Owner.IsA('PlayerPawn') )
	{
		PlayerPawn(Owner).ToggleZoom();
		SetTimer(0.075,True);
	}
	else
	{
		Pawn(Owner).bFire = 1;
		Pawn(Owner).bAltFire = 0;
		Global.Fire(0);
	}
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	PlayAnim('Still',1.0, 0.05);
}

State DownWeapon
{
	function BeginState()
	{
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(Owner).EndZoom();
		bChangeWeapon = false;
		bMuzzleFlash = 0;
	}
}

defaultproperties
{
	itemname="Sniper Rifle"
	AmmoName=Class'UnrealI.RifleAmmo'
	PickupAmmoCount=8
	bInstantHit=True
	bAltInstantHit=True
	FireOffset=(Y=-5.000000,Z=-2.000000)
	shakemag=400.000000
	shaketime=0.150000
	shakevert=8.000000
	AIRating=0.700000
	RefireRate=0.600000
	AltRefireRate=0.300000
	FireSound=Sound'UnrealI.Rifle.RifleShot'
	SelectSound=Sound'UnrealI.Rifle.RiflePickup'
	AutoSwitchPriority=9
	InventoryGroup=9
	PickupMessage="You got the Rifle"
	PlayerViewOffset=(X=3.200000,Y=-1.200000,Z=-1.700000)
	PlayerViewMesh=Mesh'UnrealI.RifleM'
	PickupViewMesh=Mesh'UnrealI.RiPick'
	ThirdPersonMesh=Mesh'UnrealI.Rifle3rd'
	PickupSound=Sound'UnrealI.Pickups.WeaponPickup'
	Mesh=Mesh'UnrealI.RiPick'
	bNoSmooth=False
	bMeshCurvy=False
	CollisionRadius=28.000000
	CollisionHeight=8.000000
	DeathMessage="%k put a bullet through %o's head."
	MyDamageType="Shot"
	AltDamageType="Decapitated"
	FiringSpeed=1
}
