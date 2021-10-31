class UMenuConsoleWindow extends UWindowConsoleWindow;

function Created()
{
	Super.Created();

	UWindowConsoleClientWindow(ClientArea).TextArea.Font = F_Normal;
}

defaultproperties
{
}
