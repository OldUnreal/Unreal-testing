//=============================================================================
// QuadShot. New firstperson mesh by Krull0r. Original code by .:..:
//=============================================================================
class QuadShot extends Weapon;

#exec TEXTURE IMPORT NAME=GunPick1 FILE=Models\quadhand.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=QuadHand1 FILE=Models\quadhand.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=InvisibleTexture FILE=Models\Invisible.pcx GROUP=Skins FLAGS=2

// Pickup View
#exec MESH IMPORT MESH=QuadShotPickupC ANIVFILE=Models\QuadShotPickup_a.3d DATAFILE=Models\QuadShotPickup_d.3d
// 108 Vertices, 180 Triangles
#exec MESH ORIGIN MESH=QuadShotPickupC X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=QuadShotPickupC STRENGTH=0.3

#exec MESH SEQUENCE MESH=QuadShotPickupC SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=QuadShotPickupC SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=QuadShotPickupC MESH=QuadShotPickupC
#exec MESHMAP SCALE MESHMAP=QuadShotPickupC X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotPickupC NUM=4 TEXTURE=GunPick1

// Third Person View
// Mesh re-animated by .:..:
#exec MESH IMPORT MESH=QuadShotThird ANIVFILE=Models\QuadThirdT_a.3d DATAFILE=Models\QuadThirdT_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=QuadShotThird STRENGTH=0
#exec MESH ORIGIN MESH=QuadShotThird X=0 Y=700 Z=-100 YAW=64

#exec MESH SEQUENCE MESH=QuadShotThird SEQ=All STARTFRAME=0 NUMFRAMES=8
#exec MESH SEQUENCE MESH=QuadShotThird SEQ=Idle STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=QuadShotThird SEQ=Reload STARTFRAME=3 NUMFRAMES=5

#exec MESHMAP NEW MESHMAP=QuadShotThird MESH=QuadShotThird
#exec MESHMAP SCALE MESHMAP=QuadShotThird X=0.02 Y=0.02 Z=0.04

#exec MESHMAP SETTEXTURE MESHMAP=QuadShotThird NUM=1 TEXTURE=QuadHand1
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotThird NUM=2 TEXTURE=QuadHand1
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotThird NUM=3 TEXTURE=QuadHand1


// Right Handed First Person View
// Mesh re-animated by Krull0r
#exec MESH IMPORT MESH=QuadShotHeldR ANIVFILE=MODELS\QuadShotR_a.3d DATAFILE=MODELS\QuadShotR_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=QuadShotHeldR X=-80 Y=-50 Z=0 YAW=0 PITCH=-64 ROLL=64

#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=All        STARTFRAME=0 NUMFRAMES=53
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=DOWN       STARTFRAME=0 NUMFRAMES=5 Rate=8
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=FIRE       STARTFRAME=5 NUMFRAMES=10 Rate=22
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=IDLE       STARTFRAME=15 NUMFRAMES=6 Rate=1
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=PRERELOAD  STARTFRAME=21 NUMFRAMES=3 Rate=15
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=RELOAD     STARTFRAME=24 NUMFRAMES=13 Rate=18
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=RELOADEND  STARTFRAME=37 NUMFRAMES=3 Rate=15
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=RELOADLOOP STARTFRAME=40 NUMFRAMES=7 Rate=15
#exec MESH SEQUENCE MESH=QuadShotHeldR SEQ=SELECT     STARTFRAME=47 NUMFRAMES=6 Rate=8

#exec MESHMAP NEW   MESHMAP=QuadShotHeldR MESH=QuadShotHeldR
#exec MESHMAP SCALE MESHMAP=QuadShotHeldR X=0.007 Y=0.006 Z=0.014

#exec MESHMAP SETTEXTURE MESHMAP=QuadShotHeldR NUM=1 TEXTURE=Automa1
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotHeldR NUM=2 TEXTURE=Quadhand1
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotHeldR NUM=3 TEXTURE=Quadhand1

// Left Handed First Person View
// Mesh re-animated by Krull0r
#exec MESH IMPORT MESH=QuadShotHeldL ANIVFILE=MODELS\QuadShotL_a.3d DATAFILE=MODELS\QuadShotL_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=QuadShotHeldL X=-80 Y=-50 Z=0 YAW=0 PITCH=-64 ROLL=64

#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=All        STARTFRAME=0 NUMFRAMES=53
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=DOWN       STARTFRAME=0 NUMFRAMES=5 Rate=8
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=FIRE       STARTFRAME=5 NUMFRAMES=10 Rate=22
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=IDLE       STARTFRAME=15 NUMFRAMES=6 Rate=1
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=PRERELOAD  STARTFRAME=21 NUMFRAMES=3 Rate=15
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=RELOAD     STARTFRAME=24 NUMFRAMES=13 Rate=18
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=RELOADEND  STARTFRAME=37 NUMFRAMES=3 Rate=15
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=RELOADLOOP STARTFRAME=40 NUMFRAMES=7 Rate=15
#exec MESH SEQUENCE MESH=QuadShotHeldL SEQ=SELECT     STARTFRAME=47 NUMFRAMES=6 Rate=8

#exec MESHMAP NEW   MESHMAP=QuadShotHeldL MESH=QuadShotHeldL
#exec MESHMAP SCALE MESHMAP=QuadShotHeldL X=0.007 Y=0.006 Z=0.014

#exec MESHMAP SETTEXTURE MESHMAP=QuadShotHeldL NUM=1 TEXTURE=Automa1
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotHeldL NUM=2 TEXTURE=Quadhand1
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotHeldL NUM=3 TEXTURE=Quadhand1

// ------------------------------------------------------------------------------------------------------------------------

// Backwards Compatibility Pickup View - NOT USED
#exec MESH IMPORT MESH=QuadShotPickup ANIVFILE=Models\QuadShotPickup_a.3d DATAFILE=Models\QuadShotPickup_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=QuadShotPickup X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=QuadShotPickup SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=QuadShotPickup X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotPickup NUM=4 TEXTURE=GunPick1



// Backwards Compatibility First Person View - NOT USED
#exec MESH IMPORT MESH=QuadShotHeld ANIVFILE=Models\QuadShotHeld_a.3d DATAFILE=Models\QuadShotHeld_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=QuadShotHeld X=0 Y=0 Z=0 YAW=128
#exec MESH SEQUENCE MESH=QuadShotHeld SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=QuadShotHeld SEQ=Fire STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=QuadShotHeld SEQ=Reload STARTFRAME=8 NUMFRAMES=21
#exec MESHMAP SCALE MESHMAP=QuadShotHeld X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=QuadShotHeld NUM=4 TEXTURE=QuadHand1

// ------------------------------------------------------------------------------------------------------------------------

#exec AUDIO IMPORT FILE="Sounds\ShotgunFire.wav" NAME="ShotgunFire" GROUP="QuadShot"
#exec AUDIO IMPORT FILE="Sounds\ShotgunFire2.wav" NAME="ShotgunFire2" GROUP="QuadShot"
#exec AUDIO IMPORT FILE="Sounds\ShotgunFire3.wav" NAME="ShotgunFire3" GROUP="QuadShot"
#exec AUDIO IMPORT FILE="Sounds\ShotgunFire4.wav" NAME="ShotgunFire4" GROUP="QuadShot"
#exec AUDIO IMPORT FILE="Sounds\ShotgunLoad.wav" NAME="ShotgunLoad" GROUP="QuadShot"
#exec AUDIO IMPORT FILE="Sounds\ShotgunActivate.wav" NAME="ShotgunActivate" GROUP="QuadShot"


var travel byte LoadCount;			  // Keeps track of the number of Shells Currently Loaded
var travel int SpentCartridge;		// Keeps track of the number of Spent Cartridges Loaded
var() int HitDamage;			  // Hit Damage induced per Shotgun pellet
var() float HitMomentum;		 // Hit Momentum induced per Shotgun pellet
var() int PelletsPerShell;	  // Number of Pellets per Shotgun Shell
var() int BarrelShotOffset;	 // Offset Adjustment from standard offset to account for multi-barrel
var() float ShotSpread;		  // Shot Spread
var() float OptimalRange;		// Optimal Operational Range
var() sound 	FireSound2;
var() sound 	FireSound3;
var() sound 	FireSound4;

//======================================================================================
// QuadShot.TraceFire
//======================================================================================
function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5 )* Y * 1000 + Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (OptimalRange * 6 * X);
	Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}

//======================================================================================
// QuadShot.ProcessTraceHit
//======================================================================================
function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int ModifiedDamage;
	local float EnemyDist, ModifiedMomentum, AddedImpactEffect;
	local vector EnemyDir;
	local vector realLoc;
	local ZoneInfo HitZone;
	local byte HitCount;
	local rotator Dummy;

	/* Check if were passing through zoneportals */
	if ( Other!=None )
	{
		HitZone = Level.GetLocZone(HitLocation+HitNormal).Zone;
		while ( WarpZoneInfo(HitZone)!=None && WarpZoneInfo(HitZone).OtherSideActor!=None && HitCount++<5 )
		{
			realLoc = HitLocation;
			WarpZoneInfo(HitZone).UnWarp(realLoc,X,Dummy);
			WarpZoneInfo(HitZone).OtherSideActor.Warp(realLoc,X,Dummy);
			Z = realLoc+X*8000;
			Other = Trace(HitLocation,HitNormal,Z,realLoc,True); // We dont use owner pawn trace here because we could hit ourselves.
			while ( Other!=None && Other.bIsPawn && !Pawn(Other).AdjustHitLocation(HitLocation, Z - realLoc) )
			{
				realLoc = HitLocation;
				Other = Other.Trace(HitLocation,HitNormal,Z,realLoc,True);
			}
			if ( Other==None )
				Break;
			HitZone = Level.GetLocZone(HitLocation+HitNormal).Zone;
		}
	}

	if (other != none)
	{
		EnemyDir = Other.Location - Owner.Location;
		EnemyDist = FMax((1.f-VSize(EnemyDir)/OptimalRange),0.25f);
	}

	// Modify Damage/Momentum for Long Distance Shots
	ModifiedDamage=Max(int(float(HitDamage)*EnemyDist),1);
	ModifiedMomentum=FMax(HitMomentum*EnemyDist,500.0);
	AddedImpactEffect = FRand();
	if ( AddedImpactEffect < 0.2 )
		ModifiedMomentum *= 2;

	if (Other == Level)
	{
		if ( AddedImpactEffect < 0.2 )
			Spawn(class'WallHitEffect',,, HitLocation+HitNormal*9, Rotator(HitNormal));
		else if ( AddedImpactEffect < 0.5 )
			Spawn(class'LightWallHitEffect',,,HitLocation+HitNormal*9, Rotator(HitNormal));
		else Spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
	else if ( (Other != None) && (Other != self) && (Other != Owner)  )
	{
		if ( Other.IsA('Pawn') && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight)
				&& (instigator.IsA('PlayerPawn') || (instigator.skill > 1))
				&& (!Other.IsA('ScriptedPawn') || !ScriptedPawn(Other).bIsBoss) )
			Other.TakeDamage(ModifiedDamage*2, Pawn(Owner), HitLocation, ModifiedMomentum*X, 'decapitated');
		else if (Other.IsA('Pawn'))
			Other.TakeDamage(ModifiedDamage, Pawn(Owner), HitLocation, ModifiedMomentum*X, 'shot');
		else if (other != none)
		{
			Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, ModifiedMomentum*X, 'shot');
			if ( !Other.IsA('Pawn') && !Other.IsA('Carcass') )
				spawn(class'SpriteSmokePuff',,,HitLocation+HitNormal*9);
		}
	}
}

//======================================================================================
// QuadShot.RateSelf
//======================================================================================
// AI Interface
// Determines if QuadShot is a good choice to use
//======================================================================================
function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist, Rating;
	local vector EnemyDir;
	local Pawn P;

	// don't recommend self if out of ammo
	if ( AmmoType.AmmoAmount <=0 && LoadCount==0)
		return -2;

	// Attempt to use regular mode only if Already Loaded otherwise load a random charge up
	if (LoadCount>0)
	{
		if (FRand()>=0.5 || LoadCount==4)
			bUseAltMode = 0;
		else
			bUseAltMode = 1;
	}
	else bUseAltMode = 1;

	P = Pawn(Owner);
	if ( P.Enemy == None )
		return AIRating;
	else
	{
		EnemyDir = P.Enemy.Location - Owner.Location;
		EnemyDist = VSize(EnemyDir);
		Rating = AIRating;

		Rating = FClamp(AIRating - (EnemyDist - OptimalRange) * 0.001 + float(LoadCount)/10.0, 0.2, AIRating);
		return Rating;
	}
}

//======================================================================================
// QuadShot.SuggestAttackStyle
//======================================================================================
// AI Interface
// Determines if QuadShot is a good choice to attack with
//======================================================================================
function float SuggestAttackStyle()
{
	local Pawn P;
	local float EnemyDist;

	P = Pawn(Owner);

	// Move forward at a moderate pace
	if ( P == None || P.Target==None )
	{
		if ( P!=None )
			P.bAltFire=1;
		return 0.4;
	}
	else EnemyDist = VSize(P.Target.Location - P.Location);

	// If enemy outside of optimal fighting range then charge in closer
	if ( EnemyDist > OptimalRange*2 )
	{
		Pawn(Owner).bAltFire=1;
		return 1.0;
	}

	// If enemy too close then back off quickly
	if ( EnemyDist < OptimalRange*0.33 )
		return -1.5;

	// If enemy close then back off with moderately quick speed
	if ( EnemyDist < OptimalRange*0.66 )
		return -0.75;

	// Otherwise close with enemy at slow pace
	P.bAltFire=1;
	return 0.2;

}

//======================================================================================
// QuadShot.SuggestDefenseStyle()
//======================================================================================
// AI Interface
// Determines best defensive action vs QuadShot
//======================================================================================
function float SuggestDefenseStyle()
{
	local Pawn P;
	local float EnemyDist;

	P = Pawn(Owner);

	// No recommended defensive action
	if ( P==None || P.Target == None )
		return 0;
	else if ( P.Target == None )
		return 0;
	else EnemyDist = VSize(P.Target.Location - P.Location);

	// If enemy has not loaded a shell yet - charge them
	if (LoadCount==0)
		return 1;
	else if ( EnemyDist < OptimalRange*1.5 )
		return -0.75; // If enemey is relatively close - retreat moderately quickly away from weapon
	else return 0; // Otherwise no recommended defensive action
}

//======================================================================================
// QuadShot.SetHand
//======================================================================================
function SetHand(float Hand)
{
	if ( Hand == 0 ) // CENTER
	{
		Mesh = Mesh'QuadShotHeldR';
		bHideWeapon = false;
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = 0;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
		PlayerViewOffset *= 100; //scale since network passes vector components as ints
		FireOffset.Y = 0;
	}
	else if ( Hand == 1 )  // LEFT
	{
		Mesh = Mesh'QuadShotHeldL';
		bHideWeapon = false;
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
		PlayerViewOffset *= 100; //scale since network passes vector components as ints
		FireOffset.Y = Default.FireOffset.Y * Hand;
	}
	else if ( Hand == -1)  // RIGHT
	{
		Mesh = Mesh'QuadShotHeldR';
		bHideWeapon = false;
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
		PlayerViewOffset *= 100; //scale since network passes vector components as ints
		FireOffset.Y = Default.FireOffset.Y * Hand;
	}
	else if ( Hand == 2 )  // HIDDEN
	{
		bHideWeapon = true;
		PlayerViewOffset.Y = 0;
		PlayerViewOffset *= 100; //scale since network passes vector components as ints
		FireOffset.Y = 0;
	}

}

//======================================================================================
// QuadShot.Fire
//======================================================================================
function Fire( float Value )
{
	GoToState('NormalFire');
}

//======================================================================================
// QuadShot.AltFire
//======================================================================================
function AltFire( float Value )
{
	GoToState('ReLoad');
}

//======================================================================================
// QuadShot.PlayPostSelect
//======================================================================================
function PlayPostSelect()
{
	Super.PlayPostSelect();
	if ( LoadCount==0 )
		GoToState('ReLoad');
	else GotoState('Idle');
}

//======================================================================================
// QuadShot.SetShotPattern
//======================================================================================
function SetShotPattern( int LoadCount, int ShotNum )
{
	FireOffset = default.FireOffset;
	if (LoadCount==1)
		return;
	else if (LoadCount==2)
	{
		if (ShotNum==1)
			FireOffset.Y -= BarrelShotOffset;
		if (ShotNum==2)
			FireOffset.Z += BarrelShotOffset;
	}
	else if (LoadCount==3)
	{
		if (ShotNum==1)
			FireOffset.Y -= BarrelShotOffset;
		if (ShotNum==2)
			FireOffset.Z += BarrelShotOffset;
		if (ShotNum==3)
			FireOffset.Y += BarrelShotOffset;
	}
	else
	{
		if (ShotNum==1)
			FireOffset.Y -= BarrelShotOffset;
		if (ShotNum==2)
			FireOffset.Z += BarrelShotOffset;
		if (ShotNum==3)
			FireOffset.Y += BarrelShotOffset;
		if (ShotNum==4)
			FireOffset.Z -= BarrelShotOffset;
	}
}

//======================================================================================
// QuadShot.EjectCartridge
//======================================================================================
function EjectCartridge()
{
	local shellcase s;
	local vector realLoc, X, Y, Z;
	local Pawn PawnOwner;
	local int i;

	PawnOwner = Pawn(Owner);

	GetAxes(PawnOwner.ViewRotation,X,Y,Z);

	realLoc = Owner.Location + CalcDrawOffset();
	for( i=Max(SpentCartridge,1); i>0; --i )
	{
		s = Spawn(class'ShotShellCase',,, realLoc - (2.f*X) + (FireOffset.Y * Y) + Z);
		if ( s != None )
			s.Eject((RandRange(0.4,0.7)*X + RandRange(0.2,0.4)*Y + RandRange(1,1.3)*Z)*160);
	}
	SpentCartridge = 0;
}

//======================================================================================
// QuadShot.PlayIdleAnim
//======================================================================================
function PlayIdleAnim()
{
	if ( AnimSequence!='Idle' )
		LoopAnim('Idle',0.5);
}

//======================================================================================
// QuadShot.Finish
//======================================================================================
function Finish()
{
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	else if ( PlayerPawn(Owner) == None )
		Super(Weapon).Finish();
	else if ( Pawn(Owner).Weapon!=self )
		GotoState('');
	else if ( Pawn(Owner).bFire!=0 )
		Global.Fire(0);
	else if ( Pawn(Owner).bAltFire!=0 )
		Global.AltFire(0);
	else
		GotoState('Idle');
}

//======================================================================================
// QuadShot.DisplayMuzzleFlash
//======================================================================================
function DisplayMuzzleFlash()
{
	local vector Start,X,Y,Z;

	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;

	Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));

	bDrawMuzzleFlash=True;
	bMuzzleFlash=0;
}

//======================================================================================
// QuadShot:NormalFire
//======================================================================================
state NormalFire
{
	ignores Fire, AltFire;

	function DischargeWeapon()
	{
		local int loads,shots;

		CheckVisibility();
		bPointing=True;

		// Shoot all barrels
		for (loads = 0; loads < LoadCount; loads++)
		{
			SetShotPattern(LoadCount, loads);
			DisplayMuzzleFlash();
			for (shots = 0; shots < PelletsperShell; shots++)
				TraceFire(ShotSpread);
		}
		if (PlayerPawn(Owner)!=None)
			PlayerPawn(Owner).ShakeView(ShakeTime*Sqrt(float(LoadCount)), ShakeMag*Sqrt(float(LoadCount)), ShakeVert*Sqrt(float(LoadCount)));

		Owner.MakeNoise(LoadCount * Pawn(Owner).SoundDampening);
		if (LoadCount == 1)
			Owner.PlaySound(FireSound,SLOT_Misc,FMin(0.95,Pawn(Owner).SoundDampening*((float(LoadCount)/20.0)+0.7)),,1500.0,1.1-(float(LoadCount)/20.0));
		else if (LoadCount == 2)
			Owner.PlaySound(FireSound2,SLOT_Misc,FMin(0.95,Pawn(Owner).SoundDampening*((float(LoadCount)/20.0)+0.7)),,1500.0,1.1-(float(LoadCount)/20.0));
		else if (LoadCount == 3)
			Owner.PlaySound(FireSound3,SLOT_Misc,FMin(0.95,Pawn(Owner).SoundDampening*((float(LoadCount)/20.0)+0.7)),,1500.0,1.1-(float(LoadCount)/20.0));
		else 
			Owner.PlaySound(FireSound4,SLOT_Misc,FMin(0.95,Pawn(Owner).SoundDampening*((float(LoadCount)/20.0)+0.7)),,1500.0,1.1-(float(LoadCount)/20.0));						

		// Unload the weapon
		LoadCount=0;
	}

Begin:
	if (LoadCount==0)
	{
		PlayIdleAnim();
		Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening*1.0,False,300.0);
		Sleep(0.5);
		Finish();
	}
	PlayAnim( 'Fire', 0.9, 0.05);
	DischargeWeapon();
	FinishAnim();
	EjectCartridge();
	GoToState('ReLoad');
}

//======================================================================================
// QuadShot:Reload
//======================================================================================
state Reload
{
	ignores Fire, AltFire;

Begin:
	if ( LoadCount>=4 || (AmmoType!=None && !AmmoType.UseAmmo(1)) )
	{
		PlayIdleAnim();
		Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening*1.0,False,300.0);
		Sleep(0.5);
		Finish();
	}
	LoadCount++;
	PlayAnim('Reload',1.2,0);
	Owner.PlaySound(CockingSound, SLOT_None,0.6*Pawn(Owner).SoundDampening);
	SpentCartridge++;
	FinishAnim();
	LoopAnim('Idle',0.5,0.f);
	Finish();
}

//======================================================================================
// QuadShot:Idle
//======================================================================================
state Idle
{
	Ignores AnimEnd;

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( !HasRequiredAmmo() )
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 )
		Global.Fire(0.0);
	if ( LoadCount < 4 )
		if ( Pawn(Owner).bAltFire!=0 )
			Global.AltFire(0.0);
	PlayIdleAnim();
	if ( PlayerPawn(Owner)==None && LoadCount<4 && (AmmoType==None || AmmoType.AmmoAmount>0) )
	{
		Sleep(LoadCount*(3+FRand()*5)+2); // Automatic charging up...
		Global.AltFire(0.0);
	}
}

function bool HasRequiredAmmo()
{
	Return (AmmoType==None || AmmoType.AmmoAmount>0 || LoadCount>0);
}

//
// Fix for ammo bugs..
function Weapon WeaponChange( byte F )
{
	local Weapon newWeapon;

	if ( InventoryGroup == F )
	{
		if ( !HasRequiredAmmo() )
		{
			if ( Inventory == None )
				newWeapon = None;
			else
				newWeapon = Inventory.WeaponChange(F);
			if ( newWeapon == None )
				Pawn(Owner).ClientMessage( ItemName$MessageNoAmmo );
			return newWeapon;
		}
		else
			return self;
	}
	else if ( Inventory == None )
		return None;
	else
		return Inventory.WeaponChange(F);
}

function float SwitchPriority()
{
	local int bTemp;

	if ( !Owner.IsA('PlayerPawn') )
		return RateSelf(bTemp);
	else if ( !HasRequiredAmmo() )
	{
		if ( Pawn(Owner).Weapon == self )
			return -0.5;
		else
			return -1;
	}
	else
		return AutoSwitchPriority;
}
function Weapon RecommendWeapon( out float rating, out int bUseAltMode )
{
	local Weapon Recommended;
	local float oldRating;
	local int oldMode;

	if ( Owner.IsA('PlayerPawn') )
		rating = SwitchPriority();
	else
	{
		rating = RateSelf(bUseAltMode);
		if ( (self == Pawn(Owner).Weapon) && (Pawn(Owner).Enemy != None) && HasRequiredAmmo() )
			rating += 0.21; // tend to stick with same weapon
	}
	if ( inventory != None )
	{
		Recommended = inventory.RecommendWeapon(oldRating, oldMode);
		if ( (Recommended != None) && (oldRating > rating) )
		{
			rating = oldRating;
			bUseAltMode = oldMode;
			return Recommended;
		}
	}
	return self;
}

defaultproperties
{
	hitdamage=12
	HitMomentum=18000.000000
	PelletsPerShell=10
	BarrelShotOffset=3
	ShotSpread=1.250000
	OptimalRange=750.000000
	AmmoName=Class'UnrealShare.Shells'
	PickupAmmoCount=12
	MyDamageType=shot
	AltDamageType=Decapitated
	shakemag=400.000000
	shaketime=0.150000
	shakevert=20.000000
	AIRating=0.300000
	RefireRate=0.700000
	AltRefireRate=0.900000
	FireSound=Sound'UnrealI.QuadShot.ShotgunFire'
	FireSound2=Sound'UnrealI.QuadShot.ShotgunFire2'
	FireSound3=Sound'UnrealI.QuadShot.ShotgunFire3'
	FireSound4=Sound'UnrealI.QuadShot.ShotgunFire4'	
	CockingSound=Sound'UnrealI.QuadShot.ShotgunLoad'
	SelectSound=Sound'UnrealI.QuadShot.ShotgunActivate'
	Misc1Sound=Sound'UnrealShare.flak.Click'
	DeathMessage="%o was blasted to bits by %k's %w."
	bSetFlashTime=True
	bMuzzleFlash=1
	FlashTime=0.500000
	MuzzleScale=1.000000
	FlashY=0.110000
	FlashO=0.140000
	FlashC=0.030000
	FlashLength=0.250000
	FlashS=64
	MFTexture=Texture'UnrealShare.Effects.Arc1'
	AutoSwitchPriority=4
	InventoryGroup=2
	PickupMessage="You got the Quad-Barreled ShotGun"
	ItemName="QuadShot"
	PlayerViewOffset=(X=7.000000,Y=-4.000000,Z=-4.000000)
	PlayerViewMesh=Mesh'UnrealI.QuadShotHeldR'
	PlayerViewScale=2.000000
	PickupViewMesh=Mesh'UnrealI.QuadShotPickupC'
	PickupViewScale=1.500000
	ThirdPersonMesh=Mesh'UnrealI.QuadShotThird'
	PickupSound=Sound'UnrealI.Pickups.WeaponPickup'
	Mesh=LodMesh'UnrealI.QuadShotPickupC'
	DrawScale=1.500000
	bNoSmooth=False
	bMeshCurvy=True
	SoundRadius=200
	SoundVolume=180
	CollisionHeight=10.000000
	Mass=45.000000
}
