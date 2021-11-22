class UWindowConsoleWindow extends UWindowFramedWindow;

var float OldParentWidth, OldParentHeight;

function Created()
{
	Super.Created();
	bSizable = True;
	bStatusBar = True;
	bLeaveOnScreen = True;

	OldParentWidth = ParentWindow.WinWidth;
	OldParentHeight = ParentWindow.WinHeight;

	SetDimensions();

	SetAcceptsFocus();
}

function ShowWindow()
{
	Super.ShowWindow();

	if (ParentWindow.WinWidth != OldParentWidth || ParentWindow.WinHeight != OldParentHeight)
	{
		SetDimensions();
		OldParentWidth = ParentWindow.WinWidth;
		OldParentHeight = ParentWindow.WinHeight;
	}
}

function ResolutionChanged(float W, float H)
{
	SetDimensions();
}

function SetDimensions()
{
	// CHANGED 227
	SetSize(ParentWindow.WinWidth *0.9, ParentWindow.WinHeight*0.9);
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop = ParentWindow.WinHeight/2 - WinHeight/2;
}


function Close(optional bool bByParent)
{
	ClientArea.Close(True);
	Root.Console.HideConsole();
	Root.CheckUWindowActivation();
}

defaultproperties
{
	ClientClass=Class'UWindow.UWindowConsoleClientWindow'
	WindowTitle="System Console"
}
