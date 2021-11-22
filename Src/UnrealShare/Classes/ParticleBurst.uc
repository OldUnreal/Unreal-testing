//=============================================================================
// ParticleBurst.
//=============================================================================
class ParticleBurst extends Effects
	transient;

#exec MESH IMPORT MESH=PartBurst ANIVFILE=Models\pexpl_a.3d DATAFILE=Models\pexpl_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=PartBurst X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=PartBurst SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=PartBurst SEQ=Explo     STARTFRAME=0   NUMFRAMES=2
#exec MESHMAP SCALE MESHMAP=PartBurst X=0.15 Y=0.15 Z=0.3
#exec TEXTURE IMPORT NAME=T_PBurst FILE=Models\rflare.pcx GROUP=Effects


auto state Explode
{
	simulated function Tick( float DeltaTime )
	{
		ScaleGlow = (Lifespan/Default.Lifespan);
	}

	simulated function BeginState()
	{
		PlayAnim('Explo',0.05);
	}

	simulated function AnimEnd()
	{
		Destroy();
	}
}

defaultproperties
{
	Physics=PHYS_Rotating
	LifeSpan=0.600000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'UnrealShare.Effects.T_PBurst'
	Mesh=Mesh'UnrealShare.PartBurst'
	DrawScale=0.700000
	bParticles=True
	bFixedRotationDir=True
	RotationRate=(Pitch=100,Yaw=100,Roll=-200)
}
