//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BlastMark added for a BlastMark decal when using Rockets and Grenades
// usage:
// if the class uses the explode function (such as Rockets, Dispersionammo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.BallBlastMark' into the default properties
// otherwise (Grenades) put in function BlowUp(vector HitLocation)
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'BallBlastMark',,,Location, rotator(HitNormal));
//=============================================================================


class BallBlastMark expands Scorch;

#exec TEXTURE IMPORT NAME=ballexplosion FILE=Textures\Decals\ballexplosion.pcx LODSET=2
#exec TEXTURE IMPORT NAME=ballexplosion2 FILE=Textures\Decals\ballexplosion2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=ballexplosion3 FILE=Textures\Decals\ballexplosion3.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.33)			Texture = texture'Unrealshare.ballexplosion';
	else if (f<0.66)	Texture = texture'Unrealshare.ballexplosion2';
	else				Texture = texture'Unrealshare.ballexplosion3';
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=+1.0
	Texture=texture'Unrealshare.ballexplosion'
}
