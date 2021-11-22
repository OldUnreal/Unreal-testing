//=============================================================================
// BioGel.
//=============================================================================
class BioGel extends Projectile;

#exec MESH IMPORT MESH=BioRGel ANIVFILE=Models\nGel_a.3d DATAFILE=Models\nGel_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BioRGel X=-45 Y=0 Z=0 YAW=0 PITCH=-64 ROLL=0

#exec MESH SEQUENCE MESH=BioRGel SEQ=All     STARTFRAME=0   NUMFRAMES=56
#exec MESH SEQUENCE MESH=BioRGel SEQ=Flying  STARTFRAME=0   NUMFRAMES=13
#exec MESH SEQUENCE MESH=BioRGel SEQ=Still   STARTFRAME=13  NUMFRAMES=1
#exec MESH SEQUENCE MESH=BioRGel SEQ=Hit     STARTFRAME=14  NUMFRAMES=10
#exec MESH SEQUENCE MESH=BioRGel SEQ=Drip    STARTFRAME=24  NUMFRAMES=13
#exec MESH SEQUENCE MESH=BioRGel SEQ=Slide   STARTFRAME=37  NUMFRAMES=7
#exec MESH SEQUENCE MESH=BioRGel SEQ=Shrivel STARTFRAME=44  NUMFRAMES=12

#exec TEXTURE IMPORT NAME=Jflare FILE=Models\flare.pcx
#exec MESHMAP SCALE MESHMAP=BioRGel X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=BioRGel NUM=1 TEXTURE=Jflare

#exec MESH NOTIFY MESH=BioRGel SEQ=Drip TIME=0.6 FUNCTION=DropDrip

#exec AUDIO IMPORT FILE="Sounds\General\explg02.wav" NAME="Explg02" GROUP="General"
#exec AUDIO IMPORT FILE="..\UnrealI\Sounds\BRifle\GelHit1.wav" NAME="GelHit" GROUP="BioRifle"

var vector SurfaceNormal;
var bool bOnGround;
var bool bCheckedSurface;
var int numBio;
var float wallTime;
var float BaseOffset;

function PostBeginPlay()
{
	SetTimer(3.0, false);
	Super.PostbeginPlay();
}

function Timer()
{
	local GreenGelPuff f;

	f = spawn(class'GreenGelPuff',,,Location + SurfaceNormal*8);
	f.DrawScale = DrawScale*2.0;
	f.numBlobs = numBio;
	if ( numBio > 0 )
		f.SurfaceNormal = SurfaceNormal;
	PlaySound (MiscSound,,3.0*DrawScale);
	if ( (Mover(Base) != None) && Mover(Base).bDamageTriggered )
		Base.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');

	HurtRadiusProj(damage * Drawscale, DrawScale * 120, 'corroded', MomentumTransfer * Drawscale, Location);
	Destroy();
}

simulated function SetWall(vector HitNormal, Actor Wall)
{
	SurfaceNormal = HitNormal;
	SetRotation(rotator(HitNormal) + rotang(0,0,180));
	if ( Mover(Wall) != None )
		SetBase(Wall);
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
							  vector momentum, name damageType )
{
	if ( damageType == 'Corroded' )
		numBio = 3;
	GoToState('Exploding');
}

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		if ( Pawn(Other)!=Instigator || bOnGround)
			Global.Timer();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		SetPhysics(PHYS_None);
		MakeNoise(0.3);
		bOnGround = True;
		PlaySound(ImpactSound);
		SetWall(HitNormal, Wall);
		if ( Level.NetMode != NM_DedicatedServer )
			spawn(class'BioMark',,,Location, rotator(SurfaceNormal));
		PlayAnim('Hit');
		GoToState('OnSurface');
	}


	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local waterring w;

		if (!NewZone.bWaterZone) Return;

		if (!bOnGround)
		{
			w = Spawn(class'WaterRing',,,,rotang(90,0,0));
			w.DrawScale = 0.1;
		}
		bOnGround = True;
		Velocity=0.1*Velocity;
	}

	function Timer()
	{
		GotoState('Exploding');
	}

	function BeginState()
	{
		if ( Role == ROLE_Authority )
		{
			Velocity = Vector(Rotation) * Speed;
			Velocity.z += 120;
			if ( Region.zone.bWaterZone )
				Velocity=Velocity*0.7;
		}
		if ( Level.NetMode != NM_DedicatedServer )
			RandSpin(100000);
		LoopAnim('Flying',0.4);
		bOnGround=False;
		PlaySound(SpawnSound);
	}
}

state Exploding
{
	ignores Touch, TakeDamage;

	function BeginState()
	{
		SetTimer(0.1+FRand()*0.2, False);
	}
}

state OnSurface
{
	function ProcessTouch (Actor Other, vector HitLocation)
	{
		GotoState('Exploding');
	}

	simulated function CheckSurface()
	{
		local float DotProduct;

		DotProduct = SurfaceNormal dot vect(0,0,-1);
		If( DotProduct > 0.7 )
		PlayAnim('Drip',0.1);
		else if (DotProduct > -0.5)
			PlayAnim('Slide',0.2);
	}

	function Timer()
	{
		if ( Mover(Base) != None )
		{
			WallTime -= 0.2;
			if ( WallTime < 0.15 )
				Global.Timer();
			else if ( VSize(Location - Base.Location) > BaseOffset + 4 )
				Global.Timer();
		}
		else
			Global.Timer();
	}

	function BeginState()
	{
		wallTime = DrawScale*3+1;

		if ( Mover(Base) != None )
		{
			BaseOffset = VSize(Location - Base.Location);
			SetTimer(0.2, true);
		}
		else
			SetTimer(wallTime, false);
	}

	simulated function AnimEnd()
	{
		if ( !bCheckedSurface && (DrawScale > 1.0) )
			CheckSurface();

		bCheckedSurface = true;
	}
}

defaultproperties
{
	numBio=7
	speed=+00800.000000
	MaxSpeed=+01500.000000
	Damage=+00040.000000
	MomentumTransfer=20000
	ImpactSound=UnrealShare.GelHit
	MiscSound=UnrealShare.Explg02
	Mesh=UnrealShare.BioRGel
	AnimSequence=Flying
	bUnlit=True
	CollisionRadius=+00002.000000
	CollisionHeight=+00002.000000
	bProjTarget=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=70
	LightHue=91
	LightRadius=3
	Physics=PHYS_Falling
	bBounce=True
	Buoyancy=+00170.000000
	LifeSpan=+00012.000000
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=+00006.000000
	bNetTemporary=false
	MyDamageType="Corroded"
	bNetInterpolatePos=true
}