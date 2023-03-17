//=============================================================================
// AutoMag.
//=============================================================================
class AutoMag extends Weapon;

// pickup version
#exec MESH IMPORT MESH=AutoMagPickup ANIVFILE=Models\pislow_a.3d DATAFILE=Models\pislow_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=AutoMagPickup X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=AutoMagPickup SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Automa1 FILE=Models\pistol.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=AutoMagPickup X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=AutoMagPickup NUM=1 TEXTURE=Automa1

// 3rd person perspective version
#exec MESH IMPORT MESH=auto3rd ANIVFILE=Models\pis3rd_a.3d DATAFILE=Models\pis3rd_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=auto3rd X=0 Y=-60 Z=-220 YAW=64 PITCH=0 ROLL=-72
#exec MESH SEQUENCE MESH=auto3rd SEQ=All  STARTFRAME=0  NUMFRAMES=5
#exec MESH SEQUENCE MESH=auto3rd SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=auto3rd SEQ=Shoot  STARTFRAME=1  NUMFRAMES=4 RATE=30.0
#exec MESH SEQUENCE MESH=auto3rd SEQ=Shot2b  STARTFRAME=1  NUMFRAMES=4 RATE=30.0
#exec MESH SEQUENCE MESH=auto3rd SEQ=Shot2a  STARTFRAME=1  NUMFRAMES=4 RATE=30.0
#exec TEXTURE IMPORT NAME=Automa1 FILE=Models\pistol.pcx GROUP="Skins"
#exec OBJ LOAD FILE=Textures\FireEffect18.utx PACKAGE=UnrealShare.Effect18
#exec MESHMAP SCALE MESHMAP=auto3rd X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=auto3rd NUM=1 TEXTURE=Automa1
#exec MESHMAP SETTEXTURE MESHMAP=auto3rd NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

//  player view version
#exec MESH IMPORT MESH=AutoMagL ANIVFILE=Models\pistol_a.3d DATAFILE=Models\pistol_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=AutoMagL X=0 Y=0 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=AutoMagL SEQ=All     STARTFRAME=0  NUMFRAMES=190
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Still   STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Shoot   STARTFRAME=0  NUMFRAMES=4
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Shoot0  STARTFRAME=6  NUMFRAMES=3
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Shoot1  STARTFRAME=7  NUMFRAMES=7
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Shoot2  STARTFRAME=15 NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Shot2a  STARTFRAME=20  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Shot2b  STARTFRAME=29  NUMFRAMES=3
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Shot2c  STARTFRAME=45  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Twiddle STARTFRAME=50  NUMFRAMES=25
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Sway1   STARTFRAME=50  NUMFRAMES=2
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Eject   STARTFRAME=75  NUMFRAMES=25
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Down    STARTFRAME=100  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Select  STARTFRAME=105  NUMFRAMES=30 RATE=40 GROUP=Select
#exec MESH SEQUENCE MESH=AutoMagL SEQ=T1      STARTFRAME=135  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagL SEQ=Twirl   STARTFRAME=140  NUMFRAMES=45
#exec MESH SEQUENCE MESH=AutoMagL SEQ=T2      STARTFRAME=185  NUMFRAMES=5
#exec TEXTURE IMPORT NAME=Automa1 FILE=Models\pistol.pcx GROUP="Skins"
#exec OBJ LOAD FILE=Textures\FireEffect18.utx PACKAGE=UnrealShare.Effect18
#exec MESHMAP SCALE MESHMAP=AutoMagL X=0.007 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=AutoMagL NUM=1 TEXTURE=Automa1
#exec MESHMAP SETTEXTURE MESHMAP=AutoMagL NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

// right handed player view version
#exec MESH IMPORT MESH=AutoMagR ANIVFILE=Models\pistol_a.3d DATAFILE=Models\pistol_d.3d unmirror=1
#exec MESH ORIGIN MESH=AutoMagR X=0 Y=0 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=AutoMagR SEQ=All     STARTFRAME=0  NUMFRAMES=190
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Still   STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Shoot   STARTFRAME=0  NUMFRAMES=4
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Shoot0  STARTFRAME=6  NUMFRAMES=3
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Shoot1  STARTFRAME=7  NUMFRAMES=7
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Shoot2  STARTFRAME=15 NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Shot2a  STARTFRAME=20  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Shot2b  STARTFRAME=29  NUMFRAMES=3
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Shot2c  STARTFRAME=45  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Twiddle STARTFRAME=50  NUMFRAMES=25
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Sway1   STARTFRAME=50  NUMFRAMES=2
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Eject   STARTFRAME=75  NUMFRAMES=25
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Down    STARTFRAME=100  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Select  STARTFRAME=105  NUMFRAMES=30 RATE=40 GROUP=Select
#exec MESH SEQUENCE MESH=AutoMagR SEQ=T1      STARTFRAME=135  NUMFRAMES=5
#exec MESH SEQUENCE MESH=AutoMagR SEQ=Twirl   STARTFRAME=140  NUMFRAMES=45
#exec MESH SEQUENCE MESH=AutoMagR SEQ=T2      STARTFRAME=185  NUMFRAMES=5
#exec MESHMAP SCALE MESHMAP=AutoMagR X=0.007 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=AutoMagR NUM=1 TEXTURE=Automa1
#exec MESHMAP SETTEXTURE MESHMAP=AutoMagR NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

#exec AUDIO IMPORT FILE="Sounds\Automag\Cocking.wav" NAME="Cocking" GROUP="AutoMag"
#exec AUDIO IMPORT FILE="Sounds\Automag\Shot.wav" NAME="shot" GROUP="AutoMag"
#exec AUDIO IMPORT FILE="Sounds\Flak\click.wav" NAME="click" GROUP="Flak"
#exec AUDIO IMPORT FILE="Sounds\Automag\Reload1.wav" NAME="Reload" GROUP="Automag"

var() int hitdamage;
var  float AltAccuracy;
var int ClipCount;

function AltFire( float Value )
{
	bPointing=True;
	AltAccuracy = 0.4;
	CheckVisibility();
	if (AmmoType.AmmoAmount>0)
	{
		PlayAnim('T1', 1.3, 0.05);
		GotoState('AltFiring');
	}
}

function PlayFiring()
{
	ClipCount++;
	Owner.PlaySound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
}

// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'AutoMagL';
	else
		Mesh = mesh'AutoMagR';
}

///////////////////////////////////////////////////////
state NormalFire
{
Begin:
	if (AnimSequence!='Shoot0')
	{
		PlayAnim('Shoot',2.5, 0.02);
		FinishAnim();
	}
	PlayAnim('Shoot0',0.26, 0.04);
	FinishAnim();
	if (ClipCount>15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( PlayerPawn(Owner) == None )
		Super.Finish();
	else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
		GotoState('Idle');
	else if (ClipCount>=20) GoToState('NewClip');
	else if ( Pawn(Owner).bFire!=0 ) Global.Fire(0);
	else if ( Pawn(Owner).bAltFire!=0 )Global.AltFire(0);
	PlayAnim('Shoot2',0.8, 0.0);
	FinishAnim();
	GoToState('Idle');
}


////////////////////////////////////////////////////////
state NewClip
{
	ignores Fire, AltFire;
Begin:
	PlayAnim('Eject',1.5,0.05);
	Owner.PlaySound(Misc2Sound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
	FinishAnim();
	PlayAnim('Down',1.2,0.05);
	FinishAnim();
	ClipCount = 0;
	Owner.PlaySound(SelectSound, SLOT_None,1.0*Pawn(Owner).SoundDampening);
	PlayAnim('Select',1.6,0.07);
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else if ( Pawn(Owner).bAltFire!=0 )
		Global.AltFire(0);
	else GotoState('Idle');
}

////////////////////////////////////////////////////////
state AltFiring
{
	ignores Fire, AltFire;

Begin:
	FinishAnim();
	PlayAnim('Shot2a', 1.2, 0.05);
	FinishAnim();
Repeater:
	if (AmmoType.UseAmmo(1))
	{
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ShakeView(ShakeTime, ShakeMag, ShakeVert);
		ClipCount++;
		if ( FiringSpeed>0 )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		TraceFire(AltAccuracy);
		PlayAltFiring();
		FinishAnim();
	}
	if ( AltAccuracy < 3 )
		AltAccuracy += 0.5;
	if (ClipCount>15) Owner.PlaySound(Misc1Sound, SLOT_None, 3.5*Pawn(Owner).SoundDampening);
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( Pawn(Owner).Weapon != Self )
		GotoState('Idle');
	else if ( /*bAltFireMem ||*/ (Pawn(Owner).bAltFire!=0)
								 && AmmoType.AmmoAmount>0 && ClipCount<20)
	{
		if ( PlayerPawn(Owner) == None )
			Pawn(Owner).bAltFire = int( FRand() < AltReFireRate );
		//bFireMem = false;
		//bAltFireMem = false;
		Goto('Repeater');
	}
	PlayAnim('Shot2c', 0.7, 0.05);
	FinishAnim();
	PlayAnim('T2', 0.9, 0.05);
	FinishAnim();
	Finish();
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local shellcase s;
	local vector realLoc;
	local ZoneInfo HitZone;
	local byte HitCount;
	local Actor A;

	realLoc = Owner.Location + CalcDrawOffset();
	s = Spawn(class'ShellCase',Pawn(Owner), '', realLoc + 20 * X + FireOffset.Y * Y + Z);
	if ( s != None )
		s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
	A = Self;

	/* Check if were passing through zoneportals */
	if ( Other!=None )
	{
		HitZone = Level.GetLocZone(HitLocation+HitNormal).Zone;
		while ( WarpZoneInfo(HitZone) && WarpZoneInfo(HitZone).OtherSideActor && HitCount++<5 )
		{
			realLoc = HitLocation;
			WarpZoneInfo(HitZone).WarpBothCoords(realLoc,X);
			A = WarpZoneInfo(HitZone).OtherSideActor;
			Z = realLoc+X*8000;
			Other = A.Trace(HitLocation,HitNormal,Z,realLoc,True); // We dont use owner pawn trace here because we could hit ourselves.
			while ( Other!=None && Other.bIsPawn && !Pawn(Other).AdjustHitLocation(HitLocation, Z - realLoc) )
			{
				realLoc = HitLocation;
				Other = Other.Trace(HitLocation,HitNormal,Z,realLoc,True);
			}
			if ( Other==None )
				Break;
			HitZone = A.Level.GetLocZone(HitLocation+HitNormal).Zone;
		}
	}

	if ( Other != None && (Other == A.Level || Other.bWorldGeometry))
		A.Spawn(class'WallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
	else if ( Other!=None && Other!=Self )
	{
		if ( FRand() < 0.2 )
			X *= 5;
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			A.spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
		Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, 'shot');
	}
	if ( Other!=None && Other.Brush!=None )
		A.Spawn(class'WallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
}

function PlayPostSelect()
{
	ClipCount = 0;
}

function Finish()
{
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( PlayerPawn(Owner) == None )
		Super.Finish();
	else if ( (AmmoType.AmmoAmount<=0) || (Pawn(Owner).Weapon != self) )
		GotoState('Idle');
	else if (ClipCount>=20) GoToState('NewClip');
	else if ( /*bFireMem ||*/ Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else if ( /*bAltFireMem ||*/ Pawn(Owner).bAltFire!=0 )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

function PlayAltFiring()
{
	Owner.PlaySound(FireSound, SLOT_None,2.0*Pawn(Owner).SoundDampening);
	PlayAnim('Shot2b', 0.4, 0.05);
}

state Idle
{
	function AnimEnd()
	{
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

	function Timer()
	{
		if (FRand()>0.8) PlayAnim('Twiddle',0.6,0.3);
		else if (AnimSequence == 'Twiddle') LoopAnim('Sway1',0.02, 0.3);
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	Disable('AnimEnd');
	LoopAnim('Sway1',0.02, 0.1);
	SetTimer(1.5,True);
	if ( /*bFireMem ||*/ Pawn(Owner).bFire!=0 ) Global.Fire(0.0);
	if ( /*bAltFireMem ||*/ Pawn(Owner).bAltFire!=0 ) Global.AltFire(0.0);
}

defaultproperties
{
	hitdamage=17
	AmmoName=Class'UnrealShare.ShellBox'
	itemname="Automag"
	PickupAmmoCount=20
	bInstantHit=True
	bAltInstantHit=True
	FireOffset=(Y=-10.000000,Z=-4.000000)
	shakemag=200.000000
	shakevert=4.000000
	AIRating=0.200000
	RefireRate=0.700000
	AltRefireRate=0.900000
	FireSound=Sound'UnrealShare.AutoMag.shot'
	AltFireSound=Sound'UnrealShare.AutoMag.shot'
	CockingSound=Sound'UnrealShare.AutoMag.Cocking'
	SelectSound=Sound'UnrealShare.AutoMag.Cocking'
	Misc1Sound=Sound'UnrealShare.flak.click'
	Misc2Sound=Sound'UnrealShare.AutoMag.Reload'
	AutoSwitchPriority=2
	InventoryGroup=2
	PickupMessage="You got the AutoMag"
	PlayerViewOffset=(X=4.800000,Y=-1.700000,Z=-2.700000)
	PlayerViewMesh=Mesh'UnrealShare.AutoMagL'
	PickupViewMesh=Mesh'UnrealShare.AutoMagPickup'
	ThirdPersonMesh=Mesh'UnrealShare.auto3rd'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Mesh=Mesh'UnrealShare.AutoMagPickup'
	bNoSmooth=False
	bMeshCurvy=False
	CollisionRadius=25.000000
	CollisionHeight=10.000000
	Mass=15.000000
	DeathMessage="%o got gatted by %k's %w."
	MyDamageType="Shot"
	FiringSpeed=2.5
}
