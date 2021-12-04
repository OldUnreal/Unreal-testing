//=============================================================================
// Cannon.
//=============================================================================
class Cannon extends Decoration;

#exec MESH IMPORT MESH=CannonM ANIVFILE=Models\cannon_a.3d DATAFILE=Models\cannon_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CannonM X=0 Y=270 Z=0 YAW=-64 ROLL=-64
#exec MESH SEQUENCE MESH=CannonM SEQ=All  STARTFRAME=0  NUMFRAMES=20
#exec MESH SEQUENCE MESH=CannonM SEQ=Activate STARTFRAME=0   NUMFRAMES=10
#exec MESH SEQUENCE MESH=CannonM SEQ=Angle0  STARTFRAME=10  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=Angle1  STARTFRAME=11  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=Angle2  STARTFRAME=12  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=Angle3  STARTFRAME=13  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=Angle4  STARTFRAME=14  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=FAngle0  STARTFRAME=15  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=FAngle1  STARTFRAME=16  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=FAngle2  STARTFRAME=17  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=FAngle3  STARTFRAME=18  NUMFRAMES=1
#exec MESH SEQUENCE MESH=CannonM SEQ=FAngle4 STARTFRAME=19  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JCannon1 FILE=Models\cannon.pcx GROUP=Skins DETAIL=Metal
#exec OBJ LOAD FILE=..\UnrealShare\Textures\fireeffect13.utx PACKAGE=UNREALI.Effect13
#exec MESHMAP SCALE MESHMAP=CannonM X=0.2 Y=0.2 Z=0.4
#exec MESHMAP SETTEXTURE MESHMAP=CannonM NUM=0 TEXTURE=UnrealI.Effect13.FireEffect13
#exec MESHMAP SETTEXTURE MESHMAP=CannonM NUM=1 TEXTURE=JCannon1

#exec AUDIO IMPORT FILE="Sounds\Cannon\turshot1.wav" NAME="CannonShot" GROUP="Cannon"
#exec AUDIO IMPORT FILE="Sounds\Cannon\turdrop1.wav" NAME="CannonActivate" GROUP="Cannon"
#exec AUDIO IMPORT FILE="Sounds\Cannon\turExpl.wav" NAME="CannonExplode" GROUP="Cannon"

var() float DeactivateDistance;		// How far away Instigator must be to deactivate Cannon
var() float SampleTime; 			// How often we sample Instigator's location
var() int   TrackingRate;			// How fast Cannon tracks Instigator
var() float Drop;					// How far down to drop spawning of projectile
var() float Health;					// -1 health = undestructable
var() sound FireSound;
var() sound ActivateSound;
var() sound ExplodeSound;
var() class<Projectile> ProjectileClass; // 227j: Type of projectile to fire.
var() int MaxShots;					// 227j: Number of shots this can fire on one trigger event (0 = no limit).
var() float AimError;				// 227j: Aim error of the turret.
var() bool bShootTriggerInstigator;	// If true, trigger instigator will be the target of the turret, if false, the actor that triggered will be the target.
var() bool bIsArmed;				// Turret will animate to be active but wont fire.
var() bool bReTargetOnTrigger;		// 227j: Allow to retarget to new target while already active when retriggering.
var() bool bDeActivateOnUntrigger;	// 227j: Deactivate when untriggered.
var actor cTarget;
var bool bShoot;
var int ShotsFired;
var float InitialHealth;
var actor a;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	InitialHealth = Health;
}
function Shoot() {}   // To resolve error 'virtual function 'shoot' not found'

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	if( Health>=0.f && (Health-=NDamage)<0.f )
	{
		PlaySound(ExplodeSound, SLOT_None,5.0);
		skinnedFrag(class'Fragment1',texture'JCannon1', Momentum,1.0,17);
		Destroy();
	}
}

function DrawEditorSelection( Canvas C )
{
	C.DrawCircle(MakeColor(255,255,0), 0, Location, DeactivateDistance);
}

function Reset()
{
	Health = InitialHealth;
	TweenAnim('Activate',0.1);
	Instigator = None;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if( bShootTriggerInstigator )
	{
		cTarget = EventInstigator;
		Instigator = None;
	}
	else
	{
		cTarget    = Other;
		Instigator = EventInstigator;
	}
	ShotsFired = 0;
	GotoState( 'ActivateCannon');
}

state ActivateCannon
{
	function EndState()
	{
		SetTimer(0, false);
	}
	
	function Reset()
	{
		Global.Reset();
		GoToState('');
	}

	function Trigger( actor Other, pawn EventInstigator )
	{
		if( bReTargetOnTrigger )
		{
			if( bShootTriggerInstigator )
				cTarget = EventInstigator;
			else
			{
				cTarget    = Other;
				Instigator = EventInstigator;
			}
			ShotsFired = 0;
		}
	}
	function UnTrigger( Actor Other, Pawn EventInstigator )
	{
		if( bDeActivateOnUntrigger && (bShootTriggerInstigator ? (cTarget==EventInstigator) : (cTarget==Other)) )
			GoToState('Deactivate');
	}
	
	function Timer()
	{
		local int a;

		if( !cTarget || cTarget.bDeleteMe
			|| (MaxShots>0 && ShotsFired>=MaxShots)
			|| VSizeSq(cTarget.Location - Location) > Square(DeactivateDistance)
			|| (cTarget.bIsPawn && Pawn(cTarget).Health<=0) )
		{
			GoToState('Deactivate');
			return;
		}
		
		DesiredRotation = rotator(cTarget.Location - Location + Vect(0,0,1)*Drop);
		if( bShoot && bIsArmed && DesiredRotation.Pitch<1000 && DesiredRotation.Pitch >= -10000 )
		{
			a = (DesiredRotation.Yaw - Rotation.Yaw) & 65535;
			if( a>32768 )
				a = -(a-65536);
			if( a<1000 )
			{
				Shoot();
				return;
			}
		}

		if (DesiredRotation.Pitch < -6000 ) TweenAnim('Angle4', 0.25);
		else if (DesiredRotation.Pitch < -4000 ) TweenAnim('Angle3', 0.25);
		else if (DesiredRotation.Pitch < -2000 ) TweenAnim('Angle2', 0.25);
		else if (DesiredRotation.Pitch < -500 ) TweenAnim('Angle1', 0.25);
		else TweenAnim('Angle0', 0.25);
		bShoot=True;
		
		bRotateToDesired = True;
		SetTimer(SampleTime,True);
	}

	function Shoot()
	{
		if ( !bIsArmed || DesiredRotation.Pitch < -10000 ) Return;
		PlaySound(FireSound, SLOT_None,5.0);
		if (DesiredRotation.Pitch < -6000 ) PlayAnim('FAngle4',5.0);
		else if (DesiredRotation.Pitch < -4000 ) PlayAnim('FAngle3',5.0);
		else if (DesiredRotation.Pitch < -2000 ) PlayAnim('FAngle2',5.0);
		else if (DesiredRotation.Pitch < -500 ) PlayAnim('FAngle1',5.0);
		else PlayAnim('FAngle0',5.0);
		Spawn(ProjectileClass,,,Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop,(AimError<=0.f) ? DesiredRotation : rotator(vector(DesiredRotation) + VRand()*(AimError*FRand())));
		bShoot=False;
		++ShotsFired;
		SetTimer(SampleTime, True);
	}

Begin:
	PlayAnim('Activate',0.5);
	PlaySound(ActivateSound, SLOT_None, 2.0);
	FinishAnim();
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
	bShoot=True;
}

state DeActivate
{
	function Reset()
	{
		Global.Reset();
		GoToState('');
	}

Begin:
	TweenAnim('Activate',3.0);
	TriggerEvent(Event,Self,Instigator);
}

defaultproperties
{
	bEditorSelectRender=true
	DeactivateDistance=+02000.000000
	SampleTime=+00000.300000
	TrackingRate=10000
	Drop=+00060.000000
	Health=+00100.000000
	FireSound=UnrealI.CannonShot
	ActivateSound=UnrealI.CannonActivate
	ExplodeSound=UnrealI.CannonExplode
	bStatic=False
	DrawType=DT_Mesh
	Mesh=UnrealI.CannonM
	bMeshCurvy=False
	CollisionRadius=+00044.000000
	CollisionHeight=+00044.000000
	bCollideActors=True
	bCollideWorld=True
	bProjTarget=True
	bIsArmed=False
	RotationRate=(Yaw=50000)
	ProjectileClass=class'CannonBolt'
}