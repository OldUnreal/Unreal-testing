/*
New in 227, allow custom modders easly set up a custom UWindow menu for their gametype.
Warning: If you want keep your server/mod backwards compatible, do not use this feature then!
Useage: Simply call function WindowConsole.SetCustomUMenu(<Your menu class>); and it will handle rest of it automatly.
*/
Class UWindowCustomMenu extends UWindowFramedWindow;

function Created()
{
	bStatusBar = False;
	bSizable = True;

	Super.Created();

	MinWinWidth = 200;
	MinWinHeight = 100;

	SetSizePos();
}
function SetSizePos()
{
	SetSize(ParentWindow.WinWidth *0.6, ParentWindow.WinHeight*0.8);
	WinLeft = Root.WinWidth/2 - WinWidth/2;
	WinTop = Root.WinHeight/2 - WinHeight/2;
}
function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

// Auto unloading this menu on mapchange:
function NotifyBeforeLevelChange()
{
	Super.NotifyBeforeLevelChange();
	Close();
}

defaultproperties
{
	ClientClass=Class'UWindow.UWindowConsoleClientWindow'
	bLeaveOnscreen=True
}
