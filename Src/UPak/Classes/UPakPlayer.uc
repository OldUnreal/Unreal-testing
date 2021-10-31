//=============================================================================
// UPakPlayer.
//=============================================================================
class UPakPlayer expands Human;

var bool bTransition;
var float ScaleMagnitude;

var travel int CARKills;
var travel int RLKills;
var travel int GLKills;
var travel int OtherKills;
var travel int TotalKills;
var travel int ASMDKills;
var travel int RifleKills;
var travel int EightballKills;
var travel int StingerKills;
var travel int DispersionKills;
var travel int AutomagKills;
var travel int MinigunKills;
var travel int FlakCannonKills;
var travel int RazorjackKills;
var travel int BioRifleKills;

var bool bIgnoreESC;
var bool bAcceptESC, bMetricMeasured;

var int IntroCount, TransitionCount;
var travel bool bHintDisplayed;


exec function Fire( optional float F )
{
	bJustFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) || !CanInteractWithWorld() )
		return;
	if( Level.Game!=None && Level.Game.IsA( 'CSMovie' ) )
		ShowMenu();
	else if( myHUD!=None && myHUD.IsA('TransitionNullHUD') )
		TransitionNullHUD(myHUD).EndLevel();
	else if( Weapon!=None )
	{
		Weapon.bPointing = true;
		Weapon.Fire(F);
		PlayFiring();
	}
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	bJustAltFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) || !CanInteractWithWorld() )
		return;
	if( Level.Game!=None && Level.Game.IsA( 'CSMovie' ) )
		ShowMenu();
	else if( myHUD!=None && myHUD.IsA('TransitionNullHUD') )
		TransitionNullHUD(myHUD).EndLevel();
	else if( Weapon!=None )
	{
		Weapon.bPointing = true;
		Weapon.AltFire(F);
		PlayFiring();
	}
}

exec function ShowMenu()
{
	if( Level.Title != "FirstIntermission" )
	{
		IntroCount = 5;
	}
	
	if( myHUD!=None && myHUD.IsA('TransitionNullHUD') )
	{
		if( IntroCount > 1 )
		{
			bShowMenu = false;
			bTransition = true;
			return;
		}
		else
		{
			bShowMenu = false;
			bTransition = false;
			IntroCount = 5;
		}	
	}
	else
	{
		WalkBob = vect(0,0,0);
		bShowMenu = true; // menu is responsible for turning this off
		Player.Console.GotoState('Menuing');
			
		if( Level.Netmode == NM_Standalone )
			SetPause(true);
	}
}



function Timer()
{
	if( ScaleMagnitude <= 1.0 )
	{
		ClientAdjustGlow( ScaleMagnitude, vect( 0, 0, 0 ) );
		ScaleMagnitude += 0.001;
	}
	else
	{
		ClientAdjustGlow( 1.0, vect( 0, 0, 0 ) );
		ScaleMagnitude = 0.0;
		Disable( 'Timer' );
	}
	
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local string GivenClassName;
	
	if (!Level.Game.GetAccessManager().CanExecuteCheatStr(self, 'Summon', ClassName))
		return;
	GivenClassName = ClassName;
	
	if( instr( ClassName, "." ) == -1 )
	{
		ClassName = "UPak." $ GivenClassName;
		
		NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class',True) );
		if( NewClass==None )
		{
			ClassName = "UnrealI." $ GivenClassName;
		
			NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class',True) );
			if( NewClass==None )
			{
				ClassName = "UnrealShare." $ GivenClassName;
		
				NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class',True) );
			}
		}
	}
	else
		NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class',True) );
		
	if( NewClass!=None )
	{
		if (NewClass.default.bStatic)
			ClientMessage("Cannot spawn a bStatic actor" @ NewClass);
		else if (NewClass.default.bNoDelete)
			ClientMessage("Cannot spawn a bNoDelete actor" @ NewClass);
		else if (Spawn( NewClass,,,Location + 72 * Vector(Rotation) + vect(0,0,1) * 15 ) == none)
			ClientMessage("Failed to spawn an actor" @ NewClass);
	}
	else
		ClientMessage( "  Class " $ GivenClassName $ " not found!" );
}



state PlayerWalking
{
	function BeginState()
	{
		if( Level.NetMode==NM_StandAlone && Level.Game!=None && Level.Game.IsA('UPakTransitionInfo') )
		{
			bShowMenu = false;
			bTransition = false;
			if( UPakConsole( Player.Console )!=None )
				UPakConsole( Player.Console ).bTransition = true;
		}
		Super.BeginState();
	}

	function Timer()
	{
	}
}


state PlayerFrozen
{
	function bool CanInteractWithWorld()
	{
		return false;
	}
	function Fire( float Value )
	{
		if( Level.Game!=None && Level.Game.IsA( 'UPakTransitionInfo' ) )
			ShowMenu();
	}
	function AltFire( float Value )
	{
		if( Level.Game!=None && Level.Game.IsA( 'UPakTransitionInfo' ) )
			ShowMenu();
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
	}


	function BeginState()
	{
		SetPhysics( PHYS_None );
		ViewRotation.Pitch = 16384;
	}
}	

exec function Difficulty( int Difficulty )
{
	if( Level.NetMode==NM_Client )
		Return;
	if( Difficulty < 0 || Difficulty > 3 )
	{
		ClientMessage( "Choose a value between 0 [ Easy ] and 3 [ Unreal ]." );
		return;
	}
	else
	{
		log ( "Level.Game.Difficulty is now: "$Level.Game.Difficulty );
		Level.Game.Difficulty = Difficulty;
		switch ( Difficulty )
		{
			Case 0:
				ClientMessage( "Difficulty set to EASY." );
				break;
			Case 1:
				ClientMessage( "Difficulty set to MEDIUM." );
				break;
			Case 2:
				ClientMessage( "Difficulty set to HARD." );
				break;
			Case 3:
				ClientMessage( "Difficulty set to UNREAL." );
				break;
		}		
		log ( "Level.Game.Difficulty is now: "$Level.Game.Difficulty );
	}
}

defaultproperties
{
     AirControl=0.400000
}
