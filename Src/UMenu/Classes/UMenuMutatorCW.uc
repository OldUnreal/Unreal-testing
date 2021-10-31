class UMenuMutatorCW expands UMenuDialogClientWindow;

var globalconfig string MutatorList;
var globalconfig bool bKeepMutators;

var UWindowHSplitter Splitter;

var UMenuMutatorExclude Exclude;
var UMenuMutatorInclude Include;

var localized string ExcludeCaption;
var localized string ExcludeHelp;
var localized string IncludeCaption;
var localized string IncludeHelp;

var UWindowCheckbox KeepCheck;
var localized string KeepText;
var localized string KeepHelp;

var UMenuMutatorFrameCW FrameExclude;
var UMenuMutatorFrameCW FrameInclude;

var string MutatorBaseClass;

function Created()
{
	Super.Created();

	KeepCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', 10, 2, 190, 1));
	KeepCheck.SetText(KeepText);
	KeepCheck.SetHelpText(KeepHelp);
	KeepCheck.SetFont(F_Normal);
	KeepCheck.bChecked = Default.bKeepMutators;
	KeepCheck.Align = TA_Right;

	Splitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));

	FrameExclude = UMenuMutatorFrameCW(Splitter.CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, 100));
	FrameInclude = UMenuMutatorFrameCW(Splitter.CreateWindow(class'UMenuMutatorFrameCW', 0, 0, 100, 100));

	Splitter.LeftClientWindow  = FrameExclude;
	Splitter.RightClientWindow = FrameInclude;

	Exclude = UMenuMutatorExclude(CreateWindow(class'UMenuMutatorExclude', 0, 0, 100, 100, Self));
	FrameExclude.Frame.SetFrame(Exclude);
	Include = UMenuMutatorInclude(CreateWindow(class'UMenuMutatorInclude', 0, 0, 100, 100, Self));
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

	LoadMutators();
}

function Paint(Canvas C, float X, float Y)
{
	KeepCheck.AutoWidth(C);

	Super.Paint(C, X, Y);

	DrawUpBevel( C, 0, 20, WinWidth, 15, GetLookAndFeelTexture());

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

function UpdateMutators()
{
	local string Mutators, MutatorClass, MutatorPackage;
	local UMenuMutatorList Item, NextItem;
	local bool bLastMutator;

	for (Item = UMenuMutatorList(Include.Items.Next); Item != none; Item = NextItem)
	{
		NextItem = UMenuMutatorList(Item.Next);
		Item.Remove();
		Exclude.Items.AppendItem(Item);
	}

	Mutators = default.MutatorList;

	if (Len(Mutators) > 0)
		while (!bLastMutator)
		{
			if (!Divide(Mutators, ",", MutatorClass, Mutators))
			{
				MutatorClass = Mutators;
				bLastMutator = true;
			}
			Item = UMenuMutatorList(Exclude.Items).FindMutator(MutatorClass);
			if (Item != none)
			{
				Item.Remove();
				Include.Items.AppendItem(Item);
			}
			else
			{
				Item = UMenuMutatorList(Include.Items.Append(class'UMenuMutatorList'));
				Item.MutatorClass = MutatorClass;
				Divide(MutatorClass, ".", MutatorPackage, MutatorClass);
				Item.MutatorName = MutatorClass;
				Item.HelpText = "";
			}
		}

	Exclude.Sort();
}

function LoadMutators()
{
	local string NextMutator, NextDesc;
	local UMenuMutatorList I;
	local int k;

	foreach GetPlayerOwner().IntDescIterator(MutatorBaseClass,NextMutator,NextDesc,true)
	{
		I = UMenuMutatorList(Exclude.Items.Append(class'UMenuMutatorList'));
		I.MutatorClass = NextMutator;

		if ( Len(NextDesc)==0 )
		{
			I.MutatorName = NextMutator;
			I.HelpText = "";
		}
		else
		{
			k = InStr(NextDesc, ",");
			if (k == -1)
			{
				I.MutatorName = NextDesc;
				I.HelpText = "";
			}
			else
			{
				I.MutatorName = Left(NextDesc, k);
				I.HelpText = Mid(NextDesc, k+1);
			}
		}
	}

	UpdateMutators();
}

function SaveConfigs()
{
	local UMenuMutatorList I;
	local string ML;

	Super.SaveConfigs();

	for (I = UMenuMutatorList(Include.Items.Next); I != None; I = UMenuMutatorList(I.Next))
	{
		if( ML=="" )
			ML = I.MutatorClass;
		else
			ML = ML $ "," $I.MutatorClass;
	}
	Default.MutatorList = ML;
	StaticSaveConfig();
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if( E==DE_Change && C==KeepCheck )
	{
		bKeepMutators = KeepCheck.bChecked;
		Default.bKeepMutators = bKeepMutators;
	}
}

defaultproperties
{
	ExcludeCaption="Mutators not Used"
	ExcludeHelp="Click and drag a mutator to the right hand column to include that mutator in this game."
	IncludeCaption="Mutators Used"
	IncludeHelp="Click and drag a mutator to the left hand column to remove it from the mutator list, or drag it up or down to re-order it in the mutator list."
	KeepText="Always use this Mutator configuration"
	KeepHelp="If checked, these Mutators will always be used when starting games."
	MutatorBaseClass="Engine.Mutator"
}
