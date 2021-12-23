//=============================================================================
// UTranslocator.
//=============================================================================
class UTranslocator extends Weapon;

#exec MESH  IMPORT MESH=TeleHand ANIVFILE=Models\Hand_a.3D DATAFILE=Models\Hand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TeleHand X=0 Y=0 Z=0 YAW=64 PITCH=-10 ROLL=-10
#exec MESH SEQUENCE MESH=TeleHand SEQ=All    STARTFRAME=0  NUMFRAMES=105
#exec MESH SEQUENCE MESH=TeleHand SEQ=Temp      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TeleHand SEQ=Select    STARTFRAME=1  NUMFRAMES=13
#exec MESH SEQUENCE MESH=TeleHand SEQ=Still     STARTFRAME=14 NUMFRAMES=2
#exec MESH SEQUENCE MESH=TeleHand SEQ=Twiddle1  STARTFRAME=16 NUMFRAMES=4
#exec MESH SEQUENCE MESH=TeleHand SEQ=Twiddle2  STARTFRAME=20 NUMFRAMES=6
#exec MESH SEQUENCE MESH=TeleHand SEQ=Throw     STARTFRAME=26 NUMFRAMES=15
#exec MESH SEQUENCE MESH=TeleHand SEQ=Select2   STARTFRAME=41 NUMFRAMES=15
#exec MESH SEQUENCE MESH=TeleHand SEQ=Fire      STARTFRAME=56 NUMFRAMES=5
#exec MESH SEQUENCE MESH=TeleHand SEQ=Rub1      STARTFRAME=61 NUMFRAMES=2
#exec MESH SEQUENCE MESH=TeleHand SEQ=Rub2      STARTFRAME=63 NUMFRAMES=2
#exec MESH SEQUENCE MESH=TeleHand SEQ=Walk      STARTFRAME=65 NUMFRAMES=4
#exec MESH SEQUENCE MESH=TeleHand SEQ=Down      STARTFRAME=69 NUMFRAMES=7
#exec MESH SEQUENCE MESH=TeleHand SEQ=Finger    STARTFRAME=76 NUMFRAMES=29
#exec TEXTURE IMPORT NAME=Ahand1 FILE=Models\hand.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=TeleHand X=0.005 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=TeleHand NUM=0 TEXTURE=Ahand1

#exec MESH NOTIFY MESH=TeleHand SEQ=Throw TIME=0.6 FUNCTION=Toss
#exec MESH NOTIFY MESH=TeleHand SEQ=Fire TIME=0.5 FUNCTION=Teleport

// Right handed model.
#exec MESH  IMPORT MESH=TeleHandR ANIVFILE=Models\Hand_a.3D DATAFILE=Models\Hand_d.3D X=0 Y=0 Z=0 unmirror=1
#exec MESH ORIGIN MESH=TeleHandR X=0 Y=0 Z=0 YAW=64 PITCH=-10 ROLL=-10
#exec MESH SEQUENCE MESH=TeleHandR SEQ=All    STARTFRAME=0  NUMFRAMES=105
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Temp      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Select    STARTFRAME=1  NUMFRAMES=13
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Still     STARTFRAME=14 NUMFRAMES=2
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Twiddle1  STARTFRAME=16 NUMFRAMES=4
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Twiddle2  STARTFRAME=20 NUMFRAMES=6
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Throw     STARTFRAME=26 NUMFRAMES=15
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Select2   STARTFRAME=41 NUMFRAMES=15
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Fire      STARTFRAME=56 NUMFRAMES=5
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Rub1      STARTFRAME=61 NUMFRAMES=2
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Rub2      STARTFRAME=63 NUMFRAMES=2
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Walk      STARTFRAME=65 NUMFRAMES=4
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Down      STARTFRAME=69 NUMFRAMES=7
#exec MESH SEQUENCE MESH=TeleHandR SEQ=Finger    STARTFRAME=76 NUMFRAMES=29
#exec TEXTURE IMPORT NAME=Ahand1 FILE=Models\hand.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=TeleHandR X=0.005 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=TeleHandR NUM=0 TEXTURE=Ahand1

#exec MESH NOTIFY MESH=TeleHandR SEQ=Throw TIME=0.6 FUNCTION=Toss
#exec MESH NOTIFY MESH=TeleHandR SEQ=Fire TIME=0.5 FUNCTION=Teleport

#exec AUDIO IMPORT FILE="Sounds\Pickups\FFIELDh2.wav" NAME="TranslocatorError" GROUP="Translocator"
#exec AUDIO IMPORT FILE="Sounds\Translocator\tranreturn.wav" NAME="ReturnTarget" GROUP="Translocator"

var UTranslocatorTarget MyTarget;
var vector BotTransTarget,BotTransJumpTarget;
var float BotPausingTime;
var Weapon LastUsedWeapon;

replication
{
	// Functions client can call.
	reliable if ( Role<ROLE_Authority )
		SelectTranslocator;
}

// set which hand is holding weapon
function setHand(float Hand)
{
	Super.SetHand(Hand);
	if ( Hand == 1 )
		Mesh = mesh'TeleHand';
	else
		Mesh = mesh'TeleHandR';
}

function TargetDestroyed()
{
	MyTarget = None;
	PlayAnim('Select2',,0.25);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local UTranslocatorTarget T;

	T = UTranslocatorTarget(Super.ProjectileFire(ProjClass,ProjSpeed,bWarn));
	if( T==None )
		return None;
	if( MyTarget!=None )
		MyTarget.Destroy();
	MyTarget = T;
	T.MyTranslocator = Self;
	if( PlayerPawn(Owner)==None )
	{
		T.Velocity = T.SuggestFallVelocity(T.Location,BotTransTarget,1500.f,1500.f,100.f);
		BotPausingTime = Level.TimeSeconds + FMax(0.5f, (VSize2D(BotTransTarget-T.Location) / FMax(1.f,VSize2D(T.Velocity))));
	}
}

function Fire( float Value )
{
	bPointing=True;
	if( PlayerPawn(Owner)==None && Pawn(Owner).Enemy!=None )
	{
		BotTransTarget = Pawn(Owner).Enemy.Location;
		BotTransJumpTarget = Pawn(Owner).Enemy.Location;
	}
 	GotoState('NormalFire');
}

function AltFire( float Value )
{
	bPointing=True;
	GoToState('AltFiring');
}

function Destroyed()
{
	if( MyTarget!=None )
	{
		MyTarget.MyTranslocator = None;
		MyTarget.Destroy();
		MyTarget = None;
	}
	Super.Destroyed();
}

// Toss this weapon out
function DropFrom(vector StartLocation)
{
	if ( !SetLocation(StartLocation) )
		return; 
	AIRating = Default.AIRating;
	bMuzzleFlash = 0;
	if( MyTarget!=None )
	{
		MyTarget.MyTranslocator = None;
		MyTarget.Destroy();
		MyTarget = None;
	}
	Super(Inventory).DropFrom(StartLocation);
}

function TryToSwitchToOld()
{
	if( PlayerPawn(Owner)!=None && Pawn(Owner).bFire!=0 && Pawn(Owner).bAltFire!=0 && LastUsedWeapon!=None && LastUsedWeapon.Owner==Owner )
	{
		Pawn(Owner).PendingWeapon = LastUsedWeapon;
		PutDown();
	}
}

////////////////////////////////////////////////////////
state AltFiring
{
Ignores TargetDestroyed;

	function Fire(float F)
	{
		TryToSwitchToOld();
	}
	function AltFire(float F)
	{
		TryToSwitchToOld();
	}
Begin:
	if( MyTarget==None )
	{
		PlayAnim('Down',1.2);
		FinishAnim();
		PlayAnim('Finger',1);
		FinishAnim();
		PlayAnim('Select',1.2);
	}
	else
	{
		if( PlayerPawn(Owner)==None && BotPausingTime>Level.TimeSeconds )
			Sleep(BotPausingTime-Level.TimeSeconds);
		PlayAnim('Fire',0.6);
	}
	FinishAnim();
	Finish();
}

function Teleport()
{
	local vector OldPos;
	local TeleportEffectB Tel;

	if ( MyTarget==None )
		Owner.PlaySound(Misc1Sound, SLOT_Misc, Pawn(Owner).SoundDampening);    // Teleport Fail Sound
	else
	{
		MyTarget.bCantPickup = true;
		OldPos = Owner.Location;
		if( !TryToTeleport(MyTarget.Location) )
		{
			MyTarget.bCantPickup = false;
			Owner.PlaySound(Misc1Sound, SLOT_Misc, Pawn(Owner).SoundDampening);    // Teleport Fail Sound
			return;
		}
		Tel = Spawn(Class'TeleportEffectB',Owner,,OldPos,Owner.Rotation);
		Tel.Mesh = Owner.Mesh;
		Tel.PrePivot = Owner.PrePivot;
		Tel.DrawScale = Owner.DrawScale;
		Spawn(class'TeleportEffect',Owner,,Owner.Location);
		MyTarget.MyTranslocator = None;
		MyTarget.Destroy();
		MyTarget = None;
		if( PlayerPawn(Owner)==None )
		{
			Pawn(Owner).Destination = BotTransJumpTarget;
			Owner.Velocity = Pawn(Owner).EAdjustJump();
			Pawn(Owner).MoveTarget = None;
			Pawn(Owner).Focus = BotTransJumpTarget;
		}
		else PlayerPawn(Owner).SetFOVAngle(170);
	}
}

// Try to teleport, if blocks any team-mates, disallow, otherwise just telefrag them.
function bool TryToTeleport( vector Dest )
{
	local bool bBlockedA,bBlockedP;
	local vector StartPos;
	local Pawn P,Enemies[6];
	local byte i,j;

	StartPos = Owner.Location;
	bBlockedA = Owner.bBlockActors;
	bBlockedP = Owner.bBlockPlayers;
	Owner.bBlockActors = false;
	Owner.bBlockPlayers = false;
	if( !Owner.SetLocation(Dest) || !FastTrace(Dest,Owner.Location) )
	{
		Owner.bBlockActors = bBlockedA;
		Owner.bBlockPlayers = bBlockedP;
		return false;
	}
	foreach Owner.TouchingActors(Class'Pawn',P)
	{
		if( P!=Self && P.Health>0 )
		{
			if( IsTeamMate(P) )
			{
				Owner.SetLocation(StartPos);
				Owner.bBlockActors = bBlockedA;
				Owner.bBlockPlayers = bBlockedP;
				return false;
			}
			else if( i<6 )
				Enemies[i++] = P; // Telefrag later.
		}
	}
	Owner.bBlockActors = bBlockedA;
	Owner.bBlockPlayers = bBlockedP;
	for( j=0; j<i; j++ )
		Enemies[j].EncroachedBy(Owner);
	return true;
}
function Toss()
{
	ProjectileFire(ProjectileClass,1000,false);
}

///////////////////////////////////////////////////////
state NormalFire
{
Ignores TargetDestroyed;

	function Fire(float F)
	{
		TryToSwitchToOld();
	}
	function AltFire(float F)
	{
		TryToSwitchToOld();
	}
Begin:
	if( MyTarget==None )
		PlayAnim('Throw');
	else
	{
		Owner.PlaySound(Misc3Sound, SLOT_Misc, Pawn(Owner).SoundDampening);
		MyTarget.MyTranslocator = None;
		MyTarget.Destroy();
		MyTarget = None;
		PlayAnim('Select2',,0.5);
	}
	Sleep(0.01);
	FinishAnim();
	Finish();
}

///////////////////////////////////////////////////////////
state Idle
{
	function AnimEnd()
	{
		PlayIdleAnim();
	}
	function Timer()
	{
		if( MyTarget!=None )
			return;
		if( (Owner.Velocity.X*Owner.Velocity.X+Owner.Velocity.Y*Owner.Velocity.Y)<400 )
		{
			if( AnimSequence=='Walk' )
				PlayIdleAnim();
		}
		else if( AnimSequence!='Walk' )
			LoopAnim('Walk',0.06,0.2);
	}

Begin:
	bPointing=False;
	if ( (AmmoType != None) && (AmmoType.AmmoAmount<=0) ) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);	
	PlayIdleAnim();
	SetTimer(0.5,true);
}

function PlayIdleAnim()
{
	local Float decision;

	if( MyTarget!=None )
	{
		if( AnimSequence!='Temp' )
			LoopAnim('Temp',0.1,0.3);
	}
	else if( (Owner.Velocity.X*Owner.Velocity.X+Owner.Velocity.Y*Owner.Velocity.Y)>=400 )
	{
		if( AnimSequence!='Walk' )
			LoopAnim('Walk',0.06,0.2);
	}
	else  
	{
		decision = FRand();
		if ( decision<0.33 && AnimSequence!='Still' ) 
			PlayAnim('Still',0.02);
		else if ( decision<0.66 && AnimSequence!='Rub1' ) 
			PlayAnim('Rub1',0.02);			
		else 
			PlayAnim('Rub2',0.025);	
	}
}

function PlaySelect()
{
	PlayAnim('Select',0.9, 0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc,Pawn(Owner).SoundDampening);		
}

// For use to check whatever this pawn may be telefragged.
function bool IsTeamMate( Pawn TargetPawn )
{
	if( Level.Game.bTeamGame )
		return (Pawn(Owner).GetTeamNum()==TargetPawn.GetTeamNum());
	else if( Level.Game.bDeathMatch )
		return true;
	return (Pawn(Owner).bIsPlayer==TargetPawn.bIsPlayer);
}

function TweenDown()
{
	if( MyTarget!=None )
	{
		Owner.PlaySound(Misc3Sound, SLOT_Misc, Pawn(Owner).SoundDampening);
		MyTarget.MyTranslocator = None;
		MyTarget.Destroy();
		MyTarget = None;
	}
	Super.TweenDown();
}

function RaiseUp(Weapon OldWeapon)
{
	LastUsedWeapon = OldWeapon;
	BringUp();
}
exec function SelectTranslocator()
{
	if( Pawn(Owner).Weapon==None )
	{
		LastUsedWeapon = None;
		Pawn(Owner).Weapon = Self;
		Pawn(Owner).PlayWeaponSwitch(Self);
		BringUp();
	}
	else if( Pawn(Owner).Weapon==Self )
	{
		if( LastUsedWeapon!=None && LastUsedWeapon.Owner==Owner )
		{
			Pawn(Owner).PendingWeapon = LastUsedWeapon;
			PutDown();
		}
	}
	else
	{
		LastUsedWeapon = Pawn(Owner).Weapon;
		Pawn(Owner).PendingWeapon = Self;
		LastUsedWeapon.PutDown();
	}
}

///////////////////////////////////////////////////////////
// AI:

// Bots do not want to use this as their weapon.
function float RateSelf( out int bUseAltMode )
{
	if( MyTarget!=None )
		bUseAltMode = 1;
	else bUseAltMode = 0;
	return 0;
}

function TranslocateTo( vector TargetPos, vector JumpEndSpot )
{
	BotTransTarget = TargetPos;
	BotTransJumpTarget = JumpEndSpot;
	GoToState('BotTranslocate');
}

function float SuggestAttackStyle()
{
	return -0.2;
}
function float SuggestDefenseStyle()
{
	return -0.4;
}

state BotTranslocate
{
Ignores BringUp,PutDown,Fire,AltFire;

	function Tick( float Delta )
	{
		Pawn(Owner).Focus = BotTransTarget;
		Owner.DesiredRotation = rotator(BotTransTarget-Owner.Location);
	}
	function float RateSelf( out int bUseAltMode )
	{
		return 100.f;
	}
	function TranslocateTo( vector TargetPos, vector JumpEndSpot )
	{
		BotTransTarget = TargetPos;
		BotTransJumpTarget = JumpEndSpot;
	}
Begin:
	if( Pawn(Owner).Weapon!=Self )
	{
		if( Pawn(Owner).Weapon==None )
		{
			Pawn(Owner).PlayWeaponSwitch(Self);
			Pawn(Owner).Weapon = Self;
			Sleep(0.2);
		}
		else
		{
			Pawn(Owner).PendingWeapon = Self;
			Pawn(Owner).Weapon.PutDown();
			Sleep(0.5);
			while( Pawn(Owner).Weapon!=Self )
			{
				Pawn(Owner).PendingWeapon = Self;
				if( Pawn(Owner).Weapon!=None )
					Pawn(Owner).Weapon.PutDown();
				else
				{
					Pawn(Owner).PendingWeapon = None;
					Pawn(Owner).PlayWeaponSwitch(Self);
					Pawn(Owner).Weapon = Self;
				}
				Sleep(0.5);
			}
		}
	}
	if( MyTarget!=None )
	{
		MyTarget.MyTranslocator = None;
		MyTarget.Destroy();
		MyTarget = None;
	}
	PlayAnim('Throw');
	FinishAnim();
	if( BotPausingTime>Level.TimeSeconds )
		Sleep(BotPausingTime-Level.TimeSeconds);
	PlayAnim('Fire',0.6);
	FinishAnim();
	GoToState('Idle');
	Pawn(Owner).SwitchToBestWeapon();
}

final function float CalcRequiredZHeight( float DestZ, float StartZ, float GravZ )
{
	local int LCount;

	if( GravZ>=0 )
		GravZ = -100;
	DestZ-=StartZ;
	StartZ = 0;
	while( DestZ>0 && LCount<8000 )
	{
		StartZ+=GravZ*0.05f;
		DestZ+=StartZ*0.05f;
		LCount++;
	}
	return Abs(StartZ);
}

defaultproperties
{
	PickupMessage="You got the Translocator Source Module"
	PlayerViewMesh=Mesh'TeleHand'
	PickupViewMesh=Mesh'TeleportProj'
	ThirdPersonMesh=Mesh'TeleportProj'
	Mesh=Mesh'TeleportProj'
	bNoSmooth=false
	PlayerViewOffset=(X=3,Y=-2.4,Z=-2.4)
	ProjectileClass=Class'UTranslocatorTarget'
	Misc1Sound=Sound'TranslocatorError'
	Misc3Sound=Sound'ReturnTarget'
	InventoryGroup=10
	AutoSwitchPriority=0
	ItemName="Translocator"
	ItemArticle="the"
	DeathMessage="%o was telefragged by %k."
	PickupSound=Sound'WeaponPickup'
	bCanThrow=False
	AmmoName=Class'TeleAmmo'
	PickupAmmoCount=1
}