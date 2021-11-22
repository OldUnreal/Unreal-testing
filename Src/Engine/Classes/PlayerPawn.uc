//=============================================================================
// PlayerPawn.
// player controlled pawns
// Note that Pawns which implement functions for the PlayerTick messages
// must handle player control in these functions
//=============================================================================
class PlayerPawn extends Pawn
	config(user)
		native
			NativeReplication;

// Player info.
var const player Player;
var	globalconfig string Password;	// for restarting coop savegames

var	travel	  float DodgeClickTimer;
var(Movement) globalconfig float	DodgeClickTime; // max double click interval for dodge move
var(Movement) globalconfig float Bob;
var float bobtime;

// Camera info.
var transient int ShowFlags;
var transient int RendMap;
var transient int Misc1;
var transient int Misc2;

var actor ViewTarget;
var vector FlashScale, FlashFog;
var vector CurrentFlashFog; // Used because FlashFog gets reset if under a threshold.
var HUD	myHUD;
var ScoreBoard Scoring;
var class<hud> HUDType;
var class<scoreboard> ScoringType;

var float DesiredFlashScale, ConstantGlowScale, InstantFlash;
var vector DesiredFlashFog, ConstantGlowFog, InstantFog;
var float DesiredFOV;
var float DefaultFOV;

// Music info.
var music Song;
var byte  SongSection;
var byte  CdTrack;
var EMusicTransition Transition;

var float shaketimer; // player uses this for shaking view
var int shakemag;	// max magnitude in degrees of shaking
var float shakevert; // max vertical shake magnitude
var float maxshake;
var float verttimer;
var(Pawn) class<carcass> CarcassType;
var travel globalconfig float MyAutoAim;
var travel globalconfig float Handedness;
var(Sounds) sound JumpSound;

var globalconfig float MainFOV;
var float		ZoomLevel;

var class<menu> SpecialMenu;
var string DelayedCommand;
var globalconfig float	MouseSensitivity;

var globalconfig name	WeaponPriority[30]; //weapon class priorities (9 is highest)

var globalconfig int NetSpeed, LanSpeed;
var float SmoothMouseX, SmoothMouseY, KbdAccel;
var() globalconfig float MouseSmoothThreshold;

// Unreal 227 additions
var PointRegion CameraRegion; // Player camera location
var(Collision) float CrouchHeightPct;
var transient float CrouchCheckTime; // Unused, preserved for backward compatibility
var float SpecialCollisionHeight; // User-defined normal (non-reduced) CollisionHeight for this player (unused if non-positive)
var float PrePivotZModifier; // Additional Z-offset applied to ScaledDefaultPrePivot().Z when calculating normal PrePivot.Z for this player
var transient float AccumulatedHTurn, AccumulatedVTurn; // Discarded fractional parts of horizontal (Yaw) and vertical (Pitch) turns
var transient plane DistanceFogColor, // Client distance fog color.
		DistanceFogBlend;
var transient float DistanceFogDistance[2], // Client distance fog render distance.
		DistanceFogStart[2],
		DistanceFogBlendTimer[2];
var transient ZoneInfo DistanceFogOld; // Tracking camera zonechanges.
var transient float FogDensity; // Client FogDensity. For exponential fog.
var transient int FogMode; // 0 = Linear, 1 = Exponential, 2 = Exponential 2
var PortalModifier CameraModifier; // Allow modders to modify camera (overrides ZoneInfo.CameraModifier).

// Input axes.
var input float
aBaseX, aBaseY, aBaseZ,
aMouseX, aMouseY,
aForward, aTurn, aStrafe, aUp,
aLookUp, aExtra4, aExtra3, aExtra2,
aExtra1, aExtra0;

// Move Buffering.
var transient SavedMove SavedMoves;
var transient SavedMove FreeMoves;
var float CurrentTimeStamp;
var float LastUpdateTime;
var float ServerTimeStamp;
var float TimeMargin;
var float MaxTimeMargin;

// Progess Indicator.
var string ProgressMessage[5];
var color ProgressColor[5];
var float ProgressTimeOut;

// Localized strings
var localized string QuickSaveString;
var localized string NoPauseMessage;
var localized string ViewingFrom;
var localized string OwnCamera;
var localized string FailedView;
var localized string CantChangeNameMsg;

// ReplicationInfo
var GameReplicationInfo GameReplicationInfo;

// ngWorldStats Logging
var() globalconfig string ngWorldSecret;

// Remote Pawn ViewTargets
var transient rotator TargetViewRotation;
var transient float TargetEyeHeight;
var transient vector TargetWeaponViewOffset;

// CameraLocation
var transient const vector CalcCameraLocation;
var transient const rotator CalcCameraRotation;
var transient const Actor CalcCameraActor;

var ClientReplicationInfo ClientReplicationInfo;
var PlayerAffectorInfo FirstPlayerAffector;
var CustomPlayerStateInfo CustomPlayerStateInfo;
var RealCrouchInfo RealCrouchInfo;
var LadderTrigger ActiveLadder;

// Player control flags
var bool		bAdmin;
var() globalconfig bool 		bLookUpStairs;	// look up/down stairs (player)
var() globalconfig bool		bSnapToLevel;	// Snap to level eyeheight when not mouselooking
var() globalconfig bool		bAlwaysMouseLook;
var globalconfig bool 		bKeyboardLook;	// no snapping when true
var bool		bWasForward;	// used for dodge move
var bool		bWasBack;
var bool		bWasLeft;
var bool		bWasRight;
var bool		bEdgeForward;
var bool		bEdgeBack;
var bool		bEdgeLeft;
var bool 		bEdgeRight;
var bool		bIsCrouching;
var	bool		bShakeDir;
var bool		bAnimTransition;
var bool		bIsTurning;
var bool		bFrozen;
var globalconfig bool	bInvertMouse;
var bool		bShowScores;
var bool		bShowMenu;
var bool		bSpecialMenu;
var bool		bWokeUp;
var bool		bPressedJump;
var bool		bUpdatePosition;
var bool		bDelayedCommand;
var bool		bRising;
var bool		bReducedVis;
var bool		bCenterView;
var() globalconfig bool bMaxMouseSmoothing;
var bool		bMouseZeroed;
var bool		bReadyToPlay;
var globalconfig bool bNoFlash;
var globalconfig bool bNoVoices;
var globalconfig bool bMessageBeep;
var bool		bZooming;
var() nowarn bool bSinglePlayer;				// this class allowed in single player
var bool		bJustFired;
var bool		bJustAltFired;
var bool		bIsTyping;
var bool		bFixedCamera;
var globalconfig bool bMouseSmoothing;
var bool bRepTargetViewRotation;			// Should replicate TargetViewRotation.

// 227 flags:
var globalconfig bool bNeverAutoSwitch;
var bool bIgnoreMusicChange,bIsReducedCrouch;
var bool bCanChangeBehindView;				// Whether the player can change bBehindView via function BehindView executed on the current machine
var transient bool bForwardUserCommands;	// Whether some non-replicated user-level commands should be forwarded from client to server
var transient bool bSaveClientPlayerState;	// Whether the current client-side state should be stored in the corresponding SavedMove
var transient bool bDistanceFogEnabled,		// Client render distance fog now.
		bBlendingDistanceFog;
var transient bool bConsoleCommandMessage;	// When calling PlayerPawn.ConsoleCommand, all engine commands will output in clientmessages.

replication
{
	// Things the server should send to the client.
	reliable if ( Role==ROLE_Authority && bNetOwner )
		ViewTarget, ScoringType, HUDType, GameReplicationInfo, bFixedCamera;
	reliable if ( Role==ROLE_Authority && bNetOwner && bRepTargetViewRotation )
		TargetViewRotation;
	reliable if ( Role==ROLE_Authority && bNetOwner )
		TargetEyeHeight, TargetWeaponViewOffset;

	// Things the client should send to the server
	reliable if ( Role<ROLE_Authority )
		WeaponPriority, Password, bReadyToPlay;

	// Functions client can call.
	unreliable if ( Role<ROLE_Authority )
		CallForHelp;
	reliable if ( Role<ROLE_Authority )
		ShowPath, RememberSpot, Speech, Say, TeamSay, RestartLevel, SwitchWeapon, Pause, SetPause, ServerSetHandedness,
		PrevItem, ActivateItem, ShowInventory, Grab, ServerFeignDeath, ServerSetWeaponPriority,
		ChangeName, ChangeTeam, God, Suicide, ViewClass, ViewPlayerNum, ViewSelf, ViewPlayer, ServerSetSloMo, ServerAddBots,
		PlayersOnly, ThrowWeapon, ServerRestartPlayer, NeverSwitchOnPickup,
		PrevWeapon, NextWeapon, ServerReStartGame, ServerUpdateWeapons, ServerTaunt, ServerChangeSkin,
		SwitchLevel, SwitchCoopLevel, Kick, KillAll, Summon, ActivateTranslator, Admin, Typing;
	unreliable if ( Role==ROLE_AutonomousProxy )
		ServerMove, Fly, Walk, Ghost;


	// Functions server can call.
	reliable if ( Role==ROLE_Authority )
		ClientAdjustGlow, ClientTravel, ClientSetMusic, StartZoom, ToggleZoom, StopZoom, EndZoom, SetDesiredFOV, ClearProgressMessages, SetProgressColor, SetProgressMessage, SetProgressTime;
	unreliable if ( Role==ROLE_Authority && !bDemoRecording )
		SetFOVAngle, ClientShake, ClientFlash, ClientInstantFlash;
	unreliable if ( Role==ROLE_Authority && (!bDemoRecording || bClientDemoNetFunc) )
		ClientPlaySound;
	unreliable if ( Role==ROLE_Authority && (RemoteRole==ROLE_AutonomousProxy) && !bDemoRecording )
		ClientAdjustPosition;

	// Input variables.
	unreliable if ( Role<ROLE_AutonomousProxy )
		aBaseX, aBaseY, aBaseZ,
		aMouseX, aMouseY,
		aForward, aTurn, aStrafe, aUp,
		aLookUp, aExtra4, aExtra3, aExtra2,
		aExtra1, aExtra0;
}

//
// native client-side functions.
//
native event ClientTravel( string URL, ETravelType TravelType, bool bItems );
native(544) final function ResetKeyboard();
native(546) final function UpdateURL(string NewOption, string NewValue, bool bSaveDefault);
native(549) final function bool IsPressing( byte KeyNum ); // Returns true if player is holding down key.
native final function LevelInfo GetEntryLevel();
native final function int GetClientSubVersion(); // Return the client version.
static native final function string GetCompileTime(); // Return the time and date when this version was built.

// Execute a console command in the context of this player, then forward to Actor.ConsoleCommand.
// 227 added command: ConsoleCommand("UGetIP"); for returning desired client's IP
native function string ConsoleCommand( string Command );

/* Clipboard functions, no Linux support yet, sorry. */
static final native function CopyToClipboard( string Text );
static final native function string PasteFromClipboard();

// Called from native command 'UGetFullClientList <validation code>'/'UGetBanList <validation code>'/'UGetTBanList <validation code>'
// Used by Unreal 227 Admin GUI interface.
event UPlayerListResponse( string Resp, string PlayerNm, int ID, string PlayerIP, string ClientID )
{
	ClientMessage("@"$Resp$ID@PlayerIP@ClientID@PlayerNm,'Log',False);
}


event PreClientTravel()
{
}

exec function Ping()
{
	ClientMessage("Current ping is"@PlayerReplicationInfo.Ping);
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( Weapon != None )
		Weapon.RenderOverlays(Canvas);

	if ( myHUD != None )
		myHUD.RenderOverlays(Canvas);
}

exec function ViewPlayerNum(optional int num)
{
	local Pawn P;
	local bool bFoundTarget;

	if ( num >= 0 )
	{
		P = Pawn(ViewTarget);
		if ( P != None && P.PlayerReplicationInfo != none && P.PlayerReplicationInfo.TeamID == num
				|| PlayerReplicationInfo.TeamID == num )
		{
			Level.Game.SetViewTarget(self, none);
			return;
		}
		foreach AllActors(class'Pawn',P,'Player')
			if ( P.PlayerReplicationInfo != none
					&& Level.Game.CanSpectate(self, P)
					&& P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team
					&& P.PlayerReplicationInfo.TeamID == num )
			{
				Level.Game.SetViewTarget(self, P);
				return;
			}
		ClientMessage(FailedView);
		return;
	}

	if( ViewTarget==None || !ViewTarget.bIsPawn )
	{
		foreach AllActors(class'Pawn',P,'Player')
		{
			if (P != self && P.PlayerReplicationInfo != none && !P.PlayerReplicationInfo.bIsSpectator && Level.Game.CanSpectate(self, P))
			{
				Level.Game.SetViewTarget(self, P);
				return;
			}
		}
	}
	else
	{
		foreach AllActors(class'Pawn',P,'Player')
		{
			if( !bFoundTarget )
			{
				if( P==ViewTarget )
					bFoundTarget = true;
			}
			else if (P != self && P.PlayerReplicationInfo != none && !P.PlayerReplicationInfo.bIsSpectator && Level.Game.CanSpectate(self, P))
			{
				Level.Game.SetViewTarget(self, P);
				return;
			}
		}
	}
	Level.Game.SetViewTarget(self, none);
}

exec function Profile()
{
	//TEMP for performance measurement

	ClientMessage("Average AI Time"@Level.AvgAITime);
	ClientMessage(" < 5% "$Level.AIProfile[0]);
	ClientMessage(" < 10% "$Level.AIProfile[1]);
	ClientMessage(" < 15% "$Level.AIProfile[2]);
	ClientMessage(" < 20% "$Level.AIProfile[3]);
	ClientMessage(" < 25% "$Level.AIProfile[4]);
	ClientMessage(" < 30% "$Level.AIProfile[5]);
	ClientMessage(" < 35% "$Level.AIProfile[6]);
	ClientMessage(" > 35% "$Level.AIProfile[7]);
}

// Execute an administrative console command on the server.
exec function Admin( string CommandLine )
{
	local string Result;

	if (StartsWith(CommandLine, "ForwardUserCommand ", true))
		ConsoleCommand(CommandLine);
	else if (Level.Game.GetAccessManager().CanExecuteCheatStr(Self, 'Admin', CommandLine))
	{
		bConsoleCommandMessage = true;
		if ( Level.Game.GameRules!=None )
			Result = Level.Game.GameRules.ExecAdminCmd(Self,CommandLine);
		else Result = ConsoleCommand( CommandLine );
		bConsoleCommandMessage = false;
		if ( Len(Result)>0 )
			ClientMessage( Result );
	}
}

// Hack for forwarding known user-level non-replicated functions from client to server
exec final function ForwardUserCommand(string Command)
{
	local string FuncName, Params;

	if (Level.NetMode == NM_Client)
	{
		Admin("ForwardUserCommand" @ Command);
		return;
	}

	if (!Divide(Command, " ", FuncName, Params))
		FuncName = Command;

	if (FuncName ~= "ActivateInventoryItem" ||
		FuncName ~= "BehindView" ||
		FuncName ~= "GetWeapon")
	{
		ConsoleCommand(Command);
	}
}

function bool ShouldForwardUserCommands()
{
	return bForwardUserCommands;
}

exec function PlayerList()
{
	local PlayerReplicationInfo PRI;

	log("Player List:");
	ForEach AllActors(class'PlayerReplicationInfo', PRI)
	log(PRI.PlayerName@"( ping"@PRI.Ping$")");
}
//
// native server-side functions
//
simulated event ClientMessage( coerce string S, optional Name Type, optional bool bBeep )
{
	if (Player == None)
	{
		if( Level.bIsDemoPlayback )
			GetLocalPlayerPawn().ClientMessage( S, Type, bBeep );
		return;
	}

	if (Type == '')
		Type = 'Event';

	if (Player.Console != None)
		Player.Console.Message( PlayerReplicationInfo, S, Type );
	if (bBeep && bMessageBeep)
		PlayBeepSound();
	if ( myHUD != None )
		myHUD.Message( PlayerReplicationInfo, S, Type );
}

simulated event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type )
{
	if (Player == None)
	{
		if( Level.bIsDemoPlayback )
			GetLocalPlayerPawn().TeamMessage( PRI, S, Type );
		return;
	}
	
	Class'GameInfo'.Static.StripColorCodes(S);
	if (Player.Console != None)
		Player.Console.Message ( PRI, S, Type );
	if (bMessageBeep)
		PlayBeepSound();
	if ( myHUD != None )
		myHUD.Message( PRI, S, Type );
}

simulated function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	local VoicePack V;

	if ( Player==None || (Sender.voicetype==None) || (Player.Console==None) )
	{
		if( Level.bIsDemoPlayback )
			GetLocalPlayerPawn().ClientVoiceMessage( Sender, Recipient, messagetype, messageID );
		return;
	}

	V = Spawn(Sender.voicetype, self);
	if ( V != None )
		V.ClientInitialize(Sender, Recipient, messagetype, messageID);
}

simulated function PlayBeepSound();

// 227g: Moved from UpdateView/ServerMove to here.
function UpdatePawnRotation( rotator Rot )
{
	if( Rotation!=Rot )
		SetRotation(Rot);
}

//
// Send movement to the server.
// Passes acceleration in components so it doesn't get rounded.
//
function ServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbPressedJump,
	bool bFired,
	bool bAltFired,
	eDodgeDir DodgeMove,
	byte ClientRoll,
	int View
)
{
	local float DeltaTime, clientErr;
	local rotator DeltaRot, Rot;
	local vector Accel, LocDiff;
	local int maxPitch, ViewPitch, ViewYaw;
	local actor OldBase;

	// View components
	ViewPitch = View/32768;
	ViewYaw = 2 * (View - 32768 * ViewPitch);
	ViewPitch *= 2;
	// Make acceleration.
	Accel = InAccel/10;

	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// handle firing and alt-firing
	if ( bFired )
	{
		if ( bFire == 0 )
		{
			Fire(0);
			bFire = 1;
		}
	}
	else
		bFire = 0;


	if ( bAltFired )
	{
		if ( bAltFire == 0 )
		{
			AltFire(0);
			bAltFire = 1;
		}
	}
	else
		bAltFire = 0;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = 1.0;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
		else if ( TimeMargin < -MaxTimeMargin ) // player is too far behind.
			TimeMargin = -MaxTimeMargin;
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
		maxPitch = 2;
	else
		maxPitch = 1;
	If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (ViewPitch < 32768)
		Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;
	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	UpdatePawnRotation(Rot);

	OldBase = Base;

	// Perform actual movement.
	if ( Len(Level.Pauser)==0 && (DeltaTime > 0) )
		MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 0.3 || Physics == PHYS_Interpolating )
	{
		ClientErr = 10000;
	}
	else if ( Level.TimeSeconds - LastUpdateTime > 0.07 )
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		// log("Client Error at "$TimeStamp$" is "$ClientErr$" with Velocity "$Velocity$" LocDiff "$LocDiff$" Physics "$Physics);
		LastUpdateTime = Level.TimeSeconds;
		SynchronizeClientPosition(TimeStamp);
	}
	//log("Server "$Role$" moved "$self$" stamp "$TimeStamp$" location "$Location$" Acceleration "$Acceleration$" Velocity "$Velocity);
}

final function SynchronizeClientPosition(float ClientTimeStamp)
{
	if (ObtainClientReplicationInfo())
		ClientReplicationInfo.SynchronizeFrom(ClientTimeStamp);
	else
		ClientAdjustPositionFrom(ClientTimeStamp);
}

final function ClientAdjustPositionFrom(float ClientTimeStamp)
{
	local vector Loc;

	Loc = Location;
	if (Mover(Base) != none)
		Loc -= Base.Location;

	ClientAdjustPosition(
		ClientTimeStamp,
		DesiredClientState(),
		Physics,
		Loc.X,
		Loc.Y,
		Loc.Z,
		Velocity.X,
		Velocity.Y,
		Velocity.Z,
		Base);
}

final function bool ObtainClientReplicationInfo()
{
	if (!CanUseClientReplicationInfo() || NetConnection(Player) == none)
		return false;
	if (ClientReplicationInfo != none)
	{
		if (ClassIsChildOf(ClientReplicationInfo.Class, ClientReplicationInfoBase()))
			return true;
		ClientReplicationInfo.Destroy();
	}
	ClientReplicationInfo = ClientReplicationInfoBase().static.MakeInstance(self);
	return ClientReplicationInfo != none;
}

function bool CanUseClientReplicationInfo()
{
	return Level.Game.bUseClientReplicationInfo;
}

function class<ClientReplicationInfo> ClientReplicationInfoBase()
{
	return class'ClientReplicationInfo_Basic';
}

function name DesiredClientState()
{
	return GetStateName();
}

function ProcessMove ( float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot)
{
	Acceleration = newAccel;
}

final function MoveAutonomous
(
	float DeltaTime,
	bool NewbRun,
	bool NewbDuck,
	bool NewbPressedJump,
	eDodgeDir DodgeMove,
	vector newAccel,
	rotator DeltaRot
)
{
	if ( NewbRun )
		bRun = 1;
	else
		bRun = 0;

	if ( NewbDuck )
		bDuck = 1;
	else
		bDuck = 0;
	bPressedJump = NewbPressedJump;

	HandleWalking();
	ProcessMove(DeltaTime, newAccel, DodgeMove, DeltaRot);
	AutonomousPhysics(DeltaTime);
	//log("Role "$Role$" moveauto time "$100 * DeltaTime$" ("$Level.TimeDilation$")");
}

// 227j client-side reproducing of dodge moves in online game:
// this function is used to evaluate relevant values of DodgeDir and DodgeClickTimer in ClientUpdatePosition
final function PlayerDodgeAutonomous(SavedMove CurrentMove)
{
	if (DodgeClickTime <= 0)
		return;

	if (DodgeDir < DODGE_Active &&
		CurrentMove.DodgeDir != DODGE_None && CurrentMove.DodgeDir < DODGE_Active)
	{
		if (DodgeDir != CurrentMove.DodgeDir)
			DodgeClickTimer = DodgeClickTime + 0.5 * CurrentMove.Delta;
		DodgeDir = CurrentMove.DodgeDir;
	}

	if (DodgeDir == DODGE_Active && Physics == PHYS_Walking)
	{
		// force dodge completion in case if PHYS_Walking was set without calling Landed
		DodgeDir = DODGE_Done;
		DodgeClickTimer = 0;
	}

	if (DodgeDir == DODGE_Done)
	{
		DodgeClickTimer -= CurrentMove.Delta;
		if (DodgeClickTimer < -0.35)
			ResetDodgeMove();
	}
	else if (DodgeDir != DODGE_None && DodgeDir != DODGE_Active)
	{
		DodgeClickTimer -= CurrentMove.Delta;
		if (DodgeClickTimer < 0)
			ResetDodgeMove();
	}
}

// ClientAdjustPosition - pass newloc and newvel in components so it doesn't get rounded

function ClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
	DefClientAdjustPosition(
		TimeStamp,
		newState,
		newPhysics,
		NewLocX,
		NewLocY,
		NewLocZ,
		NewVelX,
		NewVelY,
		NewVelZ,
		NewBase);
}

final function DefClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
	if ( CurrentTimeStamp > TimeStamp )
		return;
	if (newState == 'CustomPlayerState' && ClientReplicationInfo == none)
		return;
	CurrentTimeStamp = TimeStamp;

	Velocity.X = NewVelX;
	Velocity.Y = NewVelY;
	Velocity.Z = NewVelZ;

	SetBase(NewBase);
	ClientAdjustLocation(NewLocX, NewLocY, NewLocZ, NewBase);
	SetPhysics(newPhysics);
	//FIXME - don't do this state update if client dead???
	ClientAdjustState(newState);
	ClientPreadjustMovement();
	ClientAdjustMovement();
}

final function ClientAdjustLocation(float X, float Y, float Z, Actor BaseActor)
{
	local vector OldLoc, NewLocation;
	local bool bOldCollideWorld;

	NewLocation.X = X;
	NewLocation.Y = Y;
	NewLocation.Z = Z;
	if (Mover(BaseActor) != none)
	{
		if (ClientReplicationInfo != none && ClientReplicationInfo.GetTimeStamp() == CurrentTimeStamp)
			NewLocation = BaseActor.Location + (NewLocation >> BaseActor.Rotation);
		else
			NewLocation += BaseActor.Location;
	}
	//log("Client "$Role$" adjust "$self$" stamp "$CurrentTimeStamp$" location "$Location$" new location "$NewLocation);

	OldLoc = Location;

	bOldCollideWorld = bCollideWorld;
	bCollideWorld = false; // suppresses location adjustments in SetLocation
	SetLocation(NewLocation);
	bCollideWorld = bOldCollideWorld;

	if (CarriedDecoration != none)
		CarriedDecoration.ClientSyncPosition(Self, (Location - OldLoc));
}

final function ClientAdjustState(name NewState)
{
	if (NewState == 'CustomPlayerState')
	{
		if (ClientReplicationInfo != none && ClientReplicationInfo.GetTimeStamp() == CurrentTimeStamp)
			ClientReplicationInfo.ClientAdjustCustomPlayerState();
	}
	else if (GetStateName() != NewState)
		GotoState(NewState);
}

final function ClientPreadjustMovement()
{
	local SavedMove FirstMove;

	FirstMove = GetFirstSavedMoveAfter(CurrentTimeStamp);
	if (FirstMove != none && FirstMove.ExtraInfoTimeStamp == FirstMove.TimeStamp)
	{
		DodgeDir = FirstMove.DodgeDir;
		DodgeClickTimer = FirstMove.DodgeClickTimer;
		bIsCrouching = FirstMove.bIsCrouching && IsInState('PlayerWalking');
		bIsReducedCrouch = FirstMove.bIsReducedCrouch;
	}

	if (ClientReplicationInfo != none && ClientReplicationInfo.GetTimeStamp() == CurrentTimeStamp)
		ClientReplicationInfo.ClientAdjustCrouch();
}

final function ClientAdjustMovement()
{
	local PlayerAffectorInfo Affector;

	if (SupportsRealCrouching())
		RealCrouchInfo.ClientAdjustCrouch();

	for (Affector = FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
		Affector.ClientAdjustPosition();

	bUpdatePosition = true;
	if (Level.TimeSeconds - CurrentTimeStamp < 0.5 * Level.TimeDilation ||
		ClientReplicationInfo != none && ClientReplicationInfo.GetTimeStamp() == CurrentTimeStamp)
	{
		ClientUpdatePosition();
	}
}

final function SavedMove GetFirstSavedMoveAfter(float TimeStamp)
{
	local SavedMove CurrentMove;

	CurrentMove = SavedMoves;
	while (CurrentMove != none && CurrentMove.TimeStamp <= TimeStamp)
		CurrentMove = CurrentMove.NextMove;
	return CurrentMove;
}

function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;
	local rotator RealRotation, RealViewRotation;

	realbRun = bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	RealRotation = Rotation;
	RealViewRotation = ViewRotation;
	CurrentMove = SavedMoves;

	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			ApplySavedMove(CurrentMove);
			CurrentMove = CurrentMove.NextMove;
		}
	}

	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
	SetRotation(RealRotation);
	ViewRotation = RealViewRotation;

	bUpdatePosition = false;
	//log("Client adjusted "$self$" stamp "$CurrentTimeStamp$" location "$Location$" dodge "$DodgeDir);
}

final function ApplySavedMove(SavedMove CurrentMove)
{
	local PlayerAffectorInfo Affector;

	if (CurrentMove.ExtraInfoTimeStamp == CurrentMove.TimeStamp) // making sure that the extra info is actual
	{
		ClientUpdateState(CurrentMove);
		SetRotation(CurrentMove.PlayerRotation);
		ViewRotation = CurrentMove.ViewRotation;
		PlayerDodgeAutonomous(CurrentMove);
	}

	MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, CurrentMove.DodgeMove, CurrentMove.Acceleration, rot(0,0,0));

	if (SupportsRealCrouching())
		RealCrouchInfo.UpdateCrouch();
	for (Affector = FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
		Affector.ClientUpdatePlayer(CurrentMove.Delta);
}

final function ClientUpdateState(SavedMove CurrentMove)
{
	if (CurrentMove.NewState == '')
		return;

	if (CurrentMove.NewCustomPlayerState != none && !IsInCustomPlayerState(CurrentMove.NewCustomPlayerState))
		GotoCustomPlayerState(CurrentMove.NewCustomPlayerState);
	else if (GetStateName() != CurrentMove.NewState)
	{
		if (CurrentMove.NewState == 'PlayerWalking')
			GotoDefaultPlayerState();
		else
			GotoState(CurrentMove.NewState);
	}
}

function ResetSavedMoves()
{
	local SavedMove CurrentMove,N;

	if( Level.NetMode!=NM_Client )
		return;

	for (CurrentMove = SavedMoves; CurrentMove!=none; CurrentMove = N)
	{
		N = CurrentMove.NextMove;
		CurrentMove.NextMove = FreeMoves;
		FreeMoves = CurrentMove;
		FreeMoves.Clear();
	}
	SavedMoves = None;
	CurrentTimeStamp = Level.TimeSeconds;
}

final function ResetDodgeMove()
{
	DodgeDir = DODGE_None;
	DodgeClickTimer = DodgeClickTime;
}

final function SavedMove GetFreeMove()
{
	local SavedMove s;

	if ( FreeMoves == None )
		return Spawn(class'SavedMove');
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}
}

//
// Replicate this client's desired movement to the server.
//
final function ReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
)
{
	local SavedMove NewMove;
	local byte ClientRoll;

	// if am network client and am carrying flag -
	//	make its position look good client side
	if ( (PlayerReplicationInfo != None)
			&& (PlayerReplicationInfo.HasFlag != None) )
		PlayerReplicationInfo.HasFlag.FollowHolder(self);

	// Get a SavedMove actor to store the movement in.
	if ( SavedMoves == None )
	{
		SavedMoves = GetFreeMove();
		NewMove = SavedMoves;
	}
	else
	{
		NewMove = SavedMoves;
		while ( NewMove.NextMove != None )
			NewMove = NewMove.NextMove;
		if ( NewMove.bSent )
		{
			NewMove.NextMove = GetFreeMove();
			NewMove = NewMove.NextMove;
		}
	}

	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);

	InitNewSavedMove(NewMove, DeltaTime, NewAccel, DodgeMove);

	if ( Weapon != None ) // approximate pointing so don't have to replicate
		Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));

	// Simulate the movement locally.
	ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
	AutonomousPhysics(DeltaTime);
	//log("Role "$Role$" repmove at "$Level.TimeSeconds$" Move time "$100 * DeltaTime$" ("$Level.TimeDilation$")");

	// Send to the server
	NewMove.bSent = true;
	ClientRoll = (Rotation.Roll >> 8) & 255;
	ServerMove
	(
		NewMove.TimeStamp,
		NewMove.Acceleration * 10,
		Location,
		NewMove.bRun,
		NewMove.bDuck,
		NewMove.bPressedJump,
		(bJustFired || (bFire != 0)),
		(bJustAltFired || (bAltFire != 0)),
		NewMove.DodgeMove,
		ClientRoll,
		(32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2))
	);
	bJustFired = false;
	bJustAltFired = false;
	//log("Replicated "$self$" stamp "$NewMove.TimeStamp$" location "$Location$" dodge "$NewMove.DodgeMove$" to "$DodgeDir);
}

final function InitNewSavedMove(
	SavedMove NewMove,
	float DeltaTime,
	vector Accel,
	EDodgeDir DodgeMove)
{
	NewMove.TimeStamp = Level.TimeSeconds;
	NewMove.Delta = DeltaTime;
	NewMove.Acceleration = Accel;
	NewMove.DodgeMove = DodgeMove;
	NewMove.bRun = (bRun > 0);
	NewMove.bDuck = (bDuck > 0);
	NewMove.bPressedJump = bPressedJump;

	// Extra movement info (227-specific)
	NewMove.ExtraInfoTimeStamp = Level.TimeSeconds;
	NewMove.DodgeDir = DodgeDir;
	NewMove.DodgeClickTimer = DodgeClickTimer;
	NewMove.PlayerRotation = Rotation;
	NewMove.ViewRotation = ViewRotation;
	NewMove.bIsCrouching = bIsCrouching;
	NewMove.bIsReducedCrouch = bIsReducedCrouch;

	NewMove.NewState = '';
	NewMove.NewCustomPlayerState = none;
	if (bSaveClientPlayerState)
	{
		NewMove.NewState = GetStateName();
		if (CustomPlayerStateInfo != none && IsInState('CustomPlayerState'))
			NewMove.NewCustomPlayerState = CustomPlayerStateInfo.Class;
	}

	bSaveClientPlayerState = false;
}

function HandleWalking()
{
	bIsWalking = ((bRun != 0) || (bDuck != 0) || bIsReducedCrouch);
	bNoStopAtLedge = (bDuck==0 && bIsReducedCrouch);

	if ( CarriedDecoration != None )
	{
		bIsWalking = true;
		if ( Role == ROLE_Authority && !CarriedDecoration.IsStillCarrying(Self) ) // verify its still in front
			DropDecoration();
	}
}

//----------------------------------------------

event Destroyed()
{
	Super.Destroyed();
	if ( myHud != None )
		myHud.Destroy();
	if ( Scoring != None )
		Scoring.Destroy();
	if (ClientReplicationInfo != none)
		ClientReplicationInfo.Destroy();
	if( RealCrouchInfo!=None )
		RealCrouchInfo.Destroy();
	RemovePlayerAffectors();
}

function ServerReStartGame()
{
	local GameRules G;

	if ( Level.Game.GameRules!=None )
	{
		for ( G=Level.Game.GameRules; G!=None; G=G.NextRules )
			if ( G.bHandleMapEvents && !G.CanRestartGame(Self) )
				Return;
	}
	if (IsInState('GameEnded'))
		Level.Game.RestartGame();
}

function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
	Level.Game.SpecialDamageString = "";
}

function SetFOVAngle(float newFOV)
{
	FOVAngle = newFOV;
}

function ClientFlash( float scale, vector Fog )
{
	DesiredFlashScale = scale;
	DesiredFlashFog = 0.001 * Fog;
}

function ClientInstantFlash( float scale, vector Fog )
{
	InstantFlash = scale;
	InstantFog = 0.001 * Fog;
}

//Play a sound client side (so only client will hear it
simulated function ClientPlaySound(sound ASound, optional ESoundSlot SlotType )
{
	if( Player==None )
	{
		if( Level.bIsDemoPlayback )
			GetLocalPlayerPawn().ClientPlaySound( ASound, SlotType );
		return;
	}
	if ( ViewTarget != None )
		ViewTarget.PlaySound(ASound, SlotType, 255, true);
	PlaySound(ASound, SlotType, 255, true);
}

function ClientAdjustGlow( float scale, vector Fog )
{
	ConstantGlowScale += scale;
	ConstantGlowFog += 0.001 * Fog;
}

function ClientShake(vector shake)
{
	if ( (shakemag < shake.X) || (shaketimer <= 0.01 * shake.Y) )
	{
		shakemag = shake.X;
		shaketimer = 0.01 * shake.Y;
		maxshake = 0.01 * shake.Z;
		verttimer = 0;
		ShakeVert = -1.1 * maxshake;
	}
}

function ShakeView( float shaketime, float RollMag, float vertmag)
{
	local vector shake;

	shake.X = RollMag;
	shake.Y = 100 * shaketime;
	shake.Z = 100 * vertmag;
	ClientShake(shake);
}

simulated function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
	if( Player==None && Level.bIsDemoPlayback )
		GetLocalPlayerPawn().ClientSetMusic( NewSong, NewSection, NewCdTrack, NewTransition );
	if ( bIgnoreMusicChange )
		Return;
	Song        = NewSong;
	SongSection = NewSection;
	CdTrack     = NewCdTrack;
	Transition  = NewTransition;
}

function ServerFeignDeath()
{
	PendingWeapon = Weapon;
	if ( Weapon != None )
		Weapon.ForcePutDown();
	GotoState('FeigningDeath');
}

function ServerSetHandedness( float hand)
{
	Handedness = hand;
	if ( Weapon != None )
		Weapon.SetHand(Handedness);
}

function ServerReStartPlayer()
{
	local GameRules G;

	//log("calling restartplayer in dying with netmode "$Level.NetMode);
	if ( Level.NetMode == NM_Client )
		return;
	if ( Level.Game.GameRules!=None )
	{
		for ( G=Level.Game.GameRules; G!=None; G=G.NextRules )
			if ( G.bHandleMapEvents && !G.CanRestartPlayer(Self) )
				Return;
	}
	if ( Level.Game.RestartPlayer(self) )
	{
		//log("server restart client");
		ServerTimeStamp = 0;
		TimeMargin = 0;
		Level.Game.StartPlayer(self);
		BaseEyeHeight = Default.BaseEyeHeight;
		EyeHeight = BaseEyeHeight;
		PlayWaiting();
		ClientReStart();
	}
	else
		log("Restartplayer failed");
}

function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
{
	local string MeshName;

	MeshName = GetItemName(string(Mesh));
	if ( Level.Game.bCanChangeSkin
			/* && (SkinName == "" || Left(SkinName, Len(MeshName)) ~= MeshName) */)
	{
		Self.static.SetMultiSkin(Self, SkinName, FaceName, TeamNum );
	}
}

simulated static invariant function plane ColorToPlane( Color C )
{
	return Construct<Plane>(X=C.R/255.f, Y=C.G/255.f, Z=C.B/255.f, W=C.A/255.f);
}

// Called by Render Engine client side.
simulated event UpdateDistanceFog()
{
	if( DistanceFogOld!=CameraRegion.Zone )
	{
		InitNewFogZone(CameraRegion.Zone);
		DistanceFogOld = CameraRegion.Zone;
	}
	else if( bBlendingDistanceFog )
		UpdateFogBlending(CameraRegion.Zone);
}
simulated final function InitNewFogZone( ZoneInfo Z )
{
	if( !bDistanceFogEnabled && !Z.bDistanceFog)
		return; // No blending needed.

	FogMode = Z.FogMode;

	bBlendingDistanceFog = (Z.FadeTime>0.f);
	if( !bBlendingDistanceFog )
	{
		// No blending needed.
		DistanceFogColor = ColorToPlane(Z.FogColor);
		DistanceFogDistance[0] = Z.FogDistanceStart;
		DistanceFogDistance[1] = Z.FogDistance;
		bDistanceFogEnabled = Z.bDistanceFog;
		FogDensity = Z.FogDensity;
	}
	else
	{
		if( !bDistanceFogEnabled ) // Fade in from infinitive.
		{
			DistanceFogBlend = ColorToPlane(Z.FogColor);
			DistanceFogColor = DistanceFogBlend;
			DistanceFogStart[0] = Z.FogDistanceStart+5000.f;
			DistanceFogStart[1] = Z.FogDistance+5000.f;
			FogDensity = Z.FogDensity/10;
		}
		else
		{
			DistanceFogBlend = DistanceFogColor;
			DistanceFogStart[0] = DistanceFogDistance[0];
			DistanceFogStart[1] = DistanceFogDistance[1];
			FogDensity = 0.01;
		}
		DistanceFogBlendTimer[0] = Level.RealTimeSeconds+Z.FadeTime;
		DistanceFogBlendTimer[1] = Z.FadeTime;
		bDistanceFogEnabled = true;
	}
}
simulated final function UpdateFogBlending( ZoneInfo Z )
{
	local float A,NA;
	local plane P;

	A = (DistanceFogBlendTimer[0]-Level.RealTimeSeconds)/DistanceFogBlendTimer[1]; // Get alpha
	if( A<=0.f ) // Blending complete.
	{
		if( !Z.bDistanceFog )
			bDistanceFogEnabled = false;
		else
		{
			DistanceFogColor = ColorToPlane(Z.FogColor);
			DistanceFogDistance[0] = Z.FogDistanceStart;
			DistanceFogDistance[1] = Z.FogDistance;
			FogDensity = Z.FogDensity;
		}
		bBlendingDistanceFog = false;
		return;
	}
	NA = (1.f-A); // Get negative alpha.

	if( !Z.bDistanceFog ) // Fade out to infinitive distance.
	{
		DistanceFogDistance[0] = (5000.f*NA+DistanceFogStart[0]);
		DistanceFogDistance[1] = (5000.f*NA+DistanceFogStart[1]);
		FogDensity = A/1000;
	}
	else
	{
		P = ColorToPlane(Z.FogColor);
		DistanceFogColor.X = (P.X*NA+DistanceFogBlend.X*A);
		DistanceFogColor.Y = (P.Y*NA+DistanceFogBlend.Y*A);
		DistanceFogColor.Z = (P.Z*NA+DistanceFogBlend.Z*A);
		DistanceFogColor.W = (P.W*NA+DistanceFogBlend.W*A);
		DistanceFogDistance[0] = (Z.FogDistanceStart*NA+DistanceFogStart[0]*A);
		DistanceFogDistance[1] = (Z.FogDistance*NA+DistanceFogStart[1]*A);
		FogDensity =  Z.FogDensity-A/1000;
	}
}

//*************************************************************************************
// Normal gameplay execs
// Type the name of the exec function at the console to execute it

exec function ShowSpecialMenu( string ClassName )
{
	local class<menu> aMenuClass;

	aMenuClass = class<menu>( DynamicLoadObject( ClassName, class'Class' ) );
	if ( aMenuClass!=None )
	{
		bSpecialMenu = true;
		SpecialMenu = aMenuClass;
		ShowMenu();
	}
}

exec function Jump( optional float F )
{
	bPressedJump = true;
}

exec function CauseEvent( name N )
{
	if ( Level.NetMode==NM_Client )
	{
		Admin("CauseEvent"@N);
		Return; // We are a client, pass it to server.
	}
	if ( Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'CauseEvent',string(N)) )
		TriggerEvent(N,Self,Self);
}

exec function Taunt( name Sequence )
{
	if (HasAnim(Sequence) && GetAnimGroup(Sequence) == 'Gesture' &&
		!bool(Acceleration) && !bIsCrouching)
	{
		ServerTaunt(Sequence);
		PlayAnim(Sequence, 0.7, 0.2);
	}
}

function ServerTaunt(name Sequence )
{
	if (HasAnim(Sequence) && GetAnimGroup(Sequence) == 'Gesture' &&
		!bool(Acceleration) && !bIsCrouching)
	{
		PlayAnim(Sequence, 0.7, 0.2);
	}
}

exec function FeignDeath()
{
}

exec function CallForHelp()
{
	local Pawn P;

	if ( !Level.Game.bTeamGame || (Enemy == None) || (Enemy.Health <= 0) )
		return;

	foreach AllActors(class'Pawn',P,'Player')
		if ( P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team )
			P.HandleHelpMessageFrom(self);
}

function damageAttitudeTo(pawn Other)
{
	if( Level.Game!=None && Other!=None && Other!=Self )
	{
		if( Level.Game.bTeamGame )
			if( GetTeamNum()!=Other.GetTeamNum() )
				Enemy = Other;
		else if( Level.Game.bDeathMatch || !Other.bIsPlayer )
			Enemy = Other;
	}
}

exec function Grab()
{
	local GameRules G;

	for ( G = Level.Game.GameRules; G != None; G = G.NextRules )
		if ( G.bHandleGrab && !G.CanGrab(self) )
			return;

	if (!CanInteractWithWorld())
		return;

	if (CarriedDecoration == None)
		GrabDecoration();
	else
		DropDecoration();
}

function vector GrabbedDecorationOffset(Decoration Decoration)
{
	if (SupportsRealCrouching())
		return RealCrouchInfo.GrabbedDecorationOffset(Decoration);
	return super.GrabbedDecorationOffset(Decoration);
}

// Send a voice message of a certain type to a certain player.
exec function Speech( int Type, int Index, int Callsign )
{
	local VoicePack V;

	if ( PlayerReplicationInfo.VoiceType == None || Level.TimeSeconds - OldMessageTime < 3 )
		return;

	V = Spawn( PlayerReplicationInfo.VoiceType, Self );
	if (V != None)
	{
		V.PlayerSpeech( Type, Index, Callsign );
		V.Destroy();
	}
}

function PlayChatting();

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if (bTyping)
	{
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogTypingEvent(True, Self);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogTypingEvent(True, Self);
		PlayChatting();
	}
	else
	{
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogTypingEvent(False, Self);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogTypingEvent(False, Self);
	}
}

// Send a message to all players.
exec function Say( string Msg )
{
	local Pawn P;
	local GameRules G;

	if ( Level.Game.GameRules!=None )
	{
		for ( G=Level.Game.GameRules; G!=None; G=G.NextRules )
			if ( G.bNotifyMessages && !G.AllowChat(Self,Msg) )
				Return;
	}

	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
	{
		foreach AllActors(class'Pawn',P,'Player')
			P.TeamMessage( PlayerReplicationInfo, Msg, 'Say' );
	}
	return;
}

exec function TeamSay( string Msg )
{
	local Pawn P;
	local GameRules G;

	if ( !Level.Game.bTeamGame )
	{
		Say(Msg);
		return;
	}

	if ( Level.Game.GameRules!=None )
	{
		for ( G=Level.Game.GameRules; G!=None; G=G.NextRules )
			if ( G.bNotifyMessages && !G.AllowChat(Self,Msg) )
				Return;
	}

	if ( Msg ~= "Help" )
	{
		CallForHelp();
		return;
	}

	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
	{
		foreach AllActors(class'Pawn',P,'Player')
			if ( P.PlayerReplicationInfo && P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team )
			{
				if ( P.bIsPlayerPawn )
					P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay' );
			}
	}
}

exec function RestartLevel()
{
	if( Level.Game.GetAccessManager().CanExecuteCheat(Self,'RestartLevel') )
		ClientTravel( "?restart", TRAVEL_Relative, false );
}

exec function LocalTravel( string URL )
{
	if( Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'LocalTravel',URL) )
		ClientTravel( URL, TRAVEL_Relative, true );
}

exec function ThrowWeapon()
{
	if ( Level.NetMode == NM_Client || !CanInteractWithWorld() )
		return;
	if ( Weapon==None || (Weapon.Class==Level.Game.DefaultWeapon) || !Weapon.bCanThrow )
		return;
	Weapon.Velocity = Vector(ViewRotation) * 500 + vect(0,0,220);
	Weapon.bTossedOut = true;
	TossWeapon();
	if ( Weapon == None )
		SwitchToBestWeapon();
}

function ToggleZoom()
{
	if ( DefaultFOV != DesiredFOV )
		EndZoom();
	else
		StartZoom();
}

function StartZoom()
{
	ZoomLevel = 0.0;
	bZooming = true;
}

function StopZoom()
{
	bZooming = false;
}

function EndZoom()
{
	bZooming = false;
	DesiredFOV = DefaultFOV;
}

exec function FOV(float F)
{
	SetDesiredFOV(F);
}

exec function UpdateWideScreen(float F)
{
	SetDesiredFOV(F);
	MainFOV=F;
	SaveConfig();
}

exec function SetDesiredFOV(float F)
{
	if ( !Level.bNoCheating || bAdmin || (Level.Netmode==NM_Standalone) )
	{
		DefaultFOV = FClamp(F, 1, 170);
		DesiredFOV = DefaultFOV;
	}
	else
	{
		DefaultFOV = FClamp(F, 90, 170);
		DesiredFOV = DefaultFOV;
	}
}

/* PrevWeapon()
- switch to previous inventory group weapon
*/
exec function PrevWeapon()
{
	local int prevGroup;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	if ( bShowMenu || Len(Level.Pauser)>0 || !CanInteractWithWorld() )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	prevGroup = 0;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;

	foreach AllInventory(class'Weapon',w)
	{
		if ( w.InventoryGroup == Weapon.InventoryGroup )
		{
			if ( w == Weapon )
			{
				bFoundWeapon = true;
				if ( Prev != None )
				{
					PendingWeapon = Prev;
					break;
				}
			}
			else if ( !bFoundWeapon && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
				Prev = W;
		}
		else if ( (w.InventoryGroup < Weapon.InventoryGroup)
				  && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0))
				  && (w.InventoryGroup >= prevGroup) )
		{
			prevGroup = w.InventoryGroup;
			PendingWeapon = w;
		}
	}

	bFoundWeapon = false;
	prevGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		foreach AllInventory(class'Weapon',w)
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
					bFoundWeapon = true;
				else if ( bFoundWeapon && (PendingWeapon == None) && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
					PendingWeapon = W;
			}
			else if ( (w.InventoryGroup > PrevGroup)
					  && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
			{
				prevGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}

	Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	if ( Weapon != PendingWeapon )
		Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
exec function NextWeapon()
{
	local int nextGroup;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	if ( bShowMenu || Len(Level.Pauser)>0 || !CanInteractWithWorld() )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	nextGroup = 100;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;

	foreach AllInventory(class'Weapon',w)
	{
		if ( w.InventoryGroup == Weapon.InventoryGroup )
		{
			if ( w == Weapon )
				bFoundWeapon = true;
			else if ( bFoundWeapon && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
			{
				PendingWeapon = W;
				break;
			}
		}
		else if ( (w.InventoryGroup > Weapon.InventoryGroup)
				  && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0))
				  && (w.InventoryGroup < nextGroup) )
		{
			nextGroup = w.InventoryGroup;
			PendingWeapon = w;
		}
	}

	bFoundWeapon = false;
	nextGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		foreach AllInventory(class'Weapon',w)
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
				{
					bFoundWeapon = true;
					if ( Prev != None )
						PendingWeapon = Prev;
				}
				else if ( !bFoundWeapon && (PendingWeapon == None) && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
					Prev = W;
			}
			else if ( (w.InventoryGroup < nextGroup)
					  && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
			{
				nextGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}

	Weapon = realWeapon;
	if ( PendingWeapon == None )
		return;

	if ( Weapon != PendingWeapon )
		Weapon.PutDown();
}

exec function QuickSave()
{
	if ( (Health > 0)
			&& (Level.NetMode == NM_Standalone)
			&& !Level.Game.bDeathMatch )
	{
		ClientMessage(QuickSaveString);
		ConsoleCommand("SaveGame 0 QuickSave");
	}
}

exec function QuickLoad()
{
	if ( (Level.NetMode == NM_Standalone)
			&& !Level.Game.bDeathMatch )
		ClientTravel( "?load=0", TRAVEL_Absolute, false);
}

exec function Kick( string S )
{
	local Pawn aPawn;

	if ( !Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'Kick',S) )
		return;
	foreach AllActors(class'Pawn',aPawn,'Player')
		if( aPawn.PlayerReplicationInfo.PlayerName~=S
			&&	(PlayerPawn(aPawn)==None || Viewport(PlayerPawn(aPawn).Player)==None) )
		{
			aPawn.Destroy();
			return;
		}
}

// Try to set the pause state; returns success indicator.
function bool SetPause( BOOL bPause )
{
	return Level.Game.SetPause(bPause, self);
}

exec function SetMouseSmoothThreshold( float F )
{
	MouseSmoothThreshold = FClamp(F, 0, 1);
	SaveConfig();
}

exec function SetMaxMouseSmoothing( bool B )
{
	bMaxMouseSmoothing = B;
	SaveConfig();
}

// Try to pause the game.
exec function Pause()
{
	if ( bShowMenu )
		return;
	if ( !SetPause(Len(Level.Pauser)==0) )
		ClientMessage(NoPauseMessage);
}

// Activate specific inventory item
exec function ActivateInventoryItem( class InvItem )
{
	local Inventory Inv;

	if (Level.NetMode == NM_Client)
	{
		ForwardUserCommand("ActivateInventoryItem" @ InvItem);
		return;
	}
	if (!CanInteractWithWorld())
		return;

	Inv = FindInventoryType(InvItem);
	if ( Inv != None && Inv.bActivatable )
		Inv.Activate();
}

// Translator Hotkey
exec function ActivateTranslator()
{
	if ( bShowMenu || Len(Level.Pauser)>0 )
		return;
	If (Inventory!=None) Inventory.ActivateTranslator(False);
}

// Translator Hotkey
exec function ActivateHint()
{
	if ( bShowMenu || Len(Level.Pauser)>0 )
		return;
	If (Inventory!=None) Inventory.ActivateTranslator(True);
}

// HUD
exec function ChangeHud()
{
	if ( myHud != None )
		myHUD.ChangeHud(1);
	myHUD.SaveConfig();
}

// Crosshair
exec function ChangeCrosshair()
{
	if ( myHud != None )
		myHUD.ChangeCrosshair(1);
	myHUD.SaveConfig();
}

event PreRender( canvas Canvas )
{
	if( RendMap==1 )
	{
		Canvas.SetPos(0,0);
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
		Canvas.Style = 1;
		Canvas.Z = 1;
		Canvas.DrawTile(Texture'DefaultTexture',Canvas.ClipX,Canvas.ClipY,0,0,1,1);
		Canvas.DrawActor(None,False,True); // Clear Z
	}
	if ( myHud != None )
		myHUD.PreRender(Canvas);
	else if ( (Viewport(Player) != None) && (HUDType != None) )
		myHUD = spawn(HUDType, self);
}

event PostRender( canvas Canvas )
{
	if ( myHud != None )
		myHUD.PostRender(Canvas);
	else if ( (Viewport(Player) != None) && (HUDType != None) )
		myHUD = spawn(HUDType, self);
}

//=============================================================================
// Inventory-related input notifications.

// Handle function keypress for F1-F10.
exec function FunctionKey( byte Num )
{
}

// The player wants to switch to weapon group numer I.
exec function SwitchWeapon (byte F )
{
	local weapon newWeapon;

	if ( bShowMenu || Len(Level.Pauser)>0 || !CanInteractWithWorld() )
	{
		if ( myHud != None )
			myHud.InputNumber(F);
		return;
	}
	if ( Inventory == None )
		return;

	if (Weapon != none && Weapon.Inventory != none)
	{
		newWeapon = Weapon.Inventory.WeaponChange(F);
		if (newWeapon == none)
		{
			Weapon.bBreakWeaponChange = true;
			newWeapon = Inventory.WeaponChange(F);
			Weapon.bBreakWeaponChange = false;
		}
	}
	else
		newWeapon = Inventory.WeaponChange(F);

	if ( newWeapon == None )
		return;

	if ( Weapon == None )
	{
		PendingWeapon = newWeapon;
		ChangedWeapon();
	}
	else if ( (Weapon != newWeapon) && Weapon.PutDown() )
		PendingWeapon = newWeapon;
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{
	local Inventory Inv;
	local Weapon NewWeapon;

	if ( Level.NetMode==NM_Client )
	{
		if ( NewWeaponClass!=None )
		{
			if (ShouldForwardUserCommands())
				ForwardUserCommand("GetWeapon" @ NewWeaponClass);
			else
				SwitchWeapon(NewWeaponClass.Default.InventoryGroup); // Stupid workaround for clients...
		}
		return;
	}
	if (!CanInteractWithWorld() ||
		Inventory == None ||
		NewWeaponClass == None ||
		Weapon != None && Weapon.Class == NewWeaponClass)
	{
		return;
	}

	foreach AllInventory(NewWeaponClass,Inv,true)
	{
		NewWeapon = Weapon(Inv);
		if (NewWeapon.AmmoType != none && NewWeapon.AmmoType.AmmoAmount <= 0)
		{
			ClientMessage(NewWeapon.ItemName $ NewWeapon.MessageNoAmmo);
			return;
		}

		if (Weapon == none)
		{
			PendingWeapon = NewWeapon;
			ChangedWeapon();
		}
		else if (Weapon.PutDown())
			PendingWeapon = NewWeapon;
		return;
	}
}

// The player wants to select previous item
exec function PrevItem()
{
	local Inventory Inv, LastItem;

	if ( bShowMenu || Len(Level.Pauser)>0 || !CanInteractWithWorld() )
		return;
	if( Inventory==None )
	{
		SelectedItem = None;
		return;
	}
	if (SelectedItem==None)
	{
		SelectedItem = Inventory.SelectNext();
		Return;
	}
	foreach AllInventory(class'Inventory',Inv)
	{
		if( Inv==SelectedItem && LastItem!=None )
			break;
		if( Inv.bActivatable )
			LastItem = Inv;
	}
	if (LastItem!=None)
	{
		SelectedItem = LastItem;
		ClientMessage(SelectedItem.ItemName$SelectedItem.M_Selected);
	}
}

// The player wants to active selected item
exec function ActivateItem()
{
	if ( bShowMenu || Len(Level.Pauser)>0 || !CanInteractWithWorld() )
		return;
	if (SelectedItem!=None)
		SelectedItem.Activate();
}

// The player wants to fire.
exec function Fire( optional float F )
{
	bJustFired = true;
	if ( bShowMenu || Len(Level.Pauser)>0 || (Role < ROLE_Authority) || !CanInteractWithWorld() || (CarriedDecoration!=None && CarriedDecoration.CarrierFired(Self,false)) )
		return;
	if ( Weapon!=None )
	{
		Weapon.bPointing = true;
		PlayFiring();
		Weapon.Fire(F);
	}
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	bJustAltFired = true;
	if ( bShowMenu || Len(Level.Pauser)>0 || (Role < ROLE_Authority) || !CanInteractWithWorld() || (CarriedDecoration!=None && CarriedDecoration.CarrierFired(Self,true)) )
		return;
	if ( Weapon!=None )
	{
		Weapon.bPointing = true;
		PlayFiring();
		Weapon.AltFire(F);
	}
}

//Player Jumped
function DoJump( optional float F )
{
	if ( CarriedDecoration != None )
		return;
	if ( (!bIsCrouching || Level.bSupportsCrouchJump) && (Physics == PHYS_Walking) )
	{
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);
		if (!bUpdatePosition && !bIsCrouching)
			PlayInAir();
		if ( bCountJumps && (Role == ROLE_Authority) )
			Inventory.OwnerJumped();
		Velocity.Z = JumpZ;
		if ( Base!=Level && Base!=None )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);
	}
}

exec function Suicide()
{
	if (CanInteractWithWorld())
		KilledBy( None );
}

exec function AlwaysMouseLook( Bool B )
{
	ChangeAlwaysMouseLook(B);
	SaveConfig();
}

function ChangeAlwaysMouseLook(Bool B)
{
	bAlwaysMouseLook = B;
	if ( bAlwaysMouseLook )
		bLookUpStairs = false;
}

exec function SnapView( bool B )
{
	ChangeSnapView(B);
	SaveConfig();
}

function ChangeSnapView( bool B )
{
	bSnapToLevel = B;
}

exec function StairLook( bool B )
{
	ChangeStairLook(B);
	SaveConfig();
}

function ChangeStairLook( bool B )
{
	bLookUpStairs = B;
	if ( bLookUpStairs )
		bAlwaysMouseLook = false;
}

exec function SetDodgeClickTime( float F )
{
	ChangeDodgeClickTime(F);
	SaveConfig();
}

function ChangeDodgeClickTime( float F )
{
	DodgeClickTime = FMin(0.3, F);
}

exec function SetName( coerce string S )
{
	S = Left(S,40);
	ChangeName(S);
	UpdateURL("Name", S, true);
	SaveConfig();
}

function ChangeName( coerce string S )
{
	if (Level.Game.WorldLog != None)
		ClientMessage(CantChangeNameMsg);
	else
		Level.Game.ChangeName( self, S, true );
}

function ChangeTeam( int N )
{
	local byte OldTeam;

	OldTeam = PlayerReplicationInfo.Team;
	if ( Level.Game.ChangeTeam(self,N) && Level.Game.bTeamGame && OldTeam!=PlayerReplicationInfo.Team )
		Died( None, '', Location );
}

exec function SetAutoAim( float F )
{
	ChangeAutoAim(F);
	SaveConfig();
}

function ChangeAutoAim( float F )
{
	MyAutoAim = FMax(Level.Game.AutoAim, F);
}

exec function PlayersOnly()
{
	if ( Level.Netmode != NM_Standalone )
		return;

	Level.bPlayersOnly = !Level.bPlayersOnly;
}

exec function SetHand( string S )
{
	ChangeSetHand(S);
	SaveConfig();
}

function ChangeSetHand( string S )
{
	if ( S ~= "Left" )
		Handedness = 1;
	else if ( S~= "Right" )
		Handedness = -1;
	else if ( S ~= "Center" )
		Handedness = 0;
	else if ( S ~= "Hidden" )
		Handedness = 2;
	ServerSetHandedness(Handedness);
}

exec function ViewPlayer( string S )
{
	local pawn P;

	foreach AllActors(class'Pawn',P,'Player')
		if (P.PlayerReplicationInfo != none && P.PlayerReplicationInfo.PlayerName ~= S)
			break;

	if (P != none && Level.Game.CanSpectate(self, P))
		Level.Game.SetViewTarget(self, P);
	else
		ClientMessage(FailedView);
}

exec function CheatView( class<actor> aClass )
{
	local actor other, First;
	local bool bFound;

	if (Role < ROLE_Authority || !Level.Game.GetAccessManager().CanExecuteCheatStr(Self, 'CheatView', string(aClass)))
		return;

	First = None;
	ForEach AllActors( aClass, other )
	{
		if ( (First == None) && (other != self) )
		{
			First = other;
			bFound = true;
		}
		if ( other == ViewTarget )
			First = None;
	}

	if (bFound || ClassIsChildOf(Class, aClass))
		Level.Game.SetViewTarget(self, First);
	else
		ClientMessage(FailedView, 'Event', true);
}

exec function ViewSelf()
{
	Level.Game.SetViewTarget(self, none);
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet )
{
	local actor other, First;
	local bool bFound;

	First = None;
	ForEach AllActors( aClass, other,,,true )
	{
		if ( (First == None) && (other != self) && Level.Game.CanSpectate(self, other) )
		{
			First = other;
			bFound = true;
		}
		if ( other == ViewTarget )
			First = None;
	}

	if (bFound || ClassIsChildOf(Class, aClass))
		Level.Game.SetViewTarget(self, First, bQuiet);
	else if (!bQuiet)
		ClientMessage(FailedView, 'Event', true);
}

exec function NeverSwitchOnPickup( bool B )
{
	bNeverSwitchOnPickup = B;
}

exec function InvertMouse( bool B )
{
	bInvertMouse = B;
	SaveConfig();
}

exec function SwitchLevel( string URL )
{
	if( Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'SwitchLevel',URL) )
		Level.ServerTravel( URL, false );
}

exec function SwitchCoopLevel( string URL )
{
	if( Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'SwitchCoopLevel',URL) )
		Level.ServerTravel( URL, true );
}

exec function ShowScores()
{
	bShowScores = !bShowScores;
}

exec function ShowMenu()
{
	WalkBob = vect(0,0,0);
	bShowMenu = true; // menu is responsible for turning this off
	Player.Console.GotoState('Menuing');

	if ( Level.Netmode == NM_Standalone )
		SetPause(true);
}

exec function ShowLoadMenu()
{
	Player.Console.ShowLoadGameMenu();
}

exec function AddBots(int N)
{
	ServerAddBots(N);
}

function ServerAddBots(int N)
{
	local int i;

	if( !Level.Game.bDeathMatch || !Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'AddBots',string(N)) )
		return;

	for ( i=0; i<N; i++ )
		Level.Game.AddBot();
}


//*************************************************************************************
// Special purpose/cheat execs

exec function ClearProgressMessages()
{
	local int i;

	for (i=0; i<5; i++)
	{
		ProgressMessage[i] = "";
		ProgressColor[i].R = 255;
		ProgressColor[i].G = 255;
		ProgressColor[i].B = 255;
	}
}

exec function SetProgressMessage( string S, int Index )
{
	if (Index < 5)
		ProgressMessage[Index] = S;
}

exec function SetProgressColor( color C, int Index )
{
	if (Index < 5)
		ProgressColor[Index] = C;
}

exec function SetProgressTime( float T )
{
	ProgressTimeOut = T + Level.TimeSeconds;
}

exec event ShowUpgradeMenu();

exec function Amphibious()
{
	if ( Level.NetMode==NM_Client )
	{
		Admin("Amphibious");
		Return; // We are a network client, pass to server.
	}
	if( Level.Game.GetAccessManager().CanExecuteCheat(Self,'Amphibious') )
	{
		UnderwaterTime = +999999.0;
		if (HeadRegion.Zone.bWaterZone && !FootRegion.Zone.bPainZone)
			PainTime = -1;
	}
}

exec function Fly()
{
	if( !Level.Game.GetAccessManager().CanExecuteCheat(Self,'Fly') )
		return;

	UnderWaterTime = Default.UnderWaterTime;
	ClientMessage("You feel much lighter");
	SetCollision(true, true , true);
	bCollideWorld = true;
	GotoState('CheatFlying');
}

exec function Walk()
{
	if( !Level.Game.GetAccessManager().CanExecuteCheat(Self,'Walk') )
		return;

	bHidden = (Health<=0);
	Visibility = Default.Visibility;
	bProjTarget = True;
	Velocity = vect(0.0,0.0,0.0);
	Acceleration = vect(0.0,0.0,0.0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	PlayWaiting();
	bPressedJump = false;
	if ( Region.Zone.bWaterZone )
	{
		if ( HeadRegion.Zone.bWaterZone )
			PainTime = UnderWaterTime;
		GotoState('PlayerSwimming');
	}
	else GotoState('PlayerWalking');

	StartWalk();
}

function StartWalk()
{
	UnderWaterTime = Default.UnderWaterTime;
	SetCollision(true, true, true);
	if (Region.Zone.bWaterZone)
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking);
	bCollideWorld = true;
	ClientReStart();

	if (FootRegion.Zone.bPainZone)
		PainTime = 1;
	else if (HeadRegion.Zone.bWaterZone)
		PainTime = UnderWaterTime;
}

exec function Ghost()
{
	if( !Level.Game.GetAccessManager().CanExecuteCheat(Self,'Ghost') )
		return;

	UnderWaterTime = -1.0;
	ClientMessage("You feel ethereal");
	SetCollision(false, false, false);
	bCollideWorld = false;
	GotoState('CheatFlying');
}

exec function ShowInventory()
{
	local Inventory Inv;

	if (Level.Netmode != NM_Standalone)
		return;

	if ( Weapon!=None )
		log( "   Weapon: " $ Weapon.Class );
	foreach AllInventory(class'Inventory',Inv)
		log( "Inv: "$Inv );
	if ( SelectedItem != None )
		log( "Selected Item"@SelectedItem@"Charge"@SelectedItem.Charge );
}

exec function AllAmmo()
{
	local Ammo Inv;

	if ( Level.NetMode==NM_Client )
	{
		Admin("AllAmmo");
		Return; // We are a network client, pass to server.
	}
	if( !Level.Game.GetAccessManager().CanExecuteCheat(Self,'AllAmmo') )
		return;

	foreach AllInventory(class'Ammo',Inv)
	{
		Inv.AmmoAmount  = 999;
		Inv.MaxAmmo  = 999;
	}
}

exec function Invisible(bool B)
{
	if ( Level.NetMode==NM_Client )
	{
		Admin("Invisible"@B);
		Return; // We are a network client, pass to server.
	}
	if( !Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'Invisible',string(B)) )
		return;

	if (B)
	{
		bHidden = true;
		Visibility = 0;
	}
	else
	{
		bHidden = false;
		Visibility = Default.Visibility;
	}
}

exec function God()
{
	if( !Level.Game.GetAccessManager().CanExecuteCheat(Self,'God') )
		return;

	if ( ReducedDamageType == 'All' )
	{
		ReducedDamageType = '';
		ClientMessage("God mode off");
		return;
	}

	ReducedDamageType = 'All';
	ClientMessage("God Mode on");
}

exec function BehindView( Bool B )
{
	if (Level.NetMode == NM_Client && ShouldForwardUserCommands())
		ForwardUserCommand("BehindView" @ B);
	if (bCanChangeBehindView)
		bBehindView = B;
}
exec function UToggleBehindView()
{
	BehindView(!bBehindView);
}

exec function SetBob(float F)
{
	UpdateBob(F);
	SaveConfig();
}

function UpdateBob(float F)
{
	Bob = FClamp(F,0,0.032);
}

exec function SetSensitivity(float F)
{
	UpdateSensitivity(F);
	SaveConfig();
}

function UpdateSensitivity(float F)
{
	MouseSensitivity = FMax(0,F);
}

exec function SloMo( float T )
{
	ServerSetSloMo(T);
}

function ServerSetSloMo(float T)
{
	if( Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'SloMo',string(T)) )
	{
		Level.Game.SetGameSpeed(T);
		Level.Game.SaveConfig();
		Level.Game.GameReplicationInfo.SaveConfig();
	}
}

exec function SetJumpZ( float F )
{
	if ( Level.NetMode==NM_Client )
	{
		Admin("SetJumpZ"@F);
		Return; // We are a client, pass it to server.
	}
	if( Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'SetJumpZ',string(F)) )
		JumpZ = F;
}

exec function SetSpeed( float F )
{
	if ( Level.NetMode==NM_Client )
	{
		Admin("SetSpeed"@F);
		Return; // We are a client, pass it to server.
	}
	if( !Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'SetSpeed',string(F)) )
		return;
	GroundSpeed = Default.GroundSpeed * f;
	WaterSpeed = Default.WaterSpeed * f;
}

exec function KillAll(class<actor> aClass)
{
	local Actor A;

	if( aClass==None || !Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'KillAll',string(aClass)) )
		return;
	ForEach AllActors(aClass, A,,,true)
	{
		if( !A.bIsPlayerPawn )
			A.Destroy();
	}
}

exec function KillPawns()
{
	local Pawn P;

	if ( Level.NetMode==NM_Client )
	{
		Admin("KillPawns");
		Return; // We are a client, pass it to server.
	}
	if( !Level.Game.GetAccessManager().CanExecuteCheat(Self,'KillPawns') )
		return;
	ForEach AllActors(class 'Pawn', P)
		if( !P.bIsPlayerPawn )
			P.Destroy();
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local string OrginalClass;

	if( !Level.Game.GetAccessManager().CanExecuteCheatStr(Self,'Summon',ClassName) )
		return;
	OrginalClass = ClassName;
	if ( InStr(ClassName,".")==-1 )
		ClassName = "UnrealI."$ClassName;
	log( "Fabricate " $ ClassName );
	NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class',True) );
	if ( NewClass!=None )
	{
		if ( NewClass.Default.bStatic )
			ClientMessage("Cannot spawn a bStatic actor" @ NewClass);
		else if ( NewClass.Default.bNoDelete )
			ClientMessage("Cannot spawn a bNoDelete actor" @ NewClass);
		else if ( Spawn( NewClass,,,Location + (40+NewClass.Default.CollisionRadius) * Vector(Rotation) + vect(0,0,1) * 15,ViewRotation)==None )
			ClientMessage("Failed to spawn an actor" @ NewClass);
	}
	else ClientMessage("Unable to load class"@OrginalClass);
}

exec function TimeDemo( bool bActivate, optional bool bSaveToFile, optional int QuitAfterCycles )
{
	if (Player.Console != None)
	{
		if (bActivate)
		{
			if (Player.Console.TimeDemo == None)
				Player.Console.TimeDemo = Spawn(class'TimeDemo');
			Player.Console.TimeDemo.DoSetup(Player.Console, bSaveToFile, QuitAfterCycles);
		}
		else
		{
			if (Player.Console.TimeDemo != None)
				Player.Console.TimeDemo.DoShutdown();
		}
	}
}


//==============
// Navigation Aids
exec function ShowPath()
{
	//find next path to remembered spot
	local Actor node;

	if (Level.Netmode != NM_Standalone)
		return;

	node = FindPathTo(Destination);
	if (node != None)
	{
		log("found path");
		Spawn(class 'WayBeacon', self, '', node.location);
	}
	else
		log("didn't find path");
}

exec function RememberSpot()
{
	//remember spot
	Destination = Location;
}

//=============================================================================
// Input related functions.

// Postprocess the player's input.

event PlayerInput( float DeltaTime )
{
	local float SmoothTime, FOVScale, MouseScale, KbdScale, AbsSmooth, AbsInput;

	if ( bShowMenu && (myHud != None) )
	{
		if ( myHud.MainMenu != None )
			myHud.MainMenu.MenuTick( DeltaTime );
		// clear inputs
		bEdgeForward = false;
		bEdgeBack = false;
		bEdgeLeft = false;
		bEdgeRight = false;
		bWasForward = false;
		bWasBack = false;
		bWasLeft = false;
		bWasRight = false;
		aStrafe = 0;
		aTurn = 0;
		aForward = 0;
		aLookUp = 0;
		return;
	}
	else if ( bDelayedCommand )
	{
		bDelayedCommand = false;
		ConsoleCommand(DelayedCommand);
	}

	// Check for Dodge move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe > 0));
	bEdgeRight = (bWasRight ^^ (aStrafe < 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe > 0);
	bWasRight = (aStrafe < 0);

	// Smooth and amplify mouse movement
	SmoothTime = FMin(0.2, 3 * DeltaTime);
	FOVScale = DesiredFOV * 0.01111;
	MouseScale = MouseSensitivity * FOVScale;
	aMouseX *= MouseScale;
	aMouseY *= MouseScale;

//************************************************************************
	if (bMouseSmoothing)
	{
		if ( bMaxMouseSmoothing )
		{
			if ( !bMouseZeroed )
			{
				bMouseZeroed = ((aMouseX == 0) && (aMouseY == 0));
				if ( aMouseX == 0 )
				{
					if ( SmoothMouseX > 0 )
						aMouseX = 1;
					else if ( SmoothMouseX < 0 )
						aMouseX = -1;
				}
				if ( aMouseY == 0 )
				{
					if ( SmoothMouseY > 0 )
						aMouseY = 1;
					else if ( SmoothMouseY < 0 )
						aMouseY = -1;
				}
			}
			else
				bMouseZeroed = ((aMouseX == 0) && (aMouseY == 0));
		}

		if ( (SmoothMouseX == 0) || (aMouseX == 0)
				|| ((SmoothMouseX > 0) != (aMouseX > 0)) )
			SmoothMouseX = aMouseX;
		else
		{
			AbsSmooth = Abs(SmoothMouseX);
			AbsInput = Abs(aMouseX);
			if ( (AbsSmooth < 0.85 * AbsInput) || (AbsSmooth > 1.17 * AbsInput) )
				SmoothMouseX = 5 * SmoothTime * aMouseX + (1 - 5 * SmoothTime) * SmoothMouseX;
			else
				SmoothMouseX = SmoothTime * aMouseX + (1 - SmoothTime) * SmoothMouseX;
		}

		if ( (SmoothMouseY == 0) || (aMouseY == 0)
				|| ((SmoothMouseY > 0) != (aMouseY > 0)) )
			SmoothMouseY = aMouseY;
		else
		{
			AbsSmooth = Abs(SmoothMouseY);
			AbsInput = Abs(aMouseY);
			if ( (AbsSmooth < 0.85 * AbsInput) || (AbsSmooth > 1.17 * AbsInput) )
				SmoothMouseY = 5 * SmoothTime * aMouseY + (1 - 5 * SmoothTime) * SmoothMouseY;
			else
				SmoothMouseY = SmoothTime * aMouseY + (1 - SmoothTime) * SmoothMouseY;
		}
	}
	else
	{
		SmoothMouseX = aMouseX;
		SmoothMouseY = aMouseY;
	}

	// adjust keyboard and joystick movements
	/*
	if ( (aLookUp == 0) && (aBaseX == 0) && (aTurn == 0) )
		KbdAccel = 0.4;
	else if ( KbdAccel < 1.6 )
	{
		if ( KbdAccel < 0.7 )
			KbdAccel += deltatime;
		else
			KbdAccel = FMin(1.6, KbdAccel + 4 * deltatime);
	}
	*/
	KbdAccel = 1.0;
	KbdScale = FOVScale * KbdAccel;
	aLookUp *= FOVScale;
	aTurn   *= KbdScale;

	// Remap raw x-axis movement.
	if ( bStrafe!=0 )
	{
		// Strafe.
		aStrafe += aBaseX + SmoothMouseX;
		aBaseX   = 0;
	}
	else
	{
		// Forward.
		aTurn  += aBaseX * KbdScale + SmoothMouseX;
		aBaseX  = 0;
	}

	// Remap mouse y-axis movement.
	if ( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= SmoothMouseY;
		else
			aLookUp += SmoothMouseY;
	}
	else
	{
		// Move forward/backward.
		aForward += SmoothMouseY;
	}

	if ( bSnapLevel != 0 )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}
	else if ( bSnapToLevel && !bAlwaysMouseLook )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * KbdScale;
	}
	else
		aForward += aBaseY;

	aBaseY = 0;

	// Handle walking.
	HandleWalking();
}

//=============================================================================
// functions.

event UpdateEyeHeight(float DeltaTime)
{
	local float smooth, bound;
	local float DesiredEyeHeight;

	DesiredEyeHeight = CalcDesiredEyeHeight();

	smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
	// smooth up/down stairs
	If( (IsInState('PlayerSwimming') || Physics==PHYS_Walking) && !bJustLanded )
	{
		EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + DesiredEyeHeight) * smooth;
		bound = -0.5 * CollisionHeight;
		if (EyeHeight < bound)
			EyeHeight = bound;
		else
		{
			bound = CollisionHeight + FMin(FMax(0.0,(OldLocation.Z - Location.Z)), MaxStepHeight);
			if (bIsReducedCrouch && RealCrouchInfo != none)
				bound += RealCrouchInfo.MaxEyeHeightModifier;
			if ( EyeHeight > bound )
				EyeHeight = bound;
		}
	}
	else
	{
		smooth = 1 - (1 - 0.35) ** (60.0 * DeltaTime/Level.TimeDilation);
		bJustLanded = false;
		EyeHeight = EyeHeight * ( 1 - smooth) + (DesiredEyeHeight + ShakeVert) * smooth;
	}

	// teleporters affect your FOV, so adjust it back down
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		else
			FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if ( bZooming )
	{
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	}
}

function float CalcDesiredEyeHeight()
{
	if (SupportsRealCrouching())
		return RealCrouchInfo.CalcDesiredEyeHeight();
	return BaseEyeHeight;
}

event PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'suicided', Location);
}

// Just changed to pendingWeapon
function ChangedWeapon()
{
	Super.ChangedWeapon();
	if ( Weapon != None )
		Weapon.SetHand(Handedness);
}

function JumpOffPawn()
{
	Velocity += 60 * VRand();
	Velocity.Z = 120;
	SetPhysics(PHYS_Falling);
}

event TravelPostAccept()
{
	Super.TravelPostAccept();
	if (SelectedItem == none)
		NextItem();
}

// This pawn was possessed by a player.
event Possess()
{
	local byte i,j;
	local float CustomFOV;

	if (Level.NetMode == NM_Standalone && Level.Game.bIsSavedGame)
	{
		ServerUpdateWeapons();
		NeverSwitchOnPickup(bNeverAutoSwitch);
		CustomFOV = FClamp(MainFOV, 1, 170);
		DefaultFOV = FClamp(DefaultFOV, 1, 170);
		if (DefaultFOV != CustomFOV)
		{
			// Recalculate FOV according to the difference between saved and updated DefaultFOV
			FOVAngle = Atan(Tan(FovAngle * Pi / 360) * Tan(CustomFOV * Pi / 360) / Tan(DefaultFOV * Pi / 360)) * 360 / Pi;
			DesiredFOV = Atan(Tan(DesiredFOV * Pi / 360) * Tan(CustomFOV * Pi / 360) / Tan(DefaultFOV * Pi / 360)) * 360 / Pi;
			DefaultFOV = CustomFOV;
		}
		return;
	}

	if ( Level.Netmode == NM_Client )
	{
		// replicate client weapon preferences to server
		ServerSetHandedness(Handedness);
		j = (GetNegotiatedVersion()<227) ? 20 : ArrayCount(WeaponPriority); // Avoid script errors with pre-227 servers.
		for ( i=0; i<j; i++ )
			ServerSetWeaponPriority(i, WeaponPriority[i]);
	}
	else if ( ViewPort(Player)!=None )
		bAdmin = True;
	ServerUpdateWeapons();
	bIsPlayer = true;
	DodgeClickTime = FMin(0.3, DodgeClickTime);
	EyeHeight = BaseEyeHeight;
	NetPriority = 8;
	StartWalk();
	DefaultFOV = FClamp(MainFOV, 90, 170);
	DesiredFOV = DefaultFOV;
	NeverSwitchOnPickup(bNeverAutoSwitch);
}

function ServerSetWeaponPriority(byte i, name WeaponName)
{
	if (i < ArrayCount(WeaponPriority))
		WeaponPriority[i] = WeaponName;
}

// This pawn was unpossessed by a player.
event UnPossess()
{
	log(Self$" being unpossessed");
	if ( myHUD != None )
		myHUD.Destroy();
	bIsPlayer = false;
	EyeHeight = 0.8 * CollisionHeight;
}

singular function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
	{
		carc.Initfor(self);
		if (bIsReducedCrouch)
			carc.FullCollisionHeight = NormalCollisionHeight();
		if (Player != None)
			carc.bPlayerCarcass = true;
		MoveTarget = carc; //for Player 3rd person views
	}
	return carc;
}

function bool Gibbed(name damageType)
{
	if ( (damageType == 'decapitated') || (damageType == 'shot') )
		return false;
	if ( (Health < -80) || ((Health < -40) && (FRand() < 0.6)) )
		return true;
	return false;
}

singular function SpawnGibbedCarcass()
{
	local carcass carc;

	carc = Spawn(CarcassType);
	if ( carc != None )
	{
		carc.Initfor(self);
		carc.ChunkUp(-1 * Health);
		MoveTarget = carc; //for Player 3rd person views
	}
}

event PlayerTick( float Time );

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	bIsPlayer = true;
	Super.PreBeginPlay();
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);
	if ( Level.NetMode != NM_Client )
	{
		HUDType = Level.Game.HUDType;
		ScoringType = Level.Game.ScoreboardType;
		MyAutoAim = FMax(MyAutoAim, Level.Game.AutoAim);
	}
	bIsPlayer = true;
	DodgeClickTime = FMin(0.3, DodgeClickTime);
	EyeHeight = BaseEyeHeight;
	if ( Level.Game.IsA('SinglePlayer') && (Level.NetMode == NM_Standalone) )
		FlashScale = vect(0,0,0);
	If (MainFOV < 90.0 || MainFOV >170.0)
	MainFOV = 90.0;
	DefaultFOV=MainFOV;
}

event PostNetReceive()
{
	if (SupportsRealCrouching())
		RealCrouchInfo.ClientAdjustCrouch();
}

function ServerUpdateWeapons()
{
	local Weapon Inv;

	foreach AllInventory(class'Weapon',Inv)
		Inv.SetSwitchPriority(self);
}

//=============================================================================
// Animation playing - should be implemented in subclass,
//

function PlayDodge(eDodgeDir DodgeMove)
{
	PlayDuck();
}

function PlayTurning();

function PlaySwimming()
{
	PlayRunning();
}

function PlayFeignDeath();
function PlayRising();

/* Adjust hit location - adjusts the hit location in for pawns, and returns
true if it was really a hit, and false if not (for ducking, etc.)
*/
simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	local float adjZ, maxZ;

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;
	if (BaseEyeHeight == default.BaseEyeHeight || bIsReducedCrouch && bIsCrouching)
		return true;

	maxZ = Location.Z + EyeHeight + 0.25 * CollisionHeight;
	if ( HitLocation.Z > maxZ )
	{
		if ( TraceDir.Z >= 0 )
			return false;
		adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
		HitLocation.Z = maxZ;
		HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
		HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
		if ( VSize(HitLocation - Location) > CollisionRadius )
			return false;
	}
	return true;
}

/* AdjustAim()
Calls this version for player aiming help.
Aimerror not used in this version.
Only adjusts aiming at pawns
*/

function rotator AdjustAim(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	local vector FireDir, AimSpot, HitNormal, HitLocation;
	local actor BestTarget;
	local float bestAim, bestDist;
	local actor HitActor;

	FireDir = vector(ViewRotation);
	HitActor = Trace(HitLocation, HitNormal, projStart + 4000 * FireDir, projStart, true);
	if ( (HitActor != None) && HitActor.bProjTarget )
	{
		if ( bWarnTarget && HitActor.IsA('Pawn') )
			Pawn(HitActor).WarnTarget(self, projSpeed, FireDir);
		return ViewRotation;
	}

	bestAim = FMin(0.93, MyAutoAim);
	BestTarget = PickTarget(bestAim, bestDist, FireDir, projStart);

	if ( bWarnTarget && (Pawn(BestTarget) != None) )
		Pawn(BestTarget).WarnTarget(self, projSpeed, FireDir);

	if ( (Level.NetMode != NM_Standalone) || (Level.Game.Difficulty > 2)
			|| bAlwaysMouseLook || ((BestTarget != None) && (bestAim < MyAutoAim)) || (MyAutoAim >= 1) )
		return ViewRotation;

	if ( BestTarget == None )
	{
		bestAim = MyAutoAim;
		BestTarget = PickAnyTarget(bestAim, bestDist, FireDir, projStart);
		if ( BestTarget == None )
			return ViewRotation;
	}

	AimSpot = projStart + FireDir * bestDist;
	AimSpot.Z = BestTarget.Location.Z + 0.3 * BestTarget.CollisionHeight;

	return rotator(AimSpot - projStart);
}

function rotator AdjustToss(float projSpeed, vector projStart, int aimerror, bool bLeadTarget, bool bWarnTarget)
{
	local vector X,V,Grav,Pos,OldPos,HitNormal,HitLocation;
	local byte i;
	local actor HitActor;
	local float bestAim,bestDist;
	
	if( bWarnTarget && Level.Game && Level.Game.Difficulty>3 )
	{
		X = vector(ViewRotation);
		V = X*projSpeed;
		Grav = Region.Zone.ZoneGravity;
		Pos = projStart;
		OldPos = projStart;
		for( ; i<8; ++i )
		{
			Pos+=(V*0.2f);
			V+=Grav*0.2f;
			
			HitActor = Trace(HitLocation, HitNormal, Pos, OldPos, true);
			OldPos = Pos;
			if ( HitActor )
			{
				if( HitActor.bProjTarget && HitActor.bIsPawn )
					Pawn(HitActor).WarnTarget(self, projSpeed, X);
				break;
			}
		}
		
		bestAim = 0.93;
		HitActor = PickTarget(bestAim, bestDist, X, projStart);

		if ( HitActor && HitActor.bIsPawn )
			Pawn(HitActor).WarnTarget(self, projSpeed, X);
	}
	return ViewRotation;
}

function Falling()
{
	//SetPhysics(PHYS_Falling); //Note - physics changes type to PHYS_Falling by default
	//log(class$" Falling");
	if (!bUpdatePosition)
		PlayInAir();
}

function Landed(vector HitNormal)
{
	//Note - physics changes type to PHYS_Walking by default for landed pawns
	if (!bUpdatePosition)
		PlayLanded(Velocity.Z);
	if (Velocity.Z < -1.4 * JumpZ)
	{
		MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
		if (Velocity.Z <= -1100)
		{
			if ( (Velocity.Z < -2000) && (ReducedDamageType != 'All') )
				TakeDamage(1000, None, Location, vect(0,0,0), 'fell');
			else if ( Role == ROLE_Authority )
				TakeDamage(-0.15 * (Velocity.Z + 1050), None, Location, vect(0,0,0), 'fell');
		}
	}
	else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
		MakeNoise(0.1 * Level.Game.Difficulty);

	if (!bUpdatePosition)
		bJustLanded = true;

	if (SupportsRealCrouching())
		RealCrouchInfo.HandleLanding();
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	//Assert( Role = ROLE_Authority );
	// encroach problem may cause this
	// so temp
	if (Role != ROLE_Authority)
	{
		log("Non-authority tried to die");
		return;
	}

	StopZoom();

	Super.Died(Killer, damageType, HitLocation);
}

function eAttitude AttitudeTo(Pawn Other)
{
	if (Other.bIsPlayer)
		return AttitudeToPlayer;
	else
		return Other.AttitudeToPlayer;
}


function string KillMessage( name damageType, pawn Other )
{
	return ( Level.Game.PlayerKillMessage(damageType, Other)$PlayerReplicationInfo.PlayerName );
}

//=============================================================================
// Player Control

function KilledBy( pawn EventInstigator )
{
	local int OldHealth;

	if (!CanInteractWithWorld())
		return;

	OldHealth = Health;
	Health = 0;
	Died(EventInstigator, 'suicided', Location);
	if (Health > 0)
		Health = OldHealth;
}

// Player view.
// Compute the rendering viewpoint for the player.
//

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = ViewRotation;
	View = vect(1,0,0) >> CameraRotation;
	if ( ((ViewTarget!=None) ? ViewTarget : Self).Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View;
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	if ( ViewTarget )
	{
		ViewActor = ViewTarget;
		ViewTarget.GetRenderPosition(CameraLocation, CameraRotation);
		PTarget = Pawn(ViewTarget);
		if( PTarget )
		{
			if ( Level.NetMode == NM_Client )
			{
				if ( PTarget.bIsPlayer )
					PTarget.ViewRotation = TargetViewRotation;
				PTarget.EyeHeight = TargetEyeHeight;
				if ( PTarget.Weapon != None )
					PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
			}
			if ( PTarget.bIsPlayer )
				CameraRotation = PTarget.ViewRotation;
			if ( !bBehindView )
				CameraLocation.Z += PTarget.EyeHeight;
			else if (Level.bSupportsRealCrouching && PlayerPawn(PTarget) != none)
				CameraLocation.Z += PTarget.PrePivot.Z - PlayerPawn(PTarget).NormalPrePivotZ();
		}
		if ( bBehindView )
			CalcBehindView(CameraLocation, CameraRotation, 180);
		return;
	}

	ViewActor = Self;
	CameraLocation = Location;

	if ( bBehindView ) //up and behind
	{
		if (Level.bSupportsRealCrouching)
			CameraLocation.Z += PrePivot.Z - NormalPrePivotZ();
		CalcBehindView(CameraLocation, CameraRotation, 150);
	}
	else
	{
		// First-person view.
		CameraRotation = ViewRotation;
		CameraLocation.Z += EyeHeight;
		CameraLocation += WalkBob;
	}
}

function float CalcDesiredPrePivotZ()
{
	return NormalPrePivotZ();
}

final simulated function float NormalPrePivotZ()
{
	local vector NormalPrePivot;

	NormalPrePivot = ScaledDefaultPrePivot();
	NormalPrePivot.Z += PrePivotZModifier;
	return NormalPrePivot.Z;
}

final simulated function float NormalCollisionHeight()
{
	if (SpecialCollisionHeight > 0)
		return SpecialCollisionHeight;
	return ScaledDefaultCollisionHeight();
}

exec function SetViewFlash(bool B)
{
	bNoFlash = !B;
}

function ViewFlash(float DeltaTime)
{
	local vector goalFog;
	local float goalscale, delta;

	if ( bNoFlash )
	{
		InstantFlash = 0;
		InstantFog = vect(0,0,0);
	}
	delta = FMin(0.1, DeltaTime);
	goalScale = 1 + DesiredFlashScale + ConstantGlowScale;
	goalFog = DesiredFlashFog + ConstantGlowFog;

	if ( CameraRegion.Zone!=None )
	{
		goalScale+=CameraRegion.Zone.ViewFlash.X;
		goalFog+=CameraRegion.Zone.ViewFog;
	}

	DesiredFlashScale -= DesiredFlashScale * 2 * delta;
	DesiredFlashFog -= DesiredFlashFog * 2 * delta;
	FlashScale.X += (goalScale - FlashScale.X + InstantFlash) * 10 * delta;
	//FlashFog += (goalFog - FlashFog + InstantFog) * 10 * delta;
	CurrentFlashFog += (goalFog - CurrentFlashFog + InstantFog) * 10 * delta;
	InstantFlash = 0;
	InstantFog = vect(0,0,0);

	if ( FlashScale.X > 0.981 )
		FlashScale.X = 1;
	FlashScale = FlashScale.X * vect(1,1,1);

	FlashFog = CurrentFlashFog;
	if ( FlashFog.X < 0.019 )
		FlashFog.X = 0;
	if ( FlashFog.Y < 0.019 )
		FlashFog.Y = 0;
	if ( FlashFog.Z < 0.019 )
		FlashFog.Z = 0;
}

function ViewShake(float DeltaTime)
{
	if (shaketimer > 0.0) //shake view
	{
		Shaketimer=FClamp(Shaketimer,0.0,4.0); //4 seconds max
		shaketimer -= DeltaTime;
		if ( verttimer == 0 )
		{
			verttimer = 0.1;
			ShakeVert = -1.1 * maxshake;
		}
		else
		{
			verttimer -= DeltaTime;
			if ( verttimer < 0 )
			{
				verttimer = 0.2 * FRand();
				shakeVert = (2 * FRand() - 1) * maxshake;
			}
		}
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (bShakeDir)
		{
			ViewRotation.Roll += Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) || (ViewRotation.Roll < (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll < 32768) && (ViewRotation.Roll > 1.3 * shakemag) )
			{
				ViewRotation.Roll = 1.3 * shakemag;
				bShakeDir = false;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
		else
		{
			ViewRotation.Roll -= Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - 1.3 * shakemag) )
			{
				ViewRotation.Roll = 65535 - 1.3 * shakemag;
				bShakeDir = true;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
	}
	else
	{
		ShakeVert = 0;
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (ViewRotation.Roll < 32768)
		{
			if ( ViewRotation.Roll > 0 )
				ViewRotation.Roll = Max(0, ViewRotation.Roll - (Max(ViewRotation.Roll,500) * 10 * FMin(0.1,DeltaTime)));
		}
		else
		{
			ViewRotation.Roll += ((65536 - Max(500,ViewRotation.Roll)) * 10 * FMin(0.1,DeltaTime));
			if ( ViewRotation.Roll > 65534 )
				ViewRotation.Roll = 0;
		}
	}
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation;

	DesiredRotation = ViewRotation; //save old rotation
	ViewRotation.Pitch += AccumulatedPlayerTurn(32.0 * DeltaTime * aLookUp, AccumulatedVTurn);
	ViewRotation.Pitch = ViewRotation.Pitch & 65535;
	If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
	{
		If (aLookUp > 0)
		ViewRotation.Pitch = 18000;
		else
			ViewRotation.Pitch = 49152;
	}
	ViewRotation.Yaw += AccumulatedPlayerTurn(32.0 * DeltaTime * aTurn, AccumulatedHTurn);
	ViewShake(deltaTime);
	ViewFlash(deltaTime);

	newRotation = Rotation;
	newRotation.Yaw = ViewRotation.Yaw;
	newRotation.Pitch = ViewRotation.Pitch;
	If ( (newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (ViewRotation.Pitch < 32768)
		newRotation.Pitch = maxPitch * RotationRate.Pitch;
		else
			newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	UpdatePawnRotation(newRotation);
}

function int AccumulatedPlayerTurn(float CurrentTurn, out float AccumulatedTurn)
{
	local int IntTurn;

	CurrentTurn += AccumulatedTurn;
	IntTurn = CurrentTurn;
	AccumulatedTurn = CurrentTurn - IntTurn;
	return IntTurn;
}

function SwimAnimUpdate(bool bNotForward)
{
	if ( !bAnimTransition && (bool(Acceleration) || GetAnimGroup(AnimSequence) != 'Gesture') )
	{
		if ( bNotForward )
		{
			if ( GetAnimGroup(AnimSequence) != 'Waiting' )
				TweenToWaiting(0.1);
		}
		else if ( GetAnimGroup(AnimSequence) == 'Waiting' || GetAnimGroup(AnimSequence) == 'Gesture' )
			TweenToSwimming(0.1);
	}
}

// To be returned for player info on serverlist.
function GetPlayerModelInfo( out string MeshName, out string SkinName )
{
	if( Mesh!=None )
		MeshName = string(Mesh.Name);
	else MeshName = MenuName;
	if( Skin!=None )
		SkinName = string(Skin.Name);
	else SkinName = "Default";
}

// 227j real crouching mode implementation:
final function bool SetCrouch(bool bCrouching)
{
	if (SupportsRealCrouching())
		return RealCrouchInfo.SetCrouch(bCrouching);
	return true;
}

// unused, preserved for backward compatibility
final function bool TryToDuck(bool bCrouching)
{
	return SetCrouch(bCrouching);
}

final function bool SupportsRealCrouching()
{
	return Level.bSupportsRealCrouching && CrouchHeightPct < 1 && ObtainRealCrouchInfo();
}

final function bool ObtainRealCrouchInfo()
{
	if (RealCrouchInfo != none && !RealCrouchInfo.bDeleteMe)
		return true;
	if (Level.RealCrouchInfoClass != none)
		return SetRealCrouchInfo(Spawn(Level.RealCrouchInfoClass, self));
	return SetRealCrouchInfo(Spawn(class'RealCrouchInfo', self));
}

final function bool SetRealCrouchInfo(RealCrouchInfo NewRealCrouchInfo)
{
	if (NewRealCrouchInfo == none || NewRealCrouchInfo.bDeleteMe)
		return false;
	if (NewRealCrouchInfo == RealCrouchInfo)
		return true;
	if (NewRealCrouchInfo.Owner != self)
	{
		NewRealCrouchInfo.Inactivate();
		return false;
	}

	if (RealCrouchInfo != none && !RealCrouchInfo.bDeleteMe)
		RealCrouchInfo.Inactivate();

	RealCrouchInfo = NewRealCrouchInfo;
	RealCrouchInfo.Init();
	return true;
}

native final function int GetNegotiatedVersion( optional bool FullName );

function bool DesiredCrouch()
{
	return bIsCrouching;
}

// 227j player affectors
final function PlayerAffectorInfo GetPlayerAffector(class<PlayerAffectorInfo> AffectorClass)
{
	local PlayerAffectorInfo Affector;

	for (Affector = FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
		if (Affector.Class == AffectorClass)
			return Affector;
	Affector = Spawn(AffectorClass, self);
	if (Affector == none || Affector.bDeleteMe)
		return none;

	Affector.Init();
	Affector.NextAffector = FirstPlayerAffector;
	FirstPlayerAffector = Affector;
	return Affector;
}

final function RemovePlayerAffectors()
{
	local PlayerAffectorInfo Affector;

	for (Affector = FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
		Affector.Destroy();
	FirstPlayerAffector = none;
}

function GotoDefaultPlayerState()
{
	if (Region.Zone.bWaterZone )
	{
		SetPhysics(PHYS_Swimming);
		GoToState('PlayerSwimming');
	}
	else
	{
		if (!IsInState('PlayerWalking'))
			SetPhysics(PHYS_Falling);
		GoToState('PlayerWalking');
	}
}

function InterpolationEnded()
{
	Super.InterpolationEnded();
	if (Level.NetMode != NM_Client && Health>0)
		GotoDefaultPlayerState();
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	exec function FeignDeath()
	{
		if ( Physics == PHYS_Walking )
		{
			ServerFeignDeath();
			Acceleration = vect(0,0,0);
			GotoState('FeigningDeath');
		}
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	function AnimEnd()
	{
		local name MyAnimGroup;

		bAnimTransition = false;
		if ( Physics == PHYS_Spider )
		{
			if ( VSize(Velocity)<10 )
				PlayDuck();
			else PlayCrawling();
		}
		else if (Physics == PHYS_Walking)
		{
			if (bIsCrouching)
			{
				if ( !bIsTurning && ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000) )
					PlayDuck();
				else
					PlayCrawling();
			}
			else
			{
				MyAnimGroup = GetAnimGroup(AnimSequence);
				if ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000)
				{
					if ( MyAnimGroup == 'Waiting' )
						PlayWaiting();
					else
					{
						bAnimTransition = true;
						TweenToWaiting(0.2);
					}
				}
				else if (bIsWalking)
				{
					if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
					{
						TweenToWalking(0.1);
						bAnimTransition = true;
					}
					else
						PlayWalking();
				}
				else
				{
					if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
					{
						bAnimTransition = true;
						TweenToRunning(0.1);
					}
					else
						PlayRunning();
				}
			}
		}
		else if (bIsReducedCrouch)
			PlayDuck();
		else
			PlayInAir();
	}

	function Landed(vector HitNormal)
	{
		Global.Landed(HitNormal);
		if (DodgeDir == DODGE_Active)
		{
			DodgeDir = DODGE_Done;
			DodgeClickTimer = 0.0;
			Velocity *= 0.1;
		}
		else
			DodgeDir = DODGE_None;
	}

	function Dodge(eDodgeDir DodgeMove)
	{
		local vector X,Y,Z;

		if ( bIsCrouching || (Physics != PHYS_Walking) )
			return;

		GetAxes(Rotation,X,Y,Z);
		if (DodgeMove == DODGE_Forward)
			Velocity = 1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Back)
			Velocity = -1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Left)
			Velocity = 1.5*GroundSpeed*Y + (Velocity Dot X)*X;
		else if (DodgeMove == DODGE_Right)
			Velocity = -1.5*GroundSpeed*Y + (Velocity Dot X)*X;

		Velocity.Z = 160;
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
		if (!bUpdatePosition)
			PlayDodge(DodgeMove);
		DodgeDir = DODGE_Active;
		SetPhysics(PHYS_Falling);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local vector OldAccel;
		local PlayerAffectorInfo Affector;

		for (Affector = FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
			if (Affector.ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot))
				return;

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );
		if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
			DodgeDir = DODGE_Active;
		else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
			Dodge(DodgeMove);

		if ( bPressedJump )
			DoJump();
		if ( (Physics == PHYS_Walking) && (GetAnimGroup(AnimSequence) != 'Dodge') )
		{
			if ( !bIsCrouching )
			{
				if ( bDuck != 0 && SetCrouch(true) && IsInState('PlayerWalking') ) // Note: SetCrouch may change the state (e.g. to PlayerSwimming)
				{
					bIsCrouching = true;
					if (!bUpdatePosition)
						PlayDuck();
				}
			}
			else if ( bDuck == 0 && SetCrouch(false) )
			{
				OldAccel = vect(0,0,0);
				bIsCrouching = false;
				if (!IsInState('PlayerWalking'))
					return;
				if (bool(Acceleration) && !bUpdatePosition)
					TweenToRunning(0.1);
			}

			if (bUpdatePosition)
				return;

			if ( !bIsCrouching )
			{
				if ( (!bAnimTransition || (AnimFrame > 0)) && (GetAnimGroup(AnimSequence) != 'Landing') )
				{
					if ( Acceleration != vect(0,0,0) )
					{
						if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') || (GetAnimGroup(AnimSequence) == 'TakeHit') )
						{
							bAnimTransition = true;
							TweenToRunning(0.1);
						}
					}
					else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
							  && (GetAnimGroup(AnimSequence) != 'Gesture') )
					{
						if ( GetAnimGroup(AnimSequence) == 'Waiting' )
						{
							if ( bIsTurning && (AnimFrame >= 0) )
							{
								bAnimTransition = true;
								PlayTurning();
							}
						}
						else if ( !bIsTurning )
						{
							bAnimTransition = true;
							TweenToWaiting(0.2);
						}
					}
				}
			}
			else
			{
				if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
					PlayCrawling();
				else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
					PlayDuck();
			}
		}
		else if (Physics != PHYS_Walking && SupportsRealCrouching())
			RealCrouchInfo.UpdateAirCrouch();
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool    bSaveJump;
		local name AnimGroupName;

		if ( Physics==PHYS_Spider )
			GetAxes(ViewRotation,X,Y,Z);
		else GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y;
		if ( Physics!=PHYS_Spider )
			NewAccel.Z = 0;
		// Check for Dodge move
		if ( DodgeDir == DODGE_Active )
			DodgeMove = DODGE_Active;
		else DodgeMove = DODGE_None;
		if (DodgeClickTime > 0.0)
		{
			if ( DodgeDir < DODGE_Active )
			{
				OldDodge = DodgeDir;
				DodgeDir = DODGE_None;
				if (bEdgeForward && bWasForward)
					DodgeDir = DODGE_Forward;
				if (bEdgeBack && bWasBack)
					DodgeDir = DODGE_Back;
				if (bEdgeLeft && bWasLeft)
					DodgeDir = DODGE_Left;
				if (bEdgeRight && bWasRight)
					DodgeDir = DODGE_Right;
				if ( DodgeDir == DODGE_None)
					DodgeDir = OldDodge;
				else if ( DodgeDir != OldDodge )
					DodgeClickTimer = DodgeClickTime + 0.5 * DeltaTime;
				else
					DodgeMove = DodgeDir;
			}

			if (DodgeDir == DODGE_Active && Physics == PHYS_Walking)
			{
				// force dodge completion in case if PHYS_Walking was set without calling Landed
				DodgeDir = DODGE_Done;
				DodgeClickTimer = 0;
			}

			if (DodgeDir == DODGE_Done)
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < -0.35)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
			else if ((DodgeDir != DODGE_None) && (DodgeDir != DODGE_Active))
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < 0)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
		}

		AnimGroupName = GetAnimGroup(AnimSequence);
		if ( (Physics == PHYS_Walking) && (AnimGroupName != 'Dodge') )
		{
			//if walking, look up/down stairs - unless player is rotating view
			if ( !bKeyboardLook && (bLook == 0) )
			{
				if ( bLookUpStairs )
					ViewRotation.Pitch = FindStairRotation(deltaTime);
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}

			Speed2D = FMin(Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y), GroundSpeed*1.5f);
			//add bobbing when walking
			if ( !bShowMenu )
			{
				if ( Speed2D < 10 || GroundSpeed == 0 )
					BobTime += 0.2 * DeltaTime * FClamp(Region.Zone.ZoneTimeDilation,0.1,10.f);
				else
					BobTime += DeltaTime * FClamp(Region.Zone.ZoneTimeDilation,0.1,10.f) * (0.3 + 0.7 * Speed2D/GroundSpeed);
				WalkBob = Y * 0.65 * Bob * Speed2D * sin(6.0 * BobTime);
				if ( Speed2D < 10 )
					WalkBob.Z = Bob * 30 * sin(12 * BobTime);
				else WalkBob.Z = Bob * Speed2D * sin(12 * BobTime);
			}
		}
		else if ( !bShowMenu )
		{
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	function float CalcDesiredPrePivotZ()
	{
		return NormalPrePivotZ() + (NormalCollisionHeight() - CollisionHeight);
	}

	function BeginState()
	{
		WalkBob = vect(0,0,0);
		ResetDodgeMove();
		bIsCrouching = bIsReducedCrouch;
		bIsTurning = false;
		bPressedJump = false;
		if (Physics != PHYS_Falling)
			SetPhysics(PHYS_Walking);
		if ( !IsAnimating() )
		{
			if (bIsCrouching)
				PlayDuck();
			else
				PlayWaiting();
		}
	}

	function EndState()
	{
		WalkBob = vect(0,0,0);
		bIsCrouching = false;
	}
}

state FeigningDeath
{
ignores SeePlayer, HearNoise, Bump, Fire, AltFire, StartClimbing;

	function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	function PlayChatting()
	{
	}

	exec function Taunt( name Sequence )
	{
	}

	function AnimEnd()
	{
		if ( (Role == ROLE_Authority) && (Health > 0) )
		{
			GotoState('PlayerWalking');
			ChangedWeapon();
			LastUpdateTime = -1;
		}
	}

	function Landed(vector HitNormal)
	{
		if ( Role == ROLE_Authority )
			PlaySound(Land, SLOT_Interact, 0.3, false, 800, 1.0);
		if (Velocity.Z < -1.4 * JumpZ)
		{
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
			if (Velocity.Z <= -1100)
			{
				if ( (Velocity.Z < -2000) && (ReducedDamageType != 'All') )
					TakeDamage(1000, None, Location, vect(0,0,0), 'fell');
				else if ( Role == ROLE_Authority )
					TakeDamage(-0.15 * (Velocity.Z + 1050), Self, Location, vect(0,0,0), 'fell');
			}
		}
		else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
			MakeNoise(0.1 * Level.Game.Difficulty);

		if (!bUpdatePosition)
			bJustLanded = true;
	}

	function Rise()
	{
		if (!bRising && !bUpdatePosition)
		{
			if (SupportsRealCrouching())
				RealCrouchInfo.HandleRising();
			else
			{
				Enable('AnimEnd');
				BaseEyeHeight = Default.BaseEyeHeight;
				bRising = true;
				PlayRising();
			}
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		if ( bPressedJump || (NewAccel.Z > 0) )
			Rise();
		Acceleration = vect(0,0,0);
		bFire = 0;
		bAltFire = 0;
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function ServerMove
	(
		float TimeStamp,
		vector Accel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbPressedJump,
		bool bFired,
		bool bAltFired,
		eDodgeDir DodgeMove,
		byte ClientRoll,
		int View
	)
	{
		Global.ServerMove(TimeStamp, Accel, ClientLoc, NewbRun, NewbDuck, NewbPressedJump,
						  bFired, bAltFired, DodgeMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)));
	}

	function PlayerMove( float DeltaTime)
	{
		local rotator currentRot;
		local vector NewAccel;

		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		if ( !IsAnimating() && (aForward != 0) || (aStrafe != 0) )
			NewAccel = vect(0,0,1);
		else
			NewAccel = vect(0,0,0);

		// Update view rotation.
		currentRot = Rotation;
		UpdateRotation(DeltaTime, 1);
		SetRotation(currentRot);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		bPressedJump = false;
	}

	function PlayTakeHit(float tweentime, vector HitLoc, int Damage)
	{
		if ( IsAnimating() )
		{
			Enable('AnimEnd');
			Global.PlayTakeHit(tweentime, HitLoc, Damage);
		}
	}

	function PlayDying(name DamageType, vector HitLocation)
	{
		BaseEyeHeight = Default.BaseEyeHeight;
	}

	function ChangedWeapon()
	{
		Inventory.ChangedWeapon();
		Weapon = None;
	}

	function bool DesiredCrouch()
	{
		return !bRising || bDuck != 0;
	}

	function float CalcDesiredPrePivotZ()
	{
		return NormalPrePivotZ() + (NormalCollisionHeight() - CollisionHeight);
	}

	function EndState()
	{
		PlayerReplicationInfo.bFeigningDeath = false;
	}

	function BeginState()
	{
		local rotator NewRot;

		bFire = 0;
		bAltFire = 0;
		if (Role == ROLE_Authority && CarriedDecoration != none)
			DropDecoration();
		NewRot = Rotation;
		NewRot.Pitch = 0;
		SetRotation(NewRot);
		BaseEyeHeight = -0.5 * CollisionHeight;
		bIsCrouching = false;
		bPressedJump = false;
		bRising = false;
		Disable('AnimEnd');
		PlayFeignDeath();
		PlayerReplicationInfo.bFeigningDeath = true;
		bSaveClientPlayerState = true;
		if (SupportsRealCrouching())
			RealCrouchInfo.UpdateCrouch();
	}
}

// Player movement.
// Player Swimming
state PlayerSwimming
{
ignores SeePlayer, HearNoise, Bump;

	event UpdateEyeHeight(float DeltaTime)
	{
		local float smooth, bound;
		local float DesiredEyeHeight;

		DesiredEyeHeight = CalcDesiredEyeHeight();

		// smooth up/down stairs
		if ( !bJustLanded )
		{
			smooth = FMin(1.0, 10.0 * DeltaTime/Level.TimeDilation);
			EyeHeight = (EyeHeight - Location.Z + OldLocation.Z) * (1 - smooth) + ( ShakeVert + DesiredEyeHeight) * smooth;
			bound = -0.5 * CollisionHeight;
			if (EyeHeight < bound)
				EyeHeight = bound;
			else
			{
				bound = CollisionHeight + FClamp((OldLocation.Z - Location.Z), 0.0, MaxStepHeight);
				if (bIsReducedCrouch && RealCrouchInfo != none)
					bound += RealCrouchInfo.MaxEyeHeightModifier;
				if ( EyeHeight > bound )
					EyeHeight = bound;
			}
		}
		else
		{
			smooth = 1 - (1 - 0.35) ** (60.0 * DeltaTime/Level.TimeDilation);
			bJustLanded = false;
			EyeHeight = EyeHeight * ( 1 - smooth) + (DesiredEyeHeight + ShakeVert) * smooth;
		}

		// teleporters affect your FOV, so adjust it back down
		if ( FOVAngle != DesiredFOV )
		{
			if ( FOVAngle > DesiredFOV )
				FOVAngle = FOVAngle - FMax(7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
			else
				FOVAngle = FOVAngle - FMin(-7, 0.9 * DeltaTime * (FOVAngle - DesiredFOV));
			if ( Abs(FOVAngle - DesiredFOV) <= 10 )
				FOVAngle = DesiredFOV;
		}

		// adjust FOV for weapon zooming
		if ( bZooming )
		{
			ZoomLevel += DeltaTime * 1.0;
			if (ZoomLevel > 0.9)
				ZoomLevel = 0.9;
			DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
		}
	}

	function Landed(vector HitNormal)
	{
		//log(class$" Landed while swimming");
		if (!bUpdatePosition)
			PlayLanded(Velocity.Z);
		if (Velocity.Z < -1.2 * JumpZ)
		{
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
			if (Velocity.Z <= -1100)
			{
				if ( (Velocity.Z < -2000) && (ReducedDamageType != 'All') )
					TakeDamage(1000, None, Location, vect(0,0,0), 'fell');
				else if ( Role == ROLE_Authority )
					TakeDamage(-0.1 * (Velocity.Z + 1050), Self, Location, vect(0,0,0), 'fell');
			}
		}
		else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
			MakeNoise(0.1 * Level.Game.Difficulty);

		if (!bUpdatePosition)
			bJustLanded = true;

		if ( Region.Zone.bWaterZone )
			SetPhysics(PHYS_Swimming);
		else
		{
			GotoState('PlayerWalking');
			if (!bUpdatePosition)
				AnimEnd();
		}
	}

	function AnimEnd()
	{
		local vector X,Y,Z;
		GetAxes(Rotation, X,Y,Z);
		if ( (Acceleration Dot X) <= 0 )
		{
			if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			{
				bAnimTransition = true;
				TweenToWaiting(0.2);
			}
			else
				PlayWaiting();
		}
		else
		{
			if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			{
				bAnimTransition = true;
				TweenToSwimming(0.2);
			}
			else
				PlaySwimming();
		}
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint;

		if (!NewZone.bWaterZone)
		{
			SetPhysics(PHYS_Falling);
			if (bUpAndOut && CheckWaterJump(HitNormal)) //check for waterjump
			{
				velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
				if (!bUpdatePosition)
					PlayDuck();
				GotoState('PlayerWalking');
			}
			else if (!FootRegion.Zone.bWaterZone || (Velocity.Z > 160) )
			{
				GotoState('PlayerWalking');
				AnimEnd();
			}
			else //check if in deep water
			{
				checkpoint = Location;
				checkpoint.Z -= (CollisionHeight + 6.0);
				HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, false);
				if (HitActor != None)
				{
					GotoState('PlayerWalking');
					AnimEnd();
				}
				else if (!bUpdatePosition)
				{
					Enable('Timer');
					SetTimer(0.7,false);
				}
			}
			//log("Out of water");
		}
		else
		{
			if (!bUpdatePosition)
				Disable('Timer');
			SetPhysics(PHYS_Swimming);
		}
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local vector X,Y,Z, Temp;
		local PlayerAffectorInfo Affector;

		for (Affector = FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
			if (Affector.ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot))
				return;

		GetAxes(ViewRotation,X,Y,Z);
		Acceleration = NewAccel;

		if (!bUpdatePosition)
			SwimAnimUpdate( (X Dot Acceleration) <= 0 );

		bUpAndOut = ((X Dot Acceleration) > 0) && ((Acceleration.Z > 0) || (ViewRotation.Pitch > 2048));
		if ( bUpAndOut && !Region.Zone.bWaterZone && CheckWaterJump(Temp) ) //check for waterjump
		{
			velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
			if (!bUpdatePosition)
				PlayDuck();
			GotoState('PlayerWalking');
		}
		else if (SupportsRealCrouching())
			RealCrouchInfo.UpdateUnderwaterCrouch();
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		//add bobbing when swimming
		if ( !bShowMenu )
		{
			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
			WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
		}

		// Update rotation.
		oldRotation = Rotation;
		UpdateRotation(DeltaTime, 2);

		if (SupportsRealCrouching())
		{
			bPressedJump = false;
			RealCrouchInfo.HandleVerticalMovement(aUp);
		}

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);

		if (!SupportsRealCrouching())
			bPressedJump = false;
	}

	function Timer()
	{
		if ( !Region.Zone.bWaterZone && (Role == ROLE_Authority) )
		{
			//log("timer out of water");
			GotoState('PlayerWalking');
			AnimEnd();
			LastUpdateTime = -1;
		}

		Disable('Timer');
	}

	function bool DesiredCrouch()
	{
		return
			RealCrouchInfo.bCanCrouchWhenSwimming &&
			(bDuck != 0 || RealCrouchInfo.PlayerShouldCrouchToCeiling());
	}

	function BeginState()
	{
		Disable('Timer');
		if (!IsAnimating())
			TweenToWaiting(0.3);
		else if (bIsReducedCrouch)
			TweenToSwimming(0.2);
		//log("player swimming");
	}
}

state PlayerInterpolate
{
Ignores AnimEnd,FellOutOfWorld;

	function BeginState()
	{
		WalkBob = vect(0,0,0);
		LastUpdateTime = -1;
		TweenToWalking(0.1f);
	}
	function EndState()
	{
		Target = None;
		if( Physics==PHYS_Interpolating )
			SetPhysics(PHYS_Falling);
		bInterpolating = false;
		LastUpdateTime = -1;
	}

	// Basicly do nothing.
	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		PlayerMove(DeltaTime);
	}
	function PlayerMove( float DeltaTime )
	{
		bPressedJump = false;
		if ( Role < ROLE_Authority )
			ReplicateMoveIP(DeltaTime);
	}
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
	}
	final function ReplicateMoveIP( float DeltaTime )
	{
		local SavedMove NewMove;

		// if am network client and am carrying flag -
		//	make its position look good client side
		if ( (PlayerReplicationInfo != None) && (PlayerReplicationInfo.HasFlag != None) )
			PlayerReplicationInfo.HasFlag.FollowHolder(self);

		// Get a SavedMove actor to store the movement in.
		if ( SavedMoves == None )
		{
			SavedMoves = GetFreeMove();
			NewMove = SavedMoves;
		}
		else
		{
			NewMove = SavedMoves;
			while ( NewMove.NextMove != None )
				NewMove = NewMove.NextMove;
			if ( NewMove.bSent )
			{
				NewMove.NextMove = GetFreeMove();
				NewMove = NewMove.NextMove;
			}
		}

		NewMove.Delta = DeltaTime;
		NewMove.Acceleration = vect(0,0,0);

		// Set this move's data.
		NewMove.DodgeMove = DODGE_None;
		NewMove.TimeStamp = Level.TimeSeconds;
		NewMove.bRun = false;
		NewMove.bDuck = false;
		NewMove.bPressedJump = false;

		// Simulate the movement locally.
		AutonomousPhysics(DeltaTime);

		// Send to the server
		NewMove.bSent = true;
		ServerMove(Level.TimeSeconds,vect(0,0,0),Location,false,false,false,(bJustFired || (bFire != 0)),(bJustAltFired || (bAltFire != 0)),DODGE_None,0,0);

		bJustFired = false;
		bJustAltFired = false;
	}
	function ServerMove( float TimeStamp, vector InAccel, vector ClientLoc, bool NewbRun, bool NewbDuck, bool NewbPressedJump,
		bool bFired, bool bAltFired, eDodgeDir DodgeMove, byte ClientRoll, int View )
	{
		local float DeltaTime;

		// If this move is outdated, discard it.
		if ( CurrentTimeStamp >= TimeStamp )
			return;

		// handle firing and alt-firing
		if ( bFired )
		{
			if ( bFire == 0 )
			{
				Fire(0);
				bFire = 1;
			}
		}
		else
			bFire = 0;


		if ( bAltFired )
		{
			if ( bAltFire == 0 )
			{
				AltFire(0);
				bAltFire = 1;
			}
		}
		else
			bAltFire = 0;

		// Save move parameters.
		DeltaTime = TimeStamp - CurrentTimeStamp;
		if ( ServerTimeStamp > 0 )
		{
			TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
			if ( TimeMargin > MaxTimeMargin )
			{
				// player is too far ahead
				TimeMargin -= DeltaTime;
				if ( TimeMargin < 0.5 )
					MaxTimeMargin = 1.0;
				else
					MaxTimeMargin = 0.5;
				DeltaTime = 0;
			}
			else if ( TimeMargin < -MaxTimeMargin ) // player is too far behind.
				TimeMargin = -MaxTimeMargin;
		}

		CurrentTimeStamp = TimeStamp;
		ServerTimeStamp = Level.TimeSeconds;

		// Perform actual movement.
		if ( Len(Level.Pauser)==0 && (DeltaTime > 0) )
			AutonomousPhysics(DeltaTime);

		if ( (Level.TimeSeconds-LastUpdateTime)>0.25 )
		{
			LastUpdateTime = Level.TimeSeconds;
			if (ObtainClientReplicationInfo())
				ClientReplicationInfo.SynchronizeFrom(TimeStamp);
			else if (IsInState('PlayerInterpolate'))
				ClientAdjustPosition(TimeStamp, GetStateName(), PHYS_None, PhysRate, PhysAlpha, 0, 0, 0, 0, Target);
			else
				ClientAdjustPositionFrom(TimeStamp);
		}
	}
	function ClientAdjustPosition
	(
		float TimeStamp,
		name newState,
		EPhysics newPhysics,
		float NewLocX, // PhysRate
		float NewLocY, // PhysAlpha
		float NewLocZ,
		float NewVelX,
		float NewVelY,
		float NewVelZ,
		Actor NewBase // Interpolate target
	)
	{
		if ( CurrentTimeStamp > TimeStamp )
			return;
		CurrentTimeStamp = TimeStamp;

		if (GetStateName() != newState)
		{
			GotoState(newState);
			if (!IsInState('PlayerInterpolate'))
				return; // Client ended interpolating.
		}

		if( NewBase!=None )
		{
			Target = NewBase;
			PhysRate = NewLocX;
			PhysAlpha = NewLocY;
			if( Physics!=PHYS_Interpolating )
				SetPhysics(PHYS_Interpolating);
			bInterpolating = true;
		}
		bUpdatePosition = true;
	}
	function ClientUpdatePosition() // Do nothing more than let time flow by.
	{
		local SavedMove CurrentMove;

		bUpdatePosition = false;
		CurrentMove = SavedMoves;
		while ( CurrentMove != None )
		{
			if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
			{
				SavedMoves = CurrentMove.NextMove;
				CurrentMove.NextMove = FreeMoves;
				FreeMoves = CurrentMove;
				FreeMoves.Clear();
				CurrentMove = SavedMoves;
			}
			else
			{
				AutonomousPhysics(CurrentMove.Delta);
				CurrentMove = CurrentMove.NextMove;
			}
		}
	}
	function class<ClientReplicationInfo> ClientReplicationInfoBase()
	{
		return class'ClientReplicationInfo_Interpolating';
	}
}

state PlayerInterpolateNI extends PlayerInterpolate
{
Ignores
	NextWeapon, PrevWeapon, SwitchWeapon, GetWeapon, ActivateInventoryItem, ActivateItem, PrevItem, NextItem, Grab,
	Fire, AltFire, TakeDamage, Died, ZoneChange, FootZoneChange, HeadZoneChange, AnimEnd, FellOutOfWorld, KilledBy;

	function bool CanInteractWithWorld()
	{
		return false;
	}

	function ChangedWeapon()
	{
		Weapon = None;
	}
	simulated function RenderOverlays( canvas Canvas )
	{
		if ( myHUD != None )
			myHUD.RenderOverlays(Canvas);
	}
	function BeginState()
	{
		Super.BeginState();
		if( Level.NetMode!=NM_Client && Level.NetMode!=NM_StandAlone )
			bHidden = true;
	}
	function EndState()
	{
		Super.EndState();
		if( Level.NetMode!=NM_Client && Health>0 )
		{
			bHidden = false;
			if( Weapon==None && PendingWeapon!=None )
				Global.ChangedWeapon();
		}
	}
	function PlayerMove( float DeltaTime )
	{
		bFire = 0;
		bAltFire = 0;
		Super.PlayerMove(DeltaTime);
	}
}

final function bool ClientSupportsPlayerInterpolate()
{
	return
		GetNegotiatedVersion() >= 227 &&
		(GetClientSubVersion() >= 10 || GetNegotiatedVersion() > 227 && GetNegotiatedVersion() < 400);
}

state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump, StartClimbing;

	function AnimEnd()
	{
		PlaySwimming();
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.2;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		Acceleration = aForward*X + aStrafe*Y + aUp*Z;
		if ( bPressedJump && aUp<=0.01 )
			bPressedJump = False;
		// Update rotation.
		UpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	event BeginState()
	{
		SetPhysics(PHYS_Flying);
		if (!IsAnimating())
			PlaySwimming();
		bCanFly = true;
		//log("player flying");
	}

	event EndState()
	{
		bCanFly = false;
	}
}

state CheatFlying
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, StartClimbing, FellOutOfWorld, BaseChange;

	function AnimEnd()
	{
		PlaySwimming();
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		if ( VSize(NewAccel)<0.1 )
			Acceleration = vect(0,0,0);
		else Acceleration = Normal(NewAccel) * 550;
		MoveSmooth(Acceleration * DeltaTime);
		Velocity = Acceleration; // Fix for ghosting/flying players from falling down for other clients.

		if( Physics!=PHYS_None )
			SetPhysics(PHYS_None);
		if( Base!=Level )
			SetBase(Level);
		if (SupportsRealCrouching())
			RealCrouchInfo.UpdateCrouch();
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward	*= 0.1;
		aStrafe		*= 0.1;
		aLookup		*= 0.24;
		aTurn		*= 0.24;
		aUp		*= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		UpdateRotation(DeltaTime, 1);

		bPressedJump = false;
		if (SupportsRealCrouching())
			RealCrouchInfo.HandleVerticalMovement(aUp);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function bool DesiredCrouch()
	{
		return
			RealCrouchInfo.bCanCrouchWhenFlying &&
			(bCollideActors || bCollideWorld) &&
			(bDuck != 0 || RealCrouchInfo.PlayerShouldCrouchToCeiling());
	}

	function BeginState()
	{
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
		if( Base!=Level )
			SetBase(Level);
		if( !IsAnimating() )
			PlaySwimming();
		bCanFly = True;
		bPressedJump = false;
	}
	function EndState()
	{
		bCanFly = False;
	}
}

state PlayerWaiting
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, StartClimbing;

	exec function Jump( optional float F )
	{
	}

	exec function Suicide()
	{
	}

	function ChangeTeam( int N )
	{
		Level.Game.ChangeTeam(self, N);
	}

	exec function Fire(optional float F)
	{
		bReadyToPlay = !bReadyToPlay;
	}

	exec function AltFire(optional float F)
	{
		bReadyToPlay = !bReadyToPlay;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function EndState()
	{
		Mesh = Default.Mesh;
		PlayerReplicationInfo.bIsSpectator = false;
		SetCollision(true,true,true);
	}

	function BeginState()
	{
		Mesh = None;
		PlayerReplicationInfo.bIsSpectator = true;
		SetCollision(false,false,false);
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
	}
}

state PlayerSpectating
{
ignores SeePlayer, HearNoise, Bump, TakeDamage, Died, StartClimbing;

	function bool CanInteractWithWorld()
	{
		return false;
	}

	exec function Suicide()
	{
	}

	function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
	{
	}

	exec function ActivateItem()
	{
		if (bCanChangeBehindView)
			bBehindView = !bBehindView;
	}

	exec function AltFire( optional float F )
	{
		if ( Role == ROLE_Authority )
			Level.Game.SetViewTarget(self, none);
	}

	function ChangeTeam( int N )
	{
		Level.Game.ChangeTeam(self, N);
	}

	exec function Fire( optional float F )
	{
		if ( Role == ROLE_Authority )
			ViewPlayerNum(-1);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));

		bPressedJump = false;
	}

	function EndState()
	{
		Mesh = Default.Mesh;
		SetCollision(true,true,true);
		bCanFly = false;
	}

	function BeginState()
	{
		Mesh = None;
		SetCollision(false,false,false);
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
		bCanFly = true;
		bPressedJump = false;
	}
}
//===============================================================================
state PlayerWaking
{
	ignores
		SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange,
		NextWeapon, PrevWeapon, SwitchWeapon, GetWeapon, Grab, Falling, StartClimbing;

	function bool CanInteractWithWorld()
	{
		return false;
	}

	function Timer()
	{
		BaseEyeHeight = Default.BaseEyeHeight;
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(Float DeltaTime)
	{
		ViewFlash(deltaTime * 0.5);
		if ( TimerRate == 0 )
		{
			ViewRotation.Pitch -= DeltaTime * 12000;
			if ( ViewRotation.Pitch < 0 )
			{
				ViewRotation.Pitch = 0;
				GotoState('PlayerWalking');
			}
		}

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
	}

	function BeginState()
	{
		if ( bWokeUp )
		{
			ViewRotation.Pitch = 0;
			SetTimer(0, false);
			return;
		}
		BaseEyeHeight = 0;
		EyeHeight = 0;
		SetTimer(3.0, false);
		bWokeUp = true;
	}
}

state Dying
{
	ignores
		SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange,
		NextWeapon, PrevWeapon, SwitchWeapon, GetWeapon, Grab, Falling, PainTimer, StartClimbing;

	function bool CanInteractWithWorld()
	{
		return false;
	}

	exec function Fire( optional float F )
	{
		if ( Role < ROLE_Authority )
			return;
		if ( (Level.NetMode == NM_Standalone) && !Level.Game.bDeathMatch )
		{
			if ( bFrozen )
				return;
			ShowLoadMenu();
		}
		else
			ServerReStartPlayer();
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	function ServerMove
	(
		float TimeStamp,
		vector Accel,
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbPressedJump,
		bool bFired,
		bool bAltFired,
		eDodgeDir DodgeMove,
		byte ClientRoll,
		int View
	)
	{
		if ( NewbPressedJump )
			Fire(0);

		Global.ServerMove(
			TimeStamp,
			Accel,
			ClientLoc,
			NewbRun,
			NewbDuck,
			NewbPressedJump,
			bFired,
			bAltFired,
			DodgeMove,
			ClientRoll,
			View);
	}

	function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
	{
		local vector View,HitLocation,HitNormal, spot;
		local float ViewDist;
		local actor HitActor;
		local Pawn PTarget;

		if ( ViewTarget != None )
		{
			ViewActor = ViewTarget;
			CameraLocation = ViewTarget.Location;
			CameraRotation = ViewTarget.Rotation;
			PTarget = Pawn(ViewTarget);
			if ( PTarget != None )
			{
				if ( Level.NetMode == NM_Client )
				{
					if ( PTarget.bIsPlayer )
						PTarget.ViewRotation = TargetViewRotation;
					PTarget.EyeHeight = TargetEyeHeight;
					if ( PTarget.Weapon != None )
						PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
				}
				if ( PTarget.bIsPlayer )
					CameraRotation = PTarget.ViewRotation;
				CameraLocation.Z += PTarget.EyeHeight;
			}

			if ( Carcass(ViewTarget) != None )
			{
				if ( ViewTarget.Physics == PHYS_None )
					CameraRotation = ViewRotation;
				else
					ViewRotation = CameraRotation;
			}
			else if ( bBehindView )
				CalcBehindView(CameraLocation, CameraRotation, 180);

			return;
		}

		// View rotation.
		CameraRotation = ViewRotation;
		DesiredFOV = DefaultFOV;
		ViewActor = self;
		if ( bBehindView ) //up and behind (for death scene)
		{
			ViewDist = 190;
			if (MoveTarget != None)
				spot = MoveTarget.Location;
			else
				spot = Location;
			View = vect(1,0,0) >> CameraRotation;
			HitActor = Trace( HitLocation, HitNormal,
							  spot - ViewDist * vector(CameraRotation), spot, false, vect(12,12,2));
			if ( HitActor != None )
				CameraLocation = HitLocation;
			else
				CameraLocation = spot - ViewDist * View;
		}
		else
		{
			// First-person view.
			CameraLocation = Location;
			CameraLocation.Z += Default.BaseEyeHeight;
		}
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		if ( !bFrozen )
		{
			if ( bPressedJump )
				Fire(0);
			GetAxes(ViewRotation,X,Y,Z);
			// Update view rotation.
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			ViewRotation.Yaw += AccumulatedPlayerTurn(32.0 * DeltaTime * aTurn, AccumulatedHTurn);
			ViewRotation.Pitch += AccumulatedPlayerTurn(32.0 * DeltaTime * aLookUp, AccumulatedVTurn);
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
				ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
			bPressedJump = false;
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		//fixme - try to pick view with killer visible
		//fixme - also try varying starting pitch
		////log("Find good death scene view");
		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		if ( !bHidden )
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}

	function Timer()
	{
		bFrozen = false;
		bShowScores = true;
		bPressedJump = false;
	}

	function BeginState()
	{
		bBehindView = true;
		bFrozen = true;
		bPressedJump = false;
		FindGoodView();
		if ( (Role == ROLE_Authority) && !bHidden )
			Super.Timer();
		SetTimer(1.0, false);
		bCollideWorld = true;
		ResetSavedMoves();
		if (SupportsRealCrouching())
			RealCrouchInfo.UpdateCrouch();
		//log(Self$" entering dying with remote role "$RemoteRole$" and role "$Role$" in state "$state);
	}

	function EndState()
	{
		bBehindView = false;
		bShowScores = false;
		if ( Carcass(ViewTarget) != None )
			ViewTarget = None;
		//Log(self$" exiting dying with remote role "$RemoteRole$" and role "$Role);
	}
}

state GameEnded
{
ignores
	SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling,
	TakeDamage, PainTimer, Died, Suicide, ActivateItem, ActivateInventoryItem, NextItem, PrevItem,
	SwitchWeapon, GetWeapon, PrevWeapon, NextWeapon, Grab, StartClimbing;

	function bool CanInteractWithWorld()
	{
		return false;
	}

	// 227g: Prevent rotation updates for third person clients.
	function UpdatePawnRotation( rotator Rot );

	exec function ViewClass( class<actor> aClass, optional bool bQuiet )
	{
	}
	exec function ViewPlayer( string S )
	{
	}
	exec function Fire( optional float F )
	{
		if ( Role>=ROLE_Authority && !bFrozen )
			ServerReStartGame();
	}

	exec function AltFire( optional float F )
	{
		Fire(F);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);
		// Update view rotation.
		if ( !bFrozen && (bPressedJump || (bFire == 1) || (bAltFire == 1)) )
			ServerReStartGame();

		if ( !bFixedCamera )
		{
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			ViewRotation.Yaw += AccumulatedPlayerTurn(32.0 * DeltaTime * aTurn, AccumulatedHTurn);
			ViewRotation.Pitch += AccumulatedPlayerTurn(32.0 * DeltaTime * aLookUp, AccumulatedVTurn);
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
				ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		bPressedJump = false;
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			if ( ViewTarget != None )
				cameraLoc = ViewTarget.Location;
			else
				cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
	}

	function Timer()
	{
		bFrozen = false;
	}

	function BeginState()
	{
		EndZoom();
		AnimRate = 0.0;
		bFire = 0;
		bAltFire = 0;
		// Freeze animation for third person clients.
		SimAnim.X = 10000 * AnimFrame;
		SimAnim.Y = 0;
		SimAnim.Z = 0;
		SimAnim.W = 10000 * AnimLast;
		SetCollision(false,false,false);
		bShowScores = true;
		bFrozen = true;
		if ( !bFixedCamera )
		{
			FindGoodView();
			bBehindView = true;
		}
		SetTimer(1.5, false);
		SetPhysics(PHYS_None);
	}
}

// New 227g state, Laddering
function StartClimbing( LadderTrigger Other )
{
	local int YDiff;

	if (!CanInteractWithWorld())
		return;

	if( Other.MaxOffAngleRadii>0 )
	{
		YDiff = ((ViewRotation.Yaw - Other.Rotation.Yaw) & 65535);
		if( YDiff>Other.MaxOffAngleRadii && YDiff<Other.MaxOffAngleRadiiHi )
			return; // Need to face at ladder to allow start climbing
	}
	if( Abs(Velocity.Z)>Other.MaxGrabVelocity )
		return;

	ActiveLadder = Other;
	
	if( Level.NetMode!=NM_Client )
	{
		if( Other.ClimbingNoise!=None )
			PlaySound(Other.ClimbingNoise,SLOT_Misc,1.5);

		if( Other.bUnarmedClimbing )
		{
			PendingWeapon = Weapon;
			if ( Weapon != None )
				Weapon.PutDown();
		}
	}
	GoToState('PlayerClimbing');
}
function PlayClimbing( bool bMovement )
{
	if( bMovement )
		PlayCrawling();
	else PlayDuck();
}

State PlayerClimbing
{
	function ChangedWeapon()
	{
		if( ActiveLadder.bUnarmedClimbing )
		{
			Inventory.ChangedWeapon();
			Weapon = None;
		}
		else Global.ChangedWeapon();
	}
	function StartClimbing( LadderTrigger Other )
	{
		ActiveLadder = Other; // Begin next ladder.
		if( Level.NetMode!=NM_Client && Other.bUnarmedClimbing && Weapon!=None )
		{
			PendingWeapon = Weapon;
			Weapon.PutDown();
		}
	}
	function EndClimbing( LadderTrigger Other )
	{
		local LadderTrigger L;

		if( ActiveLadder==Other )
		{
			ActiveLadder = None;
			foreach TouchingActors(Class'LadderTrigger',L)
				if( L!=Other )
					L.Touch(Self);
			if( ActiveLadder==None )
				DropFromLadder();
		}
	}
	function DropFromLadder( optional bool bDropOff )
	{
		local rotator R;
		
		ActiveLadder = None;
		PlayInAir();
		if( !bDropOff )
		{
			R.Yaw = ViewRotation.Yaw;
			Velocity = vector(R)*Default.JumpZ*0.5f;
			if( Acceleration.Z>=0.f )
				Velocity.Z = Default.JumpZ*0.8f;
			else Velocity.Z = 0.f;
		}
		
		if( Region.Zone.bWaterZone )
		{
			SetPhysics(PHYS_Swimming);
			GoToState('PlayerSwimming');
		}
		else
		{
			SetPhysics(PHYS_Falling);
			GoToState('PlayerWalking');
		}
		if( Level.NetMode!=NM_Client && Weapon==None )
			ChangedWeapon();
	}
	function DoJump( optional float F )
	{
		local rotator R;
		
		if ( Role == ROLE_Authority && ActiveLadder!=None )
			PlaySound(ActiveLadder.ClimbingNoise, SLOT_Talk, 1.5, true, 1200, 1.0 );
		ActiveLadder = None;
		
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);
		PlayInAir();
		R.Yaw = ViewRotation.Yaw;
		Velocity = vector(R)*Default.JumpZ*0.75f;
		if( F<0.f )
			Velocity = -Velocity;
		Velocity.Z = Default.JumpZ*0.8f;
		if( Region.Zone.bWaterZone )
		{
			SetPhysics(PHYS_Swimming);
			GoToState('PlayerSwimming');
		}
		else
		{
			SetPhysics(PHYS_Falling);
			GoToState('PlayerWalking');
		}
		if( Weapon==None )
			ChangedWeapon();
	}
	function AnimEnd()
	{
		PlayClimbing(Acceleration!=vect(0,0,0));
	}
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local vector OldAccel;
		local int YDiff;
		local float MaxSpeed;

		if ( bPressedJump )
		{
			DoJump(NewAccel.Z);
			return;
		}
		
		if( Physics!=PHYS_Flying )
			SetPhysics(PHYS_Flying);
		if( Level.NetMode==NM_Client )
		{
			// Sync up with server move.
			if( LadderTrigger(Base)!=None )
				ActiveLadder = LadderTrigger(Base);
		}
		if( ActiveLadder!=None && Base!=ActiveLadder )
			SetBase(ActiveLadder);
		OldAccel = Acceleration;
		if ( VSize(NewAccel)<0.1 )
			Acceleration = vect(0,0,0);
		else if( ActiveLadder!=None )
		{
			MaxSpeed = AirSpeed*ActiveLadder.ClimbSpeed;
			Acceleration = FClamp(NewAccel.X,-MaxSpeed,MaxSpeed) * ActiveLadder.ClimbAxis;
			
			if( ActiveLadder.bAllowSideStep )
			{
				MaxSpeed *= ActiveLadder.SideStepSpeedMod;
				Acceleration+=FClamp(NewAccel.Y,-MaxSpeed,MaxSpeed) * ActiveLadder.SideAxis;
			}
		}
		else // Active ladder is irrelevant on clientside.
		{
			MaxSpeed = AirSpeed*class'LadderTrigger'.Default.ClimbSpeed;
			Acceleration = FClamp(NewAccel.X,-MaxSpeed,MaxSpeed) * vect(0,0,1);
		}

		Velocity = Acceleration;
		if( OldAccel==vect(0,0,0) )
		{
			if( Acceleration!=vect(0,0,0) )
				PlayClimbing(true);
		}
		else if( Acceleration==vect(0,0,0) )
			PlayClimbing(false);
		
		if( ActiveLadder==None )
		{
			if( Level.NetMode!=NM_Client )
				DropFromLadder(true);
		}
		else if( ActiveLadder.MaxOffAngleRadii>0 )
		{
			YDiff = ((ViewRotation.Yaw - ActiveLadder.Rotation.Yaw) & 65535);
			if( YDiff>ActiveLadder.MaxOffAngleRadii && YDiff<ActiveLadder.MaxOffAngleRadiiHi )
				DropFromLadder(true);
		}
	}
	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		PlayerMove(DeltaTime);
	}
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z,NewAccel;

		GetAxes(ViewRotation,X,Y,Z);

		aForward	*= 0.1;
		aStrafe		*= 0.1;
		aLookup		*= 0.24;
		aTurn		*= 0.24;
		aUp		*= 0.1;

		if( LadderTrigger(Base)!=None )
		{
			ActiveLadder = LadderTrigger(Base);
			Z = ActiveLadder.ClimbAxis;
		}
		else Z = vect(0,0,1);
		
		NewAccel.X = aForward*(X Dot Z) + aUp;
		if( ActiveLadder!=None && ActiveLadder.bAllowSideStep )
			NewAccel.Y = aStrafe*(Y Dot ActiveLadder.SideAxis);
		
		if( aForward<0 )
			NewAccel.Z = -1; // Jump off ladder backwards.

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, rot(0,0,0));
		bPressedJump = false;
	}
	function BeginState()
	{
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_Flying);
		if( Base!=ActiveLadder )
			SetBase(ActiveLadder);
		PlayClimbing(false);
		if ( CarriedDecoration != None && Role==ROLE_Authority )
			DropDecoration();
		bCanFly = true;
	}
	function EndState()
	{
		WalkBob = vect(0,0,0);
		ActiveLadder = None;
		bIsWalking = false;
		bCanFly = false;
	}
	function HandleWalking()
	{
		bIsWalking = false;
	}
}

state CustomPlayerState
{
	event AnimEnd()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_AnimEnd();
	}

	singular event BaseChange()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_BaseChange();
	}

	event BeginState()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.GotoState('Active');
	}

	event Bump(Actor A)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Bump(A);
	}

	event EndState()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Destroy();
	}

	event Falling()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Falling();
	}

	event FootZoneChange(ZoneInfo NewZone)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_FootZoneChange(NewZone);
	}

	event HeadZoneChange(ZoneInfo NewZone)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_HeadZoneChange(NewZone);
	}

	event Landed(vector HitNormal)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Landed(HitNormal);
	}

	event PainTimer()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_PainTimer();
	}

	event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
		else
			global.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
	}

	event PlayerTick(float DeltaTime)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_PlayerTick(DeltaTime);
		else if (Role == ROLE_Authority)
			GotoDefaultPlayerState();
		else
			class'CustomPlayerStateInfo'.static.Default_PlayerTick(self, DeltaTime);
	}

	event RenderOverlays(Canvas Canvas)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_RenderOverlays(Canvas);
		else
			global.RenderOverlays(Canvas);
	}

	event Touch(Actor A)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Touch(A);
	}

	event UnTouch(Actor A)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_UnTouch(A);
	}

	event UpdateEyeHeight(float DeltaTime)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_UpdateEyeHeight(DeltaTime);
		else
			global.UpdateEyeHeight(DeltaTime);
	}

	event ZoneChange(ZoneInfo NewZone)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ZoneChange(NewZone);
	}

	exec function ActivateHint()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ActivateHint();
	}

	exec function ActivateInventoryItem(class InvItem)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ActivateInventoryItem(InvItem);
	}

	exec function ActivateItem()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ActivateItem();
	}

	exec function ActivateTranslator()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ActivateTranslator();
	}

	exec function AltFire(optional float F)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_AltFire(F);
	}

	exec function ChangeHud()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ChangeHud();
	}

	exec function FeignDeath()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_FeignDeath();
	}

	exec function Fire(optional float F)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Fire(F);
	}

	exec function GetWeapon(class<Weapon> NewWeaponClass)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_GetWeapon(NewWeaponClass);
	}

	exec function Grab()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Grab();
	}

	exec function Jump(optional float F)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Jump(F);
	}

	exec function NextItem()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_NextItem();
	}

	exec function NextWeapon()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_NextWeapon();
	}

	exec function PrevItem()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_PrevItem();
	}

	exec function PrevWeapon()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_PrevWeapon();
	}

	exec function Suicide()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Suicide();
	}

	exec function SwitchWeapon(byte F)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_SwitchWeapon(F);
	}

	exec function Taunt(name Sequence)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Taunt(Sequence);
	}

	exec function ThrowWeapon()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ThrowWeapon();
	}

	exec function Walk()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Walk();
	}

	function AddVelocity(vector V)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_AddVelocity(V);
	}

	function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
	{
		if (CustomPlayerStateInfo != none)
			return CustomPlayerStateInfo.Handle_AdjustHitLocation(HitLocation, TraceDir);
		return global.AdjustHitLocation(HitLocation, TraceDir);
	}

	function float CalcDesiredPrePivotZ()
	{
		if (CustomPlayerStateInfo != none)
			return CustomPlayerStateInfo.Handle_CalcDesiredPrePivotZ();
		return global.CalcDesiredPrePivotZ();
	}

	function bool CanInteractWithWorld()
	{
		if (CustomPlayerStateInfo != none)
			return CustomPlayerStateInfo.Handle_CanInteractWithWorld();
		return global.CanInteractWithWorld();
	}

	function bool CanUseClientReplicationInfo()
	{
		return true;
	}

	function ChangedWeapon()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ChangedWeapon();
	}

	function class<ClientReplicationInfo> ClientReplicationInfoBase()
	{
		if (CustomPlayerStateInfo != none)
			return CustomPlayerStateInfo.Handle_ClientReplicationInfoBase();
		return global.ClientReplicationInfoBase();
	}

	function name DesiredClientState()
	{
		if (CustomPlayerStateInfo != none)
			return CustomPlayerStateInfo.Handle_DesiredClientState();
		return global.DesiredClientState();
	}

	function bool DesiredCrouch()
	{
		if (CustomPlayerStateInfo != none)
			return CustomPlayerStateInfo.Handle_DesiredCrouch();
		return global.DesiredCrouch();
	}

	function Died(Pawn Killer, name DamageType, vector HitLocation)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_Died(Killer, DamageType, HitLocation);
	}

	function DoJump(optional float F)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_DoJump(F);
	}

	function HandleWalking()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_HandleWalking();
	}

	function KilledBy(Pawn EventInstigator)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_KilledBy(EventInstigator);
	}

	function PlayChatting()
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_PlayChatting();
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
	}

	function ServerTaunt(name Sequence)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_ServerTaunt(Sequence);
	}

	function StartClimbing(LadderTrigger Ladder)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_StartClimbing(Ladder);
	}

	function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, name DamageType)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	}

	function UpdateRotation(float DeltaTime, float MaxPitch)
	{
		if (CustomPlayerStateInfo != none)
			CustomPlayerStateInfo.Handle_UpdateRotation(DeltaTime, MaxPitch);
	}
}

function bool GotoCustomPlayerState(class<CustomPlayerStateInfo> PlayerStateInfoClass)
{
	local CustomPlayerStateInfo NewCustomPlayerStateInfo;

	if (PlayerStateInfoClass == none || IsInCustomPlayerState(PlayerStateInfoClass))
		return false;

	NewCustomPlayerStateInfo = Spawn(PlayerStateInfoClass, self);
	if (NewCustomPlayerStateInfo == none || NewCustomPlayerStateInfo.bDeleteMe)
		return false;
	if (CustomPlayerStateInfo != none)
		CustomPlayerStateInfo.Destroy();
	CustomPlayerStateInfo = NewCustomPlayerStateInfo;
	CustomPlayerStateInfo.Init();
	if (!IsInState('CustomPlayerState'))
		GotoState('CustomPlayerState');
	else
		CustomPlayerStateInfo.GotoState('Active');

	return true;
}

final function bool IsInCustomPlayerState(class<CustomPlayerStateInfo> PlayerStateInfoClass)
{
	return
		CustomPlayerStateInfo != none &&
		CustomPlayerStateInfo.Class == PlayerStateInfoClass &&
		IsInState('CustomPlayerState');
}

final function GlobalFunc_ActivateHint()
{
	global.ActivateHint();
}

final function GlobalFunc_ActivateInventoryItem(class InvItem)
{
	global.ActivateInventoryItem(InvItem);
}

final function GlobalFunc_ActivateItem()
{
	global.ActivateItem();
}

final function GlobalFunc_ActivateTranslator()
{
	global.ActivateTranslator();
}

final function GlobalFunc_AddVelocity(vector V)
{
	global.AddVelocity(V);
}

final function bool GlobalFunc_AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	return global.AdjustHitLocation(HitLocation, TraceDir);
}

final function GlobalFunc_AltFire(optional float F)
{
	global.AltFire(F);
}

final function GlobalFunc_AnimEnd()
{
	global.AnimEnd();
}

final function GlobalFunc_BaseChange()
{
	global.BaseChange();
}

final function GlobalFunc_Bump(Actor A)
{
	global.Bump(A);
}

final function float GlobalFunc_CalcDesiredPrePivotZ()
{
	return global.CalcDesiredPrePivotZ();
}

final function bool GlobalFunc_CanInteractWithWorld()
{
	return global.CanInteractWithWorld();
}

final function GlobalFunc_ChangedWeapon()
{
	global.ChangedWeapon();
}

final function GlobalFunc_ChangeHud()
{
	global.ChangeHud();
}

final function class<ClientReplicationInfo> GlobalFunc_ClientReplicationInfoBase()
{
	return global.ClientReplicationInfoBase();
}

final function name GlobalFunc_DesiredClientState()
{
	return global.DesiredClientState();
}

final function bool GlobalFunc_DesiredCrouch()
{
	return global.DesiredCrouch();
}

final function GlobalFunc_Died(Pawn Killer, name DamageType, vector HitLocation)
{
	global.Died(Killer, DamageType, HitLocation);
}

final function GlobalFunc_DoJump(optional float F)
{
	global.DoJump(F);
}

final function GlobalFunc_Falling()
{
	global.Falling();
}

final function GlobalFunc_Fire(optional float F)
{
	global.Fire(F);
}

final function GlobalFunc_FootZoneChange(ZoneInfo NewZone)
{
	global.FootZoneChange(NewZone);
}

final function GlobalFunc_GetWeapon(class<Weapon> NewWeaponClass)
{
	global.GetWeapon(NewWeaponClass);
}

final function GlobalFunc_Grab()
{
	global.Grab();
}

final function GlobalFunc_HeadZoneChange(ZoneInfo NewZone)
{
	global.HeadZoneChange(NewZone);
}

final function GlobalFunc_HandleWalking()
{
	global.HandleWalking();
}

final function GlobalFunc_Jump(optional float F)
{
	global.Jump(F);
}

final function GlobalFunc_KilledBy(Pawn EventInstigator)
{
	global.KilledBy(EventInstigator);
}

final function GlobalFunc_Landed(vector HitNormal)
{
	global.Landed(HitNormal);
}

final function GlobalFunc_NextItem()
{
	global.NextItem();
}

final function GlobalFunc_NextWeapon()
{
	global.NextWeapon();
}

final function GlobalFunc_PainTimer()
{
	global.PainTimer();
}

final function GlobalFunc_PrevItem()
{
	global.PrevItem();
}

final function GlobalFunc_PrevWeapon()
{
	global.PrevWeapon();
}

final function GlobalFunc_PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	global.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
}

final function GlobalFunc_PlayChatting()
{
	global.PlayChatting();
}

final function GlobalFunc_ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
{
	global.ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
}

final function GlobalFunc_RenderOverlays(Canvas Canvas)
{
	global.RenderOverlays(Canvas);
}

final function GlobalFunc_ServerTaunt(name Sequence)
{
	global.ServerTaunt(Sequence);
}

final function GlobalFunc_StartClimbing(LadderTrigger Ladder)
{
	global.StartClimbing(Ladder);
}

final function GlobalFunc_Suicide()
{
	global.Suicide();
}

final function GlobalFunc_SwitchWeapon(byte F)
{
	global.SwitchWeapon(F);
}

final function GlobalFunc_TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, name DamageType)
{
	global.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

final function GlobalFunc_Taunt(name Sequence)
{
	global.Taunt(Sequence);
}

final function GlobalFunc_ThrowWeapon()
{
	global.ThrowWeapon();
}

final function GlobalFunc_Touch(Actor A)
{
	global.Touch(A);
}

final function GlobalFunc_UnTouch(Actor A)
{
	global.UnTouch(A);
}

final function GlobalFunc_UpdateEyeHeight(float DeltaTime)
{
	global.UpdateEyeHeight(DeltaTime);
}

final function GlobalFunc_UpdateRotation(float DeltaTime, float MaxPitch)
{
	global.UpdateRotation(DeltaTime, MaxPitch);
}

final function GlobalFunc_Walk()
{
	global.Walk();
}

final function GlobalFunc_ZoneChange(ZoneInfo NewZone)
{
	global.ZoneChange(NewZone);
}

simulated function bool IsHeadShot( vector HitLocation, vector TraceDir )
{
	if (SupportsRealCrouching())
		return RealCrouchInfo.IsHeadShot(HitLocation, TraceDir);
	return DefIsHeadShot(HitLocation, TraceDir);
}

simulated event OnSubLevelChange( LevelInfo PrevLevel )
{
	ResetSavedMoves();
	if( myHUD!=None )
		myHUD.SendToLevel(Level, Location);
	if( Scoring!=None )
		Scoring.SendToLevel(Level, Location);
	Super.OnSubLevelChange(PrevLevel);
}

exec function CheckLevel()
{
	ClientMessage("Level"@((Level.NetMode==NM_Client) ? "Client" : "Server")@Self@Level);
	if( Level.NetMode==NM_Client )
		Admin("CheckLevel");
}

defaultproperties
{
	ViewingFrom="Now viewing from "
	OwnCamera="own camera"
	FailedView="Failed to change view."
	DodgeClickTime=0.250000
	Bob=0.016000
	FlashScale=(X=1.000000,Y=1.000000,Z=1.000000)
	DesiredFOV=90.000000
	DefaultFOV=90.000000
	CdTrack=255
	MyAutoAim=1.000000
	Handedness=-1.000000
	bAlwaysMouseLook=True
	bMaxMouseSmoothing=False
	bMouseSmoothing=True
	MouseSensitivity=3.000000
	NetSpeed=10000
	LanSpeed=20000
	MouseSmoothThreshold=0.160000
	QuickSaveString="Quick Saving"
	NoPauseMessage="Game is not pauseable"
	CantChangeNameMsg="You can't change your name during a global logged game."
	bIsPlayer=True
	bCanJump=True
	DesiredSpeed=0.300000
	SightRadius=4100.000000
	bTravel=True
	bStasis=False
	NetPriority=8
	MaxTimeMargin=+1.0
	bMessageBeep=True
	MainFOV=90.00000;
	SightCheckType=SEE_None
	CrouchHeightPct=0.55
	bClientSimFall=True
	bRepTargetViewRotation=True
	bCanChangeBehindView=True
	bNetNotify=True
	FogDensity=0
	FogMode=0
	bIsPlayerPawn=True
	bAlwaysNetDirty=true
	CollisionFlag=COLLISIONFLAG_PlayerPawn
}
