//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_Movie ]
//
// This class is designed for non-intertactive C/S levels.  Any map of this
// game type will automatically launch a CS_ACTION at startup.  There should
// be EXACTLY ONE CS_Action actor in this case.
//=============================================================================

class CSMovie expands CSSinglePlayer;

var PlayerPawn NewPlayer;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
//log( "SpawnClass.Name="$SpawnClass.Name$" SpawnClass = "$ SpawnClass ); //UG
	if (SpawnClass.Name == 'MaleOne' )
	{
	  SpawnClass = class 'CSMaleOne';
	}
	else if (SpawnClass.Name == 'MaleTwo')   SpawnClass = class 'CSMaleTwo';
	else if (SpawnClass.Name == 'MaleThree') SpawnClass = class 'CSMaleThree';
	else if (SpawnClass.Name == 'FemaleOne' || SpawnClass == class'UnrealSpectator' || SpawnClass == class'DemoRecSpectator' || SpawnClass == class'SkaarjPlayer' )
	{
		SpawnClass = class 'CSFemaleOne';
	}
	else if (SpawnClass.Name == 'FemaleTwo') SpawnClass = class 'CSFemaleTwo';
	else if (SpawnClass.Name == 'UPakMaleOne')   SpawnClass = class 'CSMaleOne';
	else if (SpawnClass.Name == 'UPakMaleTwo')   SpawnClass = class 'CSMaleTwo';
	else if (SpawnClass.Name == 'UPakMaleThree') SpawnClass = class 'CSMaleThree';
	else if (SpawnClass.Name == 'UPakFemaleOne') SpawnClass = class 'CSFemaleOne';
	else if (SpawnClass.Name == 'UPakFemaleTwo') SpawnClass = class 'CSFemaleTwo';
//log( "SpawnClass.Name="$SpawnClass.Name$" SpawnClass = "$SpawnClass ); //UG

    NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
    NewPlayer.ClientAdjustGlow( -1.0, vect( 0, 0, 0 ) );
    NewPlayer.HudType = class'CS_HUD';	
	Spawn( class'CS_ClientFader', NewPlayer,, Location, Rotation );
    SetTimer(0.05,False);
    return NewPlayer;
}

function Timer()
{
    local CS_Action a;
    foreach AllActors(class'CS_Action', a) {
	a.Trigger(NewPlayer, NewPlayer.Instigator);
	break;
    }
}

//
// Send a player to a URL.
//
function SendPlayer( PlayerPawn aPlayer, string URL )
{
	log( "URL: "$URL );
	if( Level.Title != "Intro1" )
	{
		aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
	}
	else
	{
		aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
	}
}

defaultproperties
{
     DefaultPlayerClass=Class'UDSDemo.CSPlayer'
}
