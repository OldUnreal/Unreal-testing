//=============================================================================
// UnrealHUD
// Parent class of heads up display
//=============================================================================
class UnrealHUD extends HUD
	NoUserCreate;

#exec Texture Import File=Textures\HD_Icons\HD_HalfHud.bmp Name=HD_HalfHud Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=HalfHud FILE=Textures\HUD\HalfHud.pcx GROUP="Icons" MIPS=OFF HD=HD_HalfHud
#exec TEXTURE IMPORT NAME=HudLine FILE=Textures\HUD\Line.pcx GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=HudGreenAmmo FILE=Textures\HUD\greenammo.pcx GROUP="Icons" MIPS=OFF
#exec Texture Import File=Textures\HD_Icons\I_HD_Health.bmp Name=I_HD_Health Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=IconHealth FILE=Textures\HUD\i_health.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Health
#exec TEXTURE IMPORT NAME=I_Health FILE=Textures\Hud\i_Health.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Health // Moved from Health.uc for HD ref
#exec TEXTURE IMPORT NAME=IconSelection FILE=Textures\HUD\i_rim.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec Texture Import File=Textures\HD_Icons\I_HD_Skull.bmp Name=I_HD_Skull Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=IconSkull FILE=Textures\HUD\i_skull.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Skull

#exec TEXTURE IMPORT NAME=Crosshair1 FILE=Textures\Hud\chair1.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair2 FILE=Textures\Hud\chair2.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair3 FILE=Textures\Hud\chair3.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair4 FILE=Textures\Hud\chair4.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair5 FILE=Textures\Hud\chair5.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair6 FILE=Textures\Hud\chair6.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair7 FILE=Textures\Hud\chair7.pcx GROUP="Icons" FLAGS=2 MIPS=OFF

#exec Texture Import File=Textures\HD_Fonts\WhiteMedFont-Masked.bmp Name=HD_WhiteFont Group="HD" Mips=Off Flags=2
//#exec Texture Import File=Textures\HD_Fonts\TINYFONT-Red-Masked.bmp Name=HD_TinyRedFont Group="HD" Mips=Off Flags=2
//#exec Texture Import File=Textures\HD_Fonts\TINYFONT-White-Masked.bmp Name=HD_TinyWhiteFont Group="HD" Mips=Off Flags=2
//#exec Texture Import File=Textures\HD_Fonts\TINYFONT-Grey-Masked.bmp Name=HD_TinyFont Group="HD" Mips=Off Flags=2
#exec Texture Import File=Textures\HD_Fonts\LRGRED-AlphaBlend.dds Name=HD_LargeRedFont Group="HD" Mips=Off Flags=131074

#exec Texture Import File=Textures\HD_Fonts\HD_TinyFont.dds Name=HD_TinyFont Group="HD" Mips=Off Flags=131074
#exec Texture Import File=Textures\HD_Fonts\HD_TinyRedFont.dds Name=HD_TinyRedFont Group="HD" Mips=Off Flags=131074
#exec Texture Import File=Textures\HD_Fonts\HD_TinyWhiteFont.dds Name=HD_TinyWhiteFont Group="HD" Mips=Off Flags=131074

#exec Font Import File=Textures\Lrgred.pcx Name=LargeRedFont HD=HD_LargeRedFont
#exec Font Import File=..\Engine\Textures\LargeFont_New.pcx Name=LargeGreenFont HD=HD_LargeFont // for non-localized text
#exec Font Import File=Textures\TinyFont.pcx Name=TinyFont HD=HD_TinyFont
#exec Font Import File=Textures\TinyFon3.pcx Name=TinyWhiteFont HD=HD_TinyWhiteFont
#exec Font Import File=Textures\TinyFon2.pcx Name=TinyRedFont HD=HD_TinyRedFont
#exec Font Import File=Textures\MedFont3.pcx Name=WhiteFont HD=HD_WhiteFont

var int TranslatorTimer;
var() int TranslatorY,CurTranY,SizeY,Count;
var string CurrentMessage;
var bool bDisplayTran, bFlashTranslator;
var float MOTDFadeOutTime;

var float IdentifyFadeTime;
var Pawn IdentifyTarget;

// Identify Strings
var localized string IdentifyName;
var localized string IdentifyHealth;
var localized string SomeoneName;

var() localized string VersionMessage;

var localized string TeamName[4];
var() color TeamColor[4];
var() color AltTeamColor[4];
var color RedColor, GreenColor;

var int ArmorOffset;

// Message Struct
Struct MessageStruct
{
	var name Type;
	var PlayerReplicationInfo PRI;
};

var localized string DemoPlaybackProg,DemoRecInfo;
var transient float RecStartTime;

simulated function PostBeginPlay()
{
	MOTDFadeOutTime = 255;

	Super.PostBeginPlay();
}

simulated final function Pawn GetPawnOwner()
{
	local Pawn P;
	
	P = Pawn(Owner);
	if( Level.bIsDemoPlayback || (P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.bIsSpectator) )
	{
		P = Pawn(PlayerPawn(Owner).ViewTarget);
		if( P!=None && !P.bDeleteMe )
			return P;
		P = Pawn(Owner);
	}
	return P;
}

simulated function ChangeHud(int d)
{
	HudMode = HudMode + d;
	if ( HudMode>5 ) HudMode = 0;
	else if ( HudMode < 0 ) HudMode = 5;
}

simulated function ChangeCrosshair(int d)
{
	Crosshair = Crosshair + d;
	if ( Crosshair>6 ) Crosshair=0;
	else if ( Crosshair < 0 ) Crosshair = 6;
}

simulated function CreateMenu()
{
	if ( PlayerPawn(Owner).bSpecialMenu && (PlayerPawn(Owner).SpecialMenu != None) )
	{
		MainMenu = Spawn(PlayerPawn(Owner).SpecialMenu, self);
		PlayerPawn(Owner).bSpecialMenu = false;
	}

	if ( MainMenu == None )
		MainMenu = Spawn(MainMenuType, self);

	if ( MainMenu == None )
	{
		PlayerPawn(Owner).bShowMenu = false;
		Level.bPlayersOnly = false;
		return;
	}
	else
	{
		MainMenu.PlayerOwner = PlayerPawn(Owner);
		MainMenu.PlayEnterSound();
		MainMenu.MenuInit();
	}
}

simulated function HUDSetup(canvas canvas)
{
	// Setup the way we want to draw all HUD elements
	Canvas.Reset();
	Canvas.bNoSmooth = (Class'HUD'.Default.HudScaler==1.f);
	Canvas.SetDrawColorRGB(255,255,255);
	Canvas.Font = Canvas.LargeFont;
}

simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY )
{
	local float XL;
	
	if (Crosshair>5) Return;
	XL = (CrosshairScale-1.f) * 8.f;
	Canvas.SetPos(float(StartX)-XL, float(StartY)-XL);
	Canvas.Style = ERenderStyle.STY_Masked;
	if		(Crosshair==0) 	Canvas.DrawIcon(Texture'Crosshair1', CrosshairScale);
	else if (Crosshair==1) 	Canvas.DrawIcon(Texture'Crosshair2', CrosshairScale);
	else if (Crosshair==2) 	Canvas.DrawIcon(Texture'Crosshair3', CrosshairScale);
	else if (Crosshair==3) 	Canvas.DrawIcon(Texture'Crosshair4', CrosshairScale);
	else if (Crosshair==4) 	Canvas.DrawIcon(Texture'Crosshair5', CrosshairScale);
	else if (Crosshair==5) 	Canvas.DrawIcon(Texture'Crosshair7', CrosshairScale);
	Canvas.Style = ERenderStyle.STY_Normal;
}

simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float YOffset, XL, YL;

	Canvas.SetDrawColorRGB(255,255,255);
	Canvas.bCenter = true;
	Canvas.Font = Canvas.MedFont;
	YOffset = 0;
	Canvas.TextSize("TEST", XL, YL);
	for (i=0; i<5; i++)
	{
		Canvas.SetPos(0, 0.25 * Canvas.ClipY + YOffset);
		Canvas.DrawColor = PlayerPawn(Owner).ProgressColor[i];
		Canvas.DrawText(PlayerPawn(Owner).ProgressMessage[i], false);
		YOffset += YL + 1;
	}
	Canvas.bCenter = false;
	Canvas.SetDrawColorRGB(255,255,255);
}

simulated function PreRender( canvas Canvas )
{
	if( PlayerPawn(Owner).Weapon )
		PlayerPawn(Owner).Weapon.PreRender(Canvas);
}

simulated function DisplayMenu( canvas Canvas )
{
	local float VersionW, VersionH;

	if ( !MainMenu )
		CreateMenu();
	if ( MainMenu )
	{
		MainMenu.DrawMenu(Canvas);
		if ( MainMenu.Class == MainMenuType )
		{
			Canvas.bCenter = false;
			Canvas.Font = Canvas.MedFont;
			Canvas.Style = 1;
			Canvas.StrLen(VersionMessage@Level.EngineVersion$Chr(96+int(Level.EngineSubVersion)), VersionW, VersionH);
			Canvas.SetPos(Canvas.ClipX - VersionW - 4, 4);
			Canvas.DrawText(VersionMessage@Level.EngineVersion$Chr(96+int(Level.EngineSubVersion)), False);
		}
	}
}

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn P;
	
	P = PlayerPawn(Owner);
	if( !P )
		return;

	HUDSetup(canvas);

	if ( !P.PlayerReplicationInfo )
		return;
	
	if( Level.bIsDemoPlayback || Level.bIsDemoRecording )
		DrawDemoInfo(Canvas);
	
	if ( P.bShowMenu )
	{
		DisplayMenu(Canvas);
		return;
	}
	if ( P.bShowScores )
	{
		if ( ( P.Weapon != None ) && ( !P.Weapon.bOwnsCrossHair ) )
			DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
		if ( (P.Scoring == None) && (P.ScoringType != None) )
			P.Scoring = Spawn(P.ScoringType, P);
		if ( P.Scoring != None )
		{
			P.Scoring.ShowScores(Canvas);
			return;
		}
	}
	else if ( P.Weapon && (Level.LevelAction == LEVACT_None) )
	{
		Canvas.Font = Font'WhiteFont';
		P.Weapon.PostRender(Canvas);
		if ( !P.Weapon.bOwnsCrossHair )
			DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
	}

	if ( P.ProgressTimeOut > Level.TimeSeconds )
		DisplayProgressMessage(Canvas);

	if (HudMode==5)
	{
		DrawInventory(Canvas, Canvas.ClipX-96, 0,False);
		Return;
	}
	//if (Canvas.ClipX<320) HudMode = 4; <- Marco: Don't override HUD settings!

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
	if ( !Level.Game || Level.Game.bDeathMatch )
	{
		if (HudMode<3) DrawFragCount(Canvas, Canvas.ClipX-32,Canvas.ClipY-64);
		else if (HudMode==3) DrawFragCount(Canvas, 0,Canvas.ClipY-64);
		else if (HudMode==4) DrawFragCount(Canvas, 0,Canvas.ClipY-32);
	}

	// Display Identification Info
	DrawIdentifyInfo(Canvas, 0, Canvas.ClipY - 64.0);

	// Message of the Day / Map Info Header
	if (MOTDFadeOutTime != 0.0)
		DrawMOTD(Canvas);

	// Team Game Synopsis
	if ( (P.GameReplicationInfo != None) && P.GameReplicationInfo.bTeamGame)
		DrawTeamGameSynopsis(Canvas);
}

simulated function DrawTeamGameSynopsis(Canvas Canvas)
{
	local TeamInfo TI;
	local float XL, YL;

	foreach AllActors(class'TeamInfo', TI)
	{
		if (TI.Size > 0)
		{
			Canvas.Font = Font'WhiteFont';
			Canvas.DrawColor = TeamColor[TI.TeamIndex];
			Canvas.StrLen(TeamName[TI.TeamIndex], XL, YL);
			Canvas.SetPos(0, Canvas.ClipY - 128 + 16 * TI.TeamIndex);
			Canvas.DrawText(TeamName[TI.TeamIndex], false);
			Canvas.SetPos(XL, Canvas.ClipY - 128 + 16 * TI.TeamIndex);
			Canvas.DrawText(int(TI.Score), false);
		}
	}

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function DrawFragCount(Canvas Canvas, int X, int Y)
{
	local Pawn P;

	Canvas.SetPos(X,Y);
	Canvas.DrawIcon(Texture'IconSkull', 1.0);
	Canvas.CurX -= 19;
	Canvas.CurY += 23;

	P = GetPawnOwner();
	if ( P.PlayerReplicationInfo == None )
		return;
	Canvas.Font = Font'TinyWhiteFont';
	if (P.PlayerReplicationInfo.Score<100)
		Canvas.CurX+=6;
	if (P.PlayerReplicationInfo.Score<10)
		Canvas.CurX+=6;
	if (P.PlayerReplicationInfo.Score<0)
		Canvas.CurX-=6;
	if (P.PlayerReplicationInfo.Score<-9)
		Canvas.CurX-=6;
	Canvas.DrawText(int(P.PlayerReplicationInfo.Score),False);
}

simulated function DrawInventory(Canvas Canvas, int X, int Y, bool bDrawOne)
{
	local bool bGotNext, bGotPrev, bGotSelected;
	local inventory Inv,Prev, Next, SelectedItem;
	local translator Translator;
	local int HalfHUDX, HalfHUDY, AmmoIconSize, i;
	local Pawn P;

	P = GetPawnOwner();
	if ( HudMode < 4 ) //then draw HalfHUD
	{
		Canvas.Font = Font'TinyFont';
		HalfHUDX = Canvas.ClipX-64;
		HalfHUDY = Canvas.ClipY-32;
		Canvas.CurX = HalfHudX;
		Canvas.CurY = HalfHudY;
		Canvas.DrawIcon(Texture'HalfHud', 1.0);
	}

	if ( P.Inventory==None) Return;
	bGotSelected = False;
	bGotNext = false;
	bGotPrev = false;
	Prev = None;
	Next = None;
	SelectedItem = P.SelectedItem;

	foreach P.AllInventory(class'Inventory',Inv)
	{
		if ( !bDrawOne ) // if drawing more than one inventory, find next and previous items
		{
			if ( Inv == SelectedItem )
				bGotSelected = True;
			else if ( Inv.bActivatable )
			{
				if ( bGotSelected )
				{
					if ( !bGotNext )
					{
						Next = Inv;
						bGotNext = true;
					}
					else if ( !bGotPrev )
						Prev = Inv;
				}
				else
				{
					if ( Next == None )
						Next = Prev;
					Prev = Inv;
					bGotPrev = True;
				}
			}
		}

		if ( Translator(Inv) != None )
			Translator = Translator(Inv);

		if ( (HudMode < 4) && (Inv.InventoryGroup>0) && (Weapon(Inv)!=None) )
		{
			if (P.Weapon == Inv) Canvas.Font = Font'TinyWhiteFont';
			else Canvas.Font = Font'TinyFont';
			Canvas.CurX = HalfHudX-3+Inv.InventoryGroup*6;
			Canvas.CurY = HalfHudY+4;
			if (Inv.InventoryGroup<10) Canvas.DrawText(Inv.InventoryGroup,False);
			else Canvas.DrawText("0",False);
		}


		if ( (HudMode < 4) && (Ammo(Inv)!=None) )
		{
			for (i=0; i<10; i++)
			{
				if (Ammo(Inv).UsedInWeaponSlot[i]==1)
				{
					Canvas.CurX = HalfHudX+3+i*6;
					if (i==0) Canvas.CurX += 60;
					Canvas.CurY = HalfHudY+11;
					AmmoIconSize = 16.0*FMin(1.0,(float(Ammo(Inv).AmmoAmount)/float(Ammo(Inv).MaxAmmo)));
					if (AmmoIconSize<8 && Ammo(Inv).AmmoAmount<10 && Ammo(Inv).AmmoAmount>0)
					{
						Canvas.CurX -= 6;
						Canvas.CurY += 5;
						Canvas.Font = Font'TinyRedFont';
						Canvas.DrawText(Ammo(Inv).AmmoAmount,False);
						Canvas.CurY -= 12;
					}
					Canvas.CurY += 19-AmmoIconSize;
					Canvas.CurX -= 6;
					Canvas.DrawColor.g = 255;
					Canvas.DrawColor.r = 0;
					Canvas.DrawColor.b = 0;
					if (AmmoIconSize<8)
					{
						Canvas.DrawColor.r = 255-AmmoIconSize*30;
						Canvas.DrawColor.g = AmmoIconSize*30+40;
					}
					if (Ammo(Inv).AmmoAmount >0)
					{
						Canvas.DrawTile(Texture'HudGreenAmmo',4.0,AmmoIconSize,0,0,4.0,AmmoIconSize);
					}
					Canvas.DrawColor.g = 255;
					Canvas.DrawColor.r = 255;
					Canvas.DrawColor.b = 255;
				}
			}
		}
	}

	// List Translator messages if activated
	if ( Translator!=None )
	{
		if ( Translator.bCurrentlyActivated )
		{
			Translator.DrawTranslator(Canvas);
			HUDSetup(Canvas);
		}
		else
			bFlashTranslator = ( Translator.bNewMessage || Translator.bNotNewMessage );
	}

	if ( HUDMode == 5 )
		return;

	if ( SelectedItem != None )
	{
		Count++;
		if (Count>20) Count=0;

		if (Prev!=None)
		{
			if ( Prev.bActive || (bFlashTranslator && (Translator == Prev) && (Count>15)) )
			{
				Canvas.DrawColor.b = 0;
				Canvas.DrawColor.g = 0;
			}
			DrawHudIcon(Canvas, X, Y, Prev);
			if ( (Pickup(Prev) != None) && Pickup(Prev).bCanHaveMultipleCopies )
				DrawNumberOf(Canvas,Pickup(Prev).NumCopies,X,Y);
			Canvas.DrawColor.b = 255;
			Canvas.DrawColor.g = 255;
		}
		if ( SelectedItem.Icon != None )
		{
			if ( SelectedItem.bActive || (bFlashTranslator && (Translator == SelectedItem) && (Count>15)) )
			{
				Canvas.DrawColor.b = 0;
				Canvas.DrawColor.g = 0;
			}
			if ( (Next==None) && (Prev==None) && !bDrawOne) DrawHudIcon(Canvas, X+64, Y, SelectedItem);
			else DrawHudIcon(Canvas, X+32, Y, SelectedItem);
			Canvas.Style = 2;
			Canvas.CurX = X+32;
			if ( (Next==None) && (Prev==None) && !bDrawOne ) Canvas.CurX = X+64;
			Canvas.CurY = Y;
			Canvas.DrawIcon(texture'IconSelection', 1.0);
			if ( (Pickup(SelectedItem) != None)
					&& Pickup(SelectedItem).bCanHaveMultipleCopies )
				DrawNumberOf(Canvas,Pickup(SelectedItem).NumCopies,Canvas.CurX-32,Y);
			Canvas.Style = 1;
			Canvas.DrawColor.b = 255;
			Canvas.DrawColor.g = 255;
		}
		if (Next!=None)
		{
			if ( Next.bActive || (bFlashTranslator && (Translator == Next) && (Count>15)) )
			{
				Canvas.DrawColor.b = 0;
				Canvas.DrawColor.g = 0;
			}
			DrawHudIcon(Canvas, X+64, Y, Next);
			if ( (Pickup(Next) != None) && Pickup(Next).bCanHaveMultipleCopies )
				DrawNumberOf(Canvas,Pickup(Next).NumCopies,Canvas.CurX-32,Y);
			Canvas.DrawColor.b = 255;
			Canvas.DrawColor.g = 255;
		}
	}
}

simulated function DrawNumberOf(Canvas Canvas, int NumberOf, int X, int Y)
{
	if (NumberOf<=0) Return;

	Canvas.CurX = X + 14;
	Canvas.CurY = Y + 20;
	NumberOf++;
	if (NumberOf<100) Canvas.CurX+=6;
	if (NumberOf<10) Canvas.CurX+=6;
	Canvas.Font = Font'TinyRedFont';
	Canvas.DrawText(NumberOf,False);
}

simulated function DrawArmor(Canvas Canvas, int X, int Y, bool bDrawOne)
{
	Local int ArmorAmount,CurAbs;
	Local inventory Inv,BestArmor;
	Local float XL, YL;

	ArmorAmount = 0;
	ArmorOffset = 0;
	Canvas.Font = Canvas.LargeFont;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	CurAbs=0;
	BestArmor=None;
	foreach GetPawnOwner().AllInventory(class'Inventory',Inv)
	{
		if (Inv.bIsAnArmor)
		{
			ArmorAmount += Inv.Charge;
			if (Inv.Charge>0 && Inv.Icon!=None)
			{
				if (!bDrawOne)
				{
					ArmorOffset += 32;
					DrawHudIcon(Canvas, Canvas.CurX, Y, Inv);
					DrawIconValue(Canvas, Inv.Charge);
				}
				else if (Inv.ArmorAbsorption>CurAbs)
				{
					CurAbs = Inv.ArmorAbsorption;
					BestArmor = Inv;
				}
			}
		}
	}
	if (bDrawOne && BestArmor!=None)
	{
		DrawHudIcon(Canvas, Canvas.CurX, Y, BestArmor);
		DrawIconValue(Canvas, BestArmor.Charge);
	}
	Canvas.CurY = Y;
	if (ArmorAmount>0 && HudMode==0)
	{
		Canvas.Font = Font'LargeGreenFont';
		Canvas.StrLen(ArmorAmount,XL,YL);
		ArmorOffset += XL;
		Canvas.DrawText(ArmorAmount,False);
	}
}

// Draw the icons value in text on the icon
//
simulated function DrawIconValue(Canvas Canvas, int Amount)
{
	local int TempX,TempY;

	if (HudMode==0 || HudMode==3) Return;

	TempX = Canvas.CurX;
	TempY = Canvas.CurY;
	Canvas.CurX -= 20;
	Canvas.CurY -= 5;
	if (Amount<100) Canvas.CurX+=6;
	if (Amount<10) Canvas.CurX+=6;
	Canvas.Font = Font'TinyFont';
	Canvas.DrawText(Amount,False);
	Canvas.Font = Canvas.LargeFont;
	Canvas.CurX = TempX;
	Canvas.CurY = TempY;
}

simulated function DrawAmmo(Canvas Canvas, int X, int Y)
{
	local Pawn P;
	
	P = GetPawnOwner();
	if ( (P.Weapon == None) || (P.Weapon.AmmoType == None) )
		return;
	Canvas.CurY = Y;
	Canvas.CurX = X;
	if (P.Weapon.AmmoType.AmmoAmount < 10)
		Canvas.Font = Font'LargeRedFont';
	else
		Canvas.Font = Font'LargeGreenFont';
	if (HudMode==0)
	{
		if (P.Weapon.AmmoType.AmmoAmount>=100) Canvas.CurX -= 16;
		if (P.Weapon.AmmoType.AmmoAmount>=10) Canvas.CurX -= 16;
		Canvas.DrawText(P.Weapon.AmmoType.AmmoAmount,False);
		Canvas.CurY = Canvas.ClipY-32;
	}
	else Canvas.CurX+=16;
	if (P.Weapon.AmmoType.Icon!=None) Canvas.DrawRect(P.Weapon.AmmoType.Icon,32,32);
	Canvas.CurY += 29;
	DrawIconValue(Canvas, P.Weapon.AmmoType.AmmoAmount);
	Canvas.CurX = X+19;
	Canvas.CurY = Y+29;
	if (HudMode!=1 && HudMode!=2 && HudMode!=4)
		Canvas.DrawTile(Texture'HudLine',FMin(27.0*(float(P.Weapon.AmmoType.AmmoAmount)/float(P.Weapon.AmmoType.MaxAmmo)),27),2.0,0,0,32.0,2.0);
}

simulated function DrawHealth(Canvas Canvas, int X, int Y)
{
	local Pawn P;

	P = GetPawnOwner();
	Canvas.CurY = Y;
	Canvas.CurX = X;
	if (P.Health < 25)
		Canvas.Font = Font'LargeRedFont';
	else
		Canvas.Font = Font'LargeGreenFont';
	Canvas.DrawIcon(Texture'IconHealth', 1.0);
	Canvas.CurY += 29;
	DrawIconValue(Canvas, Max(0,P.Health));
	Canvas.CurY -= 29;
	if (HudMode==0) Canvas.DrawText(Max(0,P.Health),False);
	Canvas.CurY = Y+29;
	Canvas.CurX = X+2;
	if (HudMode!=1 && HudMode!=2 && HudMode!=4)
		Canvas.DrawTile(Texture'HudLine',FMin(27.0*(float(P.Health)/float(P.Default.Health)),27),2.0,0,0,32.0,2.0);
}

simulated function DrawHudIcon(Canvas Canvas, int X, int Y, Inventory Item)
{
	Local int Width;
	if (Item.Icon==None) Return;
	Width = Canvas.CurX;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.DrawRect(Item.Icon,32,32);
	Canvas.CurX -= 30;
	Canvas.CurY += 28;
	if ( ((HudMode!=2 && HudMode!=4 && HudMode!=1) || !Item.bIsAnArmor) && Item.Charge>0 )
		Canvas.DrawTile(Texture'HudLine',fMin(27.0,27.0*(float(Item.Charge)/float(Item.Default.Charge))),2.0,0,0,32.0,2.0);
	Canvas.CurX = Width + 32;
}

simulated function DrawTypingPrompt( canvas Canvas, console Console )
{
	local string TypingPrompt;
	local float XL, YL;

	if ( Console.bTyping )
	{
		Canvas.DrawColor.r = 0;
		Canvas.DrawColor.g = 255;
		Canvas.DrawColor.b = 0;
		if( Console.TypingOffset>=0 && Console.TypingOffset<Len(Console.TypedStr) )
			TypingPrompt = "(> "$Left(Console.TypedStr,Console.TypingOffset)$"_"$Mid(Console.TypedStr,Console.TypingOffset);
		else TypingPrompt = "(> "$Console.TypedStr$"_";
		Canvas.Font = Font'WhiteFont';
		Canvas.StrLen( TypingPrompt, XL, YL );
		Canvas.SetPos( 2, Console.FrameY - Console.ConsoleLines - YL - 1 );
		Canvas.DrawText( TypingPrompt, false );
	}
}

simulated function bool DisplayMessages( canvas Canvas )
{
	local float XL, YL;
	local int I, J, YPos;
	local float PickupColor;
	local console Console;
	local MessageStruct ShortMessages[4];
	local string MessageString[4];
	local name MsgType;

	Console = Canvas.Viewport.Console;

	Canvas.Font = Font'WhiteFont';

	if ( !Console.Viewport.Actor.bShowMenu )
		DrawTypingPrompt(Canvas, Console);

	if ( (Console.TextLines > 0) && (!Console.Viewport.Actor.bShowMenu || Console.Viewport.Actor.bShowScores) )
	{
		MsgType = Console.GetMsgType(Console.TopLine);
		if ( MsgType == 'Pickup' )
		{
			Canvas.bCenter = true;
			if ( Level.bHighDetailMode )
				Canvas.Style = ERenderStyle.STY_Translucent;
			else
				Canvas.Style = ERenderStyle.STY_Normal;
			PickupColor = 42.0 * FMin(6, Console.GetMsgTick(Console.TopLine));
			Canvas.DrawColor.r = PickupColor;
			Canvas.DrawColor.g = PickupColor;
			Canvas.DrawColor.b = PickupColor;
			Canvas.SetPos(4, Console.FrameY - 44);
			Canvas.DrawText( Console.GetMsgText(Console.TopLine), true );
			Canvas.bCenter = false;
			Canvas.Style = 1;
			J = Console.TopLine - 1;
		}
		else if ( (MsgType == 'CriticalEvent') || (MsgType == 'LowCriticalEvent')
				  || (MsgType == 'RedCriticalEvent') )
		{
			Canvas.bCenter = true;
			Canvas.Style = 1;
			Canvas.DrawColor.r = 0;
			Canvas.DrawColor.g = 128;
			Canvas.DrawColor.b = 255;
			if ( MsgType == 'CriticalEvent' )
				Canvas.SetPos(0, Console.FrameY/2 - 32);
			else if ( MsgType == 'LowCriticalEvent' )
				Canvas.SetPos(0, Console.FrameY/2 + 32);
			else if ( MsgType == 'RedCriticalEvent' )
			{
				PickupColor = 42.0 * FMin(6, Console.GetMsgTick(Console.TopLine));
				Canvas.DrawColor.r = PickupColor;
				Canvas.DrawColor.g = 0;
				Canvas.DrawColor.b = 0;
				Canvas.SetPos(4, Console.FrameY - 44);
			}

			Canvas.DrawText( Console.GetMsgText(Console.TopLine), true );
			Canvas.bCenter = false;
			J = Console.TopLine - 1;
		}
		else
			J = Console.TopLine;

		I = 0;
		while ( (I < 4) && (J >= 0) )
		{
			MsgType = Console.GetMsgType(J);
			if ((MsgType != '') && (MsgType != 'Log'))
			{
				MessageString[I] = Console.GetMsgText(J);
				if ( (MessageString[I] != "") && (Console.GetMsgTick(J) > 0.0) )
				{
					if ( (MsgType == 'Event') || (MsgType == 'DeathMessage') )
					{
						ShortMessages[I].PRI = None;
						ShortMessages[I].Type = MsgType;
						I++;
					}
					else if ( (MsgType == 'Say') || (MsgType == 'TeamSay') )
					{
						ShortMessages[I].PRI = Console.GetMsgPlayer(J);
						ShortMessages[I].Type = MsgType;
						I++;
					}
				}
			}
			J--;
		}

		// decide which speech message to show face for
		// FIXME - get the face from the PlayerReplicationInfo.TalkTexture
		J = 0;
		Canvas.Font = Font'WhiteFont';
		for ( I=0; I<4; I++ )
			if ( Len(MessageString[3 - I])!=0 )
			{
				YPos = 2 + J;
				if ( !DrawMessageHeader(Canvas, ShortMessages[3 - I], YPos) )
				{
					if (ShortMessages[3 - I].Type == 'DeathMessage')
						Canvas.DrawColor = RedColor;
					else
					{
						Canvas.DrawColor.r = 200;
						Canvas.DrawColor.g = 200;
						Canvas.DrawColor.b = 200;
					}
					Canvas.SetPos(ArmorOffset+4, YPos);
				}
				if ( !SpecialType(ShortMessages[3 - I].Type) )
				{
					Canvas.StrLen(MessageString[3-I], XL, YL);
					Canvas.DrawText(MessageString[3-I], false );
					J+=YL;
				}
			}
	}
	return true;
}

simulated function bool SpecialType(Name Type)
{
	if (Type == '')
		return true;
	if (Type == 'Log')
		return true;
	if (Type == 'Pickup')
		return true;
	if (Type == 'CriticalEvent')
		return true;
	if (Type == 'LowCriticalEvent')
		return true;
	if (Type == 'RedCriticalEvent')
		return true;
	return false;
}

simulated function float DrawNextMessagePart( Canvas Canvas, coerce string MString, float XOffset, int YPos )
{
	local float XL, YL;

	Canvas.SetPos(4 + XOffset, YPos);
	Canvas.StrLen( MString, XL, YL );
	XOffset += XL;
	Canvas.DrawText( MString, false );
	return XOffset;
}

simulated function bool DrawMessageHeader(Canvas Canvas, MessageStruct ShortMessage, int YPos)
{
	local float XOffset;

	if ( ShortMessage.Type=='Say' )
		Canvas.DrawColor = GreenColor;
	else if ( ShortMessage.Type=='TeamSay' ) // 227f: Show teamchat in yellow.
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}
	else return false;

	XOffset += ArmorOffset;
	if ( ShortMessage.PRI!=None && !ShortMessage.PRI.bDeleteMe )
		XOffset = DrawNextMessagePart(Canvas, ShortMessage.PRI.PlayerName$": ", XOffset, YPos);
	else XOffset = DrawNextMessagePart(Canvas, SomeoneName$": ", XOffset, YPos);
	Canvas.SetPos(4 + XOffset, YPos);
	return true;
}

simulated function Tick(float DeltaTime)
{
	IdentifyFadeTime -= DeltaTime;
	if (IdentifyFadeTime < 0.0)
		IdentifyFadeTime = 0.0;

	MOTDFadeOutTime -= DeltaTime * 45;
	if (MOTDFadeOutTime < 0.0)
		MOTDFadeOutTime = 0.0;
}

simulated function bool TraceIdentify(canvas Canvas)
{
	local Actor Other, Src;
	local vector HitLocation, HitNormal;
	local Coords C;
	local bool bOldTrace;

	// Update on 227g: Use player camera coords.
	C = Canvas.GetCameraCoords();
	C.XAxis = C.Origin + C.XAxis*1000.f;

	if( PlayerPawn(Owner).ViewTarget!=None && !PlayerPawn(Owner).bBehindView )
		Src = PlayerPawn(Owner).ViewTarget;
	else Src = Owner;
	
	bOldTrace = Src.bTraceHitBoxes;
	Src.bTraceHitBoxes = true;
	Other = Src.Trace(HitLocation, HitNormal, C.XAxis, C.Origin, true);
	Src.bTraceHitBoxes = bOldTrace;

	if ( Other!=None && Other.bIsPawn && !Other.bHidden && Pawn(Other).bIsPlayer )
	{
		IdentifyTarget = Pawn(Other);
		IdentifyFadeTime = 3.0;
	}

	if ( IdentifyFadeTime==0.0 )
		return false;

	if ( IdentifyTarget==None || IdentifyTarget.bDeleteMe || IdentifyTarget.PlayerReplicationInfo==None )
		return false;

	return true;
}

simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
	local float XL, YL, XOffset;

	if( !TraceIdentify(Canvas) )
		return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	XOffset = 0.0;
	Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 54);

	if ( IdentifyTarget.IsA('PlayerPawn') && IdentifyTarget.PlayerReplicationInfo.bFeigningDeath )
		return;

	if ( Len(IdentifyTarget.PlayerReplicationInfo.PlayerName)!=0 )
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

simulated function DrawMOTD(Canvas Canvas)
{
	local float XL, YL;
	local PlayerPawn PP;

	if (Owner == None) return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;

	Canvas.bCenter = true;

	PP = Canvas.Viewport.Actor;
	if ( PP.GameReplicationInfo==None )
	{
		foreach AllActors(class'GameReplicationInfo', PP.GameReplicationInfo)
			break;
	}
	if ( PP.GameReplicationInfo!=None )
	{
		if ( PP.GameReplicationInfo.GameName!="Game" )
		{
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = MOTDFadeOutTime / 2;
			Canvas.DrawColor.B = MOTDFadeOutTime;
			Canvas.SetPos(0.0, 32);
			Canvas.StrLen("TEST", XL, YL);
			if (Level.NetMode != NM_Standalone)
				Canvas.DrawText(PP.GameReplicationInfo.ServerName);
			Canvas.DrawColor.R = MOTDFadeOutTime;
			Canvas.DrawColor.G = MOTDFadeOutTime;
			Canvas.DrawColor.B = MOTDFadeOutTime;

			Canvas.SetPos(0.0, 32 + YL);
			Canvas.DrawText(Class'UnrealScoreBoard'.Default.GameType$PP.GameReplicationInfo.GameName, true);
			Canvas.SetPos(0.0, 32 + 2*YL);
			Canvas.DrawText(Class'UnrealScoreBoard'.Default.MapTitle$Level.Title, true);
			Canvas.SetPos(0.0, 32 + 3*YL);
			Canvas.DrawText(Class'UnrealScoreBoard'.Default.Author$Level.Author, true);
			Canvas.SetPos(0.0, 32 + 4*YL);
			if (Level.IdealPlayerCount != "")
				Canvas.DrawText(Class'UnrealScoreBoard'.Default.IdealPlayerCount$Level.IdealPlayerCount, true);

			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = MOTDFadeOutTime / 2;
			Canvas.DrawColor.B = MOTDFadeOutTime;

			Canvas.SetPos(0, 32 + 6*YL);
			Canvas.DrawText(Level.LevelEnterText, true);

			Canvas.SetPos(0.0, 32 + 8*YL);
			Canvas.DrawText(PP.GameReplicationInfo.MOTDLine1, true);
			Canvas.SetPos(0.0, 32 + 9*YL);
			Canvas.DrawText(PP.GameReplicationInfo.MOTDLine2, true);
			Canvas.SetPos(0.0, 32 + 10*YL);
			Canvas.DrawText(PP.GameReplicationInfo.MOTDLine3, true);
			Canvas.SetPos(0.0, 32 + 11*YL);
			Canvas.DrawText(PP.GameReplicationInfo.MOTDLine4, true);
		}
	}
	Canvas.bCenter = false;

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

// 227f: Get console message color.
simulated function GetMessageColor( name MsgType, out color Colour )
{
	switch ( MsgType )
	{
	case 'Say':
		Colour = GreenColor;
		break;
	case 'TeamSay':
		Colour.R = 255;
		Colour.G = 255;
		Colour.B = 0;
		break;
	case 'CriticalEvent':
	case 'LowCriticalEvent':
		Colour.R = 0;
		Colour.G = 128;
		Colour.B = 255;
		break;
	case 'DeathMessage':
	case 'RedCriticalEvent':
		Colour = RedColor;
		break;
	case 'Pickup':
		Colour.R = 200;
		Colour.G = 200;
		Colour.B = 200;
		break;
	default:
		Colour.R = 255;
		Colour.G = 255;
		Colour.B = 255;
	}
}

// 227j: Display demo recording progress.
simulated function DrawDemoInfo(Canvas Canvas)
{
	local string S;
	local float XL,YL,P,Y;
	local int Seconds,Minutes;

	Canvas.Font = Font'WhiteFont';
	
	if( Level.bIsDemoRecording )
	{
		if( RecStartTime==0 )
			RecStartTime = Level.RealTimeSeconds;
		Seconds = int(Level.RealTimeSeconds-RecStartTime);
		Minutes = Seconds/60;
		Seconds-=(Minutes*60);

		S = DemoRecInfo@string(Minutes)$":"$((Seconds<10) ? ("0"$string(Seconds)) : string(Seconds));
		Canvas.TextSize(S, XL, YL);
		XL+=4;
		YL+=4;
		Y = Canvas.ClipY-40.f-YL;
		
		// Draw background.
		Canvas.SetDrawColorRGB((Sin(Level.RealTimeSeconds)+1.f)*86.f,2,2);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(8.f,Y);
		Canvas.DrawTile(Texture'WhiteTexture', XL, YL, 0, 0, 1, 1);
		
		// Draw text ontop.
		Canvas.SetDrawColorRGB(200,200,200);
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(10.f,Y+2);
		Canvas.DrawText(S);
		
		Canvas.SetDrawColorRGB(255,255,255);
	}
	else
	{
		P = float(ConsoleCommand("RECPROGRESS"));
		S = string(P * 100.f);
		Canvas.TextSize(ReplaceStr(DemoPlaybackProg,"%f","100.0"), XL, YL);
		XL+=4;
		YL+=4;
		Y = Canvas.ClipY-40.f-YL;
		
		// Draw background progress bar.
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetDrawColorRGB(16,2,2);
		Canvas.SetPos(8.f,Y);
		Canvas.DrawTile(Texture'WhiteTexture', XL, YL, 0, 0, 1, 1);
		Canvas.SetDrawColorRGB(128,8,8);
		Canvas.SetPos(8.f,Y);
		Canvas.DrawTile(Texture'WhiteTexture', XL*P, YL, 0, 0, 1, 1);
		
		// Draw text ontop.
		Canvas.SetDrawColorRGB(200,200,200);
		Canvas.SetPos(10.f,Y+2);
		Canvas.DrawText(ReplaceStr(DemoPlaybackProg,"%f",Left(S,Len(S)-5)));
		
		Canvas.SetDrawColorRGB(255,255,255);
	}
}

defaultproperties
{
	TranslatorY=-128
	CurTranY=-128
	IdentifyName="Name"
	IdentifyHealth="Health"
	VersionMessage="Version"
	TeamName(0)="Red Team: "
	TeamName(1)="Blue Team: "
	TeamName(2)="Green Team: "
	TeamName(3)="Gold Team: "
	TeamColor(0)=(R=255,G=0,B=0,A=0)
	TeamColor(1)=(R=0,G=128,B=255,A=0)
	TeamColor(2)=(R=0,G=255,B=0,A=0)
	TeamColor(3)=(R=255,G=255,B=0,A=0)
	AltTeamColor(0)=(R=200,G=0,B=0,A=0)
	AltTeamColor(1)=(R=0,G=94,B=187,A=0)
	AltTeamColor(2)=(R=0,G=128,B=0,A=0)
	AltTeamColor(3)=(R=255,G=255,B=128,A=0)
	RedColor=(R=255,G=0,B=0,A=0)
	GreenColor=(R=0,G=255,B=0,A=0)
	MainMenuType=Class'UnrealMainMenu'
	SomeoneName="Someone"
	DemoPlaybackProg="Demo: %f %"
	DemoRecInfo="[REC]"
}