class UMenuStartRecWindow expands UMenuFramedWindow;

function Created()
{
	Super.Created();
	MinWinWidth = 240;
	MinWinHeight = 80;
	SetSize(MinWinWidth, WinHeight);
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, ClientArea.WinLeft, ClientArea.WinTop + ClientArea.WinHeight, ClientArea.WinWidth, 24, T);

	Super.Paint(C, X, Y);
}

defaultproperties
{
	ClientClass=Class'UMenuStartRec'
	WindowTitle="Start recording"
	bTransient=False
	bLeaveOnscreen=True
}
