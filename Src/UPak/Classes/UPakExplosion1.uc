//=============================================================================
// UPakExplosion1.
//=============================================================================
class UPakExplosion1 expands SpriteBallExplosion;

var float Count;
var float ShockSize;

#exec TEXTURE IMPORT NAME=e7_a07 FILE=Textures/e7_a07.pcx
#exec TEXTURE IMPORT NAME=e7_a06 FILE=Textures/e7_a06.pcx NEXT=e7_a07
#exec TEXTURE IMPORT NAME=e7_a05 FILE=Textures/e7_a05.pcx NEXT=e7_a06
#exec TEXTURE IMPORT NAME=e7_a04 FILE=Textures/e7_a04.pcx NEXT=e7_a05
#exec TEXTURE IMPORT NAME=e7_a03 FILE=Textures/e7_a03.pcx NEXT=e7_a04
#exec TEXTURE IMPORT NAME=e7_a02 FILE=Textures/e7_a02.pcx NEXT=e7_a03
#exec TEXTURE IMPORT NAME=e7_a01 FILE=Textures/e7_a01.pcx NEXT=e7_a02
#exec TEXTURE IMPORT NAME=e7_a00 FILE=Textures/e7_a00.pcx NEXT=e7_a01

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
     SpriteAnim(0)=Texture'e7_a00'
     SpriteAnim(1)=Texture'e7_a01'
     SpriteAnim(2)=Texture'e7_a02'
     SpriteAnim(3)=Texture'e7_a03'
     SpriteAnim(4)=Texture'e7_a04'
	 SpriteAnim(5)=Texture'e7_a05'
	 SpriteAnim(6)=Texture'e7_a06'
	 SpriteAnim(7)=Texture'e7_a07'
     NumFrames=16
     EffectSound1=None
     LifeSpan=1.150000
     DrawScale=1.000000
     AmbientGlow=255
     bMeshCurvy=True
}
