//=============================================================================
// Decal support for Unreal by Smirftsch. Partially ported from UT
// KraalScorch added for a BoltScorch decal
// usage:
// if the class uses the explode function (such as Rockets) : add in the selected class
// ExplosionDecal=class'Unrealshare.KraalScorch' into the default properties (DispersionAmmo)
// otherwise put in a function like HitWall:
// if ( Level.NetMode != NM_DedicatedServer )
//		Spawn(class'KraalScorch',,,Location, rotator(HitNormal));
//=============================================================================


class KraalScorch expands EnergyImpact;

#exec TEXTURE IMPORT NAME=boltmark FILE=Textures\Decals\kraalbolt1_g.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmark2 FILE=Textures\Decals\kraalbolt2_g.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmark3 FILE=Textures\Decals\kraalbolt3_g.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmark4 FILE=Textures\Decals\kraalbolt4_g.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmark5 FILE=Textures\Decals\kraalbolt5_g.pcx LODSET=2
#exec TEXTURE IMPORT NAME=boltmark6 FILE=Textures\Decals\kraalbolt6_g.pcx LODSET=2

simulated function BeginPlay()
{
	local float f;
	f = FRand();

	if (f<0.166)		Texture = texture'Unrealshare.boltmark';
	else if (f<0.333)	Texture = texture'Unrealshare.boltmark2';
	else if (f<0.499)	Texture = texture'Unrealshare.boltmark3';
	else if (f<0.666)	Texture = texture'Unrealshare.boltmark4';
	else if (f<0.833)	Texture = texture'Unrealshare.boltmark5';
	else				Texture = texture'Unrealshare.boltmark6';		
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
	Texture=texture'Unrealshare.boltmark'
}
