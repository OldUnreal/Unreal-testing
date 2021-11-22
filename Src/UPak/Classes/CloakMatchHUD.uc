//=============================================================================
// CloakMatchHUD.
//=============================================================================
class CloakMatchHUD expands UPakHUD;

var nowarn Pawn Target;
var int Incrementer;
var int BotCount;

function PostRender( canvas Canvas )
{	
	local float YL, DistanceToTarget;

	if ( Level.bHighDetailMode )
		Canvas.Style = ERenderStyle.STY_Translucent;
	else Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(0, 80 );

	if( Target != none && Target != PlayerPawn( Owner ) )
	{
		Canvas.DrawColor.R = 100;
		CAnvas.DrawColor.B = 100;
		Canvas.DrawColor.G = 255;
		if ( Level.bHighDetailMode )
			Canvas.Style = ERenderStyle.STY_Translucent;
		else Canvas.Style = ERenderStyle.STY_Normal;

		Canvas.SetPos( 0.0, 80 + Incrementer * ( YL * 5 ) );
		Canvas.Font = font'Axaxax';	
		Canvas.SetPos(0.0, 80 + Incrementer * ( YL * 5 ) );
		if( Target.IsA( 'PlayerPawn' ) )
		{
			Canvas.DrawText( "Target: ", false );
			Canvas.Font = font'Axaxax';
			Canvas.SetPos( 60.0, 80 + Incrementer * ( YL * 5 ) );
			Canvas.DrawText( PlayerPawn( Target ).PlayerReplicationInfo.PlayerName, false );
		}
		else
		{
			Canvas.DrawText( "Target: ", false );
			Canvas.Font = font'Axaxax';
			Canvas.SetPos( 60.0, 80 + Incrementer * ( YL * 5 ) );
			Canvas.DrawText( Bots( Target ).PlayerReplicationInfo.PlayerName, false );
		}
		Canvas.SetPos(0.0, 94 + Incrementer * ( YL * 5 ) );

		DistanceToTarget = VSize( Target.Location - PlayerPawn( Owner ).Location )/16;
		
		if( DistanceToTarget < 150 )
		{
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.B = 90;
			Canvas.DrawColor.G = 0;
		}
		else
		{
			Canvas.DrawColor.R = 100;
			CAnvas.DrawColor.B = 100;
			Canvas.DrawColor.G = 255;
		}
		Canvas.DrawText( "Distance: ", false );
		Canvas.SetPos( 60.0, 94 + Incrementer * ( YL * 5 ) );
		Canvas.DrawText( DistanceToTarget$" feet", false );
	}
	
	else if( Target == PlayerPawn( Owner ) )
	{
		Canvas.SetPos( 0.0, 80 + Incrementer * ( YL * 5 ) );
		Canvas.Font = font'AxAxAx';
		Canvas.DrawColor.R = 100;
		Canvas.DrawColor.B = 100;
		Canvas.DrawColor.G = 255;
		Canvas.DrawText( "You are cloaked.", false );
	}
	else
	{
		Canvas.SetPos( 0.0, 80 + Incrementer * ( YL * 5 ) );
		Canvas.Font = font'Axaxax';
		Canvas.DrawColor.R = 190;
		Canvas.DrawColor.B = 100;
		Canvas.DrawColor.G = 30;
		Canvas.DrawText( "No one is cloaked. Kill someone." );
	}
	Super.PostRender( Canvas );
}

defaultproperties
{
     MainMenuType=Class'UPak.UPakMainMenu'
}
