// For displaying network error status.
class UWindowNetErrorWindow extends UWindowFramedWindow;

var float OldParentWidth, OldParentHeight;

function Created()
{
	Super.Created();
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
	SetSize(Min(ParentWindow.WinWidth,340),Min(ParentWindow.WinHeight,120));
	WinLeft = ParentWindow.WinWidth/2 - WinWidth/2;
	WinTop = ParentWindow.WinHeight/3 - WinHeight/2;
}

defaultproperties
{
	ClientClass=Class'UWindowNetErrorClientWindow'
	WindowTitle="Player Network error status"
	bSizable=True
	bStatusBar=False
	bLeaveOnScreen=True
}
