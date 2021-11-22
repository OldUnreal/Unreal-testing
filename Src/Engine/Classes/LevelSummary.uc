//=============================================================================
// LevelSummary contains the summary properties from the LevelInfo actor.
// Designed for fast loading.
//=============================================================================
class LevelSummary extends Object
	native
	runtimestatic;

//-----------------------------------------------------------------------------
// Properties.

// From LevelInfo.
var() localized string Title;
var()           string Author;
var() localized string IdealPlayerCount;
var() int	RecommendedEnemies;
var() int	RecommendedTeammates;
var() localized string LevelEnterText;

defaultproperties
{
}
