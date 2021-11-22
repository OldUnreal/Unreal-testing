class UMenuGameSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuGameSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
