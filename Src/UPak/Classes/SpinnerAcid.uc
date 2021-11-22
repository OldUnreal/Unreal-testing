//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// SpinnerAcid added for a SpinnerAcid decal
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'SpinnerAcid',,,Location, rotator(HitNormal));
//=============================================================================
class SpinnerAcid expands EnergyImpact;

#exec TEXTURE IMPORT NAME=SpinnerAcid00 FILE=Textures\Decals\SpinnerAcid00.bmp LODSET=4
#exec TEXTURE IMPORT NAME=SpinnerAcid01 FILE=Textures\Decals\SpinnerAcid01.bmp LODSET=4
#exec TEXTURE IMPORT NAME=SpinnerAcid02 FILE=Textures\Decals\SpinnerAcid02.bmp LODSET=4
#exec TEXTURE IMPORT NAME=SpinnerAcid03 FILE=Textures\Decals\SpinnerAcid03.bmp LODSET=4
#exec TEXTURE IMPORT NAME=SpinnerAcid04 FILE=Textures\Decals\SpinnerAcid04.bmp LODSET=4
#exec TEXTURE IMPORT NAME=SpinnerAcid05 FILE=Textures\Decals\SpinnerAcid05.bmp LODSET=4
var int i;
var() texture DecalAnim[6];

function Timer()
{
	Texture = DecalAnim[i];
	i++;
	if (i<=5)
		SetTimer(1.0,false);
}

defaultproperties
{
	DecalAnim(0)=Texture'SpinnerAcid00'
	DecalAnim(1)=Texture'SpinnerAcid01'
	DecalAnim(2)=Texture'SpinnerAcid02'
	DecalAnim(3)=Texture'SpinnerAcid03'
	DecalAnim(4)=Texture'SpinnerAcid04'
	DecalAnim(5)=Texture'SpinnerAcid05'
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.1
	Texture=texture'SpinnerAcid00'
	Style=STY_Modulated
}
