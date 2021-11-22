class UMenuSinglePlayerSettingsSClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuSinglePlayerSettingsCWindow';
	FixedAreaClass = None;
	Super.Created();
}
