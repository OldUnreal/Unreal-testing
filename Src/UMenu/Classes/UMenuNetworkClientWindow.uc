class UMenuNetworkClientWindow extends UMenuPageWindow;

var localized int EditAreaWidth; // Maximal width of a control that indicates a modifiable value

// NetSpeed
var UWindowComboControl NetSpeedCombo;
var localized string NetSpeedText;
var localized string NetSpeedHelp;
var localized string NetSpeeds[5];

var bool bInitialized;

var config bool bShownWindow;

var float ControlOffset;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	// Net Speed
	NetSpeedCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', CenterPos, ControlOffset, CenterWidth, 1));
	NetSpeedCombo.SetText(NetSpeedText);
	NetSpeedCombo.SetHelpText(NetSpeedHelp);
	NetSpeedCombo.SetFont(F_Normal);
	NetSpeedCombo.SetEditable(False);
	NetSpeedCombo.AddItem(2600 @ NetSpeeds[0]);
	NetSpeedCombo.AddItem(5000 @ NetSpeeds[1]);
	NetSpeedCombo.AddItem(10000 @ NetSpeeds[2]);
	NetSpeedCombo.AddItem(20000 @ NetSpeeds[3]);
	NetSpeedCombo.AddItem(50000 @ NetSpeeds[4]);
	ControlOffset += 25;
}

function WindowShown()
{
	super.WindowShown();
	LoadAvailableSettings();
}

function LoadAvailableSettings()
{
	bInitialized = false;

	if (Root.Console.ViewPort.Actor.NetSpeed >= 25000)
		NetSpeedCombo.SetSelectedIndex(4);
	else if (Root.Console.ViewPort.Actor.NetSpeed >= 12500)
		NetSpeedCombo.SetSelectedIndex(3);
	else if (Root.Console.ViewPort.Actor.NetSpeed >= 6000)
		NetSpeedCombo.SetSelectedIndex(2);
	else if (Root.Console.ViewPort.Actor.NetSpeed >= 4000)
		NetSpeedCombo.SetSelectedIndex(1);
	else
		NetSpeedCombo.SetSelectedIndex(0);

	NetSpeedCombo.EditBox.Value = Root.Console.ViewPort.Actor.NetSpeed @ NetSpeeds[NetSpeedCombo.GetSelectedIndex()];

	bInitialized = true;
}

function AfterCreate()
{
	Super.AfterCreate();
	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	NetSpeedCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft;
	local int LabelHSpacing, LabelAreaWidth, RightSpacing;
	local float LabelTextAreaWidth;

	Super.BeforePaint(C, X, Y);

	if (!bShownWindow)
	{
		bShownWindow = True;
		default.bShownWindow = True;
		SaveConfig();
	}

	LabelTextAreaWidth = 0;
	CalcLabelTextAreaWidth(C, LabelTextAreaWidth);

	LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth) / 3;
	RightSpacing = VScrollbarWidth() + 3;
	if (LabelHSpacing < RightSpacing)
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth - RightSpacing) / 2;
	LabelAreaWidth = LabelTextAreaWidth + LabelHSpacing;
	ControlWidth = LabelAreaWidth + EditAreaWidth;
	ControlLeft = LabelHSpacing;

	NetSpeedCombo.SetSize(ControlWidth, 1);
	NetSpeedCombo.WinLeft = ControlLeft;
	NetSpeedCombo.EditBoxWidth = EditAreaWidth;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case NetSpeedCombo:
			NetSpeedChanged();
			break;
		}
	}
}

/*
 * Message Crackers
 */

function NetSpeedChanged()
{
	local int NewSpeed;

	if (!bInitialized)
		return;

	switch (NetSpeedCombo.GetSelectedIndex())
	{
	case 0:
		NewSpeed = 2600;
		break;
	case 1:
		NewSpeed = 5000;
		break;
	case 2:
		NewSpeed = 10000;
		break;
	case 3:
		NewSpeed = 20000;
		break;
	case 4:
		NewSpeed = 50000;
		break;
	}
	GetPlayerOwner().ConsoleCommand("NETSPEED" @ NewSpeed);
	GetPlayerOwner().SaveConfig();
}

defaultproperties
{
	EditAreaWidth=130
	NetSpeedText="Internet Connection"
	NetSpeedHelp="Select the closest match to your internet connection. Try to change this setting if you're getting huge lag."
	NetSpeeds(0)="(Dial-Up Networking)"
	NetSpeeds(1)="(Dial-Up Networking)"
	NetSpeeds(2)="(Broadband)"
	NetSpeeds(3)="(Broadband)"
	NetSpeeds(4)="(LAN)"
	bShownWindow=True
	ControlOffset=20.000000
}
