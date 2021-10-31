//=============================================================================
// UnrealNewGameMenu
//=============================================================================
class UnrealNewGameMenu extends UnrealGameMenu;

const BonusDifficulty=4;
var string StartMap;

function Destroyed()
{
	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.Game != none)
		Selection = Clamp(Level.Game.Difficulty + 1, 1, 7);
	else
		Selection = 1;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	ChildMenu = spawn(class'UnrealMeshMenu', owner);
	HUD(Owner).MainMenu = ChildMenu;
	ChildMenu.ParentMenu = self;
	ChildMenu.PlayerOwner = PlayerOwner;
	StartMap = StartMap$"?Difficulty="$(Selection - 1);
	if ( Level.Game != None )
		StartMap = StartMap$"?GameSpeed="$Level.Game.GameSpeed;
	UnrealMeshMenu(ChildMenu).StartMap = StartMap;
	UnrealMeshMenu(ChildMenu).SinglePlayerOnly = true;
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

	if ( bLargeFont )
	{
		if ( Spacing < 30 )
		{
			StartX += 0.5 * ( 0.5 * Canvas.ClipX - StartX);
			Canvas.Font = Canvas.BigFont;
		}
		else
			Canvas.Font = Canvas.LargeFont;
	}
	else
		Canvas.Font = Canvas.MedFont;

	F = 0.5 + Sin(Level.RealTimeSeconds*3.f)*0.5f;
	for (i=0; i<MenuLength; i++ )
	{
		if( i<BonusDifficulty )
			SetFontBrightness(Canvas, (i == Selection - 1) );
		else if( i==(Selection - 1) )
		{
			j = 32 + int(F*223.f);
			Canvas.DrawColor = MakeColor(255,j,j);
		}
		else
		{
			j = int(F*127.f);
			Canvas.DrawColor = MakeColor(127,j,j);
		}
		Canvas.SetPos(StartX, StartY + Spacing * i);
		Canvas.DrawText(MenuList[i + 1], false);
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
	if( Selection>BonusDifficulty )
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
	MenuLength=7
	HelpMessage(1)="Tourist mode."
	HelpMessage(2)="Ready for some action!"
	HelpMessage(3)="Not for the faint of heart."
	HelpMessage(4)="Death wish."
	HelpMessage(5)="For players who want an extra difficulty."
	HelpMessage(6)="For the hardcore gamers."
	HelpMessage(7)="HOLY SHIT!"
	MenuList(1)="EASY"
	MenuList(2)="MEDIUM"
	MenuList(3)="HARD"
	MenuList(4)="UNREAL"
	MenuList(5)="EXTREME"
	MenuList(6)="NIGHTMARE"
	MenuList(7)="ULTRA-UNREAL"
}
