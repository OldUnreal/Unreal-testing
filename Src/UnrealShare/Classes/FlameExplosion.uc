//=============================================================================
// FlameExplosion.
//=============================================================================
class FlameExplosion extends AnimSpriteEffect
	transient;

#exec TEXTURE IMPORT NAME=ExplosionPal2 FILE=Textures\exppal.pcx GROUP=Effects
#exec OBJ LOAD FILE=Textures\FlameEffect.utx PACKAGE=UnrealShare.FlameEffect

#exec AUDIO IMPORT FILE="Sounds\General\expl04.wav" NAME="Expl04" GROUP="General"

function MakeSound()
{
	PlaySound(EffectSound1,,3.0);
}

simulated function PostBeginPlay()
{
	local Actor a;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if( !Level.bHighDetailMode || Level.bDropDetail )
			Drawscale = 1.4;
		else if (!Region.Zone.bWaterZone)
		{
			a = Spawn(class'ShortSmokeGen');
			if (a!=none)
				a.RemoteRole = ROLE_None;
		}
	}
	if ( Level.NetMode!=NM_Client )
		MakeSound();
}

defaultproperties
{
	NumFrames=8
	Pause=0.050000
	EffectSound1=Sound'UnrealShare.General.Expl04'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.500000
	DrawType=DT_SpriteAnimOnce
	Style=STY_Translucent
	Texture=Texture'UnrealShare.FlameEffect.e_a01'
	Skin=Texture'UnrealShare.Effects.ExplosionPal2'
	DrawScale=2.800000
	LightType=LT_TexturePaletteOnce
	LightEffect=LE_NonIncidence
	LightBrightness=159
	LightHue=32
	LightSaturation=79
	LightRadius=8
	bCorona=False
}
