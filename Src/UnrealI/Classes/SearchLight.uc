//=============================================================================
// SearchLight.
//=============================================================================
class SearchLight extends Flashlight;

#exec Texture Import File=Textures\HD_Icons\I_HD_BigFlash.bmp Name=I_HD_BigFlash Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_BigFlash FILE=Textures\Hud\i_bigf.pcx GROUP="Icons" MIPS=OFF HD=I_HD_BigFlash

#exec MESH IMPORT MESH=BigFlash ANIVFILE=Models\BigFl_a.3d DATAFILE=Models\BigFl_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BigFlash X=0 Y=0 Z=-90 YAW=64
#exec MESH SEQUENCE MESH=BigFlash SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=BigFlash SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JBigFlash1 FILE=Models\BigFlash.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=BigFlash X=0.035 Y=0.035 Z=0.07
#exec MESHMAP SETTEXTURE MESHMAP=BigFlash NUM=1 TEXTURE=JBigFlash1

defaultproperties
{
	PickupMessage="You picked up the Searchlight."
	RespawnTime=300.00
	PickupViewMesh=LodMesh'BigFlash'
	Charge=20000
	Icon=Texture'I_BigFlash'
	Mesh=LodMesh'BigFlash'
	CollisionHeight=12.00
	LightHue=167
	LightRadius=13
	ExpireMessage="SearchLight batteries have died."
}
