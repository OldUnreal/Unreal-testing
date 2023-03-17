//=============================================================================
// MarineArctic.
//=============================================================================
class MarineArctic expands SpaceMarine;

#exec TEXTURE IMPORT NAME=Jmarine1 FILE=MODELS\MARINE\marine1.PCX GROUP=Skins FLAGS=2 // SMsnow1
#exec TEXTURE IMPORT NAME=Jmarine2 FILE=MODELS\MARINE\marine2.PCX GROUP=Skins // SMsnowx2

defaultproperties
{
     Health=90
     MultiSkins(1)=Texture'Jmarine1'
     MultiSkins(2)=Texture'Jmarine2'
}
