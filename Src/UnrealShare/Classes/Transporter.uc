//=============================================================================
// Transporter.
//=============================================================================
class Transporter extends NavigationPoint;

var() Vector Offset;
var bool bHackMode;

function PostBeginPlay()
{
	bHackMode = (string(Outer.Name)~="ExtremeDGen");
}
function Trigger( Actor Other, Pawn EventInstigator )
{
	local PlayerPawn tempPlayer;

	// Move the player instantaneously by the Offset vector

	// Find the players
	foreach AllActors( class 'PlayerPawn', tempPlayer )
	{
		if ( !tempPlayer.SetLocation( tempPlayer.Location + Offset ) )
		{
			// The player could not be moved, probably destination is inside a wall
		}
	}

	Disable( 'Trigger' );
	
	if( bHackMode )
		Level.Game.SetTimer(2,true,'TransportHack',Self);
}
function TransportHack()
{
	local PlayerPawn tempPlayer;
	
	foreach AllActors( class 'PlayerPawn', tempPlayer )
	{
		if ( tempPlayer.Location.X<2942 )
			tempPlayer.SetLocation( tempPlayer.Location + Offset );
	}
}
function Reset()
{
	Enable('Trigger');
	Level.Game.SetTimer(0,false,'TransportHack',Self);
}
function Destroyed()
{
	Level.Game.SetTimer(0,false,'TransportHack',Self);
	Super.Destroyed();
}

simulated function OnMirrorMode()
{
	Offset.Y *= -1;
}

defaultproperties
{
}
