class BloodSplat expands Scorch;

#exec TEXTURE IMPORT NAME=BloodSplat1 FILE=Textures\Decals\Blood_Splat_1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat2 FILE=Textures\Decals\Blood_Splat_2.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat3 FILE=Textures\Decals\Blood_Splat_3.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat4 FILE=Textures\Decals\BloodSplat4.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat5 FILE=Textures\Decals\Blood_Splat_5.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat6 FILE=Textures\Decals\BSplat1-S.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat7 FILE=Textures\Decals\BloodSplat1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat8 FILE=Textures\Decals\Blood_Splat_1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat9 FILE=Textures\Decals\Spatter1.pcx LODSET=2
#exec TEXTURE IMPORT NAME=BloodSplat10 FILE=Textures\Decals\BloodSplat2.pcx LODSET=2

var texture Splats[10];

simulated function BeginPlay()
{
	if ( class'GameInfo'.Default.bLowGore || (Level.bDropDetail && (FRand() < 0.35)) )
	{
		destroy();
		return;
	}
	if ( Level.bDropDetail )
		Texture = splats[Rand(5)];
	else
		Texture = splats[Rand(10)];
}

defaultproperties
{
	bImportant=false
	splats(0)=texture'Unrealshare.BloodSplat1'
	splats(1)=texture'Unrealshare.BloodSplat2'
	splats(2)=texture'Unrealshare.BloodSplat3'
	splats(3)=texture'Unrealshare.BloodSplat4'
	splats(4)=texture'Unrealshare.BloodSplat5'
	splats(5)=texture'Unrealshare.BloodSplat6'
	splats(6)=texture'Unrealshare.BloodSplat7'
	splats(7)=texture'Unrealshare.BloodSplat8'
	splats(8)=texture'Unrealshare.BloodSplat9'
	splats(9)=texture'Unrealshare.BloodSplat10'
	MultiDecalLevel=0
	DrawScale=+0.35
	Texture=texture'Unrealshare.BloodSplat1'
	RemoteRole=ROLE_None
}
