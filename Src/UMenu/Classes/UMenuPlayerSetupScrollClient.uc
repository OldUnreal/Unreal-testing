class UMenuPlayerSetupScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuPlayerSetupClient';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
