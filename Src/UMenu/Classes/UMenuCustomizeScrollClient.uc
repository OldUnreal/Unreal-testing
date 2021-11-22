class UMenuCustomizeScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuCustomizeClientWindow';
	FixedAreaClass = None;
	Super.Created();
}

function bool AllowsMouseWheelScrolling()
{
	return
		UMenuCustomizeClientWindow(ClientArea) != none &&
		AppSeconds() - UMenuCustomizeClientWindow(ClientArea).MouseWheelBindingTimestamp > 0.4;
}

defaultproperties
{
}
