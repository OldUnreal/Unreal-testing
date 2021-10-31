class UMenuHUDConfigScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = Class<UMenuPageWindow>(DynamicLoadObject(GetPlayerOwner().MyHUD.HUDConfigWindowType, class'Class'));
	Super.Created();
}

defaultproperties
{
}
