class UMenuAudioScrollClient extends UWindowScrollingDialogClient;

function Created()
{
	ClientClass = class'UMenuAudioClientWindow';
	FixedAreaClass = None;
	Super.Created();
}

defaultproperties
{
}
