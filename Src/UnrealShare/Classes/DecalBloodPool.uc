class DecalBloodPool expands Scorch;

#exec TEXTURE IMPORT NAME=BloodPool6 FILE=Textures\Decals\BSplat1-S.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodPool7 FILE=Textures\Decals\BSplat5-S.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodPool8 FILE=Textures\Decals\BSplat2-S.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodPool9 FILE=Textures\Decals\Spatter2.pcx LODSET=2

var texture Splats[5];

simulated function BeginPlay()
{
	if ( class'GameInfo'.Default.bLowGore )
	{
		destroy();
		return;
	}

	if ( Level.bDropDetail )
		Texture = splats[2 + Rand(3)];
	else
		Texture = splats[Rand(5)];;
}

defaultproperties
{
	splats(0)=texture'Unrealshare.BloodPool6'
	splats(1)=texture'Unrealshare.BloodPool8'
	splats(2)=texture'Unrealshare.BloodPool9'
	splats(3)=texture'Unrealshare.BloodPool7'
	splats(4)=texture'Unrealshare.BloodSplat4'
	MultiDecalLevel=4
	DrawScale=+0.75
	Texture=texture'Unrealshare.BloodSplat1'
	RemoteRole=ROLE_None
}
