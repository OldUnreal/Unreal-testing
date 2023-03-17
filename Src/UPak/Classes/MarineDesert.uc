//=============================================================================
// MarineDesert.
//=============================================================================
class MarineDesert expands SpaceMarine;

#exec TEXTURE IMPORT NAME=Jmarine5 FILE=MODELS\MARINE\smdesert4.PCX GROUP=Skins FLAGS=2 // SMsnow1
#exec TEXTURE IMPORT NAME=Jmarine6 FILE=MODELS\MARINE\smdesertx4.PCX GROUP=Skins // SMsnowx2

defaultproperties
{
	bLeadTarget=True
	Health=90
	MultiSkins(1)=Texture'Jmarine5'
	MultiSkins(2)=Texture'Jmarine6'
}
