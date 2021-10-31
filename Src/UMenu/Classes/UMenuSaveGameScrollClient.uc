class UMenuSaveGameScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuSaveGameClientWindow';
	//FixedAreaClass = class'UMenuScrollWindowOKArea';
	Super.Created();
}

defaultproperties
{
}
