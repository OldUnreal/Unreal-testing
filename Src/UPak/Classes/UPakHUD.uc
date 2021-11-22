//=============================================================================
// UPakHUD.
//=============================================================================
class UPakHUD expands UnrealHUD;

var bool bNoMenu;
var bool bCheck;
var bool bLetterBox;
var bool bNoHUD;
var bool bNoCrosshair;
var bool bHintDisplayed;
var bool bDisplayHint;
var float HintFadeOutTime;

var() localized String MultWeapSlotMsg;

// Press the weapon select button to toggle weapons.


simulated function CreateMenu()
{
	if ( PlayerPawn(Owner).bSpecialMenu && (PlayerPawn(Owner).SpecialMenu != None) && !bNoMenu  )
	{
		MainMenu = Spawn(PlayerPawn(Owner).SpecialMenu, self);
		PlayerPawn(Owner).bSpecialMenu = false;
	}

	if ( MainMenu == None && !bNoMenu )
		MainMenu = Spawn(MainMenuType, self);

	if ( MainMenu == None && !bNoMenu )
	{
		PlayerPawn(Owner).bShowMenu = false;
		Level.bPlayersOnly = false;
		return;
	}
	else if( MainMenu != None && !bNoMenu )
	{
		MainMenu.PlayerOwner = PlayerPawn(Owner);
		MainMenu.PlayEnterSound();
		MainMenu.MenuInit();
	}
}

simulated function PostRender( canvas Canvas )
{
	local float XL, YL;

	if( bDisplayHint )
	{
		if( HintFadeOutTime != 0 )
		{
			Canvas.Style = 3;
			Canvas.bCenter = true;
			Canvas.SetPos( 0.0, 95 );
			Canvas.Font = Canvas.MedFont;
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = HintFadeOutTime / 2;
			Canvas.DrawColor.B = HintFadeOutTime;
			Canvas.SetPos(0.0, 32);
			Canvas.StrLen("TEST", XL, YL);
			Canvas.DrawColor.R = HintFadeOutTime;
			Canvas.DrawColor.G = HintFadeOutTime;
			Canvas.DrawColor.B = HintFadeOutTime;

			Canvas.SetPos(0.0, 32 + YL);
			Canvas.DrawText( MultWeapSlotMsg, true );
		}
		else bDisplayHint = false;
	}

	HUDSetup(canvas);

	if( bLetterBox && !bNoHUD )
		DrawLetterBox(Canvas);

	if ( PlayerPawn(Owner) != None )
	{
		if ( PlayerPawn(Owner).bShowMenu  )
		{
			if( bCheck )
			{
				DisplayMenu(Canvas);
				return;
			}
			else
			{
				UPakConsole( PlayerPawn( Owner ).Player.Console ).bTransition = false;
				PlayerPawn( Owner ).bShowMenu = false;
				PlayerPawn( Owner ).SetPause( false );
				bCheck = true;
			}
		}

		if ( PlayerPawn(Owner).bShowScores )
		{
			if ( ( PlayerPawn(Owner).Weapon != None ) && ( !PlayerPawn(Owner).Weapon.bOwnsCrossHair ) )
				DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
			if ( (PlayerPawn(Owner).Scoring == None) && (PlayerPawn(Owner).ScoringType != None) )
				PlayerPawn(Owner).Scoring = Spawn(PlayerPawn(Owner).ScoringType, PlayerPawn(Owner));
			if ( PlayerPawn(Owner).Scoring != None )
			{
				PlayerPawn(Owner).Scoring.ShowScores(Canvas);
				return;
			}
		}
		else if ( (PlayerPawn(Owner).Weapon != None) && (Level.LevelAction == LEVACT_None) )
		{
			PlayerPawn(Owner).Weapon.PostRender(Canvas);
			if ( !PlayerPawn(Owner).Weapon.bOwnsCrossHair )
				DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
		}

		if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds )
			DisplayProgressMessage(Canvas);

	}

	if (HudMode==5)
	{
		DrawInventory(Canvas, Canvas.ClipX-96, 0,False);
		Return;
	}
	if (Canvas.ClipX<320) HudMode = 4;

	// Draw Armor
	if (HudMode<2) DrawArmor(Canvas, 0, 0,False);
	else if (HudMode==3 || HudMode==2) DrawArmor(Canvas, 0, Canvas.ClipY-32,False);
	else if (HudMode==4) DrawArmor(Canvas, Canvas.ClipX-64, Canvas.ClipY-64,True);

	// Draw Ammo
	if (HudMode!=4) DrawAmmo(Canvas, Canvas.ClipX-48-64, Canvas.ClipY-32);
	else DrawAmmo(Canvas, Canvas.ClipX-48, Canvas.ClipY-32);

	// Draw Health
	if (HudMode<2) DrawHealth(Canvas, 0, Canvas.ClipY-32);
	else if (HudMode==3||HudMode==2) DrawHealth(Canvas, Canvas.ClipX-128, Canvas.ClipY-32);
	else if (HudMode==4) DrawHealth(Canvas, Canvas.ClipX-64, Canvas.ClipY-32);

	// Display Inventory
	if (HudMode<2) DrawInventory(Canvas, Canvas.ClipX-96, 0,False);
	else if (HudMode==3) DrawInventory(Canvas, Canvas.ClipX-96, Canvas.ClipY-64,False);
	else if (HudMode==4) DrawInventory(Canvas, Canvas.ClipX-64, Canvas.ClipY-64,True);
	else if (HudMode==2) DrawInventory(Canvas, Canvas.ClipX/2-64, Canvas.ClipY-32,False);

	// Display Frag count
	if ( (Level.Game == None) || Level.Game.IsA('DeathMatchGame') )
	{
		if (HudMode<3) DrawFragCount(Canvas, Canvas.ClipX-32,Canvas.ClipY-64);
		else if (HudMode==3) DrawFragCount(Canvas, 0,Canvas.ClipY-64);
		else if (HudMode==4) DrawFragCount(Canvas, 0,Canvas.ClipY-32);
	}

	// Display Identification Info
	if (!bNoHUD)
		DrawIdentifyInfo(Canvas, 0, Canvas.ClipY - 64.0);

	// Message of the Day / Map Info Header
	if (MOTDFadeOutTime != 0.0)
		DrawMOTD(Canvas);

	// Team Game Synopsis
	if (PlayerPawn(Owner).GameReplicationInfo.bTeamGame)
		DrawTeamGameSynopsis(Canvas);

	if( bLetterBox && bNoHUD )
		DrawLetterBox(Canvas);
}

static function float GetLetterBoxHeight(canvas Canvas)
{
	local float lbx;

	lbx = Canvas.CLipX / 16;
	lbx *= 9;
	lbx = FMax((Canvas.ClipY-lbx)/2, Canvas.ClipY / 20);
	return lbx;
}

static function DrawLetterBox(canvas Canvas)
{
	local float lbx;

	lbx = GetLetterBoxHeight(Canvas);

	Canvas.SetPos(0, 0);
	Canvas.DrawRect(Texture'CS_LetterBox', Canvas.ClipX, lbx);
	Canvas.SetPos(0, Canvas.ClipY-lbx);
	Canvas.DrawRect(Texture'CS_letterBox', Canvas.ClipX, Canvas.ClipY);
}

simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
	local float XL, YL, XOffset;

	if (!TraceIdentify(Canvas))
		return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	XOffset = 0.0;
	Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 54);

	if(IdentifyTarget.IsA('PlayerPawn') && !IdentifyTarget.IsA( 'SpaceMarine' ) )
		if(PlayerPawn(IdentifyTarget).PlayerReplicationInfo.bFeigningDeath)
			return;

	if(IdentifyTarget.PlayerReplicationInfo.PlayerName != "" && !IdentifyTarget.IsA( 'SpaceMarine' ) )
	{
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 160 * (IdentifyFadeTime / 3.0);
		Canvas.DrawColor.B = 0;

		Canvas.StrLen(IdentifyName$": ", XL, YL);
		XOffset += XL;
		Canvas.DrawText(IdentifyName$": ");
		Canvas.SetPos(XOffset, Canvas.ClipY - 54);

		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255 * (IdentifyFadeTime / 3.0);
		Canvas.DrawColor.B = 0;

		Canvas.StrLen(IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
		Canvas.DrawText(IdentifyTarget.PlayerReplicationInfo.PlayerName);
	}

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY )
{
	if (Crosshair > 5 || bNoCrosshair ) Return;
	Canvas.SetPos(StartX, StartY );
	Canvas.Style = 2;
	if		(Crosshair==0) 	Canvas.DrawIcon(Texture'Crosshair1', 1.0);
	else if (Crosshair==1) 	Canvas.DrawIcon(Texture'Crosshair2', 1.0);
	else if (Crosshair==2) 	Canvas.DrawIcon(Texture'Crosshair3', 1.0);
	else if (Crosshair==3) 	Canvas.DrawIcon(Texture'Crosshair4', 1.0);
	else if (Crosshair==4) 	Canvas.DrawIcon(Texture'Crosshair5', 1.0);
	else if (Crosshair==5) 	Canvas.DrawIcon(Texture'Crosshair7', 1.0);
	Canvas.Style = 1;
}

function DisplayHint()
{
	HintFadeOutTime = 255;
	bDisplayHint = true;
}

simulated function Tick(float DeltaTime)
{
	HintFadeOutTime -= DeltaTime * 45;
	if( HintFadeOutTime < 0.0 )
		HintFadeOutTime = 0.0;
	Super.Tick( DeltaTime );
}

defaultproperties
{
	MultWeapSlotMsg="Press the weapon select button to toggle weapons."
}
