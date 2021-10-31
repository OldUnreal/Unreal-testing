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
var UMenuLabelControl PatchLabels[10];
var string PatchNames[10];
var int MaxPatch;

function Created()
{
	local int i;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;
	local float ControlOffset, BaseOffset;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ButtonWidth = WinWidth - 140;
	ButtonLeft = WinWidth - ButtonWidth - 40;

	ControlOffset = 25;
	ProgrammersHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	ProgrammersHeader.SetText(ProgrammersText);
	ProgrammersHeader.SetFont(F_Bold);
	ProgrammersHeader.Align = TA_Left;
	for (i=0; i<MaxProgs; i++)
	{
		ControlOffset += 10;
		ProgrammerLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		ProgrammerLabels[i].SetText(ProgrammerNames[i]);
		ProgrammerLabels[i].SetFont(F_Normal);
		ProgrammerLabels[i].Align = TA_Left;
	}

	ControlOffset = 25;
	LevelDesignHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	LevelDesignHeader.SetText(LevelDesignText);
	LevelDesignHeader.SetFont(F_Bold);
	LevelDesignHeader.Align = TA_Right;
	for (i=0; i<MaxDesigners; i++)
	{
		ControlOffset += 10;
		DesignerLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		DesignerLabels[i].SetText(DesignerNames[i]);
		DesignerLabels[i].SetFont(F_Normal);
		DesignerLabels[i].Align = TA_Right;
	}

	Controloffset += 25;
	BaseOffset = ControlOffset;
	ArtHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	ArtHeader.SetText(ArtText);
	ArtHeader.SetFont(F_Bold);
	ArtHeader.Align = TA_Left;
	for (i=0; i<MaxArts; i++)
	{
		ControlOffset += 10;
		ArtLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		ArtLabels[i].SetText(ArtNames[i]);
		ArtLabels[i].SetFont(F_Normal);
		ArtLabels[i].Align = TA_Left;
	}

	ControlOffset = BaseOffset;
	MusicSoundHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	MusicSoundHeader.SetText(MusicSoundText);
	MusicSoundHeader.SetFont(F_Bold);
	MusicSoundHeader.Align = TA_Right;
	for (i=0; i<MaxMusics; i++)
	{
		ControlOffset += 10;
		MusicLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		MusicLabels[i].SetText(MusicNames[i]);
		MusicLabels[i].SetFont(F_Normal);
		MusicLabels[i].Align = TA_Right;
	}
	ControlOffset += 25;

	BizHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	BizHeader.SetText(BizText);
	BizHeader.SetFont(F_Bold);
	BizHeader.Align = TA_Center;
	for (i=0; i<MaxBiz; i++)
	{
		ControlOffset += 10;
		BizLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		BizLabels[i].SetText(BizNames[i]);
		BizLabels[i].SetFont(F_Normal);
		BizLabels[i].Align = TA_Center;
	}
	
	ControlOffset += 25;

	PatchHeader = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
	PatchHeader.SetText(PatchText);
	PatchHeader.SetFont(F_Bold);
	PatchHeader.Align = TA_Center;
	for (i=0; i<MaxPatch; i++)
	{
		ControlOffset += 10;
		PatchLabels[i] = UMenuLabelControl(CreateWindow(class'UMenuLabelControl', CenterPos, ControlOffset, CenterWidth, 1));
		PatchLabels[i].SetText(PatchNames[i]);
		PatchLabels[i].SetFont(F_Normal);
		PatchLabels[i].Align = TA_Center;
	}	
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int i;
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ProgrammersHeader.SetSize(CenterWidth, 1);
	ProgrammersHeader.WinLeft = CenterPos;
	for (i=0; i<MaxProgs; i++)
	{
		ProgrammerLabels[i].SetSize(CenterWidth, 1);
		ProgrammerLabels[i].WinLeft = CenterPos;
	}

	LevelDesignHeader.SetSize(CenterWidth, 1);
	LevelDesignHeader.WinLeft = CenterPos;
	for (i=0; i<MaxDesigners; i++)
	{
		DesignerLabels[i].SetSize(CenterWidth, 1);
		DesignerLabels[i].WinLeft = CenterPos;
	}

	ArtHeader.SetSize(CenterWidth, 1);
	ArtHeader.WinLeft = CenterPos;
	for (i=0; i<MaxArts; i++)
	{
		ArtLabels[i].SetSize(CenterWidth, 1);
		ArtLabels[i].WinLeft = CenterPos;
	}

	MusicSoundHeader.SetSize(CenterWidth, 1);
	MusicSoundHeader.WinLeft = CenterPos;
	for (i=0; i<MaxMusics; i++)
	{
		MusicLabels[i].SetSize(CenterWidth, 1);
		MusicLabels[i].WinLeft = CenterPos;
	}

	BizHeader.SetSize(CenterWidth, 1);
	BizHeader.WinLeft = CenterPos;
	for (i=0; i<MaxBiz; i++)
	{
		BizLabels[i].SetSize(CenterWidth, 1);
		BizLabels[i].WinLeft = CenterPos;
	}
	
	PatchHeader.SetSize(CenterWidth, 1);
	PatchHeader.WinLeft = CenterPos;
	for (i=0; i<MaxPatch; i++)
	{
		PatchLabels[i].SetSize(CenterWidth, 1);
		PatchLabels[i].WinLeft = CenterPos;
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
	MusicNames(5)="Michiel Van De Bos"
	MaxMusics=6
	BizText="Biz"
	BizNames(0)="Mark Rein"
	BizNames(1)="Jay Wilbur"
	MaxBiz=2
	PatchNames(0)="www.oldunreal.com and Community"
	MaxPatch=1
}
