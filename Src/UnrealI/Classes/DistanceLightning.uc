//=============================================================================
// DistanceLightning.
//=============================================================================
class DistanceLightning extends Light;

simulated function BeginPlay()
{
	Role = ROLE_Authority;
	if ( Level.NetMode!=NM_DedicatedServer )
		SetTimer(5+FRand()*10,False);
	LightType = LT_None;
}

simulated function Timer()
{
	if (LightType == LT_Flicker)
	{
		LightType = LT_None;
		SetTimer(9+FRand()*20,False);
	}
	else
	{
		LightType = LT_Flicker;
		SetTimer(0.4+FRand()*0.05,False);
	}
}

defaultproperties
{
	bStatic=False
	LightType=LT_Flicker
	LightBrightness=255
	LightRadius=56
	LightPeriod=128
	LightPhase=32
	RemoteRole=ROLE_None
}
