//=============================================================================
// TentacleProjectile.
//=============================================================================
class TentacleProjectile extends Projectile;

#exec MESH IMPORT MESH=TentProjectile ANIVFILE=Models\Tproj_a.3d DATAFILE=Models\Tproj_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TentProjectile X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=TentProjectile SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTentacle1 FILE=Models\Tentacle.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=TentProjectile X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=TentProjectile NUM=1 TEXTURE=JTentacle1

#exec AUDIO IMPORT FILE="Sounds\Tentacle\tensht1.wav" NAME="TentSpawn" GROUP="Tentacle"
#exec AUDIO IMPORT FILE="Sounds\Tentacle\tenimp2.wav" NAME="TentImpact" GROUP="Tentacle"

auto simulated state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local vector momentum;

		if ((Tentacle(Other) == None) && (TentacleProjectile(Other) == None))
		{
			if ( Role == ROLE_Authority )
			{
				momentum = 10000.0 * Normal(Velocity);
				Other.TakeDamage(Damage, instigator, HitLocation, momentum, 'stung');
			}
			Destroy();
		}
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local SmallSpark2 s;
		PlaySound(ImpactSound);
		MakeNoise(1.0);
		s = spawn(class'SmallSpark2',,,HitLocation+HitNormal*5,rotator(HitNormal*2+VRand()));
		s.RemoteRole = ROLE_None;
		destroy();
	}

	function BeginState()
	{
		if ( ScriptedPawn(Instigator) != None )
			Speed = ScriptedPawn(Instigator).ProjectileSpeed;
		Velocity = Vector(Rotation) * speed;
		PlaySound(SpawnSound);
	}

Begin:
	Sleep(7.0); //self destruct after 7.0 seconds
	Explode(Location, vect(0,0,0));

}

defaultproperties
{
	ExplosionDecal=class'Unrealshare.TentacleMark'
	speed=800.000000
	MaxSpeed=800.000000
	Damage=12.000000
	SpawnSound=Sound'UnrealShare.Tentacle.TentSpawn'
	ImpactSound=Sound'UnrealShare.Tentacle.TentImpact'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=15.000000
	AnimRate=1.000000
	Mesh=LodMesh'UnrealShare.TentProjectile'
	AmbientGlow=255
	bUnlit=True
	Mass=2.000000
}
