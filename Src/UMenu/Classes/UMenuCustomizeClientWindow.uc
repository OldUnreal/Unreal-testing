class UMenuCustomizeClientWindow extends UMenuPageWindow;

var localized int EditAreaWidth;  // Maximal width of a control that indicates a modifiable value

var localized string LocalizedKeyName[255];
var string RealKeyName[255];

var array<string> KeyAlias;
var UMenuRaisedButton SelectedButton;
var int Selection[2];
var bool bPolling, bErasing;
var localized string OrString;
var localized string CustomizeHelp;

var UWindowSmallButton DefaultsButton;
var localized string DefaultsText;
var localized string DefaultsHelp;

var UMenuLabelControl JoystickHeading;
var localized string JoystickText;

var UWindowComboControl JoyXCombo;
var localized string JoyXText;
var localized string JoyXHelp;
var localized string JoyXOptions[2];
var string JoyXBinding[2];

var UWindowComboControl JoyYCombo;
var localized string JoyYText;
var localized string JoyYHelp;
var localized string JoyYOptions[2];
var string JoyYBinding[2];

var bool bLoadedExisting;
var bool bJoystick;
var float JoyDesiredHeight, NoJoyDesiredHeight;

// 227g: update keys menu
struct FKeyEntry
{
	var UMenuLabelControl KeyName;
	var UMenuRaisedButton KeyButton;
	var string AliasString;
	var int BoundKey1, BoundKey2;
};
struct FKeyGroupType
{
	var UMenuLabelControl LabelText;
	var string GroupName;
	var int NumKeys;
	var array<FKeyEntry> Keys;
};
var array<FKeyGroupType> KeyGroups;
var int NumGroups;

var int ConsoleButtonGroupIdx, ConsoleButtonKeyIdx;
var int ConsoleCharacterGroupIdx, ConsoleCharacterKeyIdx;
var int LastKeyDown;
var float MouseWheelBindingTimestamp;

final function bool KeyIsThere( string KeyName )
{
	local int i,j,c;

	for( i=0; i<NumGroups; i++ )
	{
		c = KeyGroups[i].NumKeys;
		for( j=0; j<c; j++ )
			if( KeyGroups[i].Keys[j].AliasString~=KeyName )
				return true;
	}
	return false;
}
function Created()
{
	local int ButtonWidth, ButtonLeft, ButtonTop, i, GroupIdx;
	local int LabelWidth, LabelLeft;
	local string E, Desc, GroupN;
	local PlayerPawn PP;
	local UMenuLabelControl NewLabel;
	local UMenuRaisedButton NewButton;

	bIgnoreLDoubleClick = True;
	bIgnoreMDoubleClick = True;
	bIgnoreRDoubleClick = True;

	PP = GetPlayerOwner();
	bJoystick =	bool(PP.ConsoleCommand("get windrv.windowsclient usejoystick"));

	Super.Created();

	SetAcceptsFocus();

	LabelWidth = 10;
	LabelLeft = (WinWidth - LabelWidth - EditAreaWidth) / 2;

	ButtonWidth = EditAreaWidth;
	ButtonLeft = LabelLeft + LabelWidth;

	// Defaults Button
	DefaultsButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 30, 10, 48, 16));
	DefaultsButton.SetText(DefaultsText);
	DefaultsButton.SetFont(F_Normal);
	DefaultsButton.SetHelpText(DefaultsHelp);

	ButtonTop = 25;

	// Setup none group
	KeyGroups[0].GroupName = "None";
	NumGroups = 1;

	ConsoleButtonGroupIdx = -1;
	ConsoleCharacterGroupIdx = -1;

	foreach PP.IntDescIterator(string(Class'Input'), E, Desc, true)
	{
		if( Len(E)==0 )
			continue;
		NewLabel = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, 0, LabelWidth, 1));
		NewButton = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, 0, ButtonWidth, 1));
		GroupIdx = 0;
		i = InStr(Desc, ",");
		if (i < 0)
		{
			KeyGroups[0].Keys[KeyGroups[0].NumKeys].KeyName = NewLabel;
			KeyGroups[0].Keys[KeyGroups[0].NumKeys].KeyButton = NewButton;
			KeyGroups[0].Keys[KeyGroups[0].NumKeys].AliasString = E;
			KeyGroups[0].NumKeys++;
		}
		else
		{
			GroupN = Left(Desc, i);
			Desc = Mid(Desc, i + 1);
			for (GroupIdx = 1; GroupIdx < NumGroups; ++GroupIdx)
				if (KeyGroups[GroupIdx].GroupName ~= GroupN)
					break;
			if (GroupIdx == NumGroups)
			{
				KeyGroups[GroupIdx].LabelText = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, 0, LabelWidth, 1));
				KeyGroups[GroupIdx].LabelText.SetText(GroupN);
				KeyGroups[GroupIdx].LabelText.SetFont(F_Bold);
				KeyGroups[GroupIdx].GroupName = GroupN;
				KeyGroups[GroupIdx].NumKeys = 0;
				NumGroups++;
			}
			KeyGroups[GroupIdx].Keys[KeyGroups[GroupIdx].NumKeys].KeyName = NewLabel;
			KeyGroups[GroupIdx].Keys[KeyGroups[GroupIdx].NumKeys].KeyButton = NewButton;
			KeyGroups[GroupIdx].Keys[KeyGroups[GroupIdx].NumKeys].AliasString = E;
			KeyGroups[GroupIdx].NumKeys++;
		}
		if (E ~= "ConsoleKey")
		{
			ConsoleButtonGroupIdx = GroupIdx;
			ConsoleButtonKeyIdx = KeyGroups[GroupIdx].NumKeys - 1;
		}
		else if (E ~= "ConsoleKeyChar")
		{
			ConsoleCharacterGroupIdx = GroupIdx;
			ConsoleCharacterKeyIdx = KeyGroups[GroupIdx].NumKeys - 1;
		}
		NewLabel.SetText(Desc);
		NewLabel.SetHelpText(CustomizeHelp);
		NewLabel.SetFont(F_Normal);
		NewLabel.bNotifyMouseClicks = true;
		NewButton.SetHelpText(CustomizeHelp);
		NewButton.bAcceptsFocus = False;
		NewButton.bIgnoreLDoubleClick = True;
		NewButton.bIgnoreMDoubleClick = True;
		NewButton.bIgnoreRDoubleClick = True;
	}
	SetButtonsHeight(ButtonTop);

	NoJoyDesiredHeight = ButtonTop + 10;

	// Joystick
	ButtonTop += 10;
	JoystickHeading = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, ButtonTop+3, WinWidth, 1));
	JoystickHeading.SetText(JoystickText);
	JoystickHeading.SetFont(F_Bold);
	ButtonTop += 19;

	JoyXCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', LabelLeft, ButtonTop, WinWidth - 2 * LabelLeft, 1));
	JoyXCombo.CancelAcceptsFocus();
	JoyXCombo.SetText(JoyXText);
	JoyXCombo.SetHelpText(JoyXHelp);
	JoyXCombo.SetFont(F_Normal);
	JoyXCombo.SetEditable(False);
	JoyXCombo.AddItem(JoyXOptions[0]);
	JoyXCombo.AddItem(JoyXOptions[1]);
	JoyXCombo.EditBoxWidth = ButtonWidth;
	ButtonTop += 20;

	JoyYCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', LabelLeft, ButtonTop, WinWidth - 2 * LabelLeft, 1));
	JoyYCombo.CancelAcceptsFocus();
	JoyYCombo.SetText(JoyYText);
	JoyYCombo.SetHelpText(JoyYHelp);
	JoyYCombo.SetFont(F_Normal);
	JoyYCombo.SetEditable(False);
	JoyYCombo.AddItem(JoyYOptions[0]);
	JoyYCombo.AddItem(JoyYOptions[1]);
	JoyYCombo.EditBoxWidth = ButtonWidth;
	ButtonTop += 20;

	DesiredWidth = 220;
	JoyDesiredHeight = ButtonTop + 10;
	DesiredHeight = JoyDesiredHeight;
}

// Init buttons heightmaps
final function SetButtonsHeight( out int YOffset )
{
	local int i,j;

	for( i=0; i<NumGroups; i++ )
	{
		if( KeyGroups[i].LabelText!=None )
		{
			KeyGroups[i].LabelText.WinTop = YOffset+2;
			YOffset+=19;
		}
		for( j=0; j<KeyGroups[i].NumKeys; j++ )
		{
			KeyGroups[i].Keys[j].KeyName.WinTop = YOffset+3;
			KeyGroups[i].Keys[j].KeyButton.WinTop = YOffset;
			YOffset+=19;
		}
	}
}

function WindowShown()
{
	Super.WindowShown();
	bJoystick =	bool(GetPlayerOwner().ConsoleCommand("get windrv.windowsclient usejoystick"));
	LoadExistingKeys();
}

final function LoadExistingKeys()
{
	local int i, j, pos, Z;
	local string KeyName;
	local string Alias;

	for (i=0; i<NumGroups; i++)
	{
		for( j=0; j<KeyGroups[i].NumKeys; j++ )
		{
			KeyGroups[i].Keys[j].BoundKey1 = 0;
			KeyGroups[i].Keys[j].BoundKey2 = 0;
		}
	}

	for (i=0; i<255; i++)
	{
		KeyName = GetPlayerOwner().ConsoleCommand( "KEYNAME "$i );
		RealKeyName[i] = KeyName;
		if ( KeyName != "" )
		{
			Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING "$KeyName );
			if ( Alias != "" )
			{
				pos = InStr(Alias, " ");
				if ( pos != -1 )
				{
					if ( !(Left(Alias, pos) ~= "taunt") &&
					        !(Left(Alias, pos) ~= "getweapon") &&
					        !(Left(Alias, pos) ~= "viewplayernum") &&
					        !(Left(Alias, pos) ~= "button") &&
					        !(Left(Alias, pos) ~= "mutate"))
						Alias = Left(Alias, pos);
				}
				for (J=0; J<NumGroups; J++)
				{
					for( z=0; z<KeyGroups[j].NumKeys; z++ )
					{
						if ( KeyGroups[j].Keys[z].AliasString ~= Alias )
						{
							if ( KeyGroups[j].Keys[z].BoundKey1 == 0 )
								KeyGroups[j].Keys[z].BoundKey1 = i;
							else if ( KeyGroups[j].Keys[z].BoundKey2 == 0)
								KeyGroups[j].Keys[z].BoundKey2 = i;
						}
					}
				}
			}
		}
	}

	if (ConsoleButtonGroupIdx >= 0 && Root != none && Root.Console != none)
	{
		KeyGroups[ConsoleButtonGroupIdx].Keys[ConsoleButtonKeyIdx].BoundKey1 = Clamp(Root.Console.GlobalConsoleKey, 0, 255);
		KeyGroups[ConsoleButtonGroupIdx].Keys[ConsoleButtonKeyIdx].BoundKey2 = 0;
	}
	if (ConsoleCharacterGroupIdx >= 0 && Root != none && Root.Console != none)
	{
		if (Root.Console.GlobalConsoleKey > 0)
			KeyGroups[ConsoleCharacterGroupIdx].Keys[ConsoleCharacterKeyIdx].BoundKey1 = 0;
		else
			KeyGroups[ConsoleCharacterGroupIdx].Keys[ConsoleCharacterKeyIdx].BoundKey1 = -Clamp(Root.Console.ConsoleKeyChar, 0, 65535);
		KeyGroups[ConsoleCharacterGroupIdx].Keys[ConsoleCharacterKeyIdx].BoundKey2 = 0;
	}

	bLoadedExisting = False;
	Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING JoyX" );
	if (Alias ~= JoyXBinding[0])
		JoyXCombo.SetSelectedIndex(0);
	if (Alias ~= JoyXBinding[1])
		JoyXCombo.SetSelectedIndex(1);

	Alias = GetPlayerOwner().ConsoleCommand( "KEYBINDING JoyY" );
	if (Alias ~= JoyYBinding[0])
		JoyYCombo.SetSelectedIndex(0);
	if (Alias ~= JoyYBinding[1])
		JoyYCombo.SetSelectedIndex(1);
	bLoadedExisting = True;
}

function CalcLabelTextAreaWidth(Canvas C, out float LabelTextAreaWidth)
{
	local int i, j;

	for (i = 0; i < NumGroups; ++i)
		for (j = 0; j < KeyGroups[i].NumKeys; ++j)
			KeyGroups[i].Keys[j].KeyName.GetMinTextAreaWidth(C, LabelTextAreaWidth);

	// NOTE: affects layout even when hidden
	JoyXCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	JoyYCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, i, j;
	local int LabelWidth, LabelHSpacing, RightSpacing;
	local float LabelTextAreaWidth, ControlWidth;
	local string KeyStr;

	LabelTextAreaWidth = 0;
	CalcLabelTextAreaWidth(C, LabelTextAreaWidth);

	LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth) / 3;
	RightSpacing = VScrollbarWidth() + 3;
	if (LabelHSpacing < RightSpacing)
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth - RightSpacing) / 2;
	LabelWidth = LabelTextAreaWidth + LabelHSpacing;
	ControlWidth = LabelWidth + EditAreaWidth;

	ButtonWidth = EditAreaWidth;
	ButtonLeft = LabelHSpacing + LabelWidth;

	DefaultsButton.AutoWidth(C);
	DefaultsButton.WinLeft = ButtonLeft + ButtonWidth - DefaultsButton.WinWidth;

	if (bJoystick)
	{
		DesiredHeight = JoyDesiredHeight;

		JoystickHeading.ShowWindow();
		JoyXCombo.ShowWindow();
		JoyYCombo.ShowWindow();

		JoystickHeading.WinLeft = LabelHSpacing;
		JoyXCombo.WinLeft = LabelHSpacing;
		JoyYCombo.WinLeft = LabelHSpacing;

		JoyXCombo.SetSize(ControlWidth, 1);
		JoyXCombo.EditBoxWidth = ButtonWidth;

		JoyYCombo.SetSize(ControlWidth, 1);
		JoyYCombo.EditBoxWidth = ButtonWidth;
	}
	else
	{
		DesiredHeight = NoJoyDesiredHeight;

		JoystickHeading.HideWindow();
		JoyXCombo.HideWindow();
		JoyYCombo.HideWindow();
	}

	for (i=0; i<NumGroups; i++)
	{
		if( KeyGroups[i].LabelText!=None )
		{
			KeyGroups[i].LabelText.WinLeft = LabelHSpacing;
			KeyGroups[i].LabelText.SetSize(WinWidth - 2 * LabelHSpacing, 1);
		}
		for( j=0; j<KeyGroups[i].NumKeys; j++ )
		{
			KeyGroups[i].Keys[j].KeyButton.SetSize(ButtonWidth, 1);
			KeyGroups[i].Keys[j].KeyButton.WinLeft = ButtonLeft;
			KeyStr = "";

			if (!bPolling || !bErasing || Selection[0] != i || Selection[1] != j)
			{
				if (KeyGroups[i].Keys[j].BoundKey1 > 0)
					KeyStr = LocalizedKeyName[KeyGroups[i].Keys[j].BoundKey1];
				else if (KeyGroups[i].Keys[j].BoundKey1 < 0)
					KeyStr = Chr(-KeyGroups[i].Keys[j].BoundKey1) @ "(" $ -KeyGroups[i].Keys[j].BoundKey1 $ ")";

				if (KeyGroups[i].Keys[j].BoundKey1 != 0 && KeyGroups[i].Keys[j].BoundKey2 != 0)
					KeyStr $= OrString;

				if (KeyGroups[i].Keys[j].BoundKey2 > 0)
					KeyStr $= LocalizedKeyName[KeyGroups[i].Keys[j].BoundKey2];
				else if (KeyGroups[i].Keys[j].BoundKey2 < 0)
					KeyStr $= Chr(-KeyGroups[i].Keys[j].BoundKey2) @ "(" $ -KeyGroups[i].Keys[j].BoundKey2 $ ")";
			}

			KeyGroups[i].Keys[j].KeyButton.SetText(KeyStr);

			KeyGroups[i].Keys[j].KeyName.SetSize(LabelWidth, 1);
			KeyGroups[i].Keys[j].KeyName.WinLeft = LabelHSpacing;
		}
	}
}

function KeyDown( int Key, float X, float Y )
{
	if (bPolling)
	{
		LastKeyDown = Key;
		ProcessMenuKey(Key, RealKeyName[Key]);
	}
}

function KeyType(int Key, float X, float Y)
{
	if (!bPolling)
		return;
	if (Selection[0] == ConsoleCharacterGroupIdx && Selection[1] == ConsoleCharacterKeyIdx)
		SetConsoleChar(Key);
}

function KeyUp(int Key, float X, float Y)
{
	CancelKeySelection();
}

final function RemoveExistingKey(int KeyNo, string KeyName)
{
	local int i,j;

	if (bErasing)
		UnbindSelectedItem();

	// Remove this key from any existing binding display
	for (i=0; i<NumGroups; i++)
	{
		for( j=0; j<KeyGroups[i].NumKeys; j++ )
		{
			if ( KeyGroups[i].Keys[j].BoundKey2 == KeyNo )
				KeyGroups[i].Keys[j].BoundKey2 = 0;

			if ( KeyGroups[i].Keys[j].BoundKey1 == KeyNo )
			{
				KeyGroups[i].Keys[j].BoundKey1 = KeyGroups[i].Keys[j].BoundKey2;
				KeyGroups[i].Keys[j].BoundKey2 = 0;
			}
		}
	}
}

function SetKey(int KeyNo, string KeyName)
{
	if ( KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1 != 0 )
	{

		// if this key is already chosen, just clear out other slot
		if ( KeyNo == KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1 )
		{
			// if 2 exists, remove it it.
			if ( KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2 != 0)
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2]);
				KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2 = 0;
			}
		}
		else if (KeyNo == KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2)
		{
			// Remove slot 1
			GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1]);
			KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1 = KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2;
			KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2 = 0;
		}
		else
		{
			// Clear out old slot 2 if it exists
			if (KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2 != 0)
			{
				GetPlayerOwner().ConsoleCommand("SET Input "$RealKeyName[KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2]);
				KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2 = 0;
			}

			// move key 1 to key 2, and set ourselves in 1.
			KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2 = KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1;
			KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1 = KeyNo;
			GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@KeyGroups[Selection[0]].Keys[Selection[1]].AliasString);
		}
	}
	else
	{
		KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1 = KeyNo;
		GetPlayerOwner().ConsoleCommand("SET Input"@KeyName@KeyGroups[Selection[0]].Keys[Selection[1]].AliasString);
	}
}

function SetConsoleButton(int KeyNo)
{
	local PlayerPawn P;

	P = GetPlayerOwner();
	if (ConsoleButtonGroupIdx < 0 || Root == none || Root.Console == none || P == none ||
		KeyNo == P.EInputKey.IK_LeftMouse || KeyNo == P.EInputKey.IK_RightMouse)
	{
		return;
	}
	RemoveExistingKey(KeyNo, "");
	GetPlayerOwner().ConsoleCommand("Set Input" @ RealKeyName[KeyNo]);
	Root.Console.GlobalConsoleKey = KeyNo;
	Root.Console.SaveConfig();
	KeyGroups[ConsoleButtonGroupIdx].Keys[ConsoleButtonKeyIdx].BoundKey1 = KeyNo;
	if (ConsoleCharacterGroupIdx >= 0)
		KeyGroups[ConsoleCharacterGroupIdx].Keys[ConsoleCharacterKeyIdx].BoundKey1 = 0;
}

function SetConsoleChar(int CharCode)
{
	if (ConsoleCharacterGroupIdx < 0 || Root == none || Root.Console == none || CharCode <= 0)
		return;
	RemoveExistingKey(LastKeyDown, "");
	GetPlayerOwner().ConsoleCommand("Set Input" @ RealKeyName[LastKeyDown]);
	Root.Console.GlobalConsoleKey = 0;
	Root.Console.ConsoleKeyChar = CharCode;
	Root.Console.SaveConfig();
	KeyGroups[ConsoleCharacterGroupIdx].Keys[ConsoleCharacterKeyIdx].BoundKey1 = -CharCode;
	if (ConsoleButtonGroupIdx >= 0)
		KeyGroups[ConsoleButtonGroupIdx].Keys[ConsoleButtonKeyIdx].BoundKey1 = 0;
	CancelKeySelection();
}

function ProcessMenuKey(int KeyNo, string KeyName)
{
	if (Len(KeyName) == 0 || KeyName ~= "Escape")
		return;

	if (KeyNo == IK_MouseWheelUp || KeyNo == IK_MouseWheelDown)
		MouseWheelBindingTimestamp = AppSeconds();

	if (Selection[0] == ConsoleButtonGroupIdx && Selection[1] == ConsoleButtonKeyIdx)
		SetConsoleButton(KeyNo);
	else if (Selection[0] == ConsoleCharacterGroupIdx && Selection[1] == ConsoleCharacterKeyIdx)
		return;
	else if (Root == none || Root.Console == none || KeyNo != Root.Console.GlobalConsoleKey)
	{
		RemoveExistingKey(KeyNo, KeyName);
		SetKey(KeyNo, KeyName);
	}
	CancelKeySelection();
}

function Notify(UWindowDialogControl C, byte E)
{
	local int i,j;

	Super.Notify(C, E);

	if (C == DefaultsButton && E == DE_Click)
	{
		GetPlayerOwner().ResetKeyboard();
		LoadExistingKeys();
		return;
	}

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case JoyXCombo:
			if (bLoadedExisting)
				GetPlayerOwner().ConsoleCommand("SET Input JoyX "$JoyXBinding[JoyXCombo.GetSelectedIndex()]);
			break;
		case JoyYCombo:
			if (bLoadedExisting)
				GetPlayerOwner().ConsoleCommand("SET Input JoyY "$JoyYBinding[JoyYCombo.GetSelectedIndex()]);
			break;
		}
		break;
	case DE_Click:
		if (bPolling)
		{
			CancelKeySelection();

			if (C == SelectedButton)
			{
				ProcessMenuKey(1, RealKeyName[1]);
				return;
			}
		}

		if (UMenuRaisedButton(C) != None)
		{
			SelectedButton = UMenuRaisedButton(C);

			Selection[0] = -1;
			for (i=0; i<NumGroups; i++)
			{
				for( j=0; j<KeyGroups[i].NumKeys; j++ )
					if (KeyGroups[i].Keys[j].KeyButton == C)
					{
						Selection[0] = i;
						Selection[1] = j;
						break;
					}
				if( Selection[0]!=-1 )
					break;
			}
			bPolling = True;
			bErasing = False;
			SelectedButton.bDisabled = True;
			if (Root != none)
				Root.bAllowConsole = false;
		}
		else if (bPolling)
			CancelKeySelection();
		break;
	case DE_RClick:
		if (bPolling)
		{
			CancelKeySelection();

			if (C == SelectedButton)
			{
				ProcessMenuKey(2, RealKeyName[2]);
				return;
			}
		}

		if (UMenuRaisedButton(C) != None)
		{
			SelectedButton = UMenuRaisedButton(C);

			Selection[0] = -1;
			for (i=0; i<NumGroups; i++)
			{
				for( j=0; j<KeyGroups[i].NumKeys; j++ )
					if (KeyGroups[i].Keys[j].KeyButton == C)
					{
						Selection[0] = i;
						Selection[1] = j;
						break;
					}
				if( Selection[0]!=-1 )
					break;
			}
			bPolling = True;
			bErasing = True;
			SelectedButton.bDisabled = True;
			if (Root != none)
				Root.bAllowConsole = false;
		}
		break;
	case DE_MClick:
		if (bPolling)
		{
			CancelKeySelection();

			if (C == SelectedButton)
			{
				ProcessMenuKey(4, RealKeyName[4]);
				return;
			}
		}
		break;
	}
}

function Click(float X, float Y)
{
	super.Click(X, Y);
	if (bPolling)
		CancelKeySelection();
}

function CancelKeySelection(optional bool bEscape)
{
	bPolling = false;
	if (bEscape)
		bErasing = false;
	else if (bErasing)
		UnbindSelectedItem();
	if (SelectedButton != none)
		SelectedButton.bDisabled = false;
	if (Root != none)
		Root.bAllowConsole = true;
}

function UnbindSelectedItem()
{
	local int i, pos;
	local string KeyName, Alias;

	bErasing = false;

	if (Selection[0] < 0 || Selection[1] < 0)
		return;
	if (Selection[0] == ConsoleButtonGroupIdx && Selection[1] == ConsoleButtonKeyIdx)
	{
		Root.Console.GlobalConsoleKey = 0;
		Root.Console.SaveConfig();
		KeyGroups[ConsoleButtonGroupIdx].Keys[ConsoleButtonKeyIdx].BoundKey1 = 0;
	}
	if (Selection[0] == ConsoleCharacterGroupIdx && Selection[1] == ConsoleCharacterKeyIdx)
	{
		Root.Console.ConsoleKeyChar = 0;
		Root.Console.SaveConfig();
		KeyGroups[ConsoleCharacterGroupIdx].Keys[ConsoleCharacterKeyIdx].BoundKey1 = 0;
		return;
	}

	for (i = 1; i < 255; ++i)
	{
		KeyName = GetPlayerOwner().ConsoleCommand("KEYNAME" @ i);
		if (Len(KeyName) > 0)
		{
			Alias = GetPlayerOwner().ConsoleCommand("KEYBINDING" @ KeyName);
			if (Len(Alias) > 0)
			{
				pos = InStr(Alias, " ");
				if (pos >= 0)
				{
					if (!(Left(Alias, pos) ~= "taunt") &&
						!(Left(Alias, pos) ~= "getweapon") &&
						!(Left(Alias, pos) ~= "viewplayernum") &&
						!(Left(Alias, pos) ~= "button") &&
						!(Left(Alias, pos) ~= "mutate"))
					{
						Alias = Left(Alias, pos);
					}
				}
				if (KeyGroups[Selection[0]].Keys[Selection[1]].AliasString ~= Alias)
					GetPlayerOwner().ConsoleCommand("SET Input" @ KeyName);
			}
		}
	}

	KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey1 = 0;
	KeyGroups[Selection[0]].Keys[Selection[1]].BoundKey2 = 0;
}

function GetDesiredDimensions(out float W, out float H)
{
	Super.GetDesiredDimensions(W, H);
	H = 200;
}

function Close(optional bool bByParent)
{
	CancelKeySelection();
	super.Close(bByParent);
}

function EscClosing()
{
	if (bPolling)
	{
		CancelKeySelection(true);
		if (Root != none)
			Root.bHandledWindowEvent = true;
	}
	else
		super.EscClosing();
}

defaultproperties
{
	EditAreaWidth=155
	LocalizedKeyName(1)="LeftMouse"
	LocalizedKeyName(2)="RightMouse"
	LocalizedKeyName(3)="Cancel"
	LocalizedKeyName(4)="MiddleMouse"
	LocalizedKeyName(5)="Unknown05"
	LocalizedKeyName(6)="Unknown06"
	LocalizedKeyName(7)="Unknown07"
	LocalizedKeyName(8)="Backspace"
	LocalizedKeyName(9)="Tab"
	LocalizedKeyName(10)="Unknown0A"
	LocalizedKeyName(11)="Unknown0B"
	LocalizedKeyName(12)="Unknown0C"
	LocalizedKeyName(13)="Enter"
	LocalizedKeyName(14)="Unknown0E"
	LocalizedKeyName(15)="Unknown0F"
	LocalizedKeyName(16)="Shift"
	LocalizedKeyName(17)="Ctrl"
	LocalizedKeyName(18)="Alt"
	LocalizedKeyName(19)="Pause"
	LocalizedKeyName(20)="CapsLock"
	LocalizedKeyName(21)="Mouse 4"
	LocalizedKeyName(22)="Mouse 5"
	LocalizedKeyName(23)="Mouse 6"
	LocalizedKeyName(24)="Mouse 7"
	LocalizedKeyName(25)="Mouse 8"
	LocalizedKeyName(26)="Unknown1A"
	LocalizedKeyName(27)="Escape"
	LocalizedKeyName(28)="Unknown1C"
	LocalizedKeyName(29)="Unknown1D"
	LocalizedKeyName(30)="Unknown1E"
	LocalizedKeyName(31)="Unknown1F"
	LocalizedKeyName(32)="Space"
	LocalizedKeyName(33)="PageUp"
	LocalizedKeyName(34)="PageDown"
	LocalizedKeyName(35)="End"
	LocalizedKeyName(36)="Home"
	LocalizedKeyName(37)="Left"
	LocalizedKeyName(38)="Up"
	LocalizedKeyName(39)="Right"
	LocalizedKeyName(40)="Down"
	LocalizedKeyName(41)="Select"
	LocalizedKeyName(42)="Print"
	LocalizedKeyName(43)="Execute"
	LocalizedKeyName(44)="PrintScrn"
	LocalizedKeyName(45)="Insert"
	LocalizedKeyName(46)="Delete"
	LocalizedKeyName(47)="Help"
	LocalizedKeyName(48)="0"
	LocalizedKeyName(49)="1"
	LocalizedKeyName(50)="2"
	LocalizedKeyName(51)="3"
	LocalizedKeyName(52)="4"
	LocalizedKeyName(53)="5"
	LocalizedKeyName(54)="6"
	LocalizedKeyName(55)="7"
	LocalizedKeyName(56)="8"
	LocalizedKeyName(57)="9"
	LocalizedKeyName(58)="Unknown3A"
	LocalizedKeyName(59)="Unknown3B"
	LocalizedKeyName(60)="Unknown3C"
	LocalizedKeyName(61)="Unknown3D"
	LocalizedKeyName(62)="Unknown3E"
	LocalizedKeyName(63)="Unknown3F"
	LocalizedKeyName(64)="Unknown40"
	LocalizedKeyName(65)="A"
	LocalizedKeyName(66)="B"
	LocalizedKeyName(67)="C"
	LocalizedKeyName(68)="D"
	LocalizedKeyName(69)="E"
	LocalizedKeyName(70)="F"
	LocalizedKeyName(71)="G"
	LocalizedKeyName(72)="H"
	LocalizedKeyName(73)="I"
	LocalizedKeyName(74)="J"
	LocalizedKeyName(75)="K"
	LocalizedKeyName(76)="L"
	LocalizedKeyName(77)="M"
	LocalizedKeyName(78)="N"
	LocalizedKeyName(79)="O"
	LocalizedKeyName(80)="P"
	LocalizedKeyName(81)="Q"
	LocalizedKeyName(82)="R"
	LocalizedKeyName(83)="S"
	LocalizedKeyName(84)="T"
	LocalizedKeyName(85)="U"
	LocalizedKeyName(86)="V"
	LocalizedKeyName(87)="W"
	LocalizedKeyName(88)="X"
	LocalizedKeyName(89)="Y"
	LocalizedKeyName(90)="Z"
	LocalizedKeyName(91)="Unknown5B"
	LocalizedKeyName(92)="Unknown5C"
	LocalizedKeyName(93)="Unknown5D"
	LocalizedKeyName(94)="Unknown5E"
	LocalizedKeyName(95)="Unknown5F"
	LocalizedKeyName(96)="NumPad0"
	LocalizedKeyName(97)="NumPad1"
	LocalizedKeyName(98)="NumPad2"
	LocalizedKeyName(99)="NumPad3"
	LocalizedKeyName(100)="NumPad4"
	LocalizedKeyName(101)="NumPad5"
	LocalizedKeyName(102)="NumPad6"
	LocalizedKeyName(103)="NumPad7"
	LocalizedKeyName(104)="NumPad8"
	LocalizedKeyName(105)="NumPad9"
	LocalizedKeyName(106)="GreyStar"
	LocalizedKeyName(107)="GreyPlus"
	LocalizedKeyName(108)="Separator"
	LocalizedKeyName(109)="GreyMinus"
	LocalizedKeyName(110)="NumPadPeriod"
	LocalizedKeyName(111)="GreySlash"
	LocalizedKeyName(112)="F1"
	LocalizedKeyName(113)="F2"
	LocalizedKeyName(114)="F3"
	LocalizedKeyName(115)="F4"
	LocalizedKeyName(116)="F5"
	LocalizedKeyName(117)="F6"
	LocalizedKeyName(118)="F7"
	LocalizedKeyName(119)="F8"
	LocalizedKeyName(120)="F9"
	LocalizedKeyName(121)="F10"
	LocalizedKeyName(122)="F11"
	LocalizedKeyName(123)="F12"
	LocalizedKeyName(124)="F13"
	LocalizedKeyName(125)="F14"
	LocalizedKeyName(126)="F15"
	LocalizedKeyName(127)="F16"
	LocalizedKeyName(128)="F17"
	LocalizedKeyName(129)="F18"
	LocalizedKeyName(130)="F19"
	LocalizedKeyName(131)="F20"
	LocalizedKeyName(132)="F21"
	LocalizedKeyName(133)="F22"
	LocalizedKeyName(134)="F23"
	LocalizedKeyName(135)="F24"
	LocalizedKeyName(136)="Unknown88"
	LocalizedKeyName(137)="Unknown89"
	LocalizedKeyName(138)="Unknown8A"
	LocalizedKeyName(139)="Unknown8B"
	LocalizedKeyName(140)="Unknown8C"
	LocalizedKeyName(141)="Unknown8D"
	LocalizedKeyName(142)="Unknown8E"
	LocalizedKeyName(143)="Unknown8F"
	LocalizedKeyName(144)="NumLock"
	LocalizedKeyName(145)="ScrollLock"
	LocalizedKeyName(146)="Unknown92"
	LocalizedKeyName(147)="Unknown93"
	LocalizedKeyName(148)="Unknown94"
	LocalizedKeyName(149)="Unknown95"
	LocalizedKeyName(150)="Unknown96"
	LocalizedKeyName(151)="Unknown97"
	LocalizedKeyName(152)="Unknown98"
	LocalizedKeyName(153)="Unknown99"
	LocalizedKeyName(154)="Unknown9A"
	LocalizedKeyName(155)="Unknown9B"
	LocalizedKeyName(156)="Unknown9C"
	LocalizedKeyName(157)="Unknown9D"
	LocalizedKeyName(158)="Unknown9E"
	LocalizedKeyName(159)="Unknown9F"
	LocalizedKeyName(160)="LShift"
	LocalizedKeyName(161)="RShift"
	LocalizedKeyName(162)="LControl"
	LocalizedKeyName(163)="RControl"
	LocalizedKeyName(164)="UnknownA4"
	LocalizedKeyName(165)="UnknownA5"
	LocalizedKeyName(166)="UnknownA6"
	LocalizedKeyName(167)="UnknownA7"
	LocalizedKeyName(168)="UnknownA8"
	LocalizedKeyName(169)="UnknownA9"
	LocalizedKeyName(170)="UnknownAA"
	LocalizedKeyName(171)="UnknownAB"
	LocalizedKeyName(172)="UnknownAC"
	LocalizedKeyName(173)="UnknownAD"
	LocalizedKeyName(174)="UnknownAE"
	LocalizedKeyName(175)="UnknownAF"
	LocalizedKeyName(176)="UnknownB0"
	LocalizedKeyName(177)="UnknownB1"
	LocalizedKeyName(178)="UnknownB2"
	LocalizedKeyName(179)="UnknownB3"
	LocalizedKeyName(180)="UnknownB4"
	LocalizedKeyName(181)="UnknownB5"
	LocalizedKeyName(182)="UnknownB6"
	LocalizedKeyName(183)="UnknownB7"
	LocalizedKeyName(184)="UnknownB8"
	LocalizedKeyName(185)="UnknownB9"
	LocalizedKeyName(186)="Semicolon"
	LocalizedKeyName(187)="Equals"
	LocalizedKeyName(188)="Comma"
	LocalizedKeyName(189)="Minus"
	LocalizedKeyName(190)="Period"
	LocalizedKeyName(191)="Slash"
	LocalizedKeyName(192)="Tilde"
	LocalizedKeyName(193)="UnknownC1"
	LocalizedKeyName(194)="UnknownC2"
	LocalizedKeyName(195)="UnknownC3"
	LocalizedKeyName(196)="UnknownC4"
	LocalizedKeyName(197)="UnknownC5"
	LocalizedKeyName(198)="UnknownC6"
	LocalizedKeyName(199)="UnknownC7"
	LocalizedKeyName(200)="Joy1"
	LocalizedKeyName(201)="Joy2"
	LocalizedKeyName(202)="Joy3"
	LocalizedKeyName(203)="Joy4"
	LocalizedKeyName(204)="Joy5"
	LocalizedKeyName(205)="Joy6"
	LocalizedKeyName(206)="Joy7"
	LocalizedKeyName(207)="Joy8"
	LocalizedKeyName(208)="Joy9"
	LocalizedKeyName(209)="Joy10"
	LocalizedKeyName(210)="Joy11"
	LocalizedKeyName(211)="Joy12"
	LocalizedKeyName(212)="Joy13"
	LocalizedKeyName(213)="Joy14"
	LocalizedKeyName(214)="Joy15"
	LocalizedKeyName(215)="Joy16"
	LocalizedKeyName(216)="UnknownD8"
	LocalizedKeyName(217)="UnknownD9"
	LocalizedKeyName(218)="UnknownDA"
	LocalizedKeyName(219)="LeftBracket"
	LocalizedKeyName(220)="Backslash"
	LocalizedKeyName(221)="RightBracket"
	LocalizedKeyName(222)="SingleQuote"
	LocalizedKeyName(223)="UnknownDF"
	LocalizedKeyName(224)="JoyX"
	LocalizedKeyName(225)="JoyY"
	LocalizedKeyName(226)="JoyZ"
	LocalizedKeyName(227)="JoyR"
	LocalizedKeyName(228)="MouseX"
	LocalizedKeyName(229)="MouseY"
	LocalizedKeyName(230)="MouseZ"
	LocalizedKeyName(231)="MouseW"
	LocalizedKeyName(232)="JoyU"
	LocalizedKeyName(233)="JoyV"
	LocalizedKeyName(234)="UnknownEA"
	LocalizedKeyName(235)="UnknownEB"
	LocalizedKeyName(236)="MouseWheelUp"
	LocalizedKeyName(237)="MouseWheelDown"
	LocalizedKeyName(238)="Unknown10E"
	LocalizedKeyName(239)="Unknown10F"
	LocalizedKeyName(240)="JoyPovUp"
	LocalizedKeyName(241)="JoyPovDown"
	LocalizedKeyName(242)="JoyPovLeft"
	LocalizedKeyName(243)="JoyPovRight"
	LocalizedKeyName(244)="UnknownF4"
	LocalizedKeyName(245)="UnknownF5"
	LocalizedKeyName(246)="Attn"
	LocalizedKeyName(247)="CrSel"
	LocalizedKeyName(248)="ExSel"
	LocalizedKeyName(249)="ErEof"
	LocalizedKeyName(250)="Play"
	LocalizedKeyName(251)="Zoom"
	LocalizedKeyName(252)="NoName"
	LocalizedKeyName(253)="PA1"
	LocalizedKeyName(254)="OEMClear"
	OrString=" or "
	CustomizeHelp="Click the blue rectangle and then press the key to bind to this control."
	DefaultsText="Reset"
	DefaultsHelp="Reset all controls to their default settings."
	JoystickText="Joystick"
	JoyXText="X Axis"
	JoyXHelp="Select the behavior for the left-right axis of your joystick."
	JoyXOptions(0)="Strafe Left/Right"
	JoyXOptions(1)="Turn Left/Right"
	JoyXBinding(0)="Axis aStrafe speed=2"
	JoyXBinding(1)="Axis aBaseX speed=0.7"
	JoyYText="Y Axis"
	JoyYHelp="Select the behavior for the up-down axis of your joystick."
	JoyYOptions(0)="Move Forward/Back"
	JoyYOptions(1)="Look Up/Down"
	JoyYBinding(0)="Axis aBaseY speed=2"
	JoyYBinding(1)="Axis aLookup speed=-0.4"
}
