//=============================================================================
// FlashLightBeam.
//=============================================================================
class FlashLightBeam extends Light
	NoUserCreate;

function BeginPlay()
{
	DrawType = DT_None;
	SetTimer(1.0,True);
}

function Timer()
{
	MakeNoise(0.3);
}

defaultproperties
{
	bHidden=False
	bStatic=False
	bNoDelete=False
	bMovable=True
	bMeshCurvy=False
	LightEffect=LE_NonIncidence
	LightBrightness=250
	LightHue=32
	LightSaturation=142
	LightRadius=7
	LightPeriod=0
}
