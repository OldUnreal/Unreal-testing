//=============================================================================
// ScoreBoard
//=============================================================================
class ScoreBoard extends Info
	NoUserCreate;

var font RegFont;
var HUD OwnerHUD;

function ShowScores( canvas Canvas );

function PreBeginPlay()
{
}

defaultproperties
{
	bHidden=True
}
