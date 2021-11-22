class UMenuBotmatchWindow extends UMenuFramedWindow;

function Created()
{
	bStatusBar = False;
	bSizable = False;

	Super.Created();

	SetSizePos();
}

function SetSizePos()
{
	if (Root.WinHeight < 290)
		SetSize(Min(Root.WinWidth-10, 520) , 220);
	else
		SetSize(Min(Root.WinWidth-10, 520), 270);

	WinLeft = int(Root.WinWidth/2 - WinWidth/2);
	WinTop = int(Root.WinHeight/2 - WinHeight/2);
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function SaveConfigs()
{
	ClientArea.SaveConfig();
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	ClientClass=Class'UMenu.UMenuBotmatchClientWindow'
	WindowTitle="Botmatch"
}
