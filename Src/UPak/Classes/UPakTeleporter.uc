//=============================================================================
// UPakTeleporter.
//=============================================================================
class UPakTeleporter expands Teleporter;

//-----------------------------------------------------------------------------
// Teleporter URL can be one of the following forms:
//
// TeleporterName
//		Teleports to a named teleporter in this level.
//		if none, acts only as a teleporter destination
//
// LevelName/TeleporterName
//     Teleports to a different level on this server.
//
// Unreal://Server.domain.com/LevelName/TeleporterName
//     Teleports to a different server on the net.
//
var() string LoadMessage; // Header, big letters.
var() string IntermissionMap;

// Teleporter was touched by an actor.
function Touch( actor Other )
{
	local Teleporter Dest;
	local int i;
	local Actor A;

	if( Level.NetMode!=NM_StandAlone )
	{
		Super.Touch(Other); // In online game, we skip the intermissions.
		Return;
	}
	if ( !bEnabled )
		return;
	if( Other.bCanTeleport && Other.PreTeleport(Self)==false )
	{
		if( (InStr( URL, "/" ) >= 0) || (InStr( URL, "#" ) >= 0) )
		{
			// Teleport to a level on the net.
			if( PlayerPawn(Other) != None )
			{
				if( IntermissionMap != "" )
				{
					PlayerPawn( Other ).bShowMenu = false;
					i = InStr(URL,"?");
					if( i!=-1 )
						URL = Left(URL,i);
					if( PlayerPawn( Other ).IsA( 'UPakPlayer' ))
					{
						Level.Game.SendPlayer(PlayerPawn(Other), IntermissionMap$"?Game=UPak.UPakTransitionInfo?TransURL="$URL);
					}
					else
					{
						PlayerPawn( Other ).ShowMenu();
						PlayerPawn( Other ).bShowMenu = false;
					}					
				}
				else Level.Game.SendPlayer( PlayerPawn( Other ), URL$"?Game=UPak.UPakSinglePlayer" );
			}
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
     LoadMessage="LOADING"
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.BarrelM'
     CollisionHeight=25.000000
}
