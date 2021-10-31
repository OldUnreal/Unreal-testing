class UMenuBotSetupSC extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuBotSetupClient';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
