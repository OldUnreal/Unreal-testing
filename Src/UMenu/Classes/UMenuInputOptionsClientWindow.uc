class UMenuInputOptionsClientWindow extends UMenuPageWindow;

// Auto Aim
var UWindowCheckbox AutoAimCheck;
var localized string AutoAimText;
var localized string AutoAimHelp;

// Joystick
var UWindowCheckbox JoystickCheck;
var localized string JoystickText;
var localized string JoystickHelp;

// RawHIDInput
var UWindowCheckbox RawHIDInputCheck;
var localized string RawHIDInputText;
var localized string RawHIDInputHelp;
var UWindowMessageBox ConfirmRawHidRestart;
var localized string ConfirmRawHIDRestartTitle;
var localized string ConfirmRawHIDText;

// Invert Mouse
var UWindowCheckbox InvertMouseCheck;
var localized string InvertMouseText;
var localized string InvertMouseHelp;

// Look Spring
var UWindowCheckbox LookSpringCheck;
var localized string LookSpringText;
var localized string LookSpringHelp;

// Always Mouselook
var UWindowCheckbox MouseLookCheck;
var localized string MouselookText;
var localized string MouselookHelp;

// Mouse Smoothing
var UWindowCheckbox MouseSmoothCheck;
var localized string MouseSmoothText;
var localized string MouseSmoothHelp;

// Max Smoothing
var UWindowCheckbox bMouseSmoothCheck;
var localized string bMouseSmoothText;
var localized string bMouseSmoothHelp;

// Auto Slope
var UWindowCheckbox AutoSlopeCheck;
var localized string AutoSlopeText;
var localized string AutoSlopeHelp;

// Dodging
var UWindowCheckbox DodgingCheck;
var localized string DodgingText;
var localized string DodgingHelp;

// Mouse Sensitivity
var UWindowEditControl SensitivityEdit;
var localized string SensitivityText;
var localized string SensitivityHelp;

// Dodge Click Time
var UWindowEditControl DodgeClickTimeEdit;
var localized string DodgeClickTimeText;
var localized string DodgeClickTimeHelp;

var bool bInitialized;
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

	// Joystick
	JoystickCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	JoystickCheck.SetText(JoystickText);
	JoystickCheck.SetHelpText(JoystickHelp);
	JoystickCheck.SetFont(F_Normal);
	JoystickCheck.Align = TA_Right;

	// Auto Aim
	AutoAimCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	AutoAimCheck.SetText(AutoAimText);
	AutoAimCheck.SetHelpText(AutoAimHelp);
	AutoAimCheck.SetFont(F_Normal);
	AutoAimCheck.Align = TA_Right;
	ControlOffset += 25;

	// RawHIDInput
	RawHIDInputCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	RawHIDInputCheck.SetText(RawHIDInputText);
	RawHIDInputCheck.SetHelpText(RawHIDInputHelp);
	RawHIDInputCheck.SetFont(F_Normal);
	RawHIDInputCheck.Align = TA_Right;

	// Look Spring
	LookSpringCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	LookSpringCheck.SetText(LookSpringText);
	LookSpringCheck.SetHelpText(LookSpringHelp);
	LookSpringCheck.SetFont(F_Normal);
	LookSpringCheck.Align = TA_Right;
	ControlOffset += 25;

	// Always Mouselook
	MouseLookCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	MouseLookCheck.SetText(MouselookText);
	MouseLookCheck.SetHelpText(MouselookHelp);
	MouseLookCheck.SetFont(F_Normal);
	MouseLookCheck.Align = TA_Right;

	// Auto Slope
	AutoSlopeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	AutoSlopeCheck.SetText(AutoSlopeText);
	AutoSlopeCheck.SetHelpText(AutoSlopeHelp);
	AutoSlopeCheck.SetFont(F_Normal);
	AutoSlopeCheck.Align = TA_Right;
	ControlOffset += 25;

	// Enable Mouse Smoothing
	bMouseSmoothCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	bMouseSmoothCheck.SetText(bMouseSmoothText);
	bMouseSmoothCheck.SetHelpText(bMouseSmoothHelp);
	bMouseSmoothCheck.SetFont(F_Normal);
	bMouseSmoothCheck.Align = TA_Right;

	// Invert Mouse
	InvertMouseCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	InvertMouseCheck.SetText(InvertMouseText);
	InvertMouseCheck.SetHelpText(InvertMouseHelp);
	InvertMouseCheck.SetFont(F_Normal);
	InvertMouseCheck.Align = TA_Right;
	ControlOffset += 25;

	// Max Mouse Smoothing
	MouseSmoothCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	MouseSmoothCheck.SetText(MouseSmoothText);
	MouseSmoothCheck.SetHelpText(MouseSmoothHelp);
	MouseSmoothCheck.SetFont(F_Normal);
	MouseSmoothCheck.Align = TA_Right;

	DodgingCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlRight, ControlOffset, ControlWidth, 1));
	DodgingCheck.SetText(DodgingText);
	DodgingCheck.SetHelpText(DodgingHelp);
	DodgingCheck.SetFont(F_Normal);
	DodgingCheck.Align = TA_Right;
	ControlOffset += 25;

	ControlOffset += 10;

	// Mouse Sensitivity
	SensitivityEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SensitivityEdit.SetText(SensitivityText);
	SensitivityEdit.SetHelpText(SensitivityHelp);
	SensitivityEdit.SetFont(F_Normal);
	SensitivityEdit.SetNumericOnly(True);
	SensitivityEdit.SetNumericFloat(True);
	SensitivityEdit.SetMaxLength(5);
	SensitivityEdit.Align = TA_Left;
	ControlOffset += 25;

	// Dodge Click Time
	DodgeClickTimeEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	DodgeClickTimeEdit.SetText(DodgeClickTimeText);
	DodgeClickTimeEdit.SetHelpText(DodgeClickTimeHelp);
	DodgeClickTimeEdit.SetFont(F_Normal);
	DodgeClickTimeEdit.SetNumericOnly(True);
	DodgeClickTimeEdit.SetNumericFloat(True);
	DodgeClickTimeEdit.SetMaxLength(5);
	DodgeClickTimeEdit.Align = TA_Left;

	TabLast = JoystickCheck;
	ActiveWindow = TabLast;

	LoadAvailableSettings();
}

function WindowShown()
{
	super.WindowShown();
	LoadAvailableSettings();
}

function LoadAvailableSettings()
{
	local PlayerPawn P;
	local string ViewportManager, S;
	local int i;

	bInitialized = false;
	P = GetPlayerOwner();

	ViewportManager = P.ConsoleCommand("get ini:Engine.Engine.ViewportManager Class");
	if (!Divide(ViewportManager, "'", S, ViewportManager) || !Divide(ViewportManager, "'", ViewportManager, S))
		ViewportManager = "";

	JoystickCheck.bDisabled = BoolProperty(FindObj(class'Property', ViewportManager $ ".UseJoystick")) == none;
	JoystickCheck.bChecked = !JoystickCheck.bDisabled && bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseJoystick"));
	AutoAimCheck.bChecked = P.MyAutoAim < 1.0;
	RawHIDInputCheck.bDisabled = BoolProperty(FindObj(class'Property', ViewportManager $ ".UseRawHIDInput")) == none;
	RawHIDInputCheck.bChecked = !RawHIDInputCheck.bDisabled && bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseRawHIDInput"));
	LookSpringCheck.bChecked = P.bSnapToLevel;
	MouseLookCheck.bChecked = P.bAlwaysMouseLook;
	AutoSlopeCheck.bChecked = P.bLookUpStairs;
	bMouseSmoothCheck.bChecked = P.bMouseSmoothing;
	InvertMouseCheck.bChecked = P.bInvertMouse;
	MouseSmoothCheck.bChecked = P.bMaxMouseSmoothing;
	DodgingCheck.bChecked = P.DodgeClickTime > 0;

	S = string(P.MouseSensitivity);
	i = InStr(S, ".");
	if (i < 4)
		S = Left(S, 5);
	else
		S = Left(S, i);
	SensitivityEdit.SetValue(S);

	S = string(Abs(P.DodgeClickTime));
	i = InStr(S, ".");
	if (i < 4)
		S = Left(S, 5);
	else
		S = Left(S, i);
	DodgeClickTimeEdit.SetValue(S);

	bInitialized = true;
}

function AfterCreate()
{
	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int CheckboxWidth, CheckboxLeft, CheckboxRight;
	local float EditLabelTextAreaWidth, EditControlLeft, EditControlWidth, EditBoxWidth;

	CheckboxWidth = WinWidth/2.5;
	CheckboxLeft = (WinWidth/2 - CheckboxWidth)/2;
	CheckboxRight = WinWidth/2 + CheckboxLeft;
	EditBoxWidth = 36;

	AutoAimCheck.AutoWidth(C);
	AutoAimCheck.WinLeft = CheckboxRight;

	JoystickCheck.AutoWidth(C);
	JoystickCheck.WinLeft = CheckboxLeft;

	InvertMouseCheck.AutoWidth(C);
	InvertMouseCheck.WinLeft = CheckboxRight;

	RawHIDInputCheck.AutoWidth(C);
	RawHIDInputCheck.WinLeft = CheckboxLeft;

	LookSpringCheck.AutoWidth(C);
	LookSpringCheck.WinLeft = CheckboxRight;

	MouseLookCheck.AutoWidth(C);
	MouseLookCheck.WinLeft = CheckboxLeft;

	AutoSlopeCheck.AutoWidth(C);
	AutoSlopeCheck.WinLeft = CheckboxRight;

	MouseSmoothCheck.AutoWidth(C);
	MouseSmoothCheck.WinLeft = CheckboxLeft;

	bMouseSmoothCheck.AutoWidth(C);
	bMouseSmoothCheck.WinLeft = CheckboxLeft;

	DodgingCheck.AutoWidth(C);
	DodgingCheck.WinLeft = CheckboxRight;

	SensitivityEdit.GetMinTextAreaWidth(C, EditLabelTextAreaWidth);
	DodgeClickTimeEdit.GetMinTextAreaWidth(C, EditLabelTextAreaWidth);
	EditControlWidth = EditLabelTextAreaWidth + SensitivityEdit.DesiredTextOffset + EditBoxWidth;
	EditControlLeft = CheckboxRight - (EditControlWidth - EditBoxWidth);

	SensitivityEdit.SetSize(EditControlWidth, 1);
	SensitivityEdit.WinLeft = EditControlLeft;
	SensitivityEdit.EditBoxWidth = EditBoxWidth;

	DodgeClickTimeEdit.SetSize(EditControlWidth, 1);
	DodgeClickTimeEdit.WinLeft = EditControlLeft;
	DodgeClickTimeEdit.EditBoxWidth = EditBoxWidth;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch (E)
	{
	case DE_Change:
		if (!bInitialized)
			break;
		switch (C)
		{
		case AutoAimCheck:
			AutoAimChecked();
			break;
		case JoystickCheck:
			JoystickChecked();
			break;
		case RawHIDInputCheck:
			RawHIDInputChecked();
			break;
		case InvertMouseCheck:
			InvertMouseChecked();
			break;
		case LookSpringCheck:
			LookSpringChecked();
			break;
		case MouseLookCheck:
			MouseLookChecked();
			break;
		case AutoSlopeCheck:
			AutoSlopeChecked();
			break;
		case MouseSmoothCheck:
			MouseSmoothChanged();
			break;
		case bMouseSmoothCheck:
			bMouseSmoothChanged();
			break;
		case DodgingCheck:
			DodgingChanged();
			break;
		case SensitivityEdit:
			SensitivityChanged();
			break;
		case DodgeClickTimeEdit:
			DodgeClickTimeChanged();
			break;
		}
	}
}

/*
 * Message Crackers
 */

function AutoAimChecked()
{
	if (AutoAimCheck.bChecked)
		GetPlayerOwner().ChangeAutoAim(0.93);
	else
		GetPlayerOwner().ChangeAutoAim(1.0);
}

function JoystickChecked()
{
	if (JoystickCheck.bDisabled)
		JoystickCheck.bChecked = false;
	else
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager UseJoystick" @ JoystickCheck.bChecked);
}

function RawHIDInputChecked()
{
	if (RawHIDInputCheck.bDisabled)
		RawHIDInputCheck.bChecked = false;
	else
		RawHIDChange();
}

function InvertMouseChecked()
{
	GetPlayerOwner().bInvertMouse = InvertMouseCheck.bChecked;
}

function LookSpringChecked()
{
	GetPlayerOwner().bSnapToLevel = LookSpringCheck.bChecked;
}

function MouseLookChecked()
{
	GetPlayerOwner().bAlwaysMouseLook = MouseLookCheck.bChecked;
}

function AutoSlopeChecked()
{
	GetPlayerOwner().bLookUpStairs = AutoSlopeCheck.bChecked;
}

function MouseSmoothChanged()
{
	GetPlayerOwner().bMaxMouseSmoothing = MouseSmoothCheck.bChecked;
}
function bMouseSmoothChanged()
{
	GetPlayerOwner().bMouseSmoothing = bMouseSmoothCheck.bChecked;
}

function DodgingChanged()
{
	local PlayerPawn P;
	local string S;
	local int i;

	P = GetPlayerOwner();
	if (DodgingCheck.bChecked && P.DodgeClickTime == 0)
		P.ChangeDodgeClickTime(0.25);
	else if (DodgingCheck.bChecked != (P.DodgeClickTime > 0))
		P.ChangeDodgeClickTime(-P.DodgeClickTime);

	S = string(Abs(P.DodgeClickTime));
	i = InStr(S, ".");
	if (i < 4)
		S = Left(S, 5);
	else
		S = Left(S, i);
	DodgeClickTimeEdit.EditBox.Value = S;
}

function SensitivityChanged()
{
	GetPlayerOwner().MouseSensitivity = float(SensitivityEdit.EditBox.Value);
}

function DodgeClickTimeChanged()
{
	GetPlayerOwner().ChangeDodgeClickTime(float(DodgeClickTimeEdit.EditBox.Value));
	DodgingCheck.bChecked = (GetPlayerOwner().DodgeClickTime > 0);
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	Super.SaveConfigs();
}

function RawHIDChange()
{
	ConfirmRawHIDRestart = MessageBox(ConfirmRawHIDRestartTitle, ConfirmRawHIDText, MB_YesNo, MR_No);
}
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if (W == ConfirmRawHIDRestart)
	{
		ConfirmRawHIDRestart = None;
		if (Result == MR_Yes)
		{
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager UseRawHIDInput" @ RawHIDInputCheck.bChecked);
			GetPlayerOwner().ConsoleCommand("RELAUNCH");
		}
		else 
			RawHIDInputCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.ViewportManager UseRawHIDInput"));
	}
}

defaultproperties
{
	AutoAimText="Auto Aim"
	AutoAimHelp="Enable or disable vertical aiming help."
	JoystickText="Joystick"
	JoystickHelp="Enable or disable joystick."
	RawHIDInputText="RawHIDInput"
	RawHIDInputHelp="Enabling RawHIDInput on Windows machines will improve mouse smoothness and is not affected by mouse acceleration.  The game is restarted for this setting to take effect."
	ConfirmRawHIDRestartTitle="Confirm RawHID Restart"
	ConfirmRawHIDText="This option will restart Unreal now to enable/disable RawHIDInput"
	InvertMouseText="Invert Mouse"
	InvertMouseHelp="Invert the mouse X axis.  When true, pushing the mouse forward causes you to look down rather than up."
	LookSpringText="Look Spring"
	LookSpringHelp="If checked, releasing the mouselook key will automatically center the view. Only valid if Mouselook is disabled."
	MouselookText="Mouselook"
	MouselookHelp="If checked, the mouse is always used for controlling your view direction."
	MouseSmoothText="Max Smoothing"
	MouseSmoothHelp="If checked, mouse input will be smoothed more to improve Mouselook smoothness."
	bMouseSmoothText="Mouse Smoothing"
	bMouseSmoothHelp="If checked, mouse input will be smoothed to improve Mouselook smoothness."
	AutoSlopeText="Auto Slope"
	AutoSlopeHelp="If checked, your view will automatically adjust to look up and down slopes and stairs. Only valid if Mouselook is disabled."
	DodgingText="Dodging"
	DodgingHelp="If checked, double tapping the movement keys (forward, back, and strafe left or right) will result in a fast dodge move."
	SensitivityText="Mouse Sensitivity"
	SensitivityHelp="Adjust the mouse sensitivity, or how far you have to move the mouse to produce a given motion in the game."
	DodgeClickTimeText="Dodge Click Time"
	DodgeClickTimeHelp="Maximal double click interval in seconds for dodge move."
	ControlOffset=20.000000
}
