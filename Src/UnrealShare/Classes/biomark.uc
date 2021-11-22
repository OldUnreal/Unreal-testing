//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BioMark added for a small biogel decal when using GESBioRifle.
// usage: add in the selected class
// in simulated function HitWall
// if ( Level.NetMode != NM_DedicatedServer )
//		spawn(class'BioMark',,,Location, rotator(SurfaceNormal));
//=============================================================================

class BioMark expands Scorch;

#exec TEXTURE IMPORT NAME=biosplat FILE=Textures\Decals\goo_splat_s.pcx LODSET=2
#exec TEXTURE IMPORT NAME=biosplat2 FILE=Textures\Decals\goo_splat2_s.pcx LODSET=2

simulated function BeginPlay()
{
	if ( !Level.bDropDetail && (FRand() < 0.5) )
		Texture = texture'Unrealshare.biosplat2';
	Super.BeginPlay();
}

defaultproperties
{
	MultiDecalLevel=2
	DrawScale=+0.65
	Texture=texture'Unrealshare.biosplat'
}
