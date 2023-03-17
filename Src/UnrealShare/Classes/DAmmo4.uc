//=============================================================================
// DAmmo4.
//=============================================================================
class DAmmo4 extends DispersionAmmo;

#exec MESH IMPORT MESH=DispM3 ANIVFILE=Models\cros_t_a.3d DATAFILE=Models\cros_t_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DispM3 X=0 Y=-500 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=DispM3 SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=DispM3 SEQ=Still  STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=DispM3 X=0.09 Y=0.15 Z=0.08
#exec  OBJ LOAD FILE=Textures\fireeffect1.utx PACKAGE=UnrealShare.Effect1
#exec MESHMAP SETTEXTURE MESHMAP=DispM3 NUM=0 TEXTURE=UnrealShare.Effect1.FireEffect1pb
#exec MESHMAP SETTEXTURE MESHMAP=DispM3 NUM=1 TEXTURE=UnrealShare.Effect1.FireEffect1o

#exec TEXTURE IMPORT NAME=PalRed FILE=Textures\expred.pcx GROUP=Effects

defaultproperties
{
	ExplosionDecal=class'BoltscorchO'
	ParticleType=Class'Spark34'
	SparkModifier=2.500000
	ExpType=Texture'DseO_A00'
	ExpSkin=Texture'PalRed'
	Damage=55.000000
	Mesh=Mesh'DispM3'
	LightBrightness=170
	LightHue=30
}
