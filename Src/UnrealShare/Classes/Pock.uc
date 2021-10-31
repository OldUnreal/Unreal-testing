//=============================================================================
// pock.
//=============================================================================
class Pock expands Scorch;

#exec TEXTURE IMPORT NAME=pock0_t FILE=Textures\Decals\pock0_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=pock1_t FILE=Textures\Decals\pock1_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=pock2_t FILE=Textures\Decals\pock2_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=pock3_t FILE=Textures\Decals\pock4_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=pock4_t FILE=Textures\Decals\pock5_t.pcx LODSET=2

var() texture PockTex[5];

simulated function PostBeginPlay()
{
	if ( Level.bDropDetail )
		Texture = PockTex[0];
	else
		Texture = PockTex[Rand(5)];

	Super.PostBeginPlay();
}

simulated function AttachToSurface()
{
	bAttached = AttachDecal(100, vect(0,0,1)) != None;
}

defaultproperties
{
	bImportant=false
	MultiDecalLevel=0
	PockTex(0)=Texture'Unrealshare.pock0_t'
	PockTex(1)=Texture'Unrealshare.pock1_t'
	PockTex(2)=Texture'Unrealshare.pock2_t'
	PockTex(3)=Texture'Unrealshare.pock3_t'
	PockTex(4)=Texture'Unrealshare.pock4_t'
	bHighDetail=True
	DrawScale=0.150000
}
