//=============================================================================
// MarineJungle.
//=============================================================================
class MarineJungle expands SpaceMarine;

#exec TEXTURE IMPORT NAME=Jmarine3 FILE=MODELS\MARINE\smjungv2-3.PCX GROUP=Skins FLAGS=2 // SMsnow1
#exec TEXTURE IMPORT NAME=Jmarine4 FILE=MODELS\MARINE\smjungv2x11.PCX GROUP=Skins // SMsnowx2

defaultproperties
{
	Health=90
	Skill=0.001000
	MultiSkins(1)=Texture'Jmarine3'
	MultiSkins(2)=Texture'Jmarine4'
}
