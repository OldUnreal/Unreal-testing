//========================================================
// Foot Decal Base class
//========================================================
class FootDecalBase extends Decal
	Abstract;

var() float FadeTime,LongFadeTime;		//when it should be destroyed
var bool bOnLongTime;

//========================================================
// Timer
//========================================================
simulated function PostBeginPlay()
{
	SetTimer(FadeTime, false);
}

//========================================================
// assign foot type
//========================================================
simulated function AssignFootType( byte PrintIndex, Pawn DecalOwner );

//========================================================
// we need to check when to destroy ourselfs
//========================================================
simulated function Timer()
{
	if( bOnLongTime || !Level.bHighDetailMode || Level.bDropDetail || (Level.TimeSeconds-LastRenderedTime)>5.f )
		Destroy();
	else
	{
		bOnLongTime = true;
		SetTimer(LongFadeTime, false);
	}
}

defaultproperties
{
	Style=STY_Modulated
	FadeTime=10
	LongFadeTime=6
	MultiDecalLevel=3
	DrawScale=0.15
}
