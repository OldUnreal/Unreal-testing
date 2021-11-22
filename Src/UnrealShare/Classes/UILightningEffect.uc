//=============================================================================
// Lightning.
//=============================================================================
// by Raven
class UILightningEffect extends UIWeather_Lightning;

#exec TEXTURE IMPORT NAME=Lightning FILE="Textures\Icons\Lightning.bmp" GROUP=Icons LODSET=2

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		PlayThunder, OffThunder;
}

simulated function BeginPlay()
{
	LightType = LT_None;
	DrawType = DT_None;
}

simulated function PlayThunder()
{
	LightType=LT_Flicker;
}

simulated function OffThunder()
{
	LightType=LT_None;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy

	Texture=Texture'UnrealShare.Icons.Lightning'
	CollisionRadius=24.000000
	CollisionHeight=24.000000
	LightType=LT_None
	LightBrightness=255
	LightSaturation=255
	LightRadius=255
	LightPeriod=32
	LightCone=128
	VolumeBrightness=64
	bStatic=False
	bStasis=false
	bMovable=True
	bNoDelete=False
	bHidden=false
}
