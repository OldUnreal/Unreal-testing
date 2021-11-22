class UMenuDialogClientWindow extends UWindowDialogClientWindow;

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (E == DE_MouseMove)
	{
		if (UMenuRootWindow(Root) != None)
			if (UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);
	}

	if (E == DE_HelpChanged && C.MouseIsOver())
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

defaultproperties
{
}
