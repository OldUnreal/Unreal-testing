//=============================================================================
// DAmmo3.
//=============================================================================
class DAmmo3 extends DispersionAmmo;

#exec MESH IMPORT MESH=DispM2 ANIVFILE=Models\cros_t_a.3d DATAFILE=Models\cros_t_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DispM2 X=0 Y=-500 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=DispM2 SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=DispM2 SEQ=Still  STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=DispM2 X=0.09 Y=0.15 Z=0.08
#exec  OBJ LOAD FILE=Textures\fireeffect1.utx PACKAGE=UnrealShare.Effect1
#exec MESHMAP SETTEXTURE MESHMAP=DispM2 NUM=0 TEXTURE=UnrealShare.Effect1.FireEffect1a
#exec MESHMAP SETTEXTURE MESHMAP=DispM2 NUM=1 TEXTURE=UnrealShare.Effect1.FireEffect1

#exec TEXTURE IMPORT NAME=PalGreen FILE=Textures\expgreen.pcx GROUP=Effects

defaultproperties
{
	ExplosionDecal=class'BoltscorchG'
	ParticleType=Class'Spark33'
	SparkModifier=2.000000
	ExpType=Texture'DISE_A00'
	ExpSkin=Texture'PalGreen'
	Damage=40.000000
	Mesh=Mesh'DispM2'
	LightBrightness=150
	LightHue=83
	LightSaturation=50
}
