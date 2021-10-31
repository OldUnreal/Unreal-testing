//=============================================================================
// SpriteLightning.
//=============================================================================
class SpriteLightning extends AnimSpriteEffect
	transient;

#exec OBJ LOAD FILE=Textures\fireeffect17.utx PACKAGE=UnrealShare.Effect17

#exec AUDIO IMPORT FILE="Sounds\General\thundr2.wav" NAME="Lightning" GROUP="General"

var rotator NormUp;
var() float Damage;
var() float radius;
var() float MomentumTransfer;

simulated function PostBeginPlay()
{
	AnimTime=0.0;
	PlaySound (EffectSound1);
	MakeNoise(1.0);
	Super.PostBeginPlay();
}

defaultproperties
{
	Damage=+00040.000000
	Radius=+00120.000000
	MomentumTransfer=+01400.000000
	EffectSound1=UnrealShare.Lightning
	Skin=UnrealShare.Effect17.fireeffect17
	DrawScale=+00000.200000
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=151
	LightRadius=8
	LifeSpan=+00001.000000
	RemoteRole=ROLE_SimulatedProxy
}
