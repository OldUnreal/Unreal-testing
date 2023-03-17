//=============================================================================
// UPakBurst.
//=============================================================================
class UPakBurst expands SpriteBallExplosion;

#exec TEXTURE IMPORT NAME=PearlGlass01 FILE=MODELS\BURST\PearlGlass01.pcx GROUP=Burst
#exec TEXTURE IMPORT NAME=PearlGlass02 FILE=MODELS\BURST\PearlGlass02.pcx GROUP=Burst
#exec TEXTURE IMPORT NAME=PearlSource01 FILE=MODELS\BURST\PearlSource01.pcx GROUP=Burst
#exec TEXTURE IMPORT NAME=PearlSource02 FILE=MODELS\BURST\PearlSource02.pcx GROUP=Burst
#exec TEXTURE IMPORT NAME=AMApearl01 FILE=MODELS\BURST\AMApearl01.fx GROUP=Burst

#exec MESH IMPORT MESH=AMApearl ANIVFILE=MODELS\BURST\AMApearl_a.3d DATAFILE=MODELS\BURST\AMApearl_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=AMApearl X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=AMApearl SEQ=All      STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=AMApearl MESH=AMApearl
#exec MESHMAP SCALE MESHMAP=AMApearl X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=Burst FILE=MODELS\BURST\burst.pcx GROUP=Burst
#exec TEXTURE IMPORT NAME=Burst2 FILE=MODELS\BURST\burst2.pcx GROUP=Burst

#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo1.WAV" NAME="Explo1" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo2.WAV" NAME="Explo2" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo3.WAV" NAME="Explo3" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo4.WAV" NAME="Explo4" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\Explosions\Explo5.WAV" NAME="Explo5" GROUP="Explosions"

var float Count;
var float ShockSize;
var bool bShrinking;
var float DeltaFatness, FatnessLimit;
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
	local float DeltaT;

	Count += DeltaTime * 15;
	ShockSize =  Count + 3.5/(ScaleGlow+0.05);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if( !bShrinking )
		{
			ScaleGlow = ( ( Lifespan/Default.Lifespan ) * 0.75 );
			AmbientGlow = ScaleGlow * 100;
		}
		DeltaT = DeltaTime * 60.;
		if( DrawScale < MaxBurstSize && !bShrinking )
		{
			DrawScale += 0.3 * DeltaT;
			if (FatnessLimit == 0)
				FatnessLimit = 230 + Rand(26);
			DeltaFatness += (15 + Rand(15)) * DeltaT;
			Fatness = Min(Fatness + int(DeltaFatness), FatnessLimit);
			DeltaFatness -= int(DeltaFatness);
		}
		else
		{
			if (!bShrinking)
			{
				bShrinking = True;
				DeltaFatness = 0;
				FatnessLimit = 95 - Rand(15);
			}
			DrawScale += 0.15 * DeltaT;
			ScaleGlow -= 0.05 * DeltaT;
			DeltaFatness -= 15 * DeltaT;
			Fatness = Max(Fatness + int(DeltaFatness), FatnessLimit);
			DeltaFatness -= int(DeltaFatness);
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
