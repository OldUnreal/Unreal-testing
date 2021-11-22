//=============================================================================
// Bloblet.
// Must tag with same tag as a Blob
//=============================================================================
class Bloblet extends FlockPawn;

#exec MESH IMPORT MESH=MiniBlob ANIVFILE=Models\MiniB_a.3d DATAFILE=Models\MiniB_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=MiniBlob X=0 Y=-100 Z=0 YAW=64 ROll=-64

#exec MESH SEQUENCE MESH=MiniBlob SEQ=All    STARTFRAME=0   NUMFRAMES=75
#exec MESH SEQUENCE MESH=MiniBlob SEQ=Glob1  STARTFRAME=0   NUMFRAMES=10
#exec MESH SEQUENCE MESH=MiniBlob SEQ=Glob2  STARTFRAME=10   NUMFRAMES=10
#exec MESH SEQUENCE MESH=MiniBlob SEQ=Glob3  STARTFRAME=20   NUMFRAMES=15
#exec MESH SEQUENCE MESH=MiniBlob SEQ=GlobProj  STARTFRAME=35   NUMFRAMES=20
#exec MESH SEQUENCE MESH=MiniBlob SEQ=Splat  STARTFRAME=55   NUMFRAMES=20
#exec MESH SEQUENCE MESH=MiniBlob SEQ=Flat   STARTFRAME=62   NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JBlob1 FILE=Models\bloblet.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=MiniBlob X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=MiniBlob NUM=0 TEXTURE=Jblob1

#exec AUDIO IMPORT FILE="Sounds\Blob\death1Bl.wav" NAME="BlobDeath" GROUP="Blob"
#exec AUDIO IMPORT FILE="Sounds\BRifle\GelHit1.wav" NAME="GelHit" GROUP="BioRifle"
#exec AUDIO IMPORT FILE="Sounds\Blob\goop2Bl.wav" NAME="BlobGoop1" GROUP="Blob"
#exec AUDIO IMPORT FILE="Sounds\Blob\goop3Bl.wav" NAME="BlobGoop2" GROUP="Blob"
#exec AUDIO IMPORT FILE="Sounds\Blob\goop4Bl.wav" NAME="BlobGoop3" GROUP="Blob"
#exec AUDIO IMPORT FILE="Sounds\Blob\hit1Bl.wav" NAME="BlobHit" GROUP="Blob"
#exec AUDIO IMPORT FILE="Sounds\Blob\injur1Bl.wav" NAME="BlobInjur" GROUP="Blob"

var ParentBlob ParentBlob;
var vector	Orientation;
var float	LastParentTime;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	DrawScale = 0.8 + 0.4 * FRand();
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	PlaySound(Die);
	SetCollision(false,false, false);
	if ( ParentBlob!=None )
	{
		ParentBlob.shrink(self);
		ParentBlob = None;
	}
	GotoState('DiedState');
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					 Vector momentum, name damageType)
{
	local rotator newRotation;
	local GreenSmokePuff f;

	if (damageType == 'corroded')
		return;
	PlaySound(HitSound1);
	f = spawn(class'GreenSmokePuff',,,Location - Normal(Momentum)*12);
	f.DrawScale = FClamp(0.1 * Damage, 1.0, 4.0);
	SetPhysics(PHYS_Falling);
	newRotation = Rotation;
	newRotation.Roll = 0;
	setRotation(newRotation);
	Super.TakeDamage(Damage,instigatedBy,hitLocation,momentum,damageType);
}

function BaseChange()
{
}

function wakeup()
{
	GotoState('Active');
}

function PreSetMovement()
{
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.7;
}


function Timer()
{
	local bool bHasEnemy;

	bHasEnemy = ((ParentBlob != None) && (ParentBlob.Enemy != None));
	if ( bHasEnemy && (VSize(Location - ParentBlob.Enemy.Location) < ParentBlob.Enemy.CollisionHeight + CollisionRadius) )
	{
		ParentBlob.Enemy.TakeDamage(18 * FRand(), Self, Location, vect(0,0,0), 'corroded');
		PlaySound(sound'BlobHit');
	}

	if ( Physics == PHYS_Spider )
	{
		if ( FRand() < 0.33 )
			PlaySound(sound'BlobGoop1');
		else if ( FRand() < 0.5 )
			PlaySound(sound'BlobGoop2');
		else
			PlaySound(sound'BlobGoop3');
	}
	if ( bHasEnemy )
		SetTimer(0.5 + 0.5 * FRand(), false);
	else
		SetTimer(1 + FRand(), false);
}

function PlayGlob(float rate)
{
	if (FRand() < 0.75)
		LoopAnim('Glob1', rate * 0.7 * FRand());
	else
		LoopAnim('Glob3', rate * (0.5 + 0.5 * FRand()));
}

function string KillMessage(name damageType, pawn Other)
{
	if( ParentBlob!=None )
		return ParentBlob.KillMessage(damageType,Other);
	return Super.KillMessage(damageType,Other);
}

auto state asleep
{
	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		PlayAnim('Splat');
		SetPhysics(PHYS_None);
	}

Begin:
	SetTimer(2 * FRand(), false);
	if (Physics != PHYS_Falling)
		SetPhysics(PHYS_None);
	PlayGlob(0.3);
}

state active
{
	function AnimEnd()
	{
		playGlob(1);
	}

	function Landed(vector HitNormal)
	{
		SetRotation(Rot(0,0,0));
		if ( Velocity.Z > 200 )
		{
			PlayAnim('Splat');
			PlaySound(Land);
		}
		SetPhysics(PHYS_Spider);
	}

begin:
	SetTimer(FRand(), false);
	SetPhysics(PHYS_Spider);
	PlayGlob(1);
	LastParentTime = Level.TimeSeconds;

wander:
	if (ParentBlob == None)
		GotoState('DiedState');
	if ( VSize(Location - ParentBlob.Location) > 120 )
	{
		if ( LastParentTime - Level.TimeSeconds > 20 )
			GotoState('DiedState');
		else
			MoveToward(ParentBlob);
	}
	else
	{
		LastParentTime = Level.TimeSeconds;
		MoveTo(ParentBlob.Location);
	}
	Sleep(0.1);
	Goto('Wander');
}


state fired
{
	function HitWall(vector HitNormal, actor Wall)
	{
		PlaySound(Land);
		GotoState('Active');
	}

	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		GotoState('Active');
	}
}

state DiedState
{
	ignores TakeDamage;

	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		SetRotation(Rot(0,0,0));
		PlayAnim('Splat');
		SetPhysics(PHYS_None);
	}

	function Tick(float DeltaTime)
	{
		DrawScale = DrawScale - 0.06 * DeltaTime;
		if (DrawScale < 0.1)
			Destroy();
	}

Begin:
	SetPhysics(PHYS_Falling);
	PlayAnim('Splat');
	FinishAnim();
	TweenAnim('Flat', 0.2);
}



defaultproperties
{
	GroundSpeed=450.000000
	AccelRate=1200.000000
	JumpZ=-1.000000
	SightRadius=3000.000000
	Health=120
	ReducedDamageType=exploded
	ReducedDamagePct=0.250000
	HitSound1=Sound'UnrealI.Blob.BlobInjur'
	Land=Sound'UnrealShare.BioRifle.GelHit'
	Die=Sound'UnrealI.Blob.BlobDeath'
	Tag=blob1
	DrawType=DT_Mesh
	Texture=Texture'UnrealI.Skins.JBlob1'
	Mesh=LodMesh'UnrealI.MiniBlob'
	bMeshEnviroMap=True
	CollisionRadius=6.000000
	CollisionHeight=6.000000
	bBlockActors=False
	bBlockPlayers=False
	bIsAmbientCreature=False;
	Mass=40.000000
	RotationRate=(Pitch=0,Yaw=0,Roll=0)
}
