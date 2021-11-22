//=============================================================================
// EndGameTeleporter.
//=============================================================================
class EndGameTeleporter expands Teleporter;

// Teleporter was touched by an actor.
function Touch( actor Other )
{
	local Teleporter Dest;
	local int i;
	local Actor A;
	
	if ( !bEnabled )
		return;

	if( Other.bCanTeleport && Other.PreTeleport(Self)==false )
	{
		if( (InStr( URL, "/" ) >= 0) || (InStr( URL, "#" ) >= 0) )
		{
			// Teleport to a level on the net.
			if( PlayerPawn(Other) != None )
				Level.Game.SendPlayer( PlayerPawn(Other), URL$"?Game=UDSDemo.CSMovie");
		}
		else
		{
			// Teleport to a random teleporter in this local level, if more than one pick random.
			foreach AllActors( class 'Teleporter', Dest )
				if( string(Dest.tag)~=URL && Dest!=Self )
					i++;
			i = rand(i);
			foreach AllActors( class 'Teleporter', Dest )
				if( string(Dest.tag)~=URL && Dest!=Self && i-- == 0 )
					break;
			if( Dest != None )
			{
				// Teleport the actor into the other teleporter.
				if ( Other.IsA('Pawn') )
					PlayTeleportEffect( Pawn(Other), false);
				Dest.Accept( Other );
				if( (Event != '') && (Other.IsA('Pawn')) )
					foreach AllActors( class 'Actor', A, Event )
						A.Trigger( Other, Other.Instigator );
			}
			else Pawn(Other).ClientMessage( "Teleport destination not found!" );
		}
	}
}

defaultproperties
{
}
