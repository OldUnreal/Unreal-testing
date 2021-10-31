//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// TentacleMark added for a TentacleMark decal
// usage:
// if the class uses the explode function (such as Rockets, Dispersionammo)
// add in the selected class
// ExplosionDecal=class'Unrealshare.TentacleMark' into the default properties
// otherwise (Grenades) put in function BlowUp(vector HitLocation)
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'TentacleMark',,,Location, rotator(HitNormal));
//=============================================================================


class TentacleMark expands Scorch;

#exec TEXTURE IMPORT NAME=TentacleProj FILE=Textures\Decals\TentacleProj.pcx LODSET=2
#exec TEXTURE IMPORT NAME=TentacleProj2 FILE=Textures\Decals\TentacleProj2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=TentacleProj3 FILE=Textures\Decals\TentacleProj3.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.33)			Texture = texture'Unrealshare.TentacleProj';
	else if (f<0.66)	Texture = texture'Unrealshare.TentacleProj2';
	else				Texture = texture'Unrealshare.TentacleProj3';
}

defaultproperties
{
	MultiDecalLevel=4
	DrawScale=+0.3
	Texture=texture'Unrealshare.TentacleProj'
}
