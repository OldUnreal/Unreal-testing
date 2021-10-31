//=============================================================================
// UPakSinglePlayer.
// $Author: Jcrable $
// $Date: 5/05/99 4:21p $
// $Revision: 2 $
//=============================================================================

class UPakSinglePlayer expands SinglePlayer;


event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	if( SpawnClass != class'UPakMaleOne'
		&& SpawnClass != class'UPakMaleTwo'
		&& SpawnClass != class'UPakMaleThree'
		&& SpawnClass != class'UPakFemaleOne'
		&& SpawnClass != class'UPakFemaleTwo' )
		SpawnClass = SwitchFromUnrealPlayer( SpawnClass );
	Return Super.Login(Portal,Options,Error,SpawnClass);
}	


// *** Jess: Killed is where deaths seem to be reliably reported, so update the stat info here.

function Killed( pawn killer, pawn Other, name damageType )
{
	local string killed;
	local string KillerWeaponName;
	local string DeathMessage;
	local string message;

	if( Other.IsA( 'PlayerPawn' ) )
	{
		super.Killed(killer, Other, damageType);
		return;
	}

	if( Killer != None && Killer.IsA( 'PlayerPawn' ) )
	{
		Killer.KillCount++;
		UPakReplicationInfo(Killer.PlayerReplicationInfo).TotalKills++;
	
		if( Killer.Weapon==None )
			UPakPlayer( Killer ).TotalKills++; // Earn double kill for killing with ur bare hands!
		else if( Killer.Weapon.IsA('CARifle') )
			UPakPlayer( Killer ).CARKills++;
		else if( Killer.Weapon.IsA('RocketLauncher') )
			UPakPlayer( Killer ).RLKills++;
		else if( Killer.Weapon.IsA('GrenadeLauncher') )
			UPakPlayer( Killer ).GLKills++;
		else if( Killer.Weapon.IsA( 'ASMD' ) )
			UPakPlayer( Killer ).ASMDKills++;
		else if( Killer.Weapon.IsA( 'Automag' ) )
			UPakPlayer( Killer ).AutomagKills++;
		else if( Killer.Weapon.IsA( 'Rifle' ) )
			UPakPlayer( Killer ).RifleKills++;
		else if( Killer.Weapon.IsA( 'FlakCannon' ) )
			UPakPlayer( Killer ).FlakCannonKills++;
		else if( Killer.Weapon.IsA( 'DispersionPistol' ) )
			UPakPlayer( Killer ).DispersionKills++;
		else if( Killer.Weapon.IsA( 'Eightball' ) )
			UPakPlayer( Killer ).EightballKills++;
		else if( Killer.Weapon.IsA( 'Minigun' ) )
			UPakPlayer( Killer ).MinigunKills++;
		else if( Killer.Weapon.IsA( 'Razorjack' ) )
			UPakPlayer( Killer ).RazorjackKills++;
		else if( Killer.Weapon.IsA( 'Stinger' ) )
			UPakPlayer( Killer ).StingerKills++;
		UPakPlayer( Killer ).TotalKills++;
		if (Other.bIsPlayer)
		{
			if (bClassicDeathmessages)
			{
				killed = Other.PlayerReplicationInfo.PlayerName;
				if( killer==None || killer==other )
					message = KillMessage(damageType, Other);
				else 
					message = killer.KillMessage(damageType, Other);
				if( !Other.IsA( 'SpaceMarine' ) )
					BroadcastMessage(killed$message, false, 'DeathMessage');
			} 
			else
			{
				killed = Other.PlayerReplicationInfo.PlayerName;
				if( killer==None || killer==other )
				{
					message = KillMessage(damageType, Other);
					BroadcastMessage(killed$message, false, 'DeathMessage');
				} 
				else 
				{
					if( Killer.Weapon != None )
					{
						KillerWeaponName = Killer.Weapon.ItemName;
						DeathMessage = Killer.Weapon.DeathMessage;
					}
					message = ParseKillMessage( Killer.PlayerReplicationInfo.PlayerName, Other.PlayerReplicationInfo.PlayerName, KillerWeaponName, DeathMessage);
					BroadcastMessage(message, false, 'DeathMessage');
				}
			}
		}
	}
}
//
// Optional handling of ServerTravel for network games.
//
function ProcessServerTravel( string URL, bool bItems )
{
	local playerpawn P;

	// Notify clients we're switching level and give them time to receive.
	log("ProcessServerTravel: "$URL);
	foreach AllActors( class'PlayerPawn', P )
		if( NetConnection(P.Player)!=None )
			P.ClientTravel( URL, TRAVEL_Relative, bItems );

	// Switch immediately if not networking.
	if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
	{
		Level.NextURL = URL;
		Level.NextSwitchCountdown = 0.0;
	}
}

function class< PlayerPawn > SwitchFromUnrealPlayer( class<PlayerPawn> SpawnClass )
{
	log( "///////////////////////////////////////////////////" );
	log( "Player class ("$SpawnClass$") is not a UPakPlayer." );
	log( "Adjusting player class." );
	log( "///////////////////////////////////////////////////" );
	
	if( ClassIsChildOf( SpawnClass, class'Male' ) )
	{
		if( ClassIsChildOf( SpawnClass, class'MaleOne' ) )
			return class'UPakMaleOne';
		else if( ClassIsChildOf( SpawnClass, class'MaleTwo' ) )
			return class'UPakMaleTwo';
		else if( ClassIsChildOf( SpawnClass, class'MaleThree' ) )
			return class'UPakMaleThree';
	}
	else if( ClassIsChildOf( SpawnClass, class'Female' ) || ClassIsChildOf( SpawnClass, class'Spectator' ))
	{
		if( ClassIsChildOf( SpawnClass, class'FemaleOne' ) )
			return class'UPakFemaleOne';
		else if( ClassIsChildOf( SpawnClass, class'FemaleTwo' ) )
			return class'UPakFemaleTwo';
	}
	else return class'UPakMaleOne';
}

defaultproperties
{
     HUDType=Class'UPak.UPakHUD'
     GameName="Unreal Mission Pack"
}
