//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// DirectionalBlast added for a DirectionalBlast decal when using FlakShell
// usage example in FlakShell.uc
// "var vector initialDir;" is needed
// and check:
// simulated function PostBeginPlay()
// function Landed( vector HitNormal )
// simulated function HitWall (vector HitNormal, actor Wall)
// simulated function Timer()
//=============================================================================

class DirectionalBlast expands Scorch;

#exec TEXTURE IMPORT NAME=directionalblast FILE=Textures\Decals\Blast2-S.pcx LODSET=2

simulated event BeginPlay()
{
	SetTimer(1.0, false);
}

simulated function AttachToSurface()
{
}

simulated function DirectionalAttach(vector Dir, vector Norm)
{
	SetRotation(rotator(Norm));
	if ( AttachDecal(100, Dir) == None )	// trace 100 units ahead in direction of current rotation
	{
		//Log("Couldn't set decal to surface");
		Destroy();
	}
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=+1.3
	Texture=texture'Unrealshare.directionalblast'
}
