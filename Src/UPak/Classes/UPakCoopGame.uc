//=============================================================================
// UPakCoopGame : Only use PlayerStart with bCoopStart set.
//=============================================================================

class UPakCoopGame expands CoopGame;

function NavigationPoint FindPlayerStart( byte InTeam, optional string incomingName)
{
	local PlayerStart Dest, Candidate[8], Best;
	local float Score[8], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;

	num = 0;
	//choose candidates
	foreach AllActors( class 'PlayerStart', Dest )
	{
		if ( Dest.bEnabled && (Dest.bSinglePlayerStart || Dest.bCoopStart ) && !Dest.Region.Zone.bWaterZone )
		{
			if (num<4)
				Candidate[num] = Dest;
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = Dest;
			num++;
		}
	}
	if (num == 0) //No enabled start found! ignoring
	{
		foreach AllActors( class 'PlayerStart', Dest )
		{
			if ( (Dest.bSinglePlayerStart || Dest.bCoopStart ) && !Dest.Region.Zone.bWaterZone )
			{
				if (num<4)
					Candidate[num] = Dest;
				else if (Rand(num) < 4)
					Candidate[Rand(4)] = Dest;
				num++;
			}
		}
	}


	if( num > 4 )
		num = 4;
	else if( num == 0 )
		return None;

	//assess candidates
	for( i = 0; i < num; i++ )
		Score[i] = 4000 * FRand(); //randomize

	foreach AllActors( class 'Pawn', OtherPlayer )
	{
		if( OtherPlayer.bIsPlayer )
		{
			for( i = 0; i < num; i++ )
			{
				NextDist = VSize( OtherPlayer.Location - Candidate[i].Location );
				Score[i] += NextDist;
				if( NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight )
					Score[i] -= 1000000.0;
			}
		}
	}

	BestScore = Score[0];
	Best = Candidate[0];
	for( i = 1; i < num; i++ )
	{
		if( Score[i] > BestScore )
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}
	}

	return Best;
}


function AddDefaultInventory(Pawn Player)
{
	super.AddDefaultInventory(Player);
	CheckScubaGear(Player);
}

function CheckScubaGear(Pawn Player)
{
	if (!Player.IsA('Spectator'))
		AddPlayerDefaultPickup(Player, class'UPakScubaGear');
}

defaultproperties
{
}