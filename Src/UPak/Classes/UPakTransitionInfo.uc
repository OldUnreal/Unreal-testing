//=============================================================================
// UPakTransitionInfo.
//=============================================================================
class UPakTransitionInfo expands UnrealGameInfo;

var PlayerPawn PlayerArray[ 32 ];
var int PlayerArrayIncrementer;
var() String AppendURL;
var PlayerPawn TargetPlayer;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	local GreenBook BookCamera;
	local UPakCamTrigger UPCT;
	
	if( !ClassIsChildOf( SpawnClass, class'UPakPlayer' ) )
		SpawnClass = SwitchFromUnrealPlayer( SpawnClass );
	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.JumpSound = none;
	PlayerArray[ PlayerArrayIncrementer ] = NewPlayer;
	PlayerArrayIncrementer++;
	
	NewPlayer.bHidden = True;
	NewPlayer.ClientAdjustGlow( -1.0, vect( 0, 0, 0 ) );
	
	foreach AllActors(class'GreenBook', BookCamera)
	{
		NewPlayer.ViewTarget = BookCamera;
		BookCamera.SetCollisionSize( 0, 0 );
		BookCamera.SetCollision( false, false );
		BookCamera.bProjTarget = false;
	}
	
	if( NewPlayer.ViewTarget == none )
	{
		foreach allactors( class'UPakCamTrigger', UPCT )
			UPCT.Touch( NewPlayer );
	}
	// Set the player's transition settings (and console)
	NewPlayer.SetPhysics( PHYS_None );
	NewPlayer.bShowMenu = false;
	NewPlayer.SetCollisionSize( 0, 0 );
	NewPlayer.SetCollision( false, false );
	NewPlayer.bProjTarget = false;
	NewPlayer.Visibility = 0;
	NewPlayer.Land = none;
	UnrealIPlayer(NewPlayer).LandGrunt = none;
	UnrealIPlayer(NewPlayer).FootStep1 = none;
	UnrealIPlayer(NewPlayer).FootStep2 = none;
	UnrealIPlayer(NewPlayer).FootStep3 = none;
	NewPlayer.AirControl = 0;
	NewPlayer.GroundSpeed = 0;
	NewPlayer.bIsAmbientCreature = true;
	NewPlayer.bHidden = true;
	TargetPlayer = NewPlayer;
	SetTimer( 0.5, false );
	return NewPlayer;
}


function Timer()
{
	AdjustVolume();
	TargetPlayer.HearingThreshold = 500;
	if( UPakConsole(TargetPlayer.Player.Console)!=None )
		UPakConsole( TargetPlayer.Player.Console ).bTransition = true;
}

function AdjustVolume()
{
	local ScriptedPawn SP;
	
	foreach allactors( class'ScriptedPawn', SP )
	{
		SP.SoundVolume = 0;
		SP.TransientSoundVolume = 0;
		SP.Acquire = none;
		SP.Threaten = none;
	}
}
	

function bool RedirectorSearch()
{
	local TransitionRedirector TR;
	
	foreach allactors( class'TransitionRedirector', TR )
		AppendURL = TR.URL;
		
	return true;
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
	else if( ClassIsChildOf( SpawnClass, class'Female' ) )
	{
		if( ClassIsChildOf( SpawnClass, class'FemaleOne' ) )
			return class'UPakFemaleOne';
		else if( ClassIsChildOf( SpawnClass, class'FemaleTwo' ) )
			return class'UPakFemaleTwo';
	}
	else return class'UPakFemaleOne';
}

defaultproperties
{
     DefaultWeapon=None
     HUDType=Class'UPak.TransitionNullHUD'
}
