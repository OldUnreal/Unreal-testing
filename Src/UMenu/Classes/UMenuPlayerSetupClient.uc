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

var UnrealUserManager Manager;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int I;

	MeshWindow = UMenuPlayerMeshClient(UMenuPlayerClientWindow(ParentWindow.ParentWindow.ParentWindow).Splitter.RightClientWindow);
	Manager = Class'UnrealUserManager'.Static.GetManager();

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

	Manager.Refresh();
	
	LoadClasses();
	LoadCurrent();
	UseSelected();

	Initialized = True;
}

function WindowShown()
{
	super.WindowShown();

	Manager.Refresh();
	
	Initialized = false;
	LoadClasses();
	LoadCurrent();
	Initialized = true;
}

function LoadClasses()
{
	local int i;
	local PlayerClassManager M;
	
	Managers.Empty();
	foreach GetPlayerOwner().AllActors(Class'PlayerClassManager',M)
		Managers.Add(M);
	
	ClassCombo.Clear();
	Manager.GetMeshList(Managers);
	for( i=0; i<Manager.FirstCustomMesh; ++i )
		ClassCombo.AddItem(Manager.MeshList[i].Desc, Manager.MeshList[i].Value, 0);
	for( ; i<Manager.MeshList.Size(); ++i )
		ClassCombo.AddItem(Manager.MeshList[i].Desc, Manager.MeshList[i].Value, 1);
	ClassCombo.Sort();
}

function LoadCurrent()
{
	local int i;
	local PlayerPawn P;
	local string S;
	local mesh PlayerMesh;

	P = GetPlayerOwner();
	NewPlayerClass = none;

	NameEdit.SetValue(Manager.InitName);

	// Player class
	S = Manager.GetCurrentClass();
	NewPlayerClass = class<PlayerPawn>(DynamicLoadObject(S, class'class', true));
	i = ClassCombo.FindItemIndex2(S, true);
	if (i >= 0)
		ClassCombo.SetSelectedIndex(i);
	else if( NewPlayerClass )
		ClassCombo.SetValue(string(NewPlayerClass.Name), string(NewPlayerClass));
	
	if( NewPlayerClass )
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
	S = Manager.GetCurrentSkin();
	SkinCombo.SetSelectedIndex((Len(S)>0) ? Max(SkinCombo.FindItemIndex2(S, true),0) : 0);

	// Player face
	IterateFaces(SkinCombo.GetValue2());
	S = Manager.GetCurrentFace();
	FaceCombo.SetSelectedIndex((Len(S)>0) ? Max(FaceCombo.FindItemIndex2(S, true),0) : 0);

	TeamCombo.SetSelectedIndex(Max(TeamCombo.FindItemIndex2(string(Manager.InitTeam), true), 0));
	SpectatorCheck.bChecked = Manager.bIsSpectator;

	UpdateMeshWindow(PlayerMesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));
}

function SaveConfigs()
{
	Super.SaveConfigs();
	// Marco: Makes no sense to save all config here...
	//GetPlayerOwner().SaveConfig();
	//GetPlayerOwner().PlayerReplicationInfo.SaveConfig();
	Manager.Save(NameEdit.GetValue(), ClassCombo.GetValue2(), SkinCombo.GetValue2(), FaceCombo.GetValue2(), byte(TeamCombo.GetValue2()), SpectatorCheck.bChecked);
}

function IterateSkins()
{
	local int i;

	SkinCombo.Clear();

	if( NewPlayerClass.Default.bIsPlayerPawn && Class<PlayerPawn>(NewPlayerClass).Default.bIsSpectatorClass )
	{
		SkinCombo.HideWindow();
		return;
	}
	else
		SkinCombo.ShowWindow();

	Manager.GetMeshSkins(NewPlayerClass,Managers);
	for( i=(Manager.SkinList.Size()-1); i>=0; --i )
		SkinCombo.AddItem(Manager.SkinList[i].Desc, Manager.SkinList[i].Value);
	SkinCombo.Sort();
}

function IterateFaces(string InSkinName)
{
	local int i;

	FaceCombo.Clear();

	// New format only
	if ( !NewPlayerClass.default.bIsMultiSkinned )
	{
		FaceCombo.HideWindow();
		return;
	}
	else
		FaceCombo.ShowWindow();

	Manager.GetMeshFaces(NewPlayerClass,InSkinName,Managers);
	for( i=(Manager.FaceList.Size()-1); i>=0; --i )
		FaceCombo.AddItem(Manager.FaceList[i].Desc, Manager.FaceList[i].Value);
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
		SanitizeString(N);
		NameEdit.SetValue(N);
		Initialized = True;
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
		Warn(self @ "failed to load player class '" $ ClassCombo.GetValue2() $ "' when trying to set a new class");
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
	// MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh); // UGold - Smirftsch
	UpdateMeshWindow(NewPlayerClass.default.Mesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));
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
