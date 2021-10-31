//=============================================================================
// Heavypock.
//=============================================================================
class HPock expands Scorch;

#exec TEXTURE IMPORT NAME=hpock0_t FILE=Textures\Decals\hpock0_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=hpock1_t FILE=Textures\Decals\hpock1_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=hpock2_t FILE=Textures\Decals\hpock2_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=hpock3_t FILE=Textures\Decals\hpock4_t.pcx LODSET=2
#exec TEXTURE IMPORT NAME=hpock4_t FILE=Textures\Decals\hpock5_t.pcx LODSET=2

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
	PockTex(0)=Texture'Unrealshare.hpock0_t'
	PockTex(1)=Texture'Unrealshare.hpock1_t'
	PockTex(2)=Texture'Unrealshare.hpock2_t'
	PockTex(3)=Texture'Unrealshare.hpock3_t'
	PockTex(4)=Texture'Unrealshare.hpock4_t'
	bHighDetail=True
	DrawScale=0.190000
}
