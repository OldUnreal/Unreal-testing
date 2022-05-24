//=============================================================================
// UnrealMeshMenu
//=============================================================================
class UnrealMeshMenu extends UnrealPlayerMenu
	config;

var int PlayerClassNum;
var string StartMap;
var bool SinglePlayerOnly;
var string GamePassword;
var config bool bUseMutators;

// Obsolete:
var transient const class<PlayerPawn> PlayerClass;
var transient const array<string> PlayerClasses;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Manager.GetMeshList(Managers);
	PlayerClassNum = Max(Manager.MeshList.Find(Value,string(CurPlayerClass)),0);
	
	// Swap places with localizations.
	HelpMessage[7] = Default.HelpMessage[8];
	HelpMessage[8] = Default.HelpMessage[9];
	HelpMessage[9] = Default.HelpMessage[7];
}

function FindSkin(int Dir)
{
	local int i;
	local bool bOldFace;
	
	bOldFace = bEnableFaceSelection;
	Super.FindSkin(Dir);
	if( bOldFace!=bEnableFaceSelection )
	{
		if( bEnableFaceSelection )
		{
			if( selection>=4 )
				++selection;
			HelpMessage[4] = Class'UnrealPlayerMenu'.Default.HelpMessage[4];
			for( i=5; i<7; ++i )
				HelpMessage[i] = Default.HelpMessage[i-1];
			
			// Swap places with localizations.
			HelpMessage[8] = Default.HelpMessage[8];
			HelpMessage[9] = Default.HelpMessage[9];
			HelpMessage[10] = Default.HelpMessage[7];
		}
		else
		{
			if( selection>=4 )
				--selection;
			for( i=4; i<7; ++i )
				HelpMessage[i] = Default.HelpMessage[i];
			
			// Swap places with localizations.
			HelpMessage[7] = Default.HelpMessage[8];
			HelpMessage[8] = Default.HelpMessage[9];
			HelpMessage[9] = Default.HelpMessage[7];
		}
	}
}

function SelectPlayerClass( int Dir )
{
	local int n;
	
	if( !Manager.MeshList.Size() )
		return;
Repeat:
	PlayerClassNum+=Dir;
	if( PlayerClassNum<0 )
		PlayerClassNum = Manager.MeshList.Size()-1;
	else if( PlayerClassNum>=Manager.MeshList.Size() )
		PlayerClassNum = 0;
	
	CurPlayerClass = class<PlayerPawn>(DynamicLoadObject(Manager.MeshList[PlayerClassNum].Value, class'class', true));
	if ( SinglePlayerOnly && !CurPlayerClass.Default.bSinglePlayer && Dir!=0 && n++<10 )
		goto 'Repeat';
	
	FindSkin(0);
	RefreshSkin();
}

function UpdatePlayerClass( string NewClass, int Offset )
{
	//PlayerClasses[Offset] = NewClass;
}

function ProcessMenuInput( coerce string InputString )
{
	Super.ProcessMenuInput(InputString);
}

function ProcessMenuUpdate( coerce string InputString )
{
	Super.ProcessMenuUpdate(InputString);
}

function SaveConfigs()
{
	Super.SaveConfigs();
	SaveConfig();
}

function bool ProcessSelection()
{
	local int i;
	local string Cl;
	local Menu ChildMenu;

	i = selection;
	if( bEnableFaceSelection && i>=4 )
		--i;

	if ( i==6 || i==7 )
		ProcessLeft();
	else if ( i == 8 )
	{
		ChildMenu = spawn(class'UnrealMutatorMenu', RealOwner);
		HUD(RealOwner).MainMenu = ChildMenu;
		ChildMenu.ParentMenu = self;
		ChildMenu.PlayerOwner = PlayerOwner;
	}
	else if ( i == 9 )
	{
		SetOwner(RealOwner);
		bExitAllMenus = true;

		SaveConfigs();

		if ( bPlayingSpectate )
			Cl = string(Class'UnrealSpectator');
		else Cl = string(CurPlayerClass);
		StartMap = StartMap
				   $"?Class="$Cl
				   $"?Name="$Manager.InitName
				   $"?Team="$string(Manager.InitTeam);
		
		if( !bPlayingSpectate )
			StartMap = StartMap$"?Skin="$GetSelectedSkin();
		if( bEnableFaceSelection )
			StartMap = StartMap$"?Face="$GetSelectedFace();
		if( bUseMutators && Len(Class'UnrealMutatorMenu'.Default.UsedMutators) )
			StartMap = StartMap$"?Mutator="$Class'UnrealMutatorMenu'.Default.UsedMutators;

		if ( GamePassword != "" )
			StartMap = StartMap$"?Password="$GamePassword;

		PlayerOwner.ClientTravel(StartMap, TRAVEL_Absolute, false);
	}
	else return Super.ProcessSelection();
	return true;
}

function bool ProcessLeft()
{
	local int i;

	i = selection;
	if( bEnableFaceSelection && i>=4 )
	{
		if( i==4 )
		{
			i = 5;
			SelectFace(-1);
		}
		else --i;
	}
	switch( i )
	{
	case 4:
		SelectPlayerClass(-1);
		break;
	case 5:
		break;
	case 6:
		bPlayingSpectate = !bPlayingSpectate;
		break;
	case 7:
		bUseMutators = !bUseMutators;
		bConfigChanged = true;
		break;
	default:
		return Super.ProcessLeft();
	}
	return true;
}

function bool ProcessRight()
{
	local int i;

	i = selection;
	if( bEnableFaceSelection && i>=4 )
	{
		if( i==4 )
		{
			i = 5;
			SelectFace(1);
		}
		else --i;
	}
	switch( i )
	{
	case 4:
		SelectPlayerClass(1);
		break;
	case 5:
		break;
	case 6:
		bPlayingSpectate = !bPlayingSpectate;
		break;
	case 7:
		bUseMutators = !bUseMutators;
		bConfigChanged = true;
		break;
	default:
		return Super.ProcessRight();
	}
	return true;
}

function class<PlayerPawn> ChangeMesh()
{
	/*local class<playerpawn> NewPlayerClass;

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
	return NewPlayerClass;*/
	return None;
}

function LoadAllMeshes()
{
	/*local string S;

	foreach PlayerClasses(S)
		DynamicLoadObject(S, class'Class');*/
}

function SetUpDisplay()
{
	/*local int i;
	local texture NewSkin;
	local string MeshName;*/

	Super.SetUpDisplay();

	/*if ( ClassString == "" )
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
	}*/
}

function DrawMenu(canvas Canvas)
{
	local int i, StartX, StartY, Spacing;
	local vector DrawOffset, DrawLoc;
	local rotator NewRot, DrawRot;
	local Coords Co;

	if (!bSetup)
		SetUpDisplay();

	if( Mesh )
	{
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
	}

	// Draw title.
	DrawFadeTitle(Canvas);

	Spacing = Clamp(0.04 * Canvas.ClipY, 12, 32);
	StartX = Canvas.ClipX/2;
	StartY = Max(40, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	if( bEnableFaceSelection )
	{
		for ( i=1; i<4; i++ )
			MenuList[i] = Default.MenuList[i];
		MenuList[4] = Class'UnrealPlayerMenu'.Default.MenuList[4];
		for ( i=5; i<8; i++ )
			MenuList[i] = Default.MenuList[i-1];

		// Swap places with localizations.
		MenuList[8] = Default.MenuList[8];
		MenuList[9] = Default.MenuList[9];
		MenuList[10] = Default.MenuList[7];
	}
	else
	{
		for ( i=1; i<7; i++ )
			MenuList[i] = Default.MenuList[i];
		// Swap places with localizations.
		MenuList[7] = Default.MenuList[8];
		MenuList[8] = Default.MenuList[9];
		MenuList[9] = Default.MenuList[7];
	}
	DrawFadeList(Canvas, Spacing, StartX, StartY);

	i = 1;
	MenuList[i++] = PlayerName;
	MenuList[i++] = Teams[CurrentTeam];

	if( CurPlayerClass && Manager.SkinList.Size() )
	{
		MenuList[i++] = Manager.SkinList[SelectionOffset].Desc;
		if( bEnableFaceSelection )
			MenuList[i++] = Manager.FaceList[FaceSelectionOffset].Desc;
	}
	else MenuList[i++] = "None";
	
	MenuList[i++] = Manager.MeshList.Size() ? Manager.MeshList[PlayerClassNum].Desc : "None";
	MenuList[i++] = "";
	MenuList[i++] = bPlayingSpectate ? YesString : NoString;
	MenuList[i++] = bUseMutators ? YesString : NoString;
	MenuList[i++] = "";
	MenuList[i++] = "";
	DrawFadeList(Canvas, Spacing, StartX + 80, StartY);

	// Draw help panel.
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
	DrawHelpPanel(Canvas, Canvas.ClipY - 64, 228);
}

defaultproperties
{
	Selection=9
	MenuLength=9
	HelpMessage(4)="Change your class using the left and right arrow keys."
	HelpMessage(5)="To enter with an adminpassword or gamepassword, launch the server Browser, right click a server and select 'Join with password'."
	HelpMessage(6)="Should spectate the match instead of playing."
	HelpMessage(7)="Press enter to start game."
	HelpMessage(8)="Should use mutators with this game?"
	HelpMessage(9)="Select which mutators to use with this game."
	MenuList(4)="Class:"
	MenuList(5)="Passwords are now entered from the Unreal Server browser."
	MenuList(6)="Spectate:"
	MenuList(7)="Start Game"
	MenuList(8)="Mutators:"
	MenuList(9)="Select Mutators"
}