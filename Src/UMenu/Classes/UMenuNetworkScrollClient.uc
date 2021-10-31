class UMenuNetworkScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuNetworkClientWindow';
	FixedAreaClass = None;//class'UMenuScrollWindowOKArea';
	Super.Created();
}

defaultproperties
{
}
