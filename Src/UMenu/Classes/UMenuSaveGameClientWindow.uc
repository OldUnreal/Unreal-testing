class UMenuSaveGameClientWindow extends UMenuSlotClientWindow;

var localized string CantSave;

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Click:
		if (GetPlayerOwner().Health <= 0 || GetPlayerOwner().Level.NetMode != NM_Standalone)
			return;

		Root.GetPlayerOwner().bDelayedCommand = true;
		Root.GetPlayerOwner().DelayedCommand = "SaveGame" @ UMenuRaisedButton(C).Index;
		GetParent(Class'UWindowFramedWindow', false).Close();
		Root.Console.CloseUWindow();
	}
}

function WindowShown()
{
	super.WindowShown();
	if (UMenuSaveGameScrollClient(ParentWindow) != none &&
		UMenuSaveGameWindow(ParentWindow.ParentWindow) != none)
	{
		if (Root.GetPlayerOwner().Health <= 0)
			UMenuSaveGameWindow(ParentWindow.ParentWindow).WindowTitle = CantSave;
		else
			UMenuSaveGameWindow(ParentWindow.ParentWindow).WindowTitle = class'UMenuSaveGameWindow'.default.WindowTitle;
	}
}

defaultproperties
{
	CantSave="Cannot Save: You are dead."
	bSaveGame=true
}