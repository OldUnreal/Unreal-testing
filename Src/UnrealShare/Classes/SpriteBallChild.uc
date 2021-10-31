//=============================================================================
// SpriteBallChild.
//=============================================================================
class SpriteBallChild extends SpriteBallExplosion;

Function PostBeginPlay()
{
	Texture = SpriteAnim[Rand(5)];
	DrawScale = FRand()*2.0+2.0;
}

defaultproperties
{
	bHighDetail=True
	DrawScale=2.500000
	LightType=LT_None
	LightEffect=LE_None
}
