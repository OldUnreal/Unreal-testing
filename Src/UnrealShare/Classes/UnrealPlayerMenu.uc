//=============================================================================
// UnrealPlayerMenu
//=============================================================================
class UnrealPlayerMenu extends UnrealShortMenu;

var actor RealOwner;
var nowarn bool bSetup, bPulseDown;
var string PlayerName;
var int CurrentTeam,SelectionOffset,FaceSelectionOffset;
var localized string Teams[5];
var array<PlayerClassManager> Managers;
var Mesh LastInitMesh;
var class<PlayerPawn> CurPlayerClass,SetupPlayerClass;
var bool bPlayingSpectate,bEnableFaceSelection;

var UnrealUserManager Manager;

// Obsolete configures.
var transient const string PreferredSkin,PreferredFace;
var transient const string ClassString;

function BeginPlay()
{
	local PlayerClassManager PM;

	Super.BeginPlay();
	ForEach AllActors(Class'PlayerClassManager',PM)
		Managers.Add(PM);
	Manager = Class'UnrealUserManager'.Static.GetManager();
	Manager.Refresh();
	CurPlayerClass = class<PlayerPawn>(DynamicLoadObject(Manager.GetCurrentClass(), class'class', true));
	bPlayingSpectate = Manager.bIsSpectator;
}

// Get current selection info.
final function byte GetSelectedTeamNum()
{
	return CurrentTeam==4 ? 255 : CurrentTeam;
}
final function string GetSelectedSkin()
{
	if( CurPlayerClass && Manager.SkinList.Size() )
		return Manager.SkinList[SelectionOffset].Value;
	return "";
}
final function string GetSelectedFace()
{
	if( CurPlayerClass && bEnableFaceSelection )
		return Manager.FaceList[FaceSelectionOffset].Value;
	return "";
}

final function RefreshSkin( optional bool bSkinOnly )
{
	local int i;
	
	if( !bSkinOnly )
	{
		Mesh = CurPlayerClass.Default.Mesh;
		DrawType = CurPlayerClass.Default.DrawType;
		if ( Mesh && HasAnim(AnimSequence) )
			LoopAnim(AnimSequence);
	}
	for( i=0; i<ArrayCount(MultiSkins); ++i )
		MultiSkins[i] = None;
	Skin = None;
	CurPlayerClass.static.SetMultiSkin(Self, GetSelectedSkin(), GetSelectedFace(), GetSelectedTeamNum());
}

function FindSkin(int Dir)
{
	if( !CurPlayerClass )
		return;
	if( SetupPlayerClass!=CurPlayerClass )
	{
		SetupPlayerClass = CurPlayerClass;
		SelectionOffset = Max(Manager.GetMeshSkins(CurPlayerClass,Managers), 0);
	}
	if( Dir )
	{
		SelectionOffset+=Dir;
		if( SelectionOffset<0 )
			SelectionOffset = Manager.SkinList.Size()-1;
		else if( SelectionOffset>=Manager.SkinList.Size() )
			SelectionOffset = 0;
	}
	
	// Decide if we need Face option.
	bEnableFaceSelection = false;
	if( CurPlayerClass.Default.bIsMultiSkinned && Manager.SkinList.Size() )
	{
		FaceSelectionOffset = Max(Manager.GetMeshFaces(CurPlayerClass, Manager.SkinList[SelectionOffset].Value, Managers), 0);
		bEnableFaceSelection = (Manager.FaceList.Size()>0);
	}
	else FaceSelectionOffset = 0;

	if( bEnableFaceSelection )
		MenuLength = Default.MenuLength + 1;
	else MenuLength = Default.MenuLength;
	
	if( Dir )
		RefreshSkin(true);
}

function SelectFace(int Dir)
{
	if( CurPlayerClass && CurPlayerClass.Default.bIsMultiSkinned && Manager.FaceList.Size() )
	{
		FaceSelectionOffset+=Dir;
		if( FaceSelectionOffset<0 )
			FaceSelectionOffset = Manager.FaceList.Size()-1;
		else if( FaceSelectionOffset>=Manager.FaceList.Size() )
			FaceSelectionOffset = 0;
		RefreshSkin(true);
	}
}

function ProcessMenuInput( coerce string InputString )
{
	if ( selection == 1 )
	{
		PlayerName = ReplaceStr(Left(InputString, 20)," ","_");
		SanitizeString(PlayerName);
	}
}

function ProcessMenuEscape()
{
	PlayerName = Manager.InitName;
}

function ProcessMenuUpdate( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
		PlayerName = (InputString$"_");
}

function Menu ExitMenu()
{
	SetOwner(RealOwner);
	Return Super.ExitMenu();
}

function bool ProcessLeft()
{
	if ( Selection == 1 )
	{
		PlayerName = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	else if ( Selection == 2 )
	{
		CurrentTeam--;
		if (CurrentTeam < 0)
			CurrentTeam = 4;
		RefreshSkin(true);
	}
	else if ( Selection == 3 )
		FindSkin(-1);
	else if ( Selection == 4 )
		SelectFace(-1);

	return true;
}

function bool ProcessRight()
{
	if ( Selection == 1 )
	{
		PlayerName = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	else if ( Selection == 2 )
	{
		CurrentTeam++;
		if (CurrentTeam > 4)
			CurrentTeam = 0;
		RefreshSkin(true);
	}
	else if ( Selection == 3 )
		FindSkin(1);
	else if ( Selection == 4 )
		SelectFace(1);

	return true;
}

function bool ProcessSelection()
{
	if ( Selection == 1 )
	{
		PlayerName = "_";
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	return true;
}

function SaveConfigs()
{
	Manager.Save(PlayerName, string(CurPlayerClass), GetSelectedSkin(), GetSelectedFace(), GetSelectedTeamNum(), bPlayingSpectate);
}

function MenuTick(float DeltaTime)
{
	local int I;

	Super.MenuTick(DeltaTime);

	// Update FadeTimes.
	if (TitleFadeTime >= 0.0)
		TitleFadeTime += DeltaTime;
	for (I=0; I<24; I++)
		if (MenuFadeTimes[I] >= 0.0)
			MenuFadeTimes[I] += DeltaTime;
}

function SetUpDisplay()
{
	local int I;

	bSetup = true;

	// Init the FadeTimes.
	// -1.0 means not updated.
	TitleFadeTime = -1.0;
	for (I=0; I<24; I++)
		MenuFadeTimes[I] = -1.0;

	RealOwner = Owner;
	SetOwner(PlayerOwner);
	CurrentTeam = Min(Manager.InitTeam, 4);
	PlayerName = Manager.InitName;
	PlayerOwner.bBehindView = false;
	FindSkin(0);
	RefreshSkin();
}

function DrawMenu(canvas Canvas)
{
	local int i, StartX, StartY, Spacing;
	local vector DrawOffset, DrawLoc;
	local rotator NewRot, DrawRot;
	local Coords Co;

	if (!bSetup)
		SetUpDisplay();

	if( !bPlayingSpectate )
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

	for ( i=1; i<6; i++ )
		MenuList[i] = Default.MenuList[i];
	DrawFadeList(Canvas, Spacing, StartX, StartY);

	MenuList[1] = PlayerName;
	MenuList[2] = Teams[CurrentTeam];
	if( !bPlayingSpectate && CurPlayerClass && Manager.SkinList.Size() )
	{
		MenuList[3] = Manager.SkinList[SelectionOffset].Desc;
		if( bEnableFaceSelection )
			MenuList[4] = Manager.FaceList[FaceSelectionOffset].Desc;
	}

	MenuList[5] = "";
	DrawFadeList(Canvas, Spacing, StartX + 80, StartY);

	// Draw help panel.
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
	DrawHelpPanel(Canvas, Canvas.ClipY - 64, 228);
}

defaultproperties
{
	Teams(0)="Red"
	Teams(1)="Blue"
	Teams(2)="Green"
	Teams(3)="Gold"
	Teams(4)="None"
	MenuLength=3
	HelpMessage(1)="Hit enter to type in your name. Be sure to do this before joining a multiplayer game."
	HelpMessage(2)="Use the arrow keys to change your team color (Red, Blue, Green, or Yellow)."
	HelpMessage(3)="Change your skin using the left and right arrow keys."
	HelpMessage(4)="Change your face skin using the left and right arrow keys."
	MenuList(1)="Name: "
	MenuList(2)="Team Color:"
	MenuList(3)="Skin:"
	MenuList(4)="Face:"
	MenuTitle="Select Digital Representation"
	AnimSequence="Walk"
	DrawType=DT_Mesh
	DrawScale=0.10
	bUnlit=True
	bOnlyOwnerSee=True
	bFixedRotationDir=True
	RotationRate=(Pitch=0,Yaw=8000,Roll=0)
	DesiredRotation=(Pitch=0,Yaw=30000,Roll=0)
}
