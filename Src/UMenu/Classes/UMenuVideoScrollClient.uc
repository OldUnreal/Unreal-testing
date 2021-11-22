class UMenuVideoScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuVideoClientWindow';
	FixedAreaClass = None;//class'UMenuScrollWindowOKArea';
	Super.Created();
}

defaultproperties
{
}
