//=============================================================================
// LesserBurst.
//=============================================================================
class LesserBurst expands UPakBurst;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
		Return;
	Count += DeltaTime * 15;
	ShockSize =  Count + 3.5/(ScaleGlow+0.05);
	ScaleGlow = (Lifespan/Default.Lifespan);
	if( DrawScale < MaxBurstSize && !bShrinking )
	{
		DrawScale += 0.4;
		if( Fatness < 230 )
			Fatness += 5 + Rand( 15 );		
	}
	else if( DrawScale > 0.1 )
	{
		bShrinking = True;
		DrawScale -= 0.01;
		ScaleGlow -= 0.1;
		if( Fatness > 95 )
			Fatness += 5;
	}
}

simulated function Timer();

defaultproperties
{
     MaxBurstSize=2.500000
     LifeSpan=1.290000
     Skin=FireTexture'UnrealShare.Effect1.FireEffect1o'
     DrawScale=0.150000
}
