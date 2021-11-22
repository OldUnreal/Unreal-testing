class UMenuMapListCW expands UMenuDialogClientWindow;

var UMenuBotmatchClientWindow BotmatchParent;
var UWindowHSplitter Splitter;

var UMenuMapListExclude Exclude;
var UMenuMapListInclude Include;

var UMenuMapListFrameCW FrameExclude;
var UMenuMapListFrameCW FrameInclude;

var UWindowComboControl DefaultCombo;
var UWindowCheckbox RandomMapOrder;

var localized string DefaultText;
var localized string DefaultHelp;
var localized string RandomText;
var localized string RandomHelp;
var localized string CustomText;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var bool bChangingDefault;
var int MinWinWidth;

var array<string> AddedFileNames; // temporary sorted array of capitalized filenames

function Created()
{
	Super.Created();

	BotmatchParent = UMenuBotmatchClientWindow(OwnerWindow);

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));

	FrameExclude = UMenuMapListFrameCW(Splitter.CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));
	FrameInclude = UMenuMapListFrameCW(Splitter.CreateWindow(class'UMenuMapListFrameCW', 0, 0, 100, 100));

	Splitter.LeftClientWindow  = FrameExclude;
	Splitter.RightClientWindow = FrameInclude;

	Exclude = UMenuMapListExclude(CreateWindow(class'UMenuMapListExclude', 0, 0, 100, 100, Self));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = UMenuMapListInclude(CreateWindow(class'UMenuMapListInclude', 0, 0, 100, 100, Self));
	FrameInclude.Frame.SetFrame(Include);

	Exclude.Register(Self);
	Include.Register(Self);

	Exclude.SetHelpText(ExcludeHelp);
	Include.SetHelpText(IncludeHelp);

	Include.DoubleClickList = Exclude;
	Exclude.DoubleClickList = Include;

	Splitter.bSizable = False;
	Splitter.bRightGrow = True;
	Splitter.SplitPos = WinWidth/2;

	DefaultCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 10, 2, WinWidth/2-10, 1));
	DefaultCombo.SetText(DefaultText);
	DefaultCombo.SetHelpText(DefaultHelp);
	DefaultCombo.SetFont(F_Normal);
	DefaultCombo.SetEditable(False);
	DefaultCombo.AddItem(CustomText, "");
	DefaultCombo.SetSelectedIndex(0);
	DefaultCombo.EditBoxWidth = 120;

	// Random Order
	RandomMapOrder = UWindowCheckbox(CreateControl(class'UWindowCheckbox', WinWidth/2+4, 2, WinWidth/2-10, 1));
	RandomMapOrder.SetText(RandomText);
	RandomMapOrder.SetHelpText(RandomHelp);
	RandomMapOrder.SetFont(F_Normal);
	RandomMapOrder.DesiredTextOffset = 23;

	LoadDefaultClasses();
	LoadMapList();
}

function BeforePaint(Canvas C, float X, float Y)
{
	DefaultCombo.AutoWidth(C);
	RandomMapOrder.AutoWidth(C);
	RandomMapOrder.WinLeft = WinWidth - RandomMapOrder.WinWidth - 6;
	MinWinWidth = DefaultCombo.WinWidth + RandomMapOrder.WinWidth + 30;
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	Super.Paint(C, X, Y);

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, 20, WinWidth, 15, T);

	C.Font = Root.Fonts[F_Normal];
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	ClipText(C, 10, 23, ExcludeCaption, True);
	ClipText(C, WinWidth/2 + 7 + 10, 23, IncludeCaption, True);
}

function Resized()
{
	Super.Resized();

	Splitter.WinTop = 35;
	Splitter.SetSize(WinWidth, WinHeight-35);
	Splitter.SplitPos = WinWidth/2;
}

function LoadDefaultClasses()
{
	local string NextDefault, NextDesc;

	foreach GetPlayerOwner().IntDescIterator(string(BotmatchParent.GameClass.Default.MapListType),NextDefault,NextDesc,true)
		DefaultCombo.AddItem(NextDesc, NextDefault);
}

function LoadMapList()
{
	local string MapName;
	local int i, IncludeCount;
	local UMenuMapList L;

	RandomMapOrder.bChecked = BotmatchParent.GameClass.Default.MapListType.Default.bShuffleMaps;
	Exclude.Items.Clear();
	Array_Size(AddedFileNames, 0);

	ForEach AllFiles("unr", BotmatchParent.GameClass.Default.MapPrefix, MapName)
		if (!SearchAddedFileName(MapName, i)) // prevents adding duplicates
		{
			Array_Insert(AddedFileNames, i);
			AddedFileNames[i] = Caps(MapName);

			L = UMenuMapList(Exclude.Items.Append(class'UMenuMapList'));
			L.MapName = MapName;
			L.DisplayName = Left(MapName, Len(MapName) - 4);
		}

	// Now load the current maplist into Include, and remove them from Exclude.
	Include.Items.Clear();
	IncludeCount = Array_Size(BotmatchParent.GameClass.Default.MapListType.Default.MapsArray);
	for (i=0; i<IncludeCount; i++)
	{
		MapName = BotmatchParent.GameClass.Default.MapListType.Default.MapsArray[i];
		if ( Len(MapName)==0 )
			continue; // Invalid map.

		if( !(Right(MapName,4)~=".unr") )
			MapName = MapName$".unr";
		L = UMenuMapList(Exclude.Items).FindMap(MapName);

		if (L != None)
		{
			L.Remove();
			Include.Items.AppendItem(L);
		}
		else
		{
			L = UMenuMapList(Include.Items.Append(class'UMenuMapList'));
			L.MapName = MapName;
			L.DisplayName = Left(MapName, Len(MapName) - 4);
		}
	}
	Exclude.Sort();
}

// Binary search among AddedFileNames
function bool SearchAddedFileName(string FileName, out int Index)
{
	local int i, lower_bound, upper_bound;

	lower_bound = 0;
	upper_bound = Array_Size(AddedFileNames);
	FileName = Caps(FileName);

	while (lower_bound < upper_bound)
	{
		i = lower_bound + (upper_bound - lower_bound) / 2;
		if (AddedFileNames[i] < FileName)
			lower_bound = i + 1;
		else if (FileName < AddedFileNames[i])
			upper_bound = i;
		else
		{
			Index = i;
			return true;
		}
	}
	Index = lower_bound;
	return false;
}

final function SetArrayLength( Class<MapList> MP, int Count )
{
	local int Num;

	Num = Array_Size(MP.Default.MapsArray,Count);
}

function DefaultComboChanged()
{
	local class<MapList> C;
	local int i, Count;

	if (bChangingDefault)
		return;

	if (DefaultCombo.GetSelectedIndex() == 0)
		return;

	bChangingDefault = True;

	C = class<MapList>(DynamicLoadObject(DefaultCombo.GetValue2(), class'Class'));
	if (C != None)
	{
		RandomMapOrder.bChecked = C.Default.bShuffleMaps;
		BotmatchParent.GameClass.Default.MapListType.Default.bShuffleMaps = C.Default.bShuffleMaps;
		Count = Array_Size(C.Default.MapsArray);
		SetArrayLength(BotmatchParent.GameClass.Default.MapListType,Count);
		for (i=0; i<Count; i++)
			BotmatchParent.GameClass.Default.MapListType.Default.MapsArray[i] = C.Default.MapsArray[i];

		BotmatchParent.GameClass.Default.MapListType.static.StaticSaveConfig();

		LoadMapList();
	}

	bChangingDefault = False;
}

function SaveConfigs()
{
	local int i;
	local UMenuMapList L;

	Super.SaveConfigs();

	L = UMenuMapList(Include.Items.Next);

	SetArrayLength(BotmatchParent.GameClass.Default.MapListType,0);
	while( L!=None )
	{
		BotmatchParent.GameClass.Default.MapListType.Default.MapsArray[i++] = L.MapName;
		L = UMenuMapList(L.Next);
	}

	BotmatchParent.GameClass.Default.MapListType.static.StaticSaveConfig();
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case DefaultCombo:
			DefaultComboChanged();
			break;
		case Exclude:
		case Include:
			DefaultCombo.SetSelectedIndex(0);
			break;
		case RandomMapOrder:
			BotmatchParent.GameClass.Default.MapListType.Default.bShuffleMaps = RandomMapOrder.bChecked;
		}
		break;
	}
}

defaultproperties
{
	DefaultText="Use Map List: "
	DefaultHelp="Choose a default map list to load, or choose Custom and configure the map list by hand."
	CustomText="Custom"
	ExcludeCaption="Maps Not Cycled"
	ExcludeHelp="Click and drag a map to the right hand column to include that map in the map cycle list."
	IncludeCaption="Maps Cycled"
	IncludeHelp="Click and drag a map to the left hand column to remove it from the map cycle list, or drag it up or down to re-order it in the map cycle list."
	RandomText="Shuffle Maps:"
	RandomHelp="Play these maps in random order."
}
