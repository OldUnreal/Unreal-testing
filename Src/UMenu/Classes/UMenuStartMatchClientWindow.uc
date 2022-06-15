class UMenuStartMatchClientWindow extends UMenuDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;

var bool Initialized, InGameChanged;

// Game Type
var UWindowEditControl GameEdit;
var UWindowComboBoxControl GameCombo;
var localized string GameText;
var localized string GameClassText;
var localized string GameHelp;
var array<string> Games; // unused, preserved for backward binary compatibility
var int MaxGames; // unused, preserved for backward binary compatibility

// Map
var UWindowComboBoxControl MapCombo;
var localized string MapText;
var localized string MapHelp;

// Map List Button
var UWindowSmallButton MapListButton;
var localized string MapListText;
var localized string MapListHelp;

var UWindowSmallButton MutatorButton;
var localized string MutatorText;
var localized string MutatorHelp;

var UWindowCheckbox FilterInvalidGameClassesCheck;
var localized string FilterInvalidGameClassesText;
var localized string FilterInvalidGameClassesHelp;
var localized string InvalidGameClass;

function Created()
{
	local int CenterWidth, CenterPos, YOffset, YDist;

	Super.Created();

	DesiredWidth = 270;
	DesiredHeight = 100;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;
	YOffset = 20;
	YDist = 25;

	BotmatchParent = UMenuBotmatchClientWindow(GetParent(class'UMenuBotmatchClientWindow'));
	if (BotmatchParent == None)
		Log("Error: UMenuStartMatchClientWindow without UMenuBotmatchClientWindow parent.");

	// Game Type
	GameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, YOffset, CenterWidth, 1));
	GameEdit.SetText(GameText);
	GameEdit.SetFont(F_Normal);
	GameEdit.EditBox.SetEditable(false);
	GameEdit.EditBox.TextColor.R = 128;
	GameEdit.EditBox.TextColor.G = 64;
	GameEdit.EditBox.TextColor.B = 0;

	// Game Classes
	GameCombo = UWindowComboBoxControl(CreateControl(class'UWindowComboBoxControl', CenterPos, YOffset += YDist, CenterWidth, 1));
	GameCombo.SetButtons(True);
	GameCombo.SetText(GameClassText);
	GameCombo.SetHelpText(GameHelp);
	GameCombo.SetFont(F_Normal);
	GameCombo.SetEditable(True);
	GameCombo.EnableQuickFilter(True);

	IterateGameClasses();

	// Map
	MapCombo = UWindowComboBoxControl(CreateControl(class'UWindowComboBoxControl', CenterPos, YOffset += YDist, CenterWidth, 1));
	MapCombo.SetButtons(True);
	MapCombo.SetText(MapText);
	MapCombo.SetHelpText(MapHelp);
	MapCombo.SetFont(F_Normal);
	MapCombo.SetEditable(True);
	MapCombo.SetAutoSort(True);
	MapCombo.EnableQuickFilter(True);

	IterateMaps(BotmatchParent.Map);

	// Map List Button
	MapListButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, YOffset += YDist, 48, 16));
	MapListButton.SetText(MapListText);
	MapListButton.SetFont(F_Normal);
	MapListButton.SetHelpText(MapListHelp);
	MapListButton.bDisabled = BotmatchParent.GameClass == none || BotmatchParent.GameClass.Default.MapListType == none;

	// Mutator Button
	MutatorButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', CenterPos, YOffset += YDist, 48, 16));
	MutatorButton.SetText(MutatorText);
	MutatorButton.SetFont(F_Normal);
	MutatorButton.SetHelpText(MutatorHelp);

	// Filter Invalid Game Classes Checkbox
	FilterInvalidGameClassesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, WinHeight - YDist, CenterWidth, 1));
	FilterInvalidGameClassesCheck.SetText(FilterInvalidGameClassesText);
	FilterInvalidGameClassesCheck.SetHelpText(FilterInvalidGameClassesHelp);
	FilterInvalidGameClassesCheck.SetFont(F_Normal);
	FilterInvalidGameClassesCheck.Align = TA_Left;
	FilterInvalidGameClassesCheck.bChecked = BotmatchParent.bFilterInvalidGameClasses;

	Initialized = True;
}

function IterateGameClasses()
{
	local string GameClassName, GameTitle;
	local string PackageName, ClassName;
	local int i, GamesCount;

	GameEdit.Clear();
	GameCombo.Clear();

	if ( !BotmatchParent )
		return;

	foreach GetPlayerOwner().IntDescIterator("Engine.GameInfo", GameClassName,, true)
	{
		if (!Divide(GameClassName, ".", PackageName, ClassName)) // ClassName may include names of groups
			continue;
		if (!BotmatchParent.CheckGameClass(PackageName, GameClassName) ||
			BotmatchParent.bFilterInvalidGameClasses && class<GameInfo>(DynamicLoadObject(GameClassName, class'class', true)) == none)
		{
			continue;
		}

		GameTitle = ClassName @ "[" $ PackageName $ "]";
		GameCombo.AddItem(GameTitle, GameClassName);
	}

	GameCombo.Sort();

	GamesCount = GameCombo.ItemsCount();
	for (i = 0; i < GamesCount; ++i)
		if (GameCombo.GetItemValue2(i) ~= BotmatchParent.GameType)
		{
			GameCombo.SetSelectedIndex(i);
			break;
		}
	if (i == GamesCount)
		GameCombo.SetSelectedIndex(0);

	BotmatchParent.GameType = GameCombo.GetValue2();
	ProcessSelectedGameClass();
}

function IterateMaps(string DefaultMap)
{
	local string TestMap;

	MapCombo.Clear();
	ForEach AllFiles("unr", BotmatchParent.MapPrefix(), TestMap)
		MapCombo.AddUniqueItem(Left(TestMap, Len(TestMap) - 4), TestMap);
	MapCombo.SetSelectedIndex(Max(MapCombo.FindItemIndex2(DefaultMap, True), 0));
}

function AfterCreate()
{
	BotmatchParent.Map = MapCombo.GetValue2();
	BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
}

function BeforePaint(Canvas C, float X, float Y)
{
	const ControlHOffset = 10;
	const EditAreaOffset = 7;
	const BottomControlOffset = 25;
	local int CenterWidth;
	local float LabelWidth;

	CenterWidth = WinWidth - 2 * ControlHOffset;
	GameCombo.GetMinTextAreaWidth(C, LabelWidth);
	MapCombo.GetMinTextAreaWidth(C, LabelWidth);
	LabelWidth += EditAreaOffset;

	GameEdit.SetSize(CenterWidth, 1);
	GameEdit.WinLeft = ControlHOffset;
	GameEdit.EditBoxWidth = CenterWidth - LabelWidth;

	GameCombo.SetSize(CenterWidth, 1);
	GameCombo.WinLeft = ControlHOffset;
	GameCombo.EditBoxWidth = CenterWidth - LabelWidth;

	MapCombo.SetSize(CenterWidth, 1);
	MapCombo.WinLeft = ControlHOffset;
	MapCombo.EditBoxWidth = CenterWidth - LabelWidth;

	MapListButton.AutoWidth(C);
	MutatorButton.AutoWidth(C);

	MapListButton.WinWidth = Max(MapListButton.WinWidth, MutatorButton.WinWidth);
	MutatorButton.WinWidth = MapListButton.WinWidth;

	MapListButton.WinLeft = (WinWidth - MapListButton.WinWidth) / 2;
	MutatorButton.WinLeft = (WinWidth - MapListButton.WinWidth) / 2;

	FilterInvalidGameClassesCheck.AutoWidth(C);
	FilterInvalidGameClassesCheck.WinLeft = WinWidth - ControlHOffset - FilterInvalidGameClassesCheck.WinWidth;
	FilterInvalidGameClassesCheck.WinTop = WinHeight - BottomControlOffset;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case GameCombo:
			GameChanged();
			break;
		case MapCombo:
			MapChanged();
			break;
		}
		break;
	case DE_Click:
		switch (C)
		{
		case MapListButton:
			if ( !MapListButton.bDisabled )
				GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'UMenuMapListWindow', 0, 0, 100, 100, BotmatchParent));
			break;
		case MutatorButton:
			GetParent(class'UWindowFramedWindow').ShowModal(Root.CreateWindow(class'UMenuMutatorWindow', 0, 0, 100, 100, BotmatchParent));
			break;
		case FilterInvalidGameClassesCheck:
			BotmatchParent.bFilterInvalidGameClasses = FilterInvalidGameClassesCheck.bChecked;
			IterateGameClasses();
			break;
		}
	}
}

function ProcessSelectedGameClass()
{
	if (Len(BotmatchParent.GameType) > 0)
	{
		BotmatchParent.GameClass = class<GameInfo>(DynamicLoadObject(BotmatchParent.GameType, class'class', true));
		if (BotmatchParent.GameClass != none)
			GameEdit.SetValue(BotmatchParent.GameClass.default.GameName);
		else
			GameEdit.SetValue(InvalidGameClass);
	}
	else
	{
		BotmatchParent.GameClass = none;
		GameEdit.SetValue("");
	}

	BotmatchParent.EnableStart(BotmatchParent.GameClass != none);
}

function GameChanged()
{
	if (!Initialized || InGameChanged || BotmatchParent == none)
		return;

	if (!GameCombo.HasValue2() && class<GameInfo>(DynamicLoadObject(GameCombo.GetValue(), class'class', true)) == none)
	{
		GameEdit.SetValue(InvalidGameClass);
		BotmatchParent.EnableStart(false);
		return;
	}

	InGameChanged = true;

	BotmatchParent.PreGameChanged();

	if (GameCombo.HasValue2())
		BotmatchParent.GameType = GameCombo.GetValue2();
	else
		BotmatchParent.GameType = GameCombo.GetValue();

	ProcessSelectedGameClass();

	if (MapCombo != none)
		IterateMaps(BotmatchParent.Map);
	BotmatchParent.GameChanged();
	InGameChanged = false;
	if (MapListButton)
		MapListButton.bDisabled = BotmatchParent.GameClass==None || BotmatchParent.GameClass.default.MapListType == none;
}

function MapChanged()
{
	if (!Initialized)
		return;

	if (MapCombo.HasValue2())
		BotmatchParent.Map = MapCombo.GetValue2();
	else
		BotmatchParent.Map = MapCombo.GetValue() $ ".unr";
	BotmatchParent.ScreenshotWindow.SetMap(BotmatchParent.Map);
}

defaultproperties
{
	GameText="Game Type:"
	GameClassText="Game Class:"
	GameHelp="Select the type of game to play."
	MapText="Map Name:"
	MapHelp="Select the map to play."
	MapListText="Map List"
	MapListHelp="Click this button to change the list of maps which will be cycled."
	MutatorText="Mutators"
	MutatorHelp="Mutators are scripts which modify gameplay.  Press this button to choose which mutators to use."
	FilterInvalidGameClassesText="Filter Invalid Game Classes"
	FilterInvalidGameClassesHelp="When checked, invalid classes are not listed (validation may be slow)."
	InvalidGameClass="<Invalid Game Class>"
}
