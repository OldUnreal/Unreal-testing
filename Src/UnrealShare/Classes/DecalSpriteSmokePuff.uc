//=============================================================================
// Decalspritesmokepuff.
//=============================================================================
class DecalSpriteSmokePuff extends AnimSpriteEffect
	transient;

#exec OBJ LOAD FILE=Textures\Decals\DecalSmoke.utx PACKAGE=Unrealshare.Decalsmoke

var() Texture SSprites[4];
var() float RisingRate;
var() int NumSets;

simulated function BeginPlay()
{
	Velocity = Vect(0,0,1)*RisingRate;
	if ( !Level.bDropDetail )
		Texture = SSPrites[Rand(NumSets)];
}

defaultproperties
{
	NumSets=4
	SSprites(0)=Texture'Unrealshare.Decalsmoke.us1_a00'
	SSprites(1)=Texture'Unrealshare.Decalsmoke.us2_a00'
	SSprites(2)=Texture'Unrealshare.Decalsmoke.us3_a00'
	SSprites(3)=Texture'Unrealshare.Decalsmoke.us8_a00'
	RisingRate=50.000000
	NumFrames=8
	Pause=0.050000
	bNetOptional=True
	Physics=PHYS_Projectile
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.500000
	DrawType=DT_SpriteAnimOnce
	Style=STY_Translucent
	Texture=Texture'Unrealshare.Decalsmoke.us1_a00'
	DrawScale=2.000000
	ScaleGlow=0.400000
	LightType=LT_None
	LightBrightness=10
	LightHue=0
	LightSaturation=255
	LightRadius=7
	bCorona=False
}
