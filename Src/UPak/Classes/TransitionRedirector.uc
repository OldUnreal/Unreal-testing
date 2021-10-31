//=============================================================================
// TransitionRedirector.
//=============================================================================
class TransitionRedirector extends Info;

var() string URL;
var() bool bFirstTransition;
var() string MapToForce;

function PostBeginPlay()
{
	local PlayerPawn P;
	
	if( Level.NetMode==NM_StandAlone && bFirstTransition )
	{
		MapToForce = "DuskFalls";
		foreach allactors( class'PlayerPawn', P )
			UPakConsole(P.Player.Console).NextMap = "DuskFalls";
	}
	SetTimer ( 0.5, false);
}

function Timer()
{
	if( UPakTransitionInfo(Level.Game)!=None )
		UPakTransitionInfo(Level.Game).AppendURL = URL;
}

defaultproperties
{
}
