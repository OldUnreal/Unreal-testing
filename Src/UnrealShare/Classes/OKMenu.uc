//=============================================================================
// OKMenu
//=============================================================================
class OKMenu extends UnrealInfoMenu;

var localized string OKString;

function ProcessResponse()
{
	//process

	ExitMenu();
}

function DrawResponse(canvas Canvas)
{
	Canvas.SetPos(100,84);
	Canvas.DrawText(OKString, False);
}

function bool ProcessYes()
{
	ProcessResponse();
	return true;
}

function bool ProcessSelection()
{
	ProcessResponse();
	return true;
}

defaultproperties
{
	OKString="[OK]"
}
