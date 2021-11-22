class UMenuStartMatchScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuStartMatchClientWindow';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
