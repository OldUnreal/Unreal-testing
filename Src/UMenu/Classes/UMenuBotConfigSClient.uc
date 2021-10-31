class UMenuBotConfigSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuBotConfigClientWindow';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
