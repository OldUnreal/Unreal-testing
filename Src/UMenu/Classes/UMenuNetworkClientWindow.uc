class UMenuNetworkClientWindow extends UMenuPageWindow;

var localized int EditAreaWidth; // Maximal width of a control that indicates a modifiable value

// NetSpeed
var UWindowComboControl NetSpeedCombo;
var localized string NetSpeedText;
var localized string NetSpeedHelp;
var localized string NetSpeeds[5];
var int NetSpeedValues[5];

// Custom NetSpeed
var UWindowEditControl NetSpeedEditBox;
var localized string CNetSpeedText;
var localized string CNetSpeedHelp;

var bool bInitialized;

var config bool bShownWindow;

var float ControlOffset;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int i;

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
	for( i=0; i<ArrayCount(NetSpeeds); ++i )
		NetSpeedCombo.AddItem(string(NetSpeedValues[i])@NetSpeeds[i]);
	NetSpeedCombo.AddItem(CNetSpeedText);
	ControlOffset += 25;
	
	// Custom NetSpeed
	NetSpeedEditBox = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	NetSpeedEditBox.SetText(CNetSpeedText);
	NetSpeedEditBox.SetHelpText(CNetSpeedHelp);
	NetSpeedEditBox.SetFont(F_Normal);
	NetSpeedEditBox.SetNumericOnly(true);
	NetSpeedEditBox.SetNumericFloat(false);
	NetSpeedEditBox.Align = TA_Left;
	ControlOffset+=25;
}

function WindowShown()
{
	super.WindowShown();
	LoadAvailableSettings();
}

function LoadAvailableSettings()
{
	local int i;

	bInitialized = false;

	for( i=0; i<ArrayCount(NetSpeeds); ++i )
	{
		if( NetSpeedValues[i]==Class'PlayerPawn'.Default.NetSpeed )
		{
			NetSpeedCombo.SetSelectedIndex(i);
			break;
		}
	}
	if( i==ArrayCount(NetSpeeds) )
		NetSpeedCombo.SetSelectedIndex(ArrayCount(NetSpeeds));
	NetSpeedEditBox.SetDisabled(NetSpeedCombo.GetSelectedIndex()!=ArrayCount(NetSpeeds));
	NetSpeedEditBox.SetValue(string(Class'PlayerPawn'.Default.NetSpeed));
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
	NetSpeedEditBox.GetMinTextAreaWidth(C, LabelTextAreaWidth);
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
	
	NetSpeedEditBox.SetSize(ControlWidth, 1);
	NetSpeedEditBox.WinLeft = ControlLeft;
	NetSpeedEditBox.EditBoxWidth = EditAreaWidth;
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
		case NetSpeedEditBox:
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
	local int NewSpeed,i;

	if (!bInitialized)
		return;

	i = NetSpeedCombo.GetSelectedIndex();
	if( i==ArrayCount(NetSpeeds) )
	{
		if( NetSpeedEditBox.bDisabled )
			NetSpeedEditBox.SetDisabled(false);
		NewSpeed = int(NetSpeedEditBox.GetValue());
	}
	else
	{
		if( !NetSpeedEditBox.bDisabled )
			NetSpeedEditBox.SetDisabled(true);
		NewSpeed = NetSpeedValues[i];
	}
	GetPlayerOwner().ConsoleCommand("NETSPEED "$NewSpeed);
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
	NetSpeedValues(0)=2600
	NetSpeedValues(1)=5000
	NetSpeedValues(2)=10000
	NetSpeedValues(3)=20000
	NetSpeedValues(4)=50000
	
	CNetSpeedText="Custom"
	CNetSpeedHelp="Enter customized NetSpeed here."
	bShownWindow=True
	ControlOffset=20.000000
}
