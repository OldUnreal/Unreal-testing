class UMenuGameOptionsScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuGameOptionsClientWindow';
	FixedAreaClass = None;//class'UMenuScrollWindowOKArea';
	Super.Created();
}

defaultproperties
{
}
