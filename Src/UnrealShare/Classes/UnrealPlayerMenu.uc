//=============================================================================
// UnrealPlayerMenu
//=============================================================================
class UnrealPlayerMenu extends UnrealShortMenu
			config(user);

var actor RealOwner;
var nowarn bool bSetup, bPulseDown;
var string PlayerName;
var int CurrentTeam,SelectionOffset;
var localized string Teams[5];
var globalconfig string PreferredSkin,PreferredFace;
var globalconfig string ClassString;
var globalconfig bool bPlayingSpectate;
var array<Texture> AdditionalSkns;
var array<PlayerClassManager> Managers;
var Mesh LastInitMesh;

function BeginPlay()
{
	local PlayerClassManager PM;

	Super.BeginPlay();
	ForEach AllActors(Class'PlayerClassManager',PM)
		Managers.Add(PM);
}

function FindSkin(int Dir)
{
	if ( Mesh!=LastInitMesh )
	{
		LastInitMesh = Mesh;
		AdditionalSkns.Empty();
		if ( Mesh )
			ListSpecialSkins(string(Mesh.Name));
		else SelectionOffset = 0;
		if ( Skin )
		{
			SelectionOffset = AdditionalSkns.Find(Skin);
			if ( SelectionOffset==-1 )
			{
				SelectionOffset = AdditionalSkns.Size();
				AdditionalSkns.Add(Skin);
			}
			Return;
		}
		else if ( !AdditionalSkns.Size() )
			Return;
		else Skin = AdditionalSkns[0];
	}
	if ( !AdditionalSkns.Size() )
	{
		Skin = None;
		Return;
	}
	SelectionOffset+=Dir;
	if ( SelectionOffset<0 )
		SelectionOffset = AdditionalSkns.Size()-1;
	else if ( SelectionOffset>=AdditionalSkns.Size() )
		SelectionOffset = 0;
	Skin = AdditionalSkns[SelectionOffset];
}
function ListSpecialSkins( string MeshName )
{
	local PlayerClassManager M;
	local int i,j;
	local array<Texture> Skn;
	local Texture T;
	local string SkinName,SkinDesc,FrstSkin;

	SelectionOffset = 0;
	GetNextSkin(MeshName,"None", 1, SkinName, SkinDesc);
	While( SkinName!="" && SkinName!=FrstSkin )
	{
		if ( FrstSkin=="" )
			FrstSkin = SkinName;
		T = texture(DynamicLoadObject(SkinName,class'Texture',True));
		if( T )
			AdditionalSkns.Add(T);
		GetNextSkin(MeshName,SkinName, 1, SkinName, SkinDesc);
	}
	foreach Managers(M,i)
	{
		if ( !M || M.bDeleteMe )
		{
			Managers.Remove(i,1);
			continue;
		}
		if( !M.bEnabled )
			continue;
		
		M.GetMeshSkins(Skn,MeshName);
		foreach Skn(T)
			AdditionalSkns.Add(T);
		Skn.Empty();
	}
	i = 0;
	while ( i<250 )
	{
		GetNextIntDesc("Engine.Texture",(i++),SkinName,SkinDesc);
		if ( SkinName=="" )
			Return;
		j = InStr(SkinDesc,";");
		if ( SkinDesc=="" || j==-1 )
			continue;
		if ( Left(SkinDesc,j)~=MeshName )
		{
			T = texture(DynamicLoadObject(SkinName, class'Texture'));
			if( T )
				AdditionalSkns.Add(T);
		}
	}
}

function ProcessMenuInput( coerce string InputString )
{
	InputString = Left(InputString, 20);

	if ( selection == 1 )
	{
		PlayerOwner.ChangeName(InputString);
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
		PlayerOwner.UpdateURL("Name", InputString, true);
	}
}

function ProcessMenuEscape()
{
	PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
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
	}
	else if ( Selection == 3 )
		FindSkin(-1);

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
	}
	else if ( Selection == 3 )
		FindSkin(1);

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
	local byte Tm;

	if ( ClassString == "" )
	{
		ClassString = string(PlayerOwner.Class);
		Skin = PlayerOwner.Skin;
	}
	PreferredFace = ""; // Not implemented in this menu.
	if ( bPlayingSpectate )
		PlayerOwner.UpdateURL("Class",string(Class'UnrealSpectator'), true);
	else PlayerOwner.UpdateURL("Class",ClassString, true);
	PreferredSkin = String(Skin);
	PlayerOwner.UpdateURL("Skin",PreferredSkin, true);
	Tm = CurrentTeam;
	if ( Tm==4 )
		Tm = 255;
	if ( Mesh == PlayerOwner.Mesh )
		PlayerOwner.ServerChangeSkin( PreferredSkin, "", Tm);

	if ( Tm!=PlayerOwner.PlayerReplicationInfo.Team )
	{
		PlayerOwner.ChangeTeam(Tm);
		PlayerOwner.UpdateURL("Team",string(Tm), true);
	}

	SaveConfig();
	PlayerOwner.SaveConfig();
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
	CurrentTeam = PlayerOwner.PlayerReplicationInfo.Team;
	if ( CurrentTeam>4 )
		CurrentTeam = 4;
	PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
	PlayerOwner.bBehindView = false;
	Mesh = PlayerOwner.Mesh;
	Skin = PlayerOwner.Skin;
	DrawType = PlayerOwner.DrawType;
	FindSkin(0);
	if ( Mesh!=None && HasAnim(AnimSequence) )
		LoopAnim(AnimSequence);
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

	for ( i=1; i<6; i++ )
		MenuList[i] = Default.MenuList[i];
	DrawFadeList(Canvas, Spacing, StartX, StartY);

	if ( !PlayerOwner.Player.Console.IsInState('MenuTyping') )
		PlayerName = PlayerOwner.PlayerReplicationInfo.PlayerName;
	MenuList[1] = PlayerName;
	MenuList[2] = Teams[Clamp(CurrentTeam,0,4)];

	if ( Mesh != None )
		MenuList[3] = GetItemName(string(Skin));
	else
		MenuList[3] = "";

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
	MenuList(1)="Name: "
	MenuList(2)="Team Color:"
	MenuList(3)="Skin:"
	MenuTitle="Select Digital Representation"
	AnimSequence="Walk"
	DrawType=DT_Mesh
	DrawScale=0.10
	bUnlit=True
	bOnlyOwnerSee=True
	bFixedRotationDir=True
	RotationRate=(Pitch=0,Yaw=8000,Roll=0)
	DesiredRotation=(Pitch=0,Yaw=30000,Roll=0)
	ClassString="UnrealI.FemaleOne"
}
