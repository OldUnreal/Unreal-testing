//=============================================================================
// PeaceMaker.
//=============================================================================
class PeaceMaker extends Weapon;

#exec MESH IMPORT MESH=peacehand ANIVFILE=Models\phand_a.3D DATAFILE=Models\phand_d.3D X=0 Y=0 Z=0 unmirror=1
#exec MESH ORIGIN MESH=peacehand X=0 Y=0 Z=0 YAW=-64 ROLL=0 PITCH=0
#exec MESH SEQUENCE MESH=peacehand SEQ=All       STARTFRAME=0   NUMFRAMES=54
#exec MESH SEQUENCE MESH=peacehand SEQ=Select    STARTFRAME=0   NUMFRAMES=20
#exec MESH SEQUENCE MESH=peacehand SEQ=Still     STARTFRAME=20  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=Down      STARTFRAME=21  NUMFRAMES=12
#exec MESH SEQUENCE MESH=peacehand SEQ=Throw     STARTFRAME=33  NUMFRAMES=10
#exec MESH SEQUENCE MESH=peacehand SEQ=CountZero     STARTFRAME=43  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountOne     STARTFRAME=44  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountTwo     STARTFRAME=45  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountThree     STARTFRAME=46  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountFour     STARTFRAME=47  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountFive     STARTFRAME=48  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountSix     STARTFRAME=49  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountSeven     STARTFRAME=50  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountEight     STARTFRAME=51  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=CountNine     STARTFRAME=52  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacehand SEQ=Count     STARTFRAME=43  NUMFRAMES=11
#exec TEXTURE IMPORT NAME=Jpeacehand1 FILE=Models\peaceh.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=peacehand  X=0.005 Y=0.005 Z=0.01
#exec MESHMAP SETTEXTURE MESHMAP=peacehand NUM=1 TEXTURE=Jpeacehand1
#exec MESHMAP SETTEXTURE MESHMAP=peacehand NUM=0 TEXTURE=Jpeacehand1

#exec MESH IMPORT MESH=peacepick ANIVFILE=Models\peacpi_a.3D DATAFILE=Models\phand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=peacepick X=0 Y=0 Z=10 YAW=-64 ROLL=0 PITCH=0
#exec MESH SEQUENCE MESH=peacepick SEQ=All       STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=peacepick SEQ=Still     STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jpeacehand1 FILE=Models\peaceh.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=peacepick  X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=peacepick NUM=1 TEXTURE=Jpeacehand1
#exec MESHMAP SETTEXTURE MESHMAP=peacepick NUM=0 TEXTURE=Jpeacehand1

var float ChargeTime;
var() name CountFrames[10];
var byte Counter;
var bool bIsRocketMode;

function Fire( float Value )
{
	bPointing=True;
 	GotoState('NormalFire');
}

function AltFire( float Value )
{
	bPointing=True;
	GoToState('AltFiring');
}

function ThrowBarrel(bool bRocketMode)
{
	local vector X,Y,Z;
	local PeaceBarrel NewBarrel;
	local Pawn OwnerPawn;
	local rotator Aim;

	OwnerPawn = Pawn(Owner);
	//Owner.PlaySound(Misc1Sound, SLOT_Misc, OwnerPawn.SoundDampening);	// Tossing barrel
	GetAxes(OwnerPawn.Rotation,X,Y,Z);
	Aim = OwnerPawn.AdjustAim(class'PeaceBarrel'.Default.Speed,(Owner.Location + 30*X - 9*Y - Z*20),25,true,false);
	GetAxes(Aim,X,Y,Z);
	NewBarrel = Spawn(class'PeaceBarrel',, '', Owner.Location + 30 * X - 9 * Y - Z * 20, Aim);
	NewBarrel.bFireType = bRocketMode;
	NewBarrel.CountDown = ChargeTime;
	OwnerPawn.DeleteInventory(self);
	OwnerPawn.SwitchToBestWeapon();
	Destroy();
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Tick( float DeltaTime )
	{
		ChargeTime += DeltaTime;
		if( (pawn(Owner).bFire==0)) 
		{
			bIsRocketMode = true;
			GoToState('TossPeaceMaker');
		}
	}

Begin:
	ChargeTime = 0.0;
	TweenAnim(CountFrames[0],0.0);
	Sleep(0.75);
	for( Counter=1; Counter<=9; Counter++ )
	{
		TweenAnim(CountFrames[Counter],0.0);
		Sleep(1);
	}
	bIsRocketMode = true;
	GoToState('TossPeaceMaker');
}

////////////////////////////////////////////////////////
state AltFiring
{
	function Tick( float DeltaTime )
	{
		ChargeTime += DeltaTime;
		if( (pawn(Owner).bAltFire==0)) 
		{
			bIsRocketMode = false;
			GoToState('TossPeaceMaker');
		}
	}

Begin:
	ChargeTime = 0.0;
	TweenAnim(CountFrames[0],0.0);
	Sleep(0.75);
	for( Counter=1; Counter<=9; Counter++ )
	{
		TweenAnim(CountFrames[Counter],0.0);
		Sleep(1);
	}
	bIsRocketMode = false;
	GoToState('TossPeaceMaker');
}

///////////////////////////////////////////////////////////
state TossPeaceMaker
{
Ignores Fire,AltFire,PutDown;

Begin:
	PlayAnim('Throw',0.5);
	FinishAnim();
	ThrowBarrel(bIsRocketMode);
}

///////////////////////////////////////////////////////////
function PlayIdleAnim()
{
	PlayAnim('Still');
}


defaultproperties
{
	PickupMessage="You got the Peacemaker"
	PlayerViewMesh=Mesh'peacehand'
	PickupViewMesh=Mesh'peacepick'
	ThirdPersonMesh=Mesh'peacepick'
	Mesh=Mesh'peacepick'
	bNoSmooth=false
	PlayerViewOffset=(X=3,Y=-1.5,Z=-1.5)
	CountFrames(0)="CountZero"
	CountFrames(1)="CountOne"
	CountFrames(2)="CountTwo"
	CountFrames(3)="CountThree"
	CountFrames(4)="CountFour"
	CountFrames(5)="CountFive"
	CountFrames(6)="CountSix"
	CountFrames(7)="CountSeven"
	CountFrames(8)="CountEight"
	CountFrames(9)="CountNine"
	InventoryGroup=5
	AutoSwitchPriority=5
	PickupSound=Sound'WeaponPickup'
	AmmoName=Class'PeaceAmmo'
	PickupAmmoCount=1
}