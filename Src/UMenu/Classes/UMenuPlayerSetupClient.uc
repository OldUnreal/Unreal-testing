class UMenuPlayerSetupClient extends UMenuDialogClientWindow;

var() int ControlOffset;

var class<Pawn> NewPlayerClass;
var string MeshName;
var bool Initialized;
var UMenuPlayerMeshClient MeshWindow;
var string PlayerBaseClass;

var localized int EditAreaWidth; // Maximal width of a control that indicates a modifiable value
var float LabelTextAreaWidth;
var bool bUpdatedLabelTextAreaWidth; // Whether LabelTextAreaWidth is updated by derived class

// Player Name
var UWindowEditControl NameEdit;
var localized string NameText;
var localized string NameHelp;

// Team Combo
var UWindowComboControl TeamCombo;
var localized string TeamText;
var localized string Teams[4];
var localized string NoTeam;
var localized string TeamHelp;

// Class Combo
var UWindowComboControl ClassCombo;
var localized string ClassText;
var localized string ClassHelp;

// Skin Combo
var UWindowComboControl SkinCombo;
var localized string SkinText;
var localized string SkinHelp;

// Face Combo
var UWindowComboControl FaceCombo;
var localized string FaceText;
var localized string FaceHelp;

// Extra:
var array<PlayerClassManager> Managers;

// Spectate
var UWindowCheckbox SpectatorCheck;
var localized string SpectatorText;
var localized string SpectatorHelp;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I;

	MeshWindow = UMenuPlayerMeshClient(UMenuPlayerClientWindow(ParentWindow.ParentWindow.ParentWindow).Splitter.RightClientWindow);

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	NewPlayerClass = GetPlayerOwner().Class;

	// Player Name
	NameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	NameEdit.SetText(NameText);
	NameEdit.SetHelpText(NameHelp);
	NameEdit.SetFont(F_Normal);
	NameEdit.SetNumericOnly(False);
	NameEdit.SetMaxLength(20);
	NameEdit.SetDelayedNotify(True);

	// Team
	ControlOffset += 25;
	TeamCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	TeamCombo.SetText(TeamText);
	TeamCombo.SetHelpText(TeamHelp);
	TeamCombo.SetFont(F_Normal);
	TeamCombo.SetEditable(False);
	TeamCombo.AddItem(NoTeam, String(255));
	for (I=0; I<4; I++)
		TeamCombo.AddItem(Teams[I], String(i));

	ControlOffset += 25;
	// Load Classes
	ClassCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	ClassCombo.SetText(ClassText);
	ClassCombo.SetHelpText(ClassHelp);
	ClassCombo.SetEditable(False);
	ClassCombo.SetFont(F_Normal);

	// Skin
	ControlOffset += 25;
	SkinCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	SkinCombo.SetText(SkinText);
	SkinCombo.SetHelpText(SkinHelp);
	SkinCombo.SetFont(F_Normal);
	SkinCombo.SetEditable(False);

	ControlOffset += 25;
	FaceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	FaceCombo.SetText(FaceText);
	FaceCombo.SetHelpText(FaceHelp);
	FaceCombo.SetFont(F_Normal);
	FaceCombo.SetEditable(False);

	ControlOffset += 25;
	SpectatorCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	SpectatorCheck.SetText(SpectatorText);
	SpectatorCheck.SetHelpText(SpectatorHelp);
	SpectatorCheck.SetFont(F_Normal);
	SpectatorCheck.Align = TA_Left;
}


function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset + 25;

	LoadClasses();
	LoadCurrent();
	UseSelected();

	Initialized = True;
}

function WindowShown()
{
	super.WindowShown();

	Initialized = false;
	LoadClasses();
	LoadCurrent();
	Initialized = true;
}

function LoadClasses()
{
	local string NextPlayer, NextDesc;
	local int SortWeight;
	local PlayerClassManager M;
	local Class<PlayerPawn> P;
	
	ClassCombo.Clear();
	foreach GetPlayerOwner().IntDescIterator(PlayerBaseClass,NextPlayer,NextDesc,true)
	{
		if( Len(NextDesc)==0 )
			NextDesc = NextPlayer;
		if ( !(NextPlayer~=string(Class'Spectator')) && !(NextPlayer~=string(Class'UnrealSpectator')) )
			ClassCombo.AddItem(NextDesc, NextPlayer, SortWeight);
	}
	
	++SortWeight;
	Managers.Empty();
	foreach GetPlayerOwner().AllActors(Class'PlayerClassManager',M)
	{
		Managers.Add(M);
		if ( !M.bEnabled )
			Continue;
		foreach M.AdditionalClasses(P)
		{
			if ( !P || ClassCombo.FindItemIndex2(string(P))>=0 )
				Continue;
			if ( P.Default.MenuName!="" )
				ClassCombo.AddItem(P.Default.MenuName, string(P), SortWeight);
			else ClassCombo.AddItem(string(P.Name), string(P), SortWeight);
		}
	}
	ClassCombo.Sort();
}

function LoadCurrent()
{
	local string Options;
	local int i;
	local PlayerPawn P;
	local string NameStr;
	local mesh PlayerMesh;

	P = GetPlayerOwner();
	Options = P.Level.GetLocalURL();
	NewPlayerClass = none;

	NameEdit.SetValue(PickOption("NAME", Options));

	// Player class
	if (Len(class'UnrealPlayerMenu'.default.ClassString) > 0)
	{
		i = ClassCombo.FindItemIndex2(class'UnrealPlayerMenu'.default.ClassString, true);
		if (i >= 0)
		{
			ClassCombo.SetSelectedIndex(i);
			NewPlayerClass = class<Pawn>(DynamicLoadObject(ClassCombo.GetValue2(), class'class', true));
		}
		else
		{
			NewPlayerClass = class<Pawn>(DynamicLoadObject(class'UnrealPlayerMenu'.default.ClassString, class'class', true));
			if (NewPlayerClass != none)
			{
				NameStr = P.GetItemName(class'UnrealPlayerMenu'.default.ClassString);
				ClassCombo.SetValue(NameStr, class'UnrealPlayerMenu'.default.ClassString);
			}
		}
	}
	if (NewPlayerClass != none)
	{
		PlayerMesh = NewPlayerClass.default.Mesh;
		MeshName = string(PlayerMesh.Name);
	}
	else
	{
		NewPlayerClass = P.Class;
		PlayerMesh = P.Mesh;
		MeshName = string(PlayerMesh.Name);
	}

	// Player skin
	IterateSkins();
	if (Len(class'UnrealPlayerMenu'.default.PreferredSkin) > 0)
	{
		i = SkinCombo.FindItemIndex2(class'UnrealPlayerMenu'.default.PreferredSkin, true);
		if (i >= 0)
			SkinCombo.SetSelectedIndex(i);
		else
		{
			NameStr = P.GetItemName(class'UnrealPlayerMenu'.default.PreferredSkin);
			SkinCombo.SetValue(NameStr, class'UnrealPlayerMenu'.default.PreferredSkin);
		}
	}
	else
		SkinCombo.SetSelectedIndex(0);

	// Player face
	IterateFaces(SkinCombo.GetValue2());
	if (Len(class'UnrealPlayerMenu'.default.PreferredFace) > 0)
	{
		i = FaceCombo.FindItemIndex2(class'UnrealPlayerMenu'.default.PreferredFace, true);
		if (i >= 0)
			FaceCombo.SetSelectedIndex(i);
		else
		{
			NameStr = P.GetItemName(class'UnrealPlayerMenu'.default.PreferredFace);
			FaceCombo.SetValue(NameStr, class'UnrealPlayerMenu'.default.PreferredFace);
		}
	}
	else
		FaceCombo.SetSelectedIndex(0);

	TeamCombo.SetSelectedIndex(Max(TeamCombo.FindItemIndex2(PickOption("TEAM", Options), true), 0));
	SpectatorCheck.bChecked = Class'UnrealPlayerMenu'.Default.bPlayingSpectate;

	UpdateMeshWindow(PlayerMesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));
}

final function string PickOption( string Option, string Options )
{
	local int i;

	i = InStr(Caps(Options),"?"$Option$"=");
	if ( i>-1 )
	{
		Options = Mid(Options,i+2+Len(Option));
		i = InStr(Options,"?");
		if ( i>-1 )
			Options = Left(Options,i);
		Return Options;
	}
	Return "";
}

function SaveConfigs()
{
	Super.SaveConfigs();
	GetPlayerOwner().SaveConfig();
	GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
}

function IterateSkins()
{
	local string SkinName, SkinDesc, TestName, Temp;
	local bool bNewFormat;
	local int i,j;
	local PlayerClassManager M;
	local array<Texture> Tex;
	local Texture T;

	SkinCombo.Clear();

	if ( ClassIsChildOf(NewPlayerClass, class'Spectator') )
	{
		SkinCombo.HideWindow();
		return;
	}
	else
		SkinCombo.ShowWindow();

	bNewFormat = NewPlayerClass.default.bIsMultiSkinned;

	SkinName = "None";
	TestName = "";
	while ( True )
	{
		GetPlayerOwner().GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

		if ( SkinName == TestName )
			break;

		if ( TestName == "" )
			TestName = SkinName;

		if ( !bNewFormat )
		{
			Temp = GetPlayerOwner().GetItemName(SkinName);
			if ( SkinDesc=="" )
				SkinCombo.AddItem(Temp, SkinName);
			else SkinCombo.AddItem(SkinDesc, SkinName);
		}
		else
		{
			// Multiskin format
			if ( SkinDesc != "")
			{
				Temp = GetPlayerOwner().GetItemName(SkinName);
				if (Mid(Temp, 5, 64) == "")
					// This is a skin
					SkinCombo.AddItem(SkinDesc, Left(SkinName, Len(SkinName) - Len(Temp)) $ Left(Temp, 4));
			}
		}
	}
	SkinName = "";
	// Add special UnrealI/UnrealShare skins.
	while ( i<250 )
	{
		GetPlayerOwner().GetNextIntDesc("Engine.Texture",(i++),SkinName,SkinDesc);
		if ( SkinName=="" )
			break;
		j = InStr(SkinDesc,";");
		if ( SkinDesc=="" || j==-1 )
			continue;
		if ( Left(SkinDesc,j)~=MeshName )
			SkinCombo.AddItem(Mid(SkinDesc,j+1), SkinName);
	}
	foreach Managers(M)
	{
		if ( !M || M.bDeleteMe || !M.bEnabled )
			continue;
		M.GetMeshSkins(Tex,MeshName);
		foreach Tex(T)
			SkinCombo.AddItem(string(T.Name), string(T));
		Tex.Empty();
	}
	SkinCombo.Sort();
}

function IterateFaces(string InSkinName)
{
	local string SkinName, SkinDesc, TestName, Temp;

	FaceCombo.Clear();

	// New format only
	if ( !NewPlayerClass.default.bIsMultiSkinned )
	{
		FaceCombo.HideWindow();
		return;
	}
	else
		FaceCombo.ShowWindow();


	SkinName = "None";
	TestName = "";
	while ( True )
	{
		GetPlayerOwner().GetNextSkin(MeshName, SkinName, 1, SkinName, SkinDesc);

		if ( SkinName == TestName )
			break;

		if ( TestName == "" )
			TestName = SkinName;

		// Multiskin format
		if ( SkinDesc != "")
		{
			Temp = GetPlayerOwner().GetItemName(SkinName);
			if (Mid(Temp, 5) != "" && Left(Temp, 4) == GetPlayerOwner().GetItemName(InSkinName))
				FaceCombo.AddItem(SkinDesc, Left(SkinName, Len(SkinName) - Len(Temp)) $ Mid(Temp, 5));
		}
	}
	FaceCombo.Sort();
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	NameEdit.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	TeamCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SkinCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	FaceCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ClassCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
}

function InitLayoutParams(out float ControlWidth, out float ControlLeft)
{
	local int LabelHSpacing, RightSpacing;

	LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth) / 3;
	RightSpacing = 3;
	if (LabelHSpacing < RightSpacing)
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth - RightSpacing) / 2;
	ControlWidth = LabelTextAreaWidth + LabelHSpacing + EditAreaWidth;
	ControlLeft = LabelHSpacing;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float ControlWidth, ControlLeft, CheckboxWidth;

	super.BeforePaint(C, X, Y);

	if (bUpdatedLabelTextAreaWidth)
		bUpdatedLabelTextAreaWidth = false;
	else
	{
		LabelTextAreaWidth = 0;
		CalcLabelTextAreaWidth(C, LabelTextAreaWidth);
	}

	InitLayoutParams(ControlWidth, ControlLeft);
	CheckboxWidth = ControlWidth - EditAreaWidth + 16;

	NameEdit.SetSize(ControlWidth, 1);
	NameEdit.WinLeft = ControlLeft;
	NameEdit.EditBoxWidth = EditAreaWidth;

	TeamCombo.SetSize(ControlWidth, 1);
	TeamCombo.WinLeft = ControlLeft;
	TeamCombo.EditBoxWidth = EditAreaWidth;

	SkinCombo.SetSize(ControlWidth, 1);
	SkinCombo.WinLeft = ControlLeft;
	SkinCombo.EditBoxWidth = EditAreaWidth;

	FaceCombo.SetSize(ControlWidth, 1);
	FaceCombo.WinLeft = ControlLeft;
	FaceCombo.EditBoxWidth = EditAreaWidth;

	ClassCombo.SetSize(ControlWidth, 1);
	ClassCombo.WinLeft = ControlLeft;
	ClassCombo.EditBoxWidth = EditAreaWidth;

	SpectatorCheck.SetSize(ControlWidth + 2, 1);
	SpectatorCheck.WinLeft = ControlLeft;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		if (!Initialized)
			break;
		switch (C)
		{
		case NameEdit:
			NameChanged();
			break;
		case TeamCombo:
			TeamChanged();
			break;
		case SkinCombo:
			SkinChanged();
			break;
		case ClassCombo:
			ClassChanged();
			break;
		case FaceCombo:
			FaceChanged();
			break;
		case SpectatorCheck:
			SpectatorChanged();
			break;
		}
	}
}

function NameChanged()
{
	local string N;
	if (Initialized)
	{
		Initialized = False;
		N = ReplaceStr(NameEdit.GetValue()," ","_");
		NameEdit.SetValue(N);
		Initialized = True;

		GetPlayerOwner().ChangeName(NameEdit.GetValue());
		GetPlayerOwner().UpdateURL("Name", NameEdit.GetValue(), True);
	}
}

function TeamChanged()
{
	if (Initialized)
		UseSelected();
}

function SkinChanged()
{
	local bool OldInitialized;

	TeamCombo.SetSelectedIndex(0); //UGold -- reset team to None if skin is selected - Smirftsch

	OldInitialized = Initialized;
	Initialized = False;
	IterateFaces(SkinCombo.GetValue2());
	FaceCombo.SetSelectedIndex(0);
	Initialized = OldInitialized;

	if (Initialized)
		UseSelected();
}

function SpectatorChanged()
{
	if ( Initialized )
		UseSelected();
}

function FaceChanged()
{
	if (Initialized)
		UseSelected();
}

function ClassChanged()
{
	local bool OldInitialized;
	local class<Pawn> LoadedPlayerClass;

	// Get the class.
	LoadedPlayerClass = class<Pawn>(DynamicLoadObject(ClassCombo.GetValue2(), class'class', true));
	if (LoadedPlayerClass == none)
	{
		Log(self @ "failed to load player class '" $ ClassCombo.GetValue2() $ "' when trying to set a new class");
		return;
	}
	NewPlayerClass = LoadedPlayerClass;

	// Get the meshname
	MeshName = GetPlayerOwner().GetItemName(string(NewPlayerClass.default.Mesh));

	OldInitialized = Initialized;
	Initialized = False;

	IterateSkins();
	SkinCombo.SetSelectedIndex(0);
	IterateFaces(SkinCombo.GetValue2());
	FaceCombo.SetSelectedIndex(0);
	Initialized = OldInitialized;

	if (Initialized)
		UseSelected();
}

function UpdateMeshWindow(mesh PlayerMesh, string Skin, string Face, int Team)
{
	if (MeshWindow.MeshActor == none || MeshWindow.MeshActor.bDeleteMe)
	{
		MeshWindow.MeshActor = GetEntryLevel().Spawn(class'MeshActor', GetEntryLevel());
		MeshWindow.MeshActor.NotifyClient = MeshWindow;
	}
	MeshWindow.SetMesh(NewPlayerClass.default.Mesh, 35.f/NewPlayerClass.default.CollisionHeight);
	MeshWindow.bIsHuman = NewPlayerClass.Default.bIsHuman;
	MeshWindow.ClearSkins();
	NewPlayerClass.static.SetMultiSkin(MeshWindow.MeshActor, Skin, Face, Team);
}

function UseSelected()
{
	local int NewTeam;

	if (Initialized)
	{
		if ( SpectatorCheck.bChecked )
		{
			GetPlayerOwner().UpdateURL("Class", string(Class'UnrealSpectator'), True);
			GetPlayerOwner().UpdateURL("Skin", "", True);
			GetPlayerOwner().UpdateURL("Face", "", True);
			GetPlayerOwner().UpdateURL("Team", "", True);
		}
		else
		{
			GetPlayerOwner().UpdateURL("Class", ClassCombo.GetValue2(), True);
			GetPlayerOwner().UpdateURL("Skin", SkinCombo.GetValue2(), True);
			GetPlayerOwner().UpdateURL("Face", FaceCombo.GetValue2(), True);
			GetPlayerOwner().UpdateURL("Team", TeamCombo.GetValue2(), True);
		}

		NewTeam = Int(TeamCombo.GetValue2());

		// if the same class as current class, change skin
		if ( ClassCombo.GetValue2() ~= String( GetPlayerOwner().Class ))
			GetPlayerOwner().ServerChangeSkin(SkinCombo.GetValue2(), FaceCombo.GetValue2(), NewTeam);

		if ( GetPlayerOwner().PlayerReplicationInfo.Team!=NewTeam )
			GetPlayerOwner().ChangeTeam(NewTeam);
	}

	// MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh); // UGold - Smirftsch
	UpdateMeshWindow(NewPlayerClass.default.Mesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));

	// Save configures
	Class'UnrealPlayerMenu'.Default.ClassString = ClassCombo.GetValue2();
	Class'UnrealPlayerMenu'.Default.PreferredSkin = SkinCombo.GetValue2();
	Class'UnrealPlayerMenu'.Default.PreferredFace = FaceCombo.GetValue2();
	Class'UnrealPlayerMenu'.Default.bPlayingSpectate = SpectatorCheck.bChecked;
	Class'UnrealPlayerMenu'.Static.StaticSaveConfig();
}

function NotifyBeforeLevelChange()
{
	Super.NotifyBeforeLevelChange();
	ParentWindow.ParentWindow.ParentWindow.Close(); // So all these classes are forced to clean from memory.
}

function Close(optional bool bByParent)
{
	Managers.Empty();
	Super.Close(bByParent);
}

defaultproperties
{
	ControlOffset=25
	EditAreaWidth=110
	PlayerBaseClass="UnrealiPlayer"
	NameText="Name:"
	NameHelp="Set your player name."
	TeamText="Team:"
	Teams(0)="Red"
	Teams(1)="Blue"
	Teams(2)="Green"
	Teams(3)="Gold"
	NoTeam="None"
	TeamHelp="Select the team you wish to play on."
	ClassText="Class:"
	ClassHelp="Select your player class."
	SkinText="Skin:"
	SkinHelp="Choose a skin for your player."
	FaceText="Face:"
	FaceHelp="Choose a face for your player."
	SpectatorText="Play as Spectator"
	SpectatorHelp="Check this checkbox to watch the action in the game as a spectator."
}
