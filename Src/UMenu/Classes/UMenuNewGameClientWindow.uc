class UMenuNewGameClientWindow extends UMenuPageWindow;

const STANDARD_SkillLevels=3;
const MAX_SkillLevels=7;

var config string LastSelectedGame;
var config byte LastSelectedSkill;

struct FCampaignInfo
{
	var string StartMap, StartGameType, SaveInfo, ScreenShotName;
	var Texture Screenshot;
};
var array<FCampaignInfo> Campaigns;
var transient string PendingURL;

// Game to start combo
var UWindowComboControl GameCombo;
var localized string GameHelp;
var localized string GameText;

// Skill Level
var UWindowComboControl SkillCombo;
var UMenuLabelControl SkillLabel;
var localized string SkillText;
var localized string Skills[MAX_SkillLevels];
var localized string SkillStrings[MAX_SkillLevels];
var localized string SkillHelp,HighSkillTitle,HighSkillWarning;

var UWindowCheckbox UseMutatorsCheck;
var localized string UseMutText;
var localized string UseMutHelp;

var UWindowCheckbox UseClassicCheck;
var localized string UseClassicText;
var localized string UseClassicHelp;

var UWindowCheckbox MirrorModeCheck;
var localized string MirrorModeText;
var localized string MirrorModeHelp;

var UWindowSmallButton OKButton;
var UWindowSmallButton MutatorButton;
var UWindowSmallButton AdvancedButton;
var UWindowBitmap ScreenshotPreview;
var float ButtonWidth;

var localized string AdvancedText;

var config bool bMutatorsSelected, bClassicChecked;

function WindowShown()
{
	UseClassicCheck.bChecked = bClassicChecked;
	UseMutatorsCheck.bChecked = bMutatorsSelected;
	CheckMirrorEnable();
	Super.WindowShown();
}

// Easter egg: You must stare at a mirror BSP surface in order for Mirror mode to show up!
final function CheckMirrorEnable()
{
	local PlayerPawn P;
	local vector HL,HN;
	local int HF;
	
	MirrorModeCheck.bChecked = false;
	
	P = GetLocalPlayerPawn();
	
	// Perform 2 traces, first one to trace through the invisible collision hull at Entry's window, second time to check its BSP flags!
	if( P.Trace(HL,HN,P.CalcCameraLocation + vector(P.CalcCameraRotation)*(P.CollisionRadius+86.f),P.CalcCameraLocation,false,,,NF_NotVisBlocking) && P.TraceSurfHitInfo(HL+HN,HL-HN,,,,HF,,,{TRACE_Level | TRACE_Movers}) && (HF & PF_Mirrored) )
		ShowChildWindow(MirrorModeCheck);
	else HideChildWindow(MirrorModeCheck);
}

function Created()
{
	local int CenterWidth, CenterPos;
	local int j,z,GameSelection;
	local string Ent,Des;

	Super.Created();

	DesiredWidth = 220;
	DesiredHeight = 330;

	CenterWidth = (WinWidth/6)*5;
	CenterPos = (WinWidth - CenterWidth)/2;
	
	ScreenshotPreview = UWindowBitmap(CreateWindow(class'UWindowBitmap',8.f,62.f,8.f,8.f));
	ScreenshotPreview.bStretch = true;

	// Campain
	GameCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 5, CenterWidth, 1));
	GameCombo.SetText(GameText);
	GameCombo.SetHelpText(GameHelp);
	GameCombo.SetFont(F_Normal);
	GameCombo.SetEditable(False);
	foreach GetPlayerOwner().IntDescIterator(string(Class'SinglePlayer'),Ent,Des) // Class: "Gametype class", Description: "StartingMap;Screenshot;Campaign name"
	{
		if ( Des!="" )
		{
			j = InStr(Des,";");
			if ( j!=-1 )
			{
				Campaigns[z].SaveInfo = Ent@Left(Des,j);
				if( LastSelectedGame~=Campaigns[z].SaveInfo )
					GameSelection = z;
				Campaigns[z].StartGameType = Ent;
				Campaigns[z].StartMap = Left(Des,j);
				Des = Mid(Des,j+1);
				
				// Check for optional screenshot.
				j = InStr(Des,";");
				if ( j!=-1 )
					Campaigns[z].ScreenShotName = Left(Des,j);
				GameCombo.AddItem(Mid(Des,j+1));
				++z;
			}
		}
	}
	GameCombo.SetSelectedIndex(GameSelection);

	// Skill Level
	SkillCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, 22, CenterWidth, 1));
	SkillCombo.SetText(SkillText);
	SkillCombo.SetHelpText(SkillHelp);
	SkillCombo.SetFont(F_Normal);
	SkillCombo.SetEditable(False);
	for( j=0; j<MAX_SkillLevels; j++ )
		SkillCombo.AddItem(Skills[j]);
	SkillLabel = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', 5, 45, WinWidth-10, 1));
	SkillLabel.Align = TA_Center;
	SkillCombo.SetSelectedIndex(Clamp(LastSelectedSkill,0,{MAX_SkillLevels-1}));

	// Use mutators
	UseMutatorsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, 78, 190, 1));
	UseMutatorsCheck.SetText(UseMutText);
	UseMutatorsCheck.SetHelpText(UseMutHelp);
	UseMutatorsCheck.SetFont(F_Normal);
	UseMutatorsCheck.bChecked = bMutatorsSelected;
	UseMutatorsCheck.Align = TA_Left;
	
	// Use classic
	UseClassicCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, 62, 190, 1));
	UseClassicCheck.SetText(UseClassicText);
	UseClassicCheck.SetHelpText(UseClassicHelp);
	UseClassicCheck.SetFont(F_Normal);
	UseClassicCheck.bChecked = bClassicChecked;
	UseClassicCheck.Align = TA_Left;
	
	// Mirror mode
	MirrorModeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, 116, 190, 1));
	MirrorModeCheck.SetText(MirrorModeText);
	MirrorModeCheck.SetHelpText(MirrorModeHelp);
	MirrorModeCheck.SetFont(F_Normal);
	MirrorModeCheck.Align = TA_Left;
	CheckMirrorEnable();

	// Mutators
	MutatorButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 98, 64, 32));
	MutatorButton.SetText(Class'UMenuStartMatchClientWindow'.Default.MutatorText);
	MutatorButton.SetHelpText(Class'UMenuStartMatchClientWindow'.Default.MutatorHelp);
	
	// OKButton
	OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 138, 64, 32));
	OKButton.SetText(class'UMenuStartGameClientWindow'.default.StartText);

	AdvancedButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, 138, 64, 32));
	AdvancedButton.SetText(AdvancedText);

	if (!class'UMenuMutatorCW'.default.bKeepMutators)
		class'UMenuMutatorCW'.default.MutatorList = "";
}

function BeforePaint(Canvas C, float X, float Y)
{
	const EditAreaOffset = 7;
	local int ControlLeft, ControlRight;
	local int CenterWidth;
	local float LabelWidth;

	CenterWidth = (WinWidth/6)*5;
	ControlLeft = (WinWidth - CenterWidth) / 2;
	ControlRight = (WinWidth + CenterWidth) / 2;
	GameCombo.GetMinTextAreaWidth(C, LabelWidth);
	SkillCombo.GetMinTextAreaWidth(C, LabelWidth);
	LabelWidth += EditAreaOffset;

	GameCombo.SetSize(CenterWidth, 1);
	GameCombo.WinLeft = ControlLeft;
	GameCombo.EditBoxWidth = CenterWidth - LabelWidth;

	SkillCombo.SetSize(CenterWidth, 1);
	SkillCombo.WinLeft = ControlLeft;
	SkillCombo.EditBoxWidth = CenterWidth - LabelWidth;

	SkillLabel.SetSize(WinWidth-10, 1);
	SkillLabel.WinLeft = 5;
	
	if( ScreenshotPreview.bWindowVisible )
	{
		LabelWidth = WinHeight-90;
		if( ScreenshotPreview.T.USize<ScreenshotPreview.T.VSize )
			ScreenshotPreview.SetSize(LabelWidth*0.5f, LabelWidth);
		else if( ScreenshotPreview.T.USize>ScreenshotPreview.T.VSize )
			ScreenshotPreview.SetSize(LabelWidth*2.f, LabelWidth);
		else ScreenshotPreview.SetSize(LabelWidth, LabelWidth);
	}

	UseMutatorsCheck.AutoWidth(C);
	UseMutatorsCheck.WinLeft = ControlRight - UseMutatorsCheck.WinWidth + 3;
	
	UseClassicCheck.AutoWidth(C);
	UseClassicCheck.WinLeft = ControlRight - UseClassicCheck.WinWidth + 3;
	
	MirrorModeCheck.AutoWidth(C);
	MirrorModeCheck.WinLeft = ControlRight - MirrorModeCheck.WinWidth + 3;

	MutatorButton.AutoWidthBy(C, ButtonWidth);
	MutatorButton.WinLeft = ControlRight - MutatorButton.WinWidth;

	OKButton.AutoWidthBy(C, ButtonWidth);
	OKButton.WinLeft = ControlLeft;

	AdvancedButton.AutoWidthBy(C, ButtonWidth);
	AdvancedButton.WinLeft = ControlRight - AdvancedButton.WinWidth;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case SkillCombo:
			SkillChanged();
			break;
		case UseMutatorsCheck:
			bMutatorsSelected = UseMutatorsCheck.bChecked;
			SaveConfig();
			break;
		case UseClassicCheck:
			bClassicChecked = UseClassicCheck.bChecked;
			SaveConfig();
			break;
		case GameCombo:
			OnCampignChange();
		}
	case DE_Click:
		switch (C)
		{
		case OKButton:
			OKClicked();
			break;
		case MutatorButton:
			GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'UMenuMutatorWindow', 0, 0, 100, 100, Self));
			break;
		case AdvancedButton:
			AdvancedClicked();
			break;
		}
	}
}

function OKClicked()
{
	local int i;
	local string S;

	i = GameCombo.GetSelectedIndex();
	LastSelectedGame = Campaigns[i].SaveInfo;
	LastSelectedSkill = SkillCombo.GetSelectedIndex();
	S = Campaigns[i].StartMap $ "?Difficulty=" $ SkillCombo.GetSelectedIndex();

	if (!(Campaigns[i].StartGameType ~= "Game.Game"))
		S $= "?Game=" $ Campaigns[i].StartGameType;
	
	if (bMutatorsSelected)
		S $= "?Mutator="$class'UMenuMutatorCW'.default.MutatorList;
	
	S $= "?ClassicMode="$string(bClassicChecked);
	
	if( MirrorModeCheck.bWindowVisible && MirrorModeCheck.bChecked )
		S $= "?MirrorMode=1";

	if( LastSelectedSkill>3 && MessageBox(HighSkillTitle, HighSkillWarning, MB_YesNo, MR_No, MR_Yes) )
		PendingURL = S;
	else
	{
		GetPlayerOwner().ClientTravel(S, TRAVEL_Absolute, false);
		GetParent(class'UWindowFramedWindow').Close();
		Root.Console.CloseUWindow();
	}
	SaveConfig();
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if( Result==MR_Yes )
	{
		GetPlayerOwner().ClientTravel(PendingURL, TRAVEL_Absolute, false);
		GetParent(class'UWindowFramedWindow').Close();
		Root.Console.CloseUWindow();
	}
}

function OnCampignChange()
{
	local int i;
	
	i = GameCombo.GetSelectedIndex();
	if( !Campaigns[i].Screenshot )
	{
		if( Len(Campaigns[i].ScreenShotName) )
		{
			Campaigns[i].Screenshot = Texture(DynamicLoadObject(Campaigns[i].ScreenShotName,Class'Texture'));
			if( !Campaigns[i].Screenshot )
				Campaigns[i].ScreenShotName = "";
		}
	}
	
	if( !Campaigns[i].Screenshot )
	{
		if( ScreenshotPreview.bWindowVisible )
			ScreenshotPreview.HideWindow();
	}
	else
	{
		ScreenshotPreview.FitTexture(Campaigns[i].Screenshot);
		if( !ScreenshotPreview.bWindowVisible )
			ScreenshotPreview.ShowWindow();
	}
}

function SkillChanged()
{
	local int i;
	
	if( SkillLabel )
	{
		i = SkillCombo.GetSelectedIndex();
		SkillLabel.SetText(SkillStrings[i]);
		SkillCombo.SetEditTextColor((i<=STANDARD_SkillLevels) ? LookAndFeel.EditBoxTextColor : MakeColor(128,0,0));
		SkillLabel.TextColor = (i<=STANDARD_SkillLevels) ? MakeColor(0,0,0) : MakeColor(128,0,0);
	}
}

function AdvancedClicked()
{
	Root.CreateWindow(class'UMenuNewStandaloneGameWindow', 100, 100, 200, 200, OwnerWindow, true);
	GetParent(class'UWindowFramedWindow').Close();
}

function Close(optional bool bByParent)
{
	super.Close(bByParent);

	if (!class'UMenuMutatorCW'.default.bKeepMutators)
		class'UMenuMutatorCW'.default.MutatorList = "";
}

defaultproperties
{
	LastSelectedGame="Game.Game Vortex2"
	LastSelectedSkill=1
	bClassicChecked=true
	GameHelp="Select your game to play."
	GameText="Campaign:"
	SkillText="Difficulty:"
	Skills(0)="Easy"
	Skills(1)="Medium"
	Skills(2)="Hard"
	Skills(3)="Unreal"
	Skills(4)="Extreme"
	Skills(5)="Nightmare"
	Skills(6)="Ultra-Unreal"
	SkillStrings(0)="Tourist mode."
	SkillStrings(1)="Ready for some action!"
	SkillStrings(2)="Not for the faint of heart."
	SkillStrings(3)="Death wish."
	SkillStrings(4)="For players who want an extra difficulty."
	SkillStrings(5)="For the hardcore gamers."
	SkillStrings(6)="HOLY SHIT!"
	SkillHelp="Select the difficulty you wish to play at."
	UseMutText="Use Mutators"
	UseMutHelp="If should use mutators in this game."
	UseClassicText="Use Classic Balance"
	UseClassicHelp="Some gameplay mechanics should behave as old Unreal versions."
	AdvancedText="Advanced..."
	HighSkillTitle="WARNING!"
	HighSkillWarning="This skill level is outside of standard difficulty settings, it will brutalize you in singleplayer. Are you sure you want to proceed?"
	MirrorModeText="Mirror Mode"
	MirrorModeHelp="The world is not what it seams..."
}