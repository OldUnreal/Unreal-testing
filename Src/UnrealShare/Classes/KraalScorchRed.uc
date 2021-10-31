//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// KraalScorchRed added for a BoltScorch decal when using DispersionPistol
// usage:
// if the class uses the explode function (such as Rockets) : add in the selected class
// ExplosionDecal=class'Unrealshare.KraalScorchRed' into the default properties (DispersionAmmo)
// otherwise put in a function like HitWall:
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'KraalScorchRed',,,Location, rotator(HitNormal));
//=============================================================================


class KraalScorchRed expands EnergyImpact;

#exec TEXTURE IMPORT NAME=boltmarkr FILE=Textures\Decals\kraalbolt1_r.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmarkr2 FILE=Textures\Decals\kraalbolt2_r.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmarkr3 FILE=Textures\Decals\kraalbolt3_r.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmarkr4 FILE=Textures\Decals\kraalbolt4_r.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmarkr5 FILE=Textures\Decals\kraalbolt5_r.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmarkr6 FILE=Textures\Decals\kraalbolt6_r.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.166)		Texture = texture'Unrealshare.boltmarkr';
	else if (f<0.333)	Texture = texture'Unrealshare.boltmarkr2';
	else if (f<0.499)	Texture = texture'Unrealshare.boltmarkr3';
	else if (f<0.666)	Texture = texture'Unrealshare.boltmarkr4';
	else if (f<0.833)	Texture = texture'Unrealshare.boltmarkr5';
	else				Texture = texture'Unrealshare.boltmarkr6';
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
	DrawScale=0.2
	Texture=texture'Unrealshare.boltmarkr'
}
