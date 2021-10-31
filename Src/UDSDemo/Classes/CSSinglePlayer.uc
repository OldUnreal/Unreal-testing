//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CSSinglePlayer ]
//
// This actor is the bases for Single Player use of the UDS.  Any map that is
// created that will use the Cut Sequence engine of the UDS needs to be of this
// game type.
//
// It's primary function is to Convert a player from the original Unreal player
// classes to our custom one.
//=============================================================================

class CSSinglePlayer expands UnrealGameInfo;

// Switch players to their Cut Sequence  equivalent as they log in.

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local playerpawn NewPlayer;

		
	if (SpawnClass.Name == 'MaleOne' )
	{
	  SpawnClass = class 'CSMaleOne';
	}
	else if (SpawnClass.Name == 'MaleTwo')   SpawnClass = class 'CSMaleTwo';
	else if (SpawnClass.Name == 'MaleThree') SpawnClass = class 'CSMaleThree';
	else if (SpawnClass.Name == 'FemaleOne' || SpawnClass == class'UnrealSpectator' || SpawnClass == class'DemoRecSpectator' || SpawnClass == class'SkaarjPlayer' )
	{
		SpawnClass = class 'CSFemaleOne';
	}
	else if (SpawnClass.Name == 'FemaleTwo') SpawnClass = class 'CSFemaleTwo';
	else if (SpawnClass.Name == 'UPakMaleOne')   SpawnClass = class 'CSMaleOne';
	else if (SpawnClass.Name == 'UPakMaleTwo')   SpawnClass = class 'CSMaleTwo';
	else if (SpawnClass.Name == 'UPakMaleThree') SpawnClass = class 'CSMaleThree';
	else if (SpawnClass.Name == 'UPakFemaleOne') SpawnClass = class 'CSFemaleOne';
	else if (SpawnClass.Name == 'UPakFemaleTwo') SpawnClass = class 'CSFemaleTwo';


	NewPlayer = Super.Login(Portal, Options, Error, SpawnClass);
	NewPlayer.HudType = class'CS_Hud';
	NewPlayer.ClientAdjustGlow( -1.0, vect( 0, 0, 0 ) );
	Spawn( class'CS_ClientFader', NewPlayer,, Location, Rotation );
	log( "TESTING: "$NewPlayer.HudType );
	return NewPlayer;
}

defaultproperties
{
     DefaultPlayerClass=Class'UDSDemo.CSMaleTwo'
     DefaultWeapon=None
     HUDType=Class'UDSDemo.CS_Hud'
}
