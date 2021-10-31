//=============================================================================
// Shield.
//=============================================================================
class Shield extends Effects
	transient;

#exec MESH IMPORT MESH=ShieldEffect ANIVFILE=Models\shield_a.3d DATAFILE=Models\shield_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ShieldEffect X=0 Y=780 Z=0 YAW=-64 ROLL=128
#exec MESH SEQUENCE MESH=ShieldEffect SEQ=All  STARTFRAME=0  NUMFRAMES=11
#exec MESH SEQUENCE MESH=ShieldEffect  SEQ=Burst  STARTFRAME=0  NUMFRAMES=11
//#exec TEXTURE IMPORT NAME=Ashield1 FILE=Models\shield.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=ShieldEffect X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=ShieldEffect NUM=1 TEXTURE=DefaultTexture

auto state Explode
{
	function Tick( float DeltaTime )
	{
		LightBrightness = Max( LightBrightness - 250*DeltaTime, 0 );
		SetLocation(Owner.Location);
	}
Begin:
	PlayAnim( 'Burst', 1.5 );
	PlaySound (EffectSound1);
	MakeNoise(1.0);
	FinishAnim();
	Destroy();
}
defaultproperties
{
	DrawType=DT_Mesh
	Mesh=ShieldEffect
	AmbientGlow=128
	bUnlit=True
	bMeshCurvy=False
	LightType=LT_Steady
	LightBrightness=114
	LightHue=147
	LightSaturation=182
	LightRadius=12
	Physics=PHYS_None
	bNetTemporary=false
}
