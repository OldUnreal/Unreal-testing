//=============================================================================
// EnergyBolt.
//=============================================================================
class EnergyBolt extends Projectile;

#exec AUDIO IMPORT FILE="Sounds\EnergyBolt.wav" NAME="EnergyBolt"

#exec MESH IMPORT MESH=bolt1 ANIVFILE=..\UnrealShare\Models\bolt1_a.3d DATAFILE=..\UnrealShare\Models\bolt1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=bolt1 X=0 Y=0 Z=-0 YAW=64
#exec MESH SEQUENCE MESH=bolt1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=bolt1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jmisc1 FILE=..\UnrealShare\Models\misc.pcx
#exec MESHMAP SCALE MESHMAP=bolt1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=bolt1 NUM=1 TEXTURE=Jmisc1



function PostBeginPlay()
{
	Super.PostBeginPlay();
	Acceleration = vect(0,0,0);
	Velocity = Vector(Rotation) * 600.0;
	PlaySound(SpawnSound,SLOT_None,4.0);
	SetLocation( Location + vect(0,0,25) );
}

function Explode(vector HitLocation, vector HitNormal)
{
	local SpriteSmokePuff s;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		s = spawn(class'SpriteSmokePuff',,,HitLocation);
		s.RemoteRole = ROLE_None;
	}
	PlaySound(ImpactSound);
	destroy();
}

/////////////////////////////////////////////////////
auto state Flying
{
	function processTouch (Actor Other, vector HitLocation)
	{
		local int hitdamage;
		//log(Other.Class$" touched missile");

		if ( Other != instigator )
		{
			hitdamage = 10;
			Other.TakeDamage(hitdamage, instigator,Other.Location,
							 (1500.0 * float(hitdamage) * Normal(Velocity)), 'zapped' );
			Explode(Location, vect(0,0,0));
		}
	}

Begin:
	Sleep(7.0);
	Explode(Location, vect(0,0,0));
}

defaultproperties
{
	ExplosionDecal=class'Unrealshare.KraalScorchRed'
			SpawnSound=Sound'UnrealI.EnergyBolt'
			MaxSpeed=+01000.000000
			DrawType=DT_Mesh
			Mesh=bolt1
			AmbientGlow=67
			bUnlit=True
			bMeshCurvy=False
			CollisionRadius=+00000.000000
			CollisionHeight=+00000.000000
			LightType=LT_Steady
			LightRadius=9
			}
