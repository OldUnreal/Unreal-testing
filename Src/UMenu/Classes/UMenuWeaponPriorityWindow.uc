class UMenuWeaponPriorityWindow expands UMenuFramedWindow;

var UWindowSmallCloseButton CloseButton;

function Created()
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));

	SetSizePos();

	MinWinWidth = Max(300, class'UMenuWeaponPriorityCW'.default.ListAreaWidth * 2 + 20);
	MinWinHeight = 170;
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function SetSizePos()
{
	SetSize(Min(700, Root.WinWidth - 50), Min(480, Root.WinHeight - 50));
	WinLeft = int(Root.WinWidth/2 - WinWidth/2);
	WinTop = int(Root.WinHeight/2 - WinHeight/2);
}

function Resized()
{
	MinWinWidth = Max(300, class'UMenuWeaponPriorityCW'.default.ListAreaWidth * 2 + 20);
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
	Super.SaveConfigs();
	GetPlayerOwner().SaveConfig();
}

function NotifyBeforeLevelChange()
{
	Super.NotifyBeforeLevelChange();
	Close(); // So all these weapon classes are forced to clean from memory.
}

defaultproperties
{
	ClientClass=Class'UMenu.UMenuWeaponPriorityCW'
	WindowTitle="Weapons"
}
