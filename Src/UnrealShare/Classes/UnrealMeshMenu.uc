//=============================================================================
// UnrealMeshMenu
//=============================================================================
class UnrealMeshMenu extends UnrealPlayerMenu
			config;

var class<PlayerPawn> PlayerClass;
var array<string> PlayerClasses;
var int PlayerClassNum;
var string StartMap;
var bool SinglePlayerOnly;
var string GamePassword;

function PostBeginPlay()
{
	local string NextPlayer;
	local int lc;
	local PlayerClassManager M;
	local class<PlayerPawn> P;

	Super.PostBeginPlay();
	NextPlayer = GetNextInt("UnrealIPlayer", 0);
	while ( NextPlayer != "" )
	{
		if ( !(NextPlayer~="UnrealShare.UnrealSpectator") )
			PlayerClasses.Add(NextPlayer);
		NextPlayer = GetNextInt("UnrealIPlayer", ++lc);
	}
	foreach Managers(M)
	{
		if ( !M || M.bDeleteMe || !M.bEnabled )
			continue;
		
		foreach M.AdditionalClasses(P)
			PlayerClasses.Add(string(P));
	}
}

function UpdatePlayerClass( string NewClass, int Offset )
{
	PlayerClasses[Offset] = NewClass;
}

function ProcessMenuInput( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
	{
		PlayerOwner.ChangeName(InputString);
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
		PlayerOwner.UpdateURL("Name",InputString, true);
	}
}

function ProcessMenuUpdate( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
		PlayerName = (InputString$"_");
}

function bool ProcessSelection()
{
	local string Cl;

	if ( selection == 6 )
		ProcessLeft();
	else if ( selection == 7 )
	{
		SetOwner(RealOwner);
		bExitAllMenus = true;

		SaveConfigs();

		if ( bPlayingSpectate )
			Cl = string(Class'UnrealSpectator');
		else Cl = ClassString;
		StartMap = StartMap
				   $"?Class="$Cl
				   $"?Skin="$Skin
				   $"?Name="$PlayerOwner.PlayerReplicationInfo.PlayerName
				   $"?Team="$PlayerOwner.PlayerReplicationInfo.Team
				   $"?Rate="$PlayerOwner.NetSpeed;

		if ( GamePassword != "" )
			StartMap = StartMap$"?Password="$GamePassword;

		PlayerOwner.ClientTravel(StartMap, TRAVEL_Absolute, false);
	}
	else Super.ProcessSelection();
	return true;
}

function bool ProcessLeft()
{
	if ( selection == 4 )
	{
		PlayerClassNum++;
		if ( PlayerClassNum == PlayerClasses.Size() )
			PlayerClassNum = 0;
		PlayerClass = ChangeMesh();
		if ( SinglePlayerOnly && !PlayerClass.Default.bSinglePlayer )
			ProcessLeft();
	}
	else if ( selection==6 )
		bPlayingSpectate = !bPlayingSpectate;
	else Super.ProcessLeft();

	return true;
}

function bool ProcessRight()
{
	if ( selection == 4 )
	{
		PlayerClassNum--;
		if ( PlayerClassNum < 0 )
			PlayerClassNum = PlayerClasses.Size() - 1;
		PlayerClass = ChangeMesh();
		if ( SinglePlayerOnly && !PlayerClass.Default.bSinglePlayer )
		{
			ProcessRight();
			return true;
		}
	}
	else if ( selection==6 )
		ProcessLeft();
	else Super.ProcessRight();

	return true;
}

function class<PlayerPawn> ChangeMesh()
{
	local class<playerpawn> NewPlayerClass;

	NewPlayerClass = class<playerpawn>(DynamicLoadObject(PlayerClasses[PlayerClassNum], class'Class'));

	if ( NewPlayerClass != None )
	{
		PlayerClass = NewPlayerClass;
		ClassString = PlayerClasses[PlayerClassNum];
		mesh = NewPlayerClass.Default.mesh;
		skin = NewPlayerClass.Default.skin;
		Texture = NewPlayerClass.Default.Texture;
		if ( Mesh!=None && HasAnim('Walk') )
			LoopAnim('Walk');
		DrawType = NewPlayerClass.Default.DrawType;
		FindSkin(0);
	}
	return NewPlayerClass;
}

function LoadAllMeshes()
{
	local string S;

	foreach PlayerClasses(S)
		DynamicLoadObject(S, class'Class');
}

function SetUpDisplay()
{
	local int i;
	local texture NewSkin;
	local string MeshName;

	Super.SetUpDisplay();

	if ( ClassString == "" )
		ClassString = string(PlayerOwner.Class);

	for ( i=0; i<PlayerClasses.Size(); i++ )
		if ( PlayerClasses[i] ~= ClassString )
		{
			PlayerClassNum = i;
			break;
		}

	ChangeMesh();
	if ( PreferredSkin != "" )
	{
		MeshName = GetItemName(String(Mesh));
		if ( Left(PreferredSkin, Len(MeshName)) != MeshName )
			PreferredSkin = MeshName$"Skins."$GetItemName(PreferredSkin);
		NewSkin = texture(DynamicLoadObject(PreferredSkin, class'Texture'));
		if ( NewSkin != None )
			Skin = NewSkin;
	}
}

function DrawMenu(canvas Canvas)
{
	local int i, StartX, StartY, Spacing;
	local vector DrawOffset, DrawLoc;
	local rotator NewRot, DrawRot;
	local Coords Co;

	if (!bSetup)
		SetUpDisplay();

	// Set menu location.
	Co = Canvas.GetCameraCoords();
	PlayerOwner.ViewRotation.Pitch = 0;
	PlayerOwner.ViewRotation.Roll = 0;
	DrawRot = OrthoRotation(Co.XAxis,Co.YAxis,Co.ZAxis);
	DrawLoc = Co.Origin;

	DrawOffset = (vect(10.0,-5.0,0.0)) >> DrawRot;
	NewRot = DrawRot;
	NewRot.Yaw = Rotation.Yaw;
	SetLocation(DrawLoc + DrawOffset, NewRot);
	Canvas.DrawActor(Self, false);

	// Draw title.
	DrawFadeTitle(Canvas);

	Spacing = Clamp(0.04 * Canvas.ClipY, 12, 32);
	StartX = Canvas.ClipX/2;
	StartY = Max(40, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	for ( i=1; i<8; i++ )
		MenuList[i] = Default.MenuList[i];
	DrawFadeList(Canvas, Spacing, StartX, StartY);

	if ( !PlayerOwner.Player.Console.IsInState('MenuTyping') )
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
	MenuList[1] = PlayerName;
	if ( CurrentTeam == 255 )
		MenuList[2] = "None";
	else
		MenuList[2] = Teams[CurrentTeam];

	if ( Skin!=None )
		MenuList[3] = string(Skin.Name);
	else
		MenuList[3] = "None";
	if ( PlayerClass==None )
		MenuList[4] = "None";
	else if ( PlayerClass.Default.MenuName=="" )
		MenuList[4] = string(PlayerClass.Name);
	else MenuList[4] = PlayerClass.Default.MenuName;
	MenuList[5] = GamePassword;
	if ( bPlayingSpectate )
		MenuList[6] = YesString;
	else MenuList[6] = NoString;
	MenuList[7] = "";
	DrawFadeList(Canvas, Spacing, StartX + 80, StartY);

	// Draw help panel.
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
	DrawHelpPanel(Canvas, Canvas.ClipY - 64, 228);
}

defaultproperties
{
	Selection=7
	MenuLength=7
	HelpMessage(4)="Change your class using the left and right arrow keys."
	HelpMessage(5)="To enter with an adminpassword or gamepassword, launch the server Browser, right click a server and select 'Join with password'."
	HelpMessage(6)="Should spectate the match instead of playing."
	HelpMessage(7)="Press enter to start game."
	MenuList(4)="Class:"
	MenuList(5)="Passwords are now entered from the Unreal Server browser."
	MenuList(6)="Spectate:"
	MenuList(7)="Start Game"
}
