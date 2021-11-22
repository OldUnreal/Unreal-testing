class UWindowRightClickMenu expands UWindowPulldownMenu;

function Created()
{
	bTransient = True;
	Super.Created();
}

function RMouseDown(float X, float Y)
{
	LMouseDown(X, Y);
}

function RMouseUp(float X, float Y)
{
	LMouseUp(X, Y);
}

function CloseUp() //UG optional bool bByOwner)
{
	Super.CloseUp(); //UG bByOwner);
	HideWindow();
}

defaultproperties
{
}
