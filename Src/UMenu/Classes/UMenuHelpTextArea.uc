class UMenuHelpTextArea extends UWindowWindow;

var string HelpText;

function Created()
{
	bAlwaysBehind = True;
}

function Paint(Canvas C, float X, float Y)
{
	C.SetPos(1, 1);
	C.DrawText(HelpText);
}

defaultproperties
{
}
