//===============================================================================
// Wind
//===============================================================================
// by Raven
class UIWind extends UIWeather;

#exec TEXTURE IMPORT NAME=Wind FILE="Textures\Icons\Wnd.bmp" GROUP=Icons LODSET=2 FLAGS=2

var() float WindTime;
var() float SleepWindTime;
var bool bIsWind;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		bIsWind;
}

function BeginPlay()
{
	SetTimer(5+FRand()*10,False);
	bIsWind=false;
}

function Timer()
{
	local Actor A;
	local UIWindSound WindSound;

	if (bIsWind)
	{
		if (Event != '')
		{
			foreach AllActors( class 'Actor', A, Event )
			A.UnTrigger(self, none);
			foreach AllActors( class 'UIWindSound', WindSound, Event )
			WindSound.GoToState('WindOff');
		}
		bIsWind=false;
		SetTimer(9+FRand()*20+SleepWindTime,False);
	}
	else
	{
		if (Event != '')
		{
			foreach AllActors( class 'Actor', A, Event )
			if (UIWindSound(A) != none) A.Trigger(self, none);
			foreach AllActors( class 'UIWindSound', WindSound, Event )
			WindSound.GoToState('WindOn');
		}
		bIsWind=true;
		SetTimer(0.8+FRand()*0.5+WindTime,False);
	}
}

defaultproperties
{
	Texture=Texture'UnrealShare.Icons.Wind'
	CollisionRadius=24.000000
	CollisionHeight=24.000000
	WindTime=8
	DrawType=DT_Sprite
}
