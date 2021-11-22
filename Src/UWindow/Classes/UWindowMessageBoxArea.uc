class UWindowMessageBoxArea expands UWindowWindow;

var string Message;

function float GetHeight(Canvas C)
{
	local float TW, TH, H;
	local int L;
	local float OldWinHeight;

	OldWinHeight = WinHeight;
	WinHeight = 1000;
	C.Font = Root.Fonts[F_Normal];
	TextSize(C, "A", TW, TH);
	L = WrapClipText(C, 0, 0, Message,,,, True);
	H = TH * L;
	WinHeight = OldWinHeight;
	return H;
}

function Paint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	WrapClipText(C, 0, 0, Message);
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

defaultproperties
{
}
