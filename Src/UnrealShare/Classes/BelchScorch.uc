//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// BelchScorch added for a BelchScorch decal
// usage:
// if the class uses the explode function (such as Rockets) : add in the selected class
// ExplosionDecal=class'Unrealshare.BelchScorch' into the default properties (DispersionAmmo)
// otherwise put in a function like HitWall:
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'BelchScorch',,,Location, rotator(HitNormal));
//=============================================================================
class BelchScorch expands EnergyImpact;

#exec TEXTURE IMPORT NAME=belchproj FILE=Textures\Decals\belchproj.pcx LODSET=2
#exec TEXTURE IMPORT NAME=belchproj2 FILE=Textures\Decals\belchproj2.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.5)	Texture = texture'Unrealshare.belchproj';
	else		Texture = texture'Unrealshare.belchproj2';
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
	Texture=texture'Unrealshare.belchproj'
}
