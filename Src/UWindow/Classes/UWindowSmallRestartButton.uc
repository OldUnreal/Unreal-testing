class UWindowSmallRestartButton extends UWindowSmallButton;

var localized string RestartText;

function Created()
{
	Super.Created();
	SetText(RestartText);
}

//function Click(float X, float Y)
//{
//	UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).Close();
//}

defaultproperties
{
	RestartText="Restart"
}