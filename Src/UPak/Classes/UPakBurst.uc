//=============================================================================
// UPakBurst.
//=============================================================================
class UPakBurst expands SpriteBallExplosion;

#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo1.WAV" NAME="Explo1" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo2.WAV" NAME="Explo2" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo3.WAV" NAME="Explo3" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo4.WAV" NAME="Explo4" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo5.WAV" NAME="Explo5" GROUP="Explosions"

var float Count;
var float ShockSize;
var bool bShrinking;
var() float MaxBurstSize;

function MakeSound()
{
	PlaySound(EffectSound1,,7.0);
}

simulated function PostBeginPlay()
{
	MakeSound();
	Texture = SpriteAnim[Rand(5)];
}


simulated function Tick( float DeltaTime )
{
	Count += DeltaTime * 15;
	ShockSize =  Count + 3.5/(ScaleGlow+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if( !bShrinking )
		{
			ScaleGlow = ( ( Lifespan/Default.Lifespan ) * 0.75 );
			AmbientGlow = ScaleGlow * 100;
		}
		if( DrawScale < MaxBurstSize && !bShrinking )
		{
			DrawScale += 0.3;
			if( Fatness < 230 )
				Fatness += 15 + Rand( 15 );
		}
		else 
		{
			bShrinking = True;
			DrawScale += 0.15;
			ScaleGlow -= 0.05;
			if( Fatness > 95 )
				Fatness -= 15;
		}
	}
}
simulated function Timer();

defaultproperties
{
     MaxBurstSize=2.000000
     EffectSound1=Sound'UPak.Explosions.Explo4'
     LifeSpan=1.000000
     DrawType=DT_Mesh
     Texture=None
     Skin=Texture'UPak.burst.Burst2'
     Mesh=LodMesh'UPak.AMAPearl'
     DrawScale=0.500000
     LightEffect=LE_TorchWaver
     LightBrightness=120
}
