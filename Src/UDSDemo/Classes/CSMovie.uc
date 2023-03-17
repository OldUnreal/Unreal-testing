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
	switch( SpawnClass.Name )
	{
	case 'MaleOne':
	case 'UPakMaleOne':
		SpawnClass = class 'CSMaleOne';
		break;
	case 'MaleTwo':
	case 'UPakMaleTwo':
		SpawnClass = class 'CSMaleTwo';
		break;
	case 'MaleThree':
	case 'UPakMaleThree':
		SpawnClass = class 'CSMaleThree';
		break;
	case 'FemaleTwo':
	case 'UPakFemaleTwo':
		SpawnClass = class 'CSFemaleTwo';
		break;
	default:
		SpawnClass = class 'CSFemaleOne';
	}

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
	
    foreach AllActors(class'CS_Action', a)
	{
		a.Trigger(NewPlayer, NewPlayer.Instigator);
		break;
    }
}

//
// Send a player to a URL.
//
function SendPlayer( PlayerPawn aPlayer, string URL )
{
	if( class'CSPlayer'.Static.LevelIsIntro1(Level) )
		URL = "Intro2";
	else if( class'CSPlayer'.Static.LevelIsIntro2(Level) )
		URL = "InterIntro?Game=UPak.UPakTransitionInfo";
	if( Left(URL,5)~="UPack" )
		aPlayer.ClientTravel( URL, TRAVEL_Absolute, false);
	else aPlayer.ClientTravel( URL, TRAVEL_Relative, true );
}

defaultproperties
{
	DefaultPlayerClass=Class'CSFemaleOne'
}
