//=============================================================================
// UnrealQuitMenu
//=============================================================================
class UnrealQuitMenu extends UnrealLongMenu;

var bool bResponse;
var localized string YesSelString;
var localized string NoSelString;

function bool ProcessYes()
{
	bResponse = true;
	return true;
}

function bool ProcessNo()
{
	bResponse = false;
	return true;
}

function bool ProcessLeft()
{
	bResponse = !bResponse;
	return true;
}

function bool ProcessRight()
{
	bResponse = !bResponse;
	return true;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	ChildMenu = None;

	if ( bResponse )
	{
		PlayerOwner.SaveConfig();
		//PlayerOwner.PlayerReplicationInfo.SaveConfig();
		if ( Level.Game != None )
		{
			Level.Game.SaveConfig();
			Level.Game.GameReplicationInfo.SaveConfig();
		}
		PlayerOwner.ConsoleCommand("Exit");
	}
	else
		ExitMenu();
	Return False;
}

function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, SecSpace, BottomTextY;
	local int i;

	DrawBackGround(Canvas, (Canvas.ClipY < 320));

	StartX = 0.5 * Canvas.ClipX - 120;
	StartY = 2;
	Spacing = 9;
	Canvas.Font = Canvas.MedFont;

	Canvas.SetPos(StartX, StartY );
	Canvas.DrawText(MenuList[0], False);
	Canvas.SetPos(StartX+72, StartY+10 );
	Canvas.DrawText(MenuList[1], False);
	StartX = Max(8, 0.5 * Canvas.ClipX - 116);
	Spacing = Clamp(0.04 * Canvas.ClipY, 7, 20);
	StartY = 16 + Spacing;
	SecSpace = Spacing/6;
	BottomTextY = Canvas.ClipY - 66;
	Canvas.Font = Canvas.SmallFont;

	Canvas.SetDrawColorRGB(30, 90, 30);

	for (i = 2; i < ArrayCount(MenuList); ++i)
	{
		if (Len(MenuList[i]) == 0 || StartY + Spacing > BottomTextY)
			break;
		Canvas.SetPos(StartX, StartY);
		Canvas.DrawText(MenuList[i], false);
		StartY += Spacing;
	}

	// draw text
	Canvas.Font = Canvas.MedFont;
	Canvas.SetDrawColorRGB(40, 60, 20);
	SetFontBrightness(Canvas, true);
	StartY = BottomTextY;
	Canvas.bCenter = true;
	Canvas.SetPos(0, StartY );
	if ( bResponse )
		Canvas.DrawText(MenuTitle$YesSelString, False);
	else
		Canvas.DrawText(MenuTitle$NoSelString, False);
	Canvas.DrawColor = Canvas.Default.DrawColor;
	Canvas.bCenter = false;

	// Draw help panel
//	DrawHelpPanel(Canvas, 0.5 * Canvas.ClipY + 16, 228);
}

defaultproperties
{
	YesSelString=" [YES]  No"
	NoSelString="  Yes  [NO]"
	HelpMessage(1)="Select yes and hit enter to return to your puny, miserable, useless real life, if you can't handle UNREALity."
	MenuList(0)="A Digital Extremes/Epic Megagames"
	MenuList(1)="Collaboration"
	MenuList(2)="Game Design: James Schmalz"
	MenuList(3)="    Cliff Bleszinski"
	MenuList(4)="Level Design: Cliff Bleszinski"
	MenuList(5)="    T. Elliot Cannon  Pancho Eekels"
	MenuList(6)="    Jeremy War  Cedric Fiorentino"
	MenuList(7)="    Shane Caudle"
	MenuList(8)="Animator: Dave Carter"
	MenuList(9)="Art: James Schmalz "
	MenuList(10)="    Mike Leatham  Artur Bialas"
	MenuList(11)="Programming: Tim Sweeney  Steven Polge"
	MenuList(12)="    Erik de Neve  James Schmalz"
	MenuList(13)="    Carlo Vogelsang  Nick Michon"
	MenuList(14)="Music: Alexander Brandon"
	MenuList(15)="    Michiel van den Bos"
	MenuList(16)="Sound Effects: Dave Ewing"
	MenuList(17)="Producer for GT: Jason Schreiber"
	MenuList(18)="Biz: Mark Rein Nigel Kent"
	MenuList(19)="    Craig Lafferty"
	MenuList(20)="Oldunreal patch: Jochen Goernitz"
	MenuList(21)="    and the Oldunreal community"
	MenuTitle="Quit?"
}
