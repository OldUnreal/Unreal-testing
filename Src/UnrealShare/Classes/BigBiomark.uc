//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BigBioMark added for a big biogel decal when using GESBioRifle.
// usage: add in the selected class
// in simulated function HitWall
// if ( Level.NetMode != NM_DedicatedServer )
//		spawn(class'BigBioMark',,,Location, rotator(SurfaceNormal));
//=============================================================================

class BigBioMark expands Scorch;

#exec TEXTURE IMPORT NAME=bigbiosplat FILE=Textures\Decals\goo_splat.pcx LODSET=2
#exec TEXTURE IMPORT NAME=bigbiosplat2 FILE=Textures\Decals\goo_splat2.pcx LODSET=2

simulated function BeginPlay()
{
	if ( !Level.bDropDetail && (FRand() < 0.5) )
		Texture = texture'Unrealshare.bigbiosplat2';
	Super.BeginPlay();
}

defaultproperties
{
	MultiDecalLevel=2
	DrawScale=+0.65
	Texture=texture'Unrealshare.bigbiosplat'
}
