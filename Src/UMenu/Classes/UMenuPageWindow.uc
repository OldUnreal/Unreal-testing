class UMenuPageWindow extends UWindowPageWindow;

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	LookAndFeel.DrawClientArea(Self, C);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (E == DE_MouseMove)
	{
		if (UMenuRootWindow(Root) != None)
			if (UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);
	}

	if (E == DE_MouseLeave)
	{
		if (UMenuRootWindow(Root) != None)
			if (UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp("");
	}
}

function float VScrollbarWidth()
{
	local UWindowScrollingDialogClient ScrollingDialogClient;

	ScrollingDialogClient = UWindowScrollingDialogClient(ParentWindow);
	if (ScrollingDialogClient != none && ScrollingDialogClient.VertSB != none)
		return ScrollingDialogClient.VertSB.WinWidth;
	return 0;
}

function Object FindObj(class<Object> ObjClass, string ObjectName)
{
	local Object Obj;
	Obj = FindObject(ObjClass, ObjectName);
	if (ObjectName ~= string(Obj))
		return Obj;
	return none;
}

defaultproperties
{
}
