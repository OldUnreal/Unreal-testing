//=============================================================================
// UnrealGameInfo.
//
// default game info is normal single player
//
//=============================================================================
class SinglePlayer extends UnrealGameInfo
	NoUserCreate;

var string StartMap;
var() globalconfig bool bUseExactHSDetection; // Monsters should use precise headshot detection?

function PostBeginPlay()
{
	Super.PostBeginPlay();

	bClassicDeathmessages = True;
}

function Killed(pawn killer, pawn Other, name damageType)
{
	super.Killed(killer, Other, damageType);
	if ( Other!=None && Other.IsA('Nali') && Killer!=None && killer.PlayerReplicationInfo!=None )
		killer.PlayerReplicationInfo.Score -= 2;
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

function DiscardInventory(Pawn Other)
{
	if ( Other.Weapon != None )
		Other.Weapon.PickupViewScale *= 0.7;
	Super.DiscardInventory(Other);
}

defaultproperties
{
	bHumansOnly=True
	GameName="Unreal"
	StartMap="..\\maps\\Vortex2.unr"
	RulesMenuType=""
	SettingsMenuType="UMenu.UMenuSinglePlayerSettingsSClient"
	BotMenuType=""
}
