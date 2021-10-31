//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// QueenScorch added for a BoltScorch decal when using DispersionPistol
// usage:
// if the class uses the explode function (such as Rockets) : add in the selected class
// ExplosionDecal=class'Unrealshare.QueenScorch' into the default properties (DispersionAmmo)
// otherwise put in a function like HitWall:
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'QueenScorch',,,Location, rotator(HitNormal));
//=============================================================================
class QueenScorch expands EnergyImpact;

#exec TEXTURE IMPORT NAME=queenproj FILE=Textures\Decals\queenproj.pcx LODSET=2
#exec TEXTURE IMPORT NAME=queenproj2 FILE=Textures\Decals\queenproj2.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.5)	Texture = texture'Unrealshare.queenproj';
	else		Texture = texture'Unrealshare.queenproj2';
}

simulated function Timer()
{
	// Check for nearby players, if none then destroy self

	if ( !bAttached )
	{
		Destroy();
		return;
	}

	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
		if ( Level.bDropDetail )
			SetTimer(3, false);
		else
			SetTimer(4, false);
		return;
	}
	Destroy();
}

defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	DrawScale=+0.2
	Texture=texture'Unrealshare.queenproj'
}
