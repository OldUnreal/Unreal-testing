//=============================================================================
// CARBulletExplosion.uc
// $Author: Deb $
// $Revision: 1 $
//=============================================================================
class CARBulletExplosion expands SpriteBallExplosion;

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_Client )
	{
		MakeSound();
	}
	Texture = SpriteAnim[Rand(5)];	
	if ( Level.NetMode == NM_Standalone ) 
	Super.PostBeginPlay();		
}

defaultproperties
{
     Pause=0.020000
     DrawScale=1.550000
}
