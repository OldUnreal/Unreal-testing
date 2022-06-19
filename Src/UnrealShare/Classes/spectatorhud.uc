//=============================================================================
// SpectatorHud.
//=============================================================================
class SpectatorHud extends UnrealHUD
	NoUserCreate;

simulated function PostRender( canvas Canvas )
{
	local float StartX;

	HUDSetup(canvas);

	if ( PlayerPawn(Owner) != None )
	{
		if ( PlayerPawn(Owner).bShowMenu  )
		{
			DisplayMenu(Canvas);
			return;
		}
		if ( PlayerPawn(Owner).bShowScores )
		{
			if ( (PlayerPawn(Owner).Scoring == None) && (PlayerPawn(Owner).ScoringType != None) )
				PlayerPawn(Owner).Scoring = Spawn(PlayerPawn(Owner).ScoringType, PlayerPawn(Owner));
			if ( PlayerPawn(Owner).Scoring != None )
			{
				PlayerPawn(Owner).Scoring.ShowScores(Canvas);
				return;
			}
		}
		else if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds )
			DisplayProgressMessage(Canvas);
	}
	if (Canvas.ClipY<290) Return;

	Canvas.bNoSmooth = false;
	Canvas.Style = ERenderStyle.STY_Translucent;
	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.SetPos(StartX,Canvas.ClipY-58);
	Canvas.DrawTile( Texture'MenuBarrier', 256, 64, 0, 0, 256, 64 );
	Canvas.Style = ERenderStyle.STY_Normal;
	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.SetPos(StartX,Canvas.ClipY-52);
	Canvas.DrawIcon(texture'Logo2', 1.0);
}

defaultproperties
{
}
