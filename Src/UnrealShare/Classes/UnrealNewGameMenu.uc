//=============================================================================
// UnrealNewGameMenu
//=============================================================================
class UnrealNewGameMenu extends UnrealGameMenu;

const BonusDifficulty=5;
var string StartMap;
var localized string ModeString[2];
var bool bClassicMode;

function Destroyed()
{
	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bClassicMode = Class'GameInfo'.Default.bUseClassicBalance;
	Selection = Clamp(Class'UnrealChooseGameMenu'.Default.LastSelectedSkill+1, 1, MenuLength-1);
}

function bool ProcessLeft()
{
	if( Selection==MenuLength )
	{
		bClassicMode = !bClassicMode;
		return true;
	}
	return false;
}
function bool ProcessRight()
{
	return ProcessLeft();
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if( Selection==MenuLength )
		bClassicMode = !bClassicMode;
	else
	{
		Class'UnrealChooseGameMenu'.Default.LastSelectedSkill = Selection-1;
		Class'UnrealChooseGameMenu'.Static.StaticSaveConfig();
		
		ChildMenu = spawn(class'UnrealMeshMenu', owner);
		HUD(Owner).MainMenu = ChildMenu;
		ChildMenu.ParentMenu = self;
		ChildMenu.PlayerOwner = PlayerOwner;
		StartMap = StartMap$"?Difficulty="$(Selection-1)$"?ClassicMode="$bClassicMode;
		UnrealMeshMenu(ChildMenu).StartMap = StartMap;
		UnrealMeshMenu(ChildMenu).SinglePlayerOnly = true;
	}
	return true;
}

function SaveConfigs();


function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing;

	DrawBackGround(Canvas, false);

	Spacing = Clamp(0.1 * Canvas.ClipY, 16, 48);
	StartX = Max(40, 0.5 * Canvas.ClipX - 96);
	StartY = Max(8, 0.5 * (Canvas.ClipY - 5 * Spacing - 128));

	DrawList(Canvas, true, Spacing, StartX, StartY);
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing + 8, 228);
}

function DrawList(canvas Canvas, bool bLargeFont, int Spacing, int StartX, int StartY)
{
	local int i;
	local float F;
	local byte j;
	local Font OrgFont;

	if ( bLargeFont )
	{
		if ( Spacing < 30 )
		{
			StartX += 0.5 * ( 0.5 * Canvas.ClipX - StartX);
			OrgFont = Canvas.BigFont;
		}
		else
			OrgFont = Canvas.LargeFont;
	}
	else OrgFont = Canvas.MedFont;

	Canvas.Font = Canvas.MedFont;
	F = 0.5 + Sin(Level.RealTimeSeconds*3.f)*0.5f;
	for (i=0; i<MenuLength; i++ )
	{
		Canvas.SetPos(StartX, StartY + Spacing * i);
		if( i==0 )
		{
			SetFontBrightness(Canvas, (MenuLength == Selection) );
			Canvas.DrawText("< "$MenuList[MenuLength]$ModeString[bClassicMode ? 1 : 0]$" >", false);
			Canvas.Font = OrgFont;
		}
		else
		{
			if( i<BonusDifficulty )
				SetFontBrightness(Canvas, (i == Selection) );
			else if( i==Selection )
			{
				j = 32 + int(F*223.f);
				Canvas.DrawColor = MakeColor(255,j,j);
			}
			else
			{
				j = int(F*127.f);
				Canvas.DrawColor = MakeColor(127,j,j);
			}
			Canvas.DrawText(MenuList[i], false);
		}
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

function DrawHelpPanel(canvas Canvas, int MinStartY, int XClip)
{
	local int OldXClip, OldYClip;
	local int StartX, StartY;
	local float XL, YL;

	if ( Canvas.ClipY < 92 + MinStartY )
		return;

	StartX = 0.5 * Canvas.ClipX - 128;
	StartY = Canvas.ClipY - 92;
	OldXClip = Canvas.ClipX;
	OldYClip = Canvas.ClipY;

	Canvas.bCenter = false;
	if( Selection>=BonusDifficulty && Selection<MenuLength )
	{
		Canvas.Font = Font'WhiteFont';
		Canvas.DrawColor = MakeColor(255,8,8);
	}
	else
	{
		Canvas.Font = Canvas.MedFont;
		SetFontBrightness(Canvas, true);
	}
	Canvas.SetOrigin(StartX + 18, StartY);
	Canvas.SetClip(XClip,128);
	Canvas.SetPos(0,0);
	Canvas.Style = 1;
	if ( Selection < 20 )
	{
		Canvas.StrLen(HelpMessage[Selection], XL, YL);
		if (YL <= Canvas.ClipY && MinStartY + YL <= OldYClip)
		{
			if (StartY + YL > OldYClip)
				Canvas.OrgY = OldYClip - YL;
			Canvas.DrawText(HelpMessage[Selection], false);
		}
	}
	SetFontBrightness(Canvas, false);
	Canvas.SetOrigin(0, 0);
	Canvas.SetClip(OldXClip,OldYClip);
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

defaultproperties
{
	MenuLength=8
	HelpMessage(1)="Tourist mode."
	HelpMessage(2)="Ready for some action!"
	HelpMessage(3)="Not for the faint of heart."
	HelpMessage(4)="Death wish."
	HelpMessage(5)="For players who want an extra difficulty."
	HelpMessage(6)="For the hardcore gamers."
	HelpMessage(7)="HOLY SHIT!"
	HelpMessage(8)="Should gameplay contain some minor bugfixes or remain classic?"
	MenuList(1)="EASY"
	MenuList(2)="MEDIUM"
	MenuList(3)="HARD"
	MenuList(4)="UNREAL"
	MenuList(5)="EXTREME"
	MenuList(6)="NIGHTMARE"
	MenuList(7)="ULTRA-UNREAL"
	MenuList(8)="Balance Mode: "
	ModeString(0)="Enhanced"
	ModeString(1)="Classic"
}
