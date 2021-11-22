//=============================================================================
// TerranWeaponMatch.
//=============================================================================
class TerranWeaponMatch expands DeathMatchGame;

function PostBeginPlay()
{
	Class'CloakMatch'.Static.TerranWeaponSetup(Self);
	Super.PostBeginPlay();
}
function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();
	GameName = Class'DeathMatchGame'.Default.GameName;
}

defaultproperties
{
     GameName="TerranWeaponMatch"
}
