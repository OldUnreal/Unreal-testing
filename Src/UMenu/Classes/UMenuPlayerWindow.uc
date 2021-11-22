class UMenuPlayerWindow extends UMenuFramedWindow;

var UWindowSmallCloseButton CloseButton;

function Created()
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));

	SetSizePos();
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function SetSizePos()
{
	if (Root.WinHeight < 400)
		SetSize(Root.WinWidth - 10, Root.WinHeight - 32);
	else
		SetSize(Max(450, Root.WinWidth - 150), Root.WinHeight - 50);

	WinLeft = int(Root.WinWidth/2 - WinWidth/2);
	WinTop = int(Root.WinHeight/2 - WinHeight/2);
}

function Resized()
{
	Super.Resized();
	ClientArea.SetSize(ClientArea.WinWidth, ClientArea.WinHeight-24);
	CloseButton.WinTop = ClientArea.WinTop+ClientArea.WinHeight+4;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, ClientArea.WinLeft, ClientArea.WinTop + ClientArea.WinHeight, ClientArea.WinWidth, 24, T);

	CloseButton.AutoWidth(C);
	CloseButton.WinLeft = WinWidth - CloseButton.WinWidth - 4;

	Super.Paint(C, X, Y);
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	ClientClass=Class'UMenu.UMenuPlayerClientWindow'
	WindowTitle="Player Setup"
}
