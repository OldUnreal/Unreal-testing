//=============================================================================
// DAmmo2.
//=============================================================================
class DAmmo2 extends DispersionAmmo;

#exec MESH IMPORT MESH=DispM1 ANIVFILE=Models\cros_t_a.3d DATAFILE=Models\cros_t_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DispM1 X=0 Y=-500 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=DispM1 SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=DispM1 SEQ=Still  STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=DispM1 X=0.09 Y=0.15 Z=0.08
#exec  OBJ LOAD FILE=Textures\fireeffect1.utx PACKAGE=UnrealShare.Effect1
#exec MESHMAP SETTEXTURE MESHMAP=DispM1 NUM=0 TEXTURE=UnrealShare.Effect1.FireEffect1e
#exec MESHMAP SETTEXTURE MESHMAP=DispM1 NUM=1 TEXTURE=UnrealShare.Effect1.FireEffect1d

#exec TEXTURE IMPORT NAME=PalYellow FILE=Textures\expyello.pcx GROUP=Effects

defaultproperties
{
	ExplosionDecal=class'BoltscorchY'
	ExpType=Texture'dseY_A00'
	ExpSkin=Texture'PalYellow'
	ParticleType=Class'Spark32'
	SparkModifier=1.500000
	Damage=25.000000
	Mesh=Mesh'DispM1'
	LightBrightness=155
	LightHue=42
	LightSaturation=72
}
