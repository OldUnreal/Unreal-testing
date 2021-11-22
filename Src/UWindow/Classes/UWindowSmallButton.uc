class UWindowSmallButton extends UWindowButton;

function Created()
{
	bNoKeyboard = True;

	Super.Created();

	ToolTipString = "";
	SetText("");
	SetFont(F_Normal);

	WinHeight = 16;
}

function AutoWidth(Canvas C)
{
	local float W, H;
	C.Font = Root.Fonts[Font];

	TextSize(C, RemoveAmpersand(Text), W, H);

	if (WinWidth < W + 10)
		WinWidth = W + 10;
}

function AutoWidthBy(Canvas C, out float MinWidth)
{
	local float TextWidth, TextHeight;

	C.Font = Root.Fonts[Font];
	TextSize(C, RemoveAmpersand(Text), TextWidth, TextHeight);
	WinWidth = FMax(MinWidth, TextWidth + 10);
	if (MinWidth < WinWidth)
		MinWidth = WinWidth;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;
	C.Font = Root.Fonts[Font];

	TextSize(C, RemoveAmpersand(Text), W, H);

	TextX = (WinWidth-W)/2;
	TextY = (WinHeight-H)/2;

	if (bMouseDown)
	{
		TextX += 1;
		TextY += 1;
	}
}

function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.Button_DrawSmallButton(Self, C);
	Super.Paint(C, X, Y);
}

defaultproperties
{
}
