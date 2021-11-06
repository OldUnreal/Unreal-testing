//=============================================================================
// Eightball.
//=============================================================================
class Eightball extends Weapon;

#exec MESH IMPORT MESH=EightB ANIVFILE=Models\eightb_a.3d DATAFILE=Models\eightb_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=EightB X=0 Y=100 Z=-120 YAW=-64 ROLL=-8
#exec MESH SEQUENCE MESH=eightb SEQ=All      STARTFRAME=0   NUMFRAMES=65
#exec MESH SEQUENCE MESH=eightb SEQ=Select   STARTFRAME=0   NUMFRAMES=15 RATE=24 GROUP=Select
#exec MESH SEQUENCE MESH=eightb SEQ=Down     STARTFRAME=15  NUMFRAMES=12
#exec MESH SEQUENCE MESH=eightb SEQ=Idle     STARTFRAME=27  NUMFRAMES=2
#exec MESH SEQUENCE MESH=eightb SEQ=Idle2    STARTFRAME=29  NUMFRAMES=1
#exec MESH SEQUENCE MESH=eightb SEQ=Loading  STARTFRAME=30  NUMFRAMES=27
#exec MESH SEQUENCE MESH=eightb SEQ=Fire     STARTFRAME=57  NUMFRAMES=8
#exec TEXTURE IMPORT NAME=JEightB1 FILE=Models\Eightbal.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=eightb X=0.005 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=eightb NUM=1 TEXTURE=Jeightb1

#exec MESH IMPORT MESH=EightPick ANIVFILE=Models\epick_a.3d DATAFILE=Models\epick_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=EightPick X=0 Y=170 Z=0 YAW=64
#exec MESH SEQUENCE MESH=eightpick SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=eightpick SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JEightB1 FILE=Models\Eightbal.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=eightpick X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=eightpick NUM=1 TEXTURE=Jeightb1

// 3rd person perspective version
#exec MESH IMPORT MESH=8Ball3rd ANIVFILE=Models\8ball3_a.3d DATAFILE=Models\8ball3_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=8Ball3rd X=0 Y=-430 Z=-45 YAW=-64 ROLL=9
#exec MESH SEQUENCE MESH=8Ball3rd SEQ=All  STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=8Ball3rd SEQ=Idle  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=8Ball3rd SEQ=Fire  STARTFRAME=1  NUMFRAMES=9
#exec TEXTURE IMPORT NAME=JEightB1 FILE=Models\Eightbal.pcx GROUP="Skins"
#exec OBJ LOAD FILE=Textures\FireEffect18.utx PACKAGE=UnrealShare.Effect18
#exec MESHMAP SCALE MESHMAP=8Ball3rd X=0.065 Y=0.065 Z=0.13
#exec MESHMAP SETTEXTURE MESHMAP=8Ball3rd NUM=1 TEXTURE=JEightB1
#exec MESHMAP SETTEXTURE MESHMAP=8Ball3rd NUM=0 TEXTURE=UnrealShare.Effect18.FireEffect18

#exec AUDIO IMPORT FILE="Sounds\Eightbal\8ALTF1.wav" NAME="EightAltFire" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\Eightbal\Barrelm1.wav" NAME="BarrelMove" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\Eightbal\Eload1.wav" NAME="Loading" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\Eightbal\Lock1.wav" NAME="SeekLock" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\Eightbal\SeekLost.wav" NAME="SeekLost" GROUP="EightBall"
#exec AUDIO IMPORT FILE="Sounds\Eightbal\Select.wav" NAME="Selecting" GROUP="EightBall"

#exec MESH NOTIFY MESH=Eightb SEQ=Loading TIME=0.45 FUNCTION=BarrelTurn

#exec TEXTURE IMPORT NAME=Crosshair6 FILE=Textures\Hud\chair6.pcx GROUP="Icons" FLAGS=2 MIPS=OFF

var int RocketsLoaded, RocketRad;
var bool bFireLoad,bTightWad;
var Actor LockedTarget, NewTarget, OldTarget;

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
	bOwnsCrossHair = bLockedOn;
	if ( bOwnsCrossHair )
	{
		// if locked on, draw special crosshair
		Canvas.SetPos(0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8 );
		Canvas.Style = 2;
		Canvas.DrawIcon(Texture'Crosshair6', 1.0);
		Canvas.Style = 1;
	}
}

function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	bUseAltMode = 0;
	if ( Pawn(Owner).Enemy == None )
		return AIRating;

	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location;
	EnemyDist = VSize(EnemyDir);
	if ( EnemyDist < 370 )
		return -0.1;

	if ( Owner.Physics == PHYS_Falling )
		bUseAltMode = 0;
	else if ( EnemyDist < -1.5 * EnemyDir.Z )
		bUseAltMode = int( FRand() < 0.5 );
	else
	{
		bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
		bUseAltMode = 0;
		if ( bRetreating && (EnemyDist < 800) && (FRand() < 0.4) )
			bUseAltMode = 1;
	}
	return AIRating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 600 )
		return -0.6;
	else
		return -0.2;
}

function BarrelTurn()
{
	Owner.PlaySound(Misc3Sound, SLOT_None, 0.1*Pawn(Owner).SoundDampening);
}

function Fire( float Value )
{
	//bFireMem = false;
	//bAltFireMem = false;
	bPointing=True;
	CheckVisibility();
	if ( AmmoType.UseAmmo(1) )
		GoToState('NormalFire');
}

function AltFire( float Value )
{
	//bFireMem = false;
	//bAltFireMem = false;
	bPointing=True;
	CheckVisibility();
	if ( AmmoType.UseAmmo(1) )
		GoToState('AltFiring');
}

function Actor CheckTarget()
{
	local Actor ETarget;
	local Vector Start, X,Y,Z;
	local float bestDist, bestAim;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	if ( !PawnOwner.bIsPlayer && (PawnOwner.Enemy == None) )
		return None;
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	bestAim = 0.93;
	ETarget = PawnOwner.PickTarget(bestAim, bestDist, X, Start);
	if ( !PawnOwner.bIsPlayer && (PawnOwner.Enemy != ETarget) )
		return None;
	bPointing = (ETarget != None);
	Return ETarget;
}

//////////////////////////////////////////////////////
state AltFiring
{
	function Tick( float DeltaTime )
	{
		if ( (pawn(Owner).bAltFire==0) || (RocketsLoaded > 5) ) // If if Fire button down, load up another
			GoToState('FireRockets');
	}
	
	function bool ForcePutDown()
	{
		GoToState('FireRockets');
		return Global.ForcePutDown();
	}

	function BeginState()
	{
		RocketsLoaded = 1;
		bFireLoad = False;
	}

Begin:
	bLockedOn = False;
	While ( RocketsLoaded < 6 )
	{
		if (AmmoType.AmmoAmount<=0) GoToState('FireRockets');
		Owner.PlaySound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
		PlayAnim('Loading', 1.1,0.0);
		FinishAnim();
		RocketsLoaded++;
		AmmoType.UseAmmo(1);
		if ( (PlayerPawn(Owner) == None) && ((FRand() > 0.5) || (Pawn(Owner).Enemy == None)) )
			Pawn(Owner).bAltFire = 0;
		if ( Level.Game.Difficulty > 0 )
			Owner.MakeNoise(0.15 * Level.Game.Difficulty * Pawn(Owner).SoundDampening);
	}
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Tick( float DeltaTime )
	{
		if ( (PlayerPawn(Owner) == None)
		&& ( Pawn(Owner).Target != None && (Pawn(Owner).MoveTarget != Pawn(Owner).Target)
		|| (Pawn(Owner).Enemy == None)
		|| ( Mover(Owner.Base) != None )
		|| ((Owner.Physics == PHYS_Falling) && (Owner.Velocity.Z < 15))
		|| (Pawn(Owner).Target != None && (VSize(Owner.Location - Pawn(Owner).Target.Location) < 400))
		|| !Pawn(Owner).CheckFutureSight(0.15)) )
			Pawn(Owner).bFire = 0;

		if ( pawn(Owner).bFire==0 || RocketsLoaded > 5 ) // If Fire button down, load up another
			GoToState('FireRockets');
	}
	
	function bool ForcePutDown()
	{
		GoToState('FireRockets');
		return Global.ForcePutDown();
	}

	function BeginState()
	{
		bFireLoad = True;
		RocketsLoaded = 1;
		Super.BeginState();
	}

Begin:
	While ( RocketsLoaded < 6 )
	{
		if ( PlayerPawn(Owner) == None )
		{
			if ( FRand() > 0.33 )
				Pawn(Owner).bFire = 0;
			if ( Pawn(Owner).bFire == 0 )
				GoToState('FireRockets');
		}
		if (AmmoType.AmmoAmount<=0) GoToState('FireRockets');
		Owner.PlaySound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
		PlayAnim('Loading', 1.1,0.0);
		FinishAnim();
		if (pawn(Owner).bAltFire!=0) bTightWad=True;
		NewTarget = CheckTarget();
		if ( Pawn(NewTarget) != None )
			Pawn(NewTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));
		If ( (LockedTarget != None) && (NewTarget != LockedTarget) )
		{
			LockedTarget = None;
			Owner.PlaySound(Misc2Sound, SLOT_None, Pawn(Owner).SoundDampening);
			bLockedOn=False;
		}
		else if (LockedTarget != None)
			Owner.PlaySound(Misc1Sound, SLOT_None, Pawn(Owner).SoundDampening);
		bPointing = true;
		if ( Level.Game.Difficulty > 0 )
			Owner.MakeNoise(0.15 * Level.Game.Difficulty * Pawn(Owner).SoundDampening);
		RocketsLoaded++;
		AmmoType.UseAmmo(1);
	}
}

///////////////////////////////////////////////////////
state Idle
{
	function Timer()
	{
		NewTarget = CheckTarget();
		if ( NewTarget == OldTarget )
		{
			LockedTarget = NewTarget;
			If (LockedTarget != None)
			{
				bLockedOn=True;
				Owner.MakeNoise(Pawn(Owner).SoundDampening);
				Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening);
				if ( (Pawn(LockedTarget) != None) && (FRand() < 0.7) )
					Pawn(LockedTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));
			}
		}
		else if ( (OldTarget != None) && (NewTarget == None) )
		{
			Owner.PlaySound(Misc2Sound, SLOT_None,Pawn(Owner).SoundDampening);
			bLockedOn = False;
		}
		else
		{
			LockedTarget = None;
			bLockedOn = False;
		}
		OldTarget = NewTarget;
	}
Begin:
	if (Pawn(Owner).bFire!=0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
	bPointing=False;
	if (AmmoType.AmmoAmount<=0)
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	LoopAnim('Idle', 0.01,0.4);
	OldTarget = CheckTarget();
	SetTimer(1.25,True);
	LockedTarget = None;
	bLockedOn = False;
}

///////////////////////////////////////////////////////
state FireRockets
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function BeginState()
	{
		local vector FireLocation, StartLoc, X,Y,Z;
		local rotator FireRot;
		local rocket r;
		local grenade g;
		local float Angle;
		local pawn BestTarget;
		local int DupRockets;

		Angle = 0;
		DupRockets = RocketsLoaded - 1;
		if (DupRockets < 0) DupRockets = 0;
		if ( PlayerPawn(Owner) != None )
		{
			PlayerPawn(Owner).shakeview(ShakeTime, ShakeMag*RocketsLoaded, ShakeVert); //shake player view
			PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
		}
		else
			bTightWad = ( FRand() * 4 < Pawn(Owner).skill );

		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		StartLoc = Owner.Location + CalcDrawOffset();
		FireLocation = StartLoc + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		if ( bFireLoad )
			AdjustedAim = pawn(owner).AdjustAim(ProjectileSpeed, FireLocation, AimError, True, bWarnTarget);
		else
			AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, FireLocation, AimError, True, bAltWarnTarget);

		GetAxes(AdjustedAim,X,Y,Z);
		PlayAnim( 'Fire', 0.6, 0.05);
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		if ( FiringSpeed > 0 )
			Pawn(Owner).PlayRecoil(FiringSpeed);
		if ( (LockedTarget!=None) || !bFireLoad )
		{
			BestTarget = Pawn(CheckTarget());
			if ( (LockedTarget!=None) && (LockedTarget != BestTarget) )
			{
				LockedTarget = None;
				bLockedOn=False;
			}
		}
		else
			BestTarget = None;
		bPointing = true;
		FireRot = AdjustedAim;
		RocketRad = 4;
		if (bTightWad || !bFireLoad) RocketRad=7;
		While ( RocketsLoaded > 0 )
		{
			Firelocation = StartLoc - Sin(Angle)*Y*RocketRad + (Cos(Angle)*RocketRad - 10.78)*Z + X * (10 + 8 * FRand());
			if (bFireLoad)
			{
				if ( Angle > 0 && !bTightWad )
				{
					if( Level.Game.bUseClassicBalance )
					{
						if ( Angle < 3 && !bTightWad)
							FireRot.Yaw = AdjustedAim.Yaw - Angle * 600;
						else if ( Angle > 3.5 && !bTightWad)
							FireRot.Yaw = AdjustedAim.Yaw + (Angle - 3)  * 600;
						else
							FireRot.Yaw = AdjustedAim.Yaw;
					}
					else if ( Angle < 3 )
						FireRot = rotator(X-Y*(Angle/16.f));
					else if ( Angle > 3.5 )
						FireRot = rotator(X+Y*((Angle-3.f)/16.f));
					else FireRot = AdjustedAim;
				}
				if ( LockedTarget )
				{
					r = Spawn( class 'SeekingRocket',, '', FireLocation,FireRot);
					r.Seeking = LockedTarget;
					r.NumExtraRockets = DupRockets;
				}
				else
				{
					r = Spawn( class 'Rocket',, '', FireLocation,FireRot);
					r.NumExtraRockets = DupRockets;
					if (RocketsLoaded>5 && bTightWad) r.bRing=True;
				}
				if ( Angle > 0 )
					r.Velocity *= (0.9 + 0.2 * FRand());
			}
			else
			{
				g = Spawn( class 'Grenade',, '', FireLocation,AdjustedAim);
				g.WarnTarget = ScriptedPawn(BestTarget);
				g.NumExtraGrenades = DupRockets;
				Owner.PlaySound(AltFireSound, SLOT_None, 3.0*Pawn(Owner).SoundDampening);
			}

			Angle += {2 * Pi / 6};
			RocketsLoaded--;
		}
		bTightWad=False;
		//bFireMem = false;
		//bAltFireMem = false;
	}

Begin:
	FinishAnim();
	if (AmmoType.AmmoAmount > 0)
	{
		Owner.PlaySound(CockingSound, SLOT_None,Pawn(Owner).SoundDampening);
		PlayAnim('Loading', 1.5,0.0);
		FinishAnim();
		RocketsLoaded = 1;
	}
	LockedTarget = None;
	Finish();
}

defaultproperties
{
	ItemName="Eightball"
	ProjectileClass=class'UnrealShare.Rocket'
	AltProjectileClass=class'UnrealShare.Grenade'
	AmmoName=Class'UnrealShare.RocketCan'
	PickupAmmoCount=6
	bWarnTarget=True
	bAltWarnTarget=True
	bSplashDamage=True
	bRecommendSplashDamage=True
	shakemag=350.000000
	shaketime=0.200000
	shakevert=7.500000
	AIRating=0.700000
	RefireRate=0.250000
	AltRefireRate=0.250000
	AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
	CockingSound=Sound'UnrealShare.Eightball.Loading'
	SelectSound=Sound'UnrealShare.Eightball.Selecting'
	Misc1Sound=Sound'UnrealShare.Eightball.SeekLock'
	Misc2Sound=Sound'UnrealShare.Eightball.SeekLost'
	Misc3Sound=Sound'UnrealShare.Eightball.BarrelMove'
	AutoSwitchPriority=5
	InventoryGroup=5
	PickupMessage="You got the Eightball gun"
	PlayerViewOffset=(X=1.900000,Z=-1.890000)
	PlayerViewMesh=Mesh'UnrealShare.EightB'
	BobDamping=0.985000
	PickupViewMesh=Mesh'UnrealShare.EightPick'
	ThirdPersonMesh=Mesh'UnrealShare.8Ball3rd'
	PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
	Mesh=Mesh'UnrealShare.EightPick'
	bNoSmooth=False
	bMeshCurvy=False
	CollisionHeight=10.000000
	DeathMessage="%o was smacked down multiple times by %k's %w."
	MyDamageType="Exploded"
	FiringSpeed=1
}
