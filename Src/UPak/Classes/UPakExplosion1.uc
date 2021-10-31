//=============================================================================
// UPakExplosion1.
//=============================================================================
class UPakExplosion1 expands SpriteBallExplosion;

var float Count;
var float ShockSize;

#exec OBJ LOAD FILE=UPakExplosion1Textures.u Package=UPak

simulated function Tick( float DeltaTime )
{
	Count += DeltaTime*2.0;
	ShockSize =  Count + 3.5/(ScaleGlow+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan);
		AmbientGlow = ScaleGlow * 255;
		DrawScale = ShockSize;
	}
}

defaultproperties
{
     SpriteAnim(0)=Texture'UPak.e7_a00'
     SpriteAnim(1)=Texture'UPak.e7_a01'
     SpriteAnim(2)=Texture'UPak.e7_a02'
     SpriteAnim(3)=Texture'UPak.e7_a03'
     SpriteAnim(4)=Texture'UPak.e7_a04'
	 SpriteAnim(5)=Texture'UPak.e7_a05'
	 SpriteAnim(6)=Texture'UPak.e7_a06'
	 SpriteAnim(7)=Texture'UPak.e7_a07'
     NumFrames=16
     EffectSound1=None
     LifeSpan=1.150000
     DrawScale=1.000000
     AmbientGlow=255
     bMeshCurvy=True
}
