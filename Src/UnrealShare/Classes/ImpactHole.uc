//=============================================================================
// pock.
//=============================================================================
class ImpactHole expands Scorch;

#exec TEXTURE IMPORT NAME=impactcrack FILE=Textures\Decals\ImpactMark.pcx LODSET=2

defaultproperties
{
	MultiDecalLevel=2
	Texture=texture'Unrealshare.ImpactCrack'
	bHighDetail=True
	DrawScale=0.400000
}
