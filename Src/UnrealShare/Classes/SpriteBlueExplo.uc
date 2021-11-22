//=============================================================================
// SpriteBlueExplo.
//=============================================================================
class SpriteBlueExplo extends SpriteBallExplosion;

#exec OBJ LOAD FILE=Textures\DispExpl.utx PACKAGE=UnrealShare.DispExpl
#exec TEXTURE IMPORT NAME=BluePal FILE=Textures\expal2a.pcx GROUP=Effects

#exec AUDIO IMPORT FILE="Sounds\Dispersion\dpexplo4.wav" NAME="DispEX1" GROUP="General"

simulated function PostBeginPlay()
{
	PlaySound (EffectSound1,,7.0);
	if (Level.bHighDetailMode)	DrawScale = DrawScale * 2.0;
}

defaultproperties
{
	EffectSound1=Sound'UnrealShare.General.DispEX1'
	Texture=Texture'UnrealShare.DispExpl.dseb_A00'
	Skin=Texture'UnrealShare.Effects.BluePal'
	DrawScale=2.700000
	LightRadius=6
}
