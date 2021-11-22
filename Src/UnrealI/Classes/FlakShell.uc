//=============================================================================
// FlakShell.
//=============================================================================
class FlakShell extends Projectile;

#exec MESH IMPORT MESH=FlakSh ANIVFILE=Models\FlakSh_a.3d DATAFILE=Models\FlakSh_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=FlakSh STRENGTH=0.3
#exec MESH ORIGIN MESH=FlakSh X=0 Y=0 Z=-0 YAW=-64
#exec MESH SEQUENCE MESH=FlakSh SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=FlakSh SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jflakshel1 FILE=..\UnrealShare\Models\FlakShel.pcx
#exec MESHMAP SCALE MESHMAP=FlakSh X=0.12 Y=0.12 Z=0.24
#exec MESHMAP SETTEXTURE MESHMAP=FlakSh NUM=1 TEXTURE=Jflakshel1 TLOD=50

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * Speed;
	Velocity.z += 200;
	if ( Level.bHighDetailMode && !Level.bDropDetail ) 
		SetTimer(0.05,True);
	else SetTimer(0.25,True);
}

function ProcessTouch (Actor Other, vector HitLocation)
{
	if ((Other != instigator) && (FlakShell(Other) == none))
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

simulated function Landed( vector HitNormal )
{
	local DirectionalBlast D;

	if ( EffectIsRelevant(Location) )
	{
		D = Spawn(class'DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(vector(rotation), HitNormal);
	}
	Explode(Location,HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	local DirectionalBlast D;

	if ( EffectIsRelevant(Location) )
	{
		D = Spawn(class'Unrealshare.DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(vector(rotation), HitNormal);
	}
	Super.HitWall(HitNormal, Wall);
}

simulated function Timer()
{
	local SpriteSmokePuff s;
	local bubble1 b;

	if (Level.NetMode!=NM_DedicatedServer)
	{
		if (Region.Zone.bWaterZone)
		{
			b=spawn(class'Bubble1');
			if (b!=none)
			{
				b.DrawScale = FRand()*0.1+0.1;
				b.RemoteRole = ROLE_None;
			}
		}
		else
		{
			s = Spawn(class'SpriteSmokePuff');
			if (s!=none)
				s.RemoteRole = ROLE_None;
		}
	}
}

function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;

	HurtRadiusProj(damage, 150, 'exploded', MomentumTransfer, HitLocation);
	start = Location + 10 * HitNormal;
	if (Region.Zone.bWaterZone)
		Spawn( class'Bubble',,,Start);
	Spawn( class'FlameExplosion',,,Start);
	Spawn( class 'MasterChunk',,,Start);
	Spawn( class 'Chunk2',,, Start);
	Spawn( class 'Chunk3',,, Start);
	Spawn( class 'Chunk4',,, Start);
	Spawn( class 'Chunk1',,, Start);
	Spawn( class 'Chunk2',,, Start);

	Destroy();
}

defaultproperties
{
	speed=1200.000000
	Damage=70.000000
	MomentumTransfer=75000
	MyDamageType=exploded
	bNetTemporary=False
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=6.000000
	Mesh=LodMesh'FlakSh'
	AmbientGlow=67
	bUnlit=True
}
