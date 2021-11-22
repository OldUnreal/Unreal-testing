class UMenuInputOptionsScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuInputOptionsClientWindow';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
