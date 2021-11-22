class UMenuStatusBar extends UWindowWindow;

var string ContextHelp;
var localized string DefaultHelp;
var localized string DefaultIntroHelp;

function Created()
{
	Super.Created();
}

function SetHelp(string NewHelp)
{
	ContextHelp = NewHelp;
}

function Close(optional bool bByParent)
{
	Root.Console.CloseUWindow();
}

function Paint(Canvas C, float X, float Y)
{
	local GameInfo G;
	local bool bIntro;

	G = GetLevel().Game;
	bIntro = G != None && G.IsA('UTIntro');

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	DrawUpBevel( C, 0, 0, WinWidth, WinHeight, LookAndFeel.Active);

	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	if (ContextHelp != "")
		ClipText(C, 2, 2, ContextHelp);
	else if (bIntro)
		ClipText(C, 2, 2, DefaultIntroHelp);
	else
		ClipText(C, 2, 2, DefaultHelp);
}

defaultproperties
{
	DefaultHelp="Press ESC to return to the game"
	DefaultIntroHelp="Use the Game menu to start a new game."
}
