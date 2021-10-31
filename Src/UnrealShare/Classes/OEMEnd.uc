//=============================================================================
// OEMEnd.
//=============================================================================
class OEMEnd extends Keypoint;

var PlayerPawn Toucher;

function Touch(Actor Other)
{
	Toucher = PlayerPawn(Other);
	if (Toucher!=None) SetTimer(1.0, False);
}


function Timer()
{

	Toucher.myHUD.MainMenu = Spawn(class'UnrealMainMenu', Toucher.myHUD);
	Toucher.myHUD.MainMenu.Selection = 5;
	Toucher.myHUD.MainMenu.ProcessSelection();
	Toucher.ShowMenu();
	Toucher.GoToState('');
}

defaultproperties
{
	bStatic=False
	CollisionRadius=50.000000
	CollisionHeight=50.000000
	bCollideActors=True
}
