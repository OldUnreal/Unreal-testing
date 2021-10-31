//=============================================================================
// Lightpock.
//=============================================================================
class LPock expands Scorch;

#exec TEXTURE IMPORT NAME=lpock0_t FILE=Textures\Decals\lpock0_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=lpock1_t FILE=Textures\Decals\lpock1_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=lpock2_t FILE=Textures\Decals\lpock2_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=lpock3_t FILE=Textures\Decals\lpock4_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=lpock4_t FILE=Textures\Decals\lpock5_t.pcx LODSET=2

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
	PockTex(0)=Texture'Unrealshare.lpock0_t'
	PockTex(1)=Texture'Unrealshare.lpock1_t'
	PockTex(2)=Texture'Unrealshare.lpock2_t'
	PockTex(3)=Texture'Unrealshare.lpock3_t'
	PockTex(4)=Texture'Unrealshare.lpock4_t'
	bHighDetail=True
	DrawScale=0.100000
}
