class UnrealCreditsCW extends UMenuDialogClientWindow;

var UMenuLabelControl ProgrammersHeader;
var localized string ProgrammersText;
var UMenuLabelControl ProgrammerLabels[10];
var string ProgrammerNames[10];
var int MaxProgs;

var UMenuLabelControl LevelDesignHeader;
var localized string LevelDesignText;
var UMenuLabelControl DesignerLabels[10];
var string DesignerNames[10];
var int MaxDesigners;

var UMenuLabelControl ArtHeader;
var localized string ArtText;
var UMenuLabelControl ArtLabels[10];
var string ArtNames[10];
var int MaxArts;

var UMenuLabelControl MusicSoundHeader;
var localized string MusicSoundText;
var UMenuLabelControl MusicLabels[10];
var string MusicNames[10];
var int MaxMusics;

var UMenuLabelControl BizHeader;
var localized string BizText;
var UMenuLabelControl BizLabels[10];
var string BizNames[10];
var int MaxBiz;

var UMenuLabelControl PatchHeader;
var localized string PatchText;
var array<UMenuLabelControl> AllLabels;
var string PatchNames[10];
var int MaxPatch;

const TEXT_BASE_OFFSET = 25;
const TEXT_SECTION_OFFSET = 15;
const TEXT_LINE_HEIGHT = 10;

function Created()
{
	local int i, ControlOffset;
	local int CenterWidth, CenterPos;
	local Engine E;

	Super.Created();

	CenterWidth = (WinWidth*0.925);
	CenterPos = (WinWidth - CenterWidth)/2;

	// Left side
	ControlOffset = TEXT_BASE_OFFSET;
	ProgrammersHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	ProgrammersHeader.SetText(ProgrammersText);
	ProgrammersHeader.SetFont(F_Bold);
	ProgrammersHeader.Align = TA_Left;
	AllLabels.Add(ProgrammersHeader);
	for (i=0; i<MaxProgs; i++)
	{
		ControlOffset += TEXT_LINE_HEIGHT;
		ProgrammerLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		ProgrammerLabels[i].SetText(ProgrammerNames[i]);
		ProgrammerLabels[i].SetFont(F_Normal);
		ProgrammerLabels[i].Align = TA_Left;
		AllLabels.Add(ProgrammerLabels[i]);
	}
	
	ControlOffset += TEXT_SECTION_OFFSET;
	ArtHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	ArtHeader.SetText(ArtText);
	ArtHeader.SetFont(F_Bold);
	ArtHeader.Align = TA_Left;
	AllLabels.Add(ArtHeader);
	for (i=0; i<MaxArts; i++)
	{
		ControlOffset += TEXT_LINE_HEIGHT;
		ArtLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		ArtLabels[i].SetText(ArtNames[i]);
		ArtLabels[i].SetFont(F_Normal);
		ArtLabels[i].Align = TA_Left;
		AllLabels.Add(ArtLabels[i]);
	}
	
	ControlOffset += TEXT_SECTION_OFFSET;
	PatchHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	PatchHeader.SetText(PatchText);
	PatchHeader.SetFont(F_Bold);
	PatchHeader.Align = TA_Left;
	AllLabels.Add(PatchHeader);
	for (i=0; i<MaxPatch; i++)
	{
		ControlOffset += TEXT_LINE_HEIGHT;
		PatchHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		PatchHeader.SetText(PatchNames[i]);
		PatchHeader.SetFont(F_Normal);
		PatchHeader.Align = TA_Left;
		AllLabels.Add(PatchHeader);
	}
	E = GetEngine();
	for( i=0; i<E.DriverCredits.Size(); ++i )
	{
		ControlOffset += TEXT_LINE_HEIGHT;
		PatchHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		PatchHeader.SetText(E.DriverCredits[i].Credits);
		PatchHeader.SetFont(F_Normal);
		PatchHeader.Align = TA_Left;
		AllLabels.Add(PatchHeader);
	}
	
	// Right side
	ControlOffset = TEXT_BASE_OFFSET;
	LevelDesignHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	LevelDesignHeader.SetText(LevelDesignText);
	LevelDesignHeader.SetFont(F_Bold);
	LevelDesignHeader.Align = TA_Right;
	AllLabels.Add(LevelDesignHeader);
	for (i=0; i<MaxDesigners; i++)
	{
		ControlOffset += TEXT_LINE_HEIGHT;
		DesignerLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		DesignerLabels[i].SetText(DesignerNames[i]);
		DesignerLabels[i].SetFont(F_Normal);
		DesignerLabels[i].Align = TA_Right;
		AllLabels.Add(DesignerLabels[i]);
	}

	ControlOffset += TEXT_SECTION_OFFSET;
	MusicSoundHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	MusicSoundHeader.SetText(MusicSoundText);
	MusicSoundHeader.SetFont(F_Bold);
	MusicSoundHeader.Align = TA_Right;
	AllLabels.Add(MusicSoundHeader);
	for (i=0; i<MaxMusics; i++)
	{
		ControlOffset += TEXT_LINE_HEIGHT;
		MusicLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		MusicLabels[i].SetText(MusicNames[i]);
		MusicLabels[i].SetFont(F_Normal);
		MusicLabels[i].Align = TA_Right;
		AllLabels.Add(MusicLabels[i]);
	}
	
	ControlOffset += TEXT_SECTION_OFFSET;
	BizHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	BizHeader.SetText(BizText);
	BizHeader.SetFont(F_Bold);
	BizHeader.Align = TA_Right;
	AllLabels.Add(BizHeader);
	for (i=0; i<MaxBiz; i++)
	{
		ControlOffset += TEXT_LINE_HEIGHT;
		BizLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		BizLabels[i].SetText(BizNames[i]);
		BizLabels[i].SetFont(F_Normal);
		BizLabels[i].Align = TA_Right;
		AllLabels.Add(BizLabels[i]);
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int i;
	local int CenterWidth, CenterPos;

	Super.BeforePaint(C, X, Y);

	CenterWidth = (WinWidth*0.925);
	CenterPos = (WinWidth - CenterWidth)/2;

	for(i=(AllLabels.Size()-1); i>=0; --i )
	{
		AllLabels[i].SetSize(CenterWidth, 1);
		AllLabels[i].WinLeft = CenterPos;
	}
}

defaultproperties
{
	ProgrammersText="Programming"
	ProgrammerNames(0)="Erik de Neve"
	ProgrammerNames(1)="Steve Polge"
	ProgrammerNames(2)="Jack Porter"
	ProgrammerNames(3)="Brandon Reinhart"
	ProgrammerNames(4)="Tim Sweeney"
	ProgrammerNames(5)="Carlo Vogelsang"
	ProgrammerNames(6)="227: Jochen Goernitz"
	MaxProgs=7
	LevelDesignText="Level Design"
	DesignerNames(0)="Cliff Bleszinski"
	DesignerNames(1)="Elliot Cannon"
	DesignerNames(2)="Shane Caudle"
	DesignerNames(3)="Pancho Eekels"
	DesignerNames(4)="Dave Ewing"
	DesignerNames(5)="Cedric Fiorentino"
	DesignerNames(6)="Alan Willard"
	MaxDesigners=7
	ArtText="Art & Models"
	ArtNames(0)="Dave Carter"
	ArtNames(1)="Shane Caudle"
	ArtNames(2)="Pancho Eekels"
	ArtNames(3)="Steve Garofalo"
	ArtNames(4)="Mike Leatham"
	ArtNames(5)="Everton Richards"
	ArtNames(6)="Dan Sarkar"
	ArtNames(7)="James Schmalz"
	MaxArts=8
	MusicSoundText="Music & Sound"
	MusicNames(0)="Alexander Brandon"
	MusicNames(1)="Sascha Dikiciyan"
	MusicNames(2)="Dave Ewing"
	MusicNames(3)="Lani Minella"
	MusicNames(4)="Shannon Newans"
	MusicNames(5)="Michiel van den Bos"
	MaxMusics=6
	BizText="Biz"
	BizNames(0)="Mark Rein"
	BizNames(1)="Jay Wilbur"
	MaxBiz=2
	PatchNames(0)="www.oldunreal.com and Community"
	MaxPatch=1
}
