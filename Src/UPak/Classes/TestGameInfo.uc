//=============================================================================
// TestGameInfo.
//=============================================================================
class TestGameInfo expands UnrealGameInfo;

function bool ShouldRespawn(Actor Other)
{
	return ( Inventory(Other) != None && Inventory(Other).ReSpawnTime != 0.0 );
}

defaultproperties
{
}
