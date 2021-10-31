class UMenuRecPlayWindow expands UMenuFramedWindow;

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, ClientArea.WinLeft, ClientArea.WinTop + ClientArea.WinHeight, ClientArea.WinWidth, 24, T);

	Super.Paint(C, X, Y);
}

function Created()
{
	Super.Created();
	MinWinWidth = 240;
	MinWinHeight = 240;
	SetSize(MinWinWidth, WinHeight);
}

function ShowWindow()
{
	Super.ShowWindow();
	UMenuRecGrid(FindChildWindow(Class'UMenuRecGrid',true)).UpdateDemoList();
}

defaultproperties
{
	ClientClass=Class'UMenuRecPlay'
	WindowTitle="Play recording"
	bTransient=False
	bLeaveOnscreen=True
	bSizable=true
}
