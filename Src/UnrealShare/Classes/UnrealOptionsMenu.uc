//=============================================================================
// UnrealOptionsMenu
//=============================================================================
class UnrealOptionsMenu extends UnrealLongMenu;

#exec Texture Import File=Textures\hud1.pcx Name=Hud1 MIPS=OFF
#exec Texture Import File=Textures\hud2.pcx Name=Hud2 MIPS=OFF
#exec Texture Import File=Textures\hud3.pcx Name=Hud3 MIPS=OFF
#exec Texture Import File=Textures\hud4.pcx Name=Hud4 MIPS=OFF
#exec Texture Import File=Textures\hud5.pcx Name=Hud5 MIPS=OFF
#exec Texture Import File=Textures\hud6.pcx Name=Hud6 MIPS=OFF

#exec Texture Import File=Textures\HD_Icons\HUD1_HD.bmp Name=HD_Hud1 Group="HD"
#exec Texture Import File=Textures\HD_Icons\HUD2_HD.bmp Name=HD_Hud2 Group="HD"
#exec Texture Import File=Textures\HD_Icons\HUD3_HD.bmp Name=HD_Hud3 Group="HD"
#exec Texture Import File=Textures\HD_Icons\HUD4_HD.bmp Name=HD_Hud4 Group="HD"
#exec Texture Import File=Textures\HD_Icons\HUD5_HD.bmp Name=HD_Hud5 Group="HD"
#exec Texture Import File=Textures\HD_Icons\HUD6_HD.bmp Name=HD_Hud6 Group="HD"

var() texture HUDIcon[6];
var   string MenuValues[21];
var	  bool bJoystick;
var	  string SelectedConsole, SelectedConsoleDesc;
var localized string HideString;

var localized string InternetOption;
var localized string FastInternetOption;
var localized string VeryFastInternetOption;
var localized string HighSpeedInternetOption;
var localized string LANOption;

function int StepSize()
{
	if ( PlayerOwner.NetSpeed < 5000 )
		return 100;
	else if ( PlayerOwner.NetSpeed < 10000 )
		return 500;
	else
		return 1000;
}

function bool ProcessYes()
{
	if ( Selection == 1 )
		PlayerOwner.ChangeAutoAim(0.93);
	else if ( Selection == 2 )
	{
		bJoystick = true;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 4 )
		PlayerOwner.bMouseSmoothing = True;
	else if ( Selection == 5 )
		PlayerOwner.bInvertMouse = True;
	else if ( Selection == 6 )
		PlayerOwner.ChangeSnapView(True);
	else if ( Selection == 7 )
		PlayerOwner.ChangeAlwaysMouseLook(True);
	else if ( Selection == 8 )
		PlayerOwner.ChangeStairLook(True);
	else if ( Selection == 9 )
		PlayerOwner.bNoFlash = true;
	else if ( Selection == 15 )
		SetAutoSwitch(True);
	else
		return false;

	return true;
}

function bool ProcessNo()
{
	if ( Selection == 1 )
		PlayerOwner.ChangeAutoAim(1);
	else if ( Selection == 2 )
	{
		bJoystick = false;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 4 )
		PlayerOwner.bMouseSmoothing = False;
	else if ( Selection == 5 )
		PlayerOwner.bInvertMouse = False;
	else if ( Selection == 6 )
		PlayerOwner.ChangeSnapView(False);
	else if ( Selection == 7 )
		PlayerOwner.ChangeAlwaysMouseLook(False);
	else if ( Selection == 8 )
		PlayerOwner.ChangeStairLook(False);
	else if ( Selection == 9 )
		PlayerOwner.bNoFlash = false;
	else if ( Selection == 15 )
		SetAutoSwitch(False);
	else
		return false;

	return true;
}

function bool ProcessLeft()
{
	local int NewSpeed;

	if ( Selection == 1 )
	{
		if ( PlayerOwner.MyAutoAim == 1 )
			PlayerOwner.ChangeAutoAim(0.93);
		else
			PlayerOwner.ChangeAutoAim(1);
	}
	else if ( Selection == 2 )
	{
		bJoystick = !bJoystick;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 3 )
	{
		if (PlayerOwner.MouseSensitivity <= 10)
			PlayerOwner.UpdateSensitivity(FMax(1, 0.1 * int(PlayerOwner.MouseSensitivity * 10 - 0.5)));
		else if (PlayerOwner.MouseSensitivity <= 11)
			PlayerOwner.UpdateSensitivity(10);
		else
			PlayerOwner.UpdateSensitivity(int(PlayerOwner.MouseSensitivity - 1));
	}
	else if ( Selection == 4 )
		PlayerOwner.bMouseSmoothing = !PlayerOwner.bMouseSmoothing;
	else if ( Selection == 5 )
		PlayerOwner.bInvertMouse = !PlayerOwner.bInvertMouse;
	else if ( Selection == 6 )
		PlayerOwner.ChangeSnapView(!PlayerOwner.bSnapToLevel);
	else if ( Selection == 7 )
		PlayerOwner.ChangeAlwaysMouseLook(!PlayerOwner.bAlwaysMouseLook);
	else if ( Selection == 8 )
		PlayerOwner.ChangeStairLook(!PlayerOwner.bLookUpStairs);
	else if ( Selection == 9 )
		PlayerOwner.bNoFlash = !PlayerOwner.bNoFlash;
	else if ( Selection == 15 )
		SetAutoSwitch(!PlayerOwner.bNeverAutoSwitch);
	else if ( Selection == 10 )
		PlayerOwner.ChangeCrossHair();
	else if ( Selection == 11 )
	{
		if ( PlayerOwner.Handedness == 1 )
			PlayerOwner.ChangeSetHand("Hidden");
		else if ( PlayerOwner.Handedness == 2 )
			PlayerOwner.ChangeSetHand("Right");
		else if ( PlayerOwner.Handedness == 0 )
			PlayerOwner.ChangeSetHand("Left");
		else
			PlayerOwner.ChangeSetHand("Center");
	}
	else if ( Selection == 12 )
	{
		if ( PlayerOwner.DodgeClickTime > 0 )
			PlayerOwner.ChangeDodgeClickTime(-1);
		else
			PlayerOwner.ChangeDodgeClickTime(0.25);
	}
	else if ( Selection == 16 )
		PlayerOwner.myHUD.ChangeHUD(-1);
	else if ( Selection == 17 )
		PlayerOwner.UpdateBob(PlayerOwner.Bob - 0.004);
	else if ( Selection == 18 )
	{
		if (PlayerOwner.NetSpeed > 50000)
			NewSpeed = 50000;
		else if (PlayerOwner.NetSpeed > 20000)
			NewSpeed = 20000;
		else if (PlayerOwner.NetSpeed > 10000)
			NewSpeed = 10000;
		else if (PlayerOwner.NetSpeed > 5000)
			NewSpeed = 5000;
		else if (PlayerOwner.NetSpeed > 2600)
			NewSpeed = 2600;
		else
			return true;

		PlayerOwner.ConsoleCommand("NETSPEED" @ NewSpeed);
	}
	else if ( Selection == 19)
		ChangeConsole(-1);
	else
		return false;

	return true;
}

function bool ProcessRight()
{
	local int NewSpeed;

	if ( Selection == 1 )
	{
		if ( PlayerOwner.MyAutoAim == 1 )
			PlayerOwner.ChangeAutoAim(0.93);
		else
			PlayerOwner.ChangeAutoAim(1);
	}
	else if ( Selection == 2 )
	{
		bJoystick = !bJoystick;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 3 )
	{
		if (PlayerOwner.MouseSensitivity >= 10)
			PlayerOwner.UpdateSensitivity(FMax(PlayerOwner.MouseSensitivity, FMin(99, int(PlayerOwner.MouseSensitivity + 1))));
		else
			PlayerOwner.UpdateSensitivity(0.1 * int(FMax(1, PlayerOwner.MouseSensitivity) * 10 + 1.5));
	}
	else if ( Selection == 4 )
		PlayerOwner.bMouseSmoothing = !PlayerOwner.bMouseSmoothing;
	else if ( Selection == 5 )
		PlayerOwner.bInvertMouse = !PlayerOwner.bInvertMouse;
	else if ( Selection == 6 )
		PlayerOwner.ChangeSnapView(!PlayerOwner.bSnapToLevel);
	else if ( Selection == 7 )
		PlayerOwner.ChangeAlwaysMouseLook(!PlayerOwner.bAlwaysMouseLook);
	else if ( Selection == 8 )
		PlayerOwner.ChangeStairLook(!PlayerOwner.bLookUpStairs);
	else if ( Selection == 9 )
		PlayerOwner.bNoFlash = !PlayerOwner.bNoFlash;
	else if ( Selection == 15 )
		SetAutoSwitch(!PlayerOwner.bNeverAutoSwitch);
	else if ( Selection == 10 )
		PlayerOwner.MyHUD.ChangeCrossHair(-1);
	else if ( Selection == 11 )
	{
		if ( PlayerOwner.Handedness == -1 )
			PlayerOwner.ChangeSetHand("Hidden");
		else if ( PlayerOwner.Handedness == 2 )
			PlayerOwner.ChangeSetHand("Left");
		else if ( PlayerOwner.Handedness == 0 )
			PlayerOwner.ChangeSetHand("Right");
		else
			PlayerOwner.ChangeSetHand("Center");
	}
	else if ( Selection == 12 )
	{
		if ( PlayerOwner.DodgeClickTime > 0 )
			PlayerOwner.ChangeDodgeClickTime(-1);
		else
			PlayerOwner.ChangeDodgeClickTime(0.25);
	}
	else if ( Selection == 16 )
		PlayerOwner.myHUD.ChangeHUD(1);
	else if ( Selection == 17 )
		PlayerOwner.UpdateBob(PlayerOwner.Bob + 0.004);
	else if ( Selection == 18 )
	{
		if (PlayerOwner.NetSpeed < 5000)
			NewSpeed = 5000;
		else if (PlayerOwner.NetSpeed < 10000)
			NewSpeed = 10000;
		else if (PlayerOwner.NetSpeed < 20000)
			NewSpeed = 20000;
		else if (PlayerOwner.NetSpeed < 50000)
			NewSpeed = 50000;
		else
			return true;

		PlayerOwner.ConsoleCommand("NETSPEED" @ NewSpeed);
	}
	else if ( Selection == 19)
		ChangeConsole(1);
	else
		return false;

	return true;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if ( Selection == 1 )
	{
		if ( PlayerOwner.MyAutoAim == 1 )
			PlayerOwner.ChangeAutoAim(0.93);
		else
			PlayerOwner.ChangeAutoAim(1);
	}
	else if ( Selection == 2 )
	{
		bJoystick = !bJoystick;
		PlayerOwner.ConsoleCommand("set windrv.windowsclient usejoystick "$int(bJoystick));
	}
	else if ( Selection == 4 )
		PlayerOwner.bMouseSmoothing = !PlayerOwner.bMouseSmoothing;
	else if ( Selection == 5 )
		PlayerOwner.bInvertMouse = !PlayerOwner.bInvertMouse;
	else if ( Selection == 6 )
		PlayerOwner.ChangeSnapView(!PlayerOwner.bSnapToLevel);
	else if ( Selection == 7 )
		PlayerOwner.ChangeAlwaysMouseLook(!PlayerOwner.bAlwaysMouseLook);
	else if ( Selection == 8 )
		PlayerOwner.ChangeStairLook(!PlayerOwner.bLookUpStairs);
	else if ( Selection == 9 )
		PlayerOwner.bNoFlash = !PlayerOwner.bNoFlash;
	else if ( Selection == 15 )
		SetAutoSwitch(!PlayerOwner.bNeverAutoSwitch);
	else if ( Selection == 10 )
		PlayerOwner.ChangeCrossHair();
	else if ( Selection == 11 )
	{
		if ( PlayerOwner.Handedness == 1 )
			PlayerOwner.ChangeSetHand("Hidden");
		else if ( PlayerOwner.Handedness == 2 )
			PlayerOwner.ChangeSetHand("Right");
		else if ( PlayerOwner.Handedness == 0 )
			PlayerOwner.ChangeSetHand("Left");
		else
			PlayerOwner.ChangeSetHand("Center");
	}
	else if ( Selection == 12 )
	{
		if ( PlayerOwner.DodgeClickTime > 0 )
			PlayerOwner.ChangeDodgeClickTime(-1);
		else
			PlayerOwner.ChangeDodgeClickTime(0.25);
	}
	else if ( Selection == 16 )
		PlayerOwner.myHUD.ChangeHUD(1);
	else if ( Selection == 13 )
		ChildMenu = spawn(class'UnrealNewKeyboardMenu', owner);
	else if ( Selection == 14 )
		ChildMenu = spawn(class'UnrealWeaponMenu', owner);
	else if ( Selection == 19 )
		ApplyConsoleChange();
	else if ( Selection == 20 )
		PlayerOwner.ConsoleCommand("PREFERENCES");
	else
		return false;

	if ( ChildMenu != None )
	{
		HUD(Owner).MainMenu = ChildMenu;
		ChildMenu.ParentMenu = self;
		ChildMenu.PlayerOwner = PlayerOwner;
	}
	return true;
}

function SaveConfigs()
{
	PlayerOwner.myHUD.SaveConfig();
	PlayerOwner.SaveConfig();
	//PlayerOwner.PlayerReplicationInfo.SaveConfig();
}

function DrawValues(canvas Canvas, Font RegFont, int Spacing, int StartX, int StartY)
{
	local int i;

	Canvas.Font = RegFont;
	for (i=0; i< MenuLength; i++ )
	{
		SetFontBrightness( Canvas, (i == Selection - 1) );
		Canvas.SetPos(StartX, StartY + Spacing * i);
		Canvas.DrawText(MenuValues[i + 1], false);
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, HelpPanelX, i, j;

	DrawBackGround(Canvas, (Canvas.ClipY < 250));

	HelpPanelX = 228;

	Spacing = Clamp(0.04 * Canvas.ClipY, 11, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);

	if ( Canvas.ClipY > 240 )
	{
		DrawTitle(Canvas);
		StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));
	}
	else
		StartY = Max(8, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	DrawList(Canvas, false, Spacing, StartX, StartY);
	MenuValues[1] = BoolOptionString( PlayerOwner.MyAutoAim < 1 );
	bJoystick =	bool(PlayerOwner.ConsoleCommand("get windrv.windowsclient usejoystick"));
	MenuValues[2] = BoolOptionString(bJoystick);
	if (PlayerOwner.MouseSensitivity < 10)
	{
		MenuValues[3] = string(PlayerOwner.MouseSensitivity);
		i = InStr(MenuValues[3], ".");
		MenuValues[3] = Left(MenuValues[3], i + 2);
	}
	else
		MenuValues[3] = string(int(PlayerOwner.MouseSensitivity));
	MenuValues[4] = BoolOptionString(PlayerOwner.bMouseSmoothing);
	MenuValues[5] = BoolOptionString(PlayerOwner.bInvertMouse);
	MenuValues[6] = BoolOptionString(PlayerOwner.bSnapToLevel);
	MenuValues[7] = BoolOptionString(PlayerOwner.bAlwaysMouseLook);
	MenuValues[8] = BoolOptionString(PlayerOwner.bLookUpStairs);
	MenuValues[9] = BoolOptionString(!PlayerOwner.bNoFlash);
	MenuValues[15] = BoolOptionString(PlayerOwner.bNeverAutoSwitch);
	if ( PlayerOwner.Handedness == 1 )
		MenuValues[11] = LeftString;
	else if ( PlayerOwner.Handedness == 0 )
		MenuValues[11] = CenterString;
	else if ( PlayerOwner.Handedness == -1 )
		MenuValues[11] = RightString;
	else
		MenuValues[11] = HideString;
	if ( PlayerOwner.DodgeClickTime > 0 )
		MenuValues[12] = EnabledString;
	else
		MenuValues[12] = DisabledString;
	MenuValues[16] = string(PlayerOwner.MyHUD.HudMode);
	if ( PlayerOwner.NetSpeed < 4000 )
		MenuValues[18] = PlayerOwner.NetSpeed @ InternetOption;
	else if ( PlayerOwner.NetSpeed < 6000 )
		MenuValues[18] = PlayerOwner.NetSpeed @ FastInternetOption;
	else if ( PlayerOwner.NetSpeed < 12500 )
		MenuValues[18] = PlayerOwner.NetSpeed @ VeryFastInternetOption;
	else if ( PlayerOwner.NetSpeed < 25000 )
		MenuValues[18] = PlayerOwner.NetSpeed @ HighSpeedInternetOption;
	else
		MenuValues[18] = PlayerOwner.NetSpeed @ LANOption;
	UpdateSelectedConsole();
	MenuValues[19] = SelectedConsoleDesc;
	DrawValues(Canvas, Canvas.MedFont, Spacing, StartX+160, StartY);

	// draw icons
	DrawSlider(Canvas, StartX + 155, StartY + 16 * Spacing + 1, 1000 * PlayerOwner.Bob, 0, 4);

	PlayerOwner.MyHUD.DrawCrossHair(Canvas, StartX + 160, StartY + 9 * Spacing - 3 );

	if (Selection==16)
	{
		if( Canvas.ClipY > 380 && PlayerOwner.MyHUD.HudMode<ArrayCount(HUDIcon) && HUDIcon[PlayerOwner.MyHud.HudMode] )
		{
			j = (Canvas.ClipX*0.02);
			Canvas.CurX = StartX+240 + j;
			i = Max(Canvas.ClipX - j - Canvas.CurX, 64);
			Canvas.CurY = Canvas.ClipY - j - i;
			Canvas.DrawRect(HUDIcon[PlayerOwner.MyHUD.HudMode],i,i);
		}
		Canvas.Font = Canvas.MedFont;
		HelpPanelX = 150;
	}

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing, HelpPanelX);
}
function SetAutoSwitch( bool bEnabled )
{
	if ( PlayerOwner.bNeverAutoSwitch==bEnabled )
		Return;
	PlayerOwner.bNeverAutoSwitch = bEnabled;
	PlayerOwner.NeverSwitchOnPickup(bEnabled);
}

function UpdateSelectedConsole()
{
	local string FullClassName, Desc, PackageName;

	if (Len(SelectedConsole) == 0)
	{
		SelectedConsole = string(PlayerOwner.Player.Console.Class);
		foreach PlayerOwner.IntDescIterator("Engine.Console", FullClassName, Desc)
			if (SelectedConsole ~= FullClassName)
			{
				SelectedConsoleDesc = Desc;
				break;
			}
		if (Len(SelectedConsoleDesc) == 0)
			Divide(SelectedConsole, ".", PackageName, SelectedConsoleDesc);
	}
}

function ChangeConsole(int IndexOffset)
{
	local string FullClassName, Desc, PackageName, ClassName;
	local array<string> FullClassNameArr, DescArr;
	local int n, SelectedIdx;

	foreach PlayerOwner.IntDescIterator("Engine.Console", FullClassName, Desc)
		if (Divide(FullClassName, ".", PackageName, ClassName))
		{
			FullClassNameArr[n] = FullClassName;
			if (Len(Desc) > 0)
				DescArr[n] = Desc;
			else
				DescArr[n] = ClassName;
			if (SelectedConsole ~= FullClassName)
				SelectedIdx = n;
			++n;
		}
	if (n > 0)
	{
		SelectedIdx = (SelectedIdx + IndexOffset + n) % n;
		SelectedConsole = FullClassNameArr[SelectedIdx];
		SelectedConsoleDesc = DescArr[SelectedIdx];
	}
}

function ApplyConsoleChange()
{
	if (Len(SelectedConsole) > 0 &&
		!(SelectedConsole ~= string(PlayerOwner.Player.Console.Class)) &&
		class<Console>(DynamicLoadObject(SelectedConsole, class'class', true)) != none)
	{
		Log("...setting Engine.Engine.Console:" @ SelectedConsole);
		PlayerOwner.ConsoleCommand("SetGameConsole" @ SelectedConsole);
		PlayerOwner.ConsoleCommand("RELAUNCH");
	}
}

defaultproperties
{
	HUDIcon(0)=Texture'HD_Hud1'
	HUDIcon(1)=Texture'HD_Hud2'
	HUDIcon(2)=Texture'HD_Hud3'
	HUDIcon(3)=Texture'HD_Hud4'
	HUDIcon(4)=Texture'HD_Hud5'
	HUDIcon(5)=Texture'HD_Hud6'
	HideString="Hidden"
	InternetOption="(Dial-Up)"
	FastInternetOption="(Dial-Up)"
	VeryFastInternetOption="(Broadband)"
	HighSpeedInternetOption="(Broadband)"
	LANOption="(LAN)"
	MenuLength=20
	HelpMessage(1)="Enable or disable vertical aiming help."
	HelpMessage(2)="Toggle enabling of joystick."
	HelpMessage(3)="Adjust the mouse sensitivity, or how far you have to move the mouse to produce a given motion in the game."
	HelpMessage(4)="Enable or disable mouse smoothing (disable for high resolution mice)"
	HelpMessage(5)="Invert the mouse X axis.  When true, pushing the mouse forward causes you to look down rather than up."
	HelpMessage(6)="If true, when you let go of the mouselook key the view will automatically center itself."
	HelpMessage(7)="If true, the mouse is always used for looking up and down, with no need for a mouselook key."
	HelpMessage(8)="If true, when not mouse-looking your view will automatically be adjusted to look up and down slopes and stairs."
	HelpMessage(9)="If true, your screen will flash when you fire your weapon."
	HelpMessage(10)="Choose the crosshair appearing at the center of your screen"
	HelpMessage(11)="Select where your weapon will appear."
	HelpMessage(12)="If enabled, double-clicking on the movement keys (forward, back, strafe left, and strafe right) will cause you to do a fast dodge move."
	HelpMessage(13)="Hit enter to customize keyboard, mouse, and joystick configuration."
	HelpMessage(14)="Hit enter to prioritize weapon switching order. (If never auto-switch is false)"
	HelpMessage(15)="Never auto-switch to better weapon on pickup."
	HelpMessage(16)="Use the left and right arrow keys to select a Heads Up Display configuration."
	HelpMessage(17)="Adjust the amount of bobbing when moving."
	HelpMessage(18)="Set your optimal networking speed.  This has an impact on internet gameplay."
	HelpMessage(19)="This option determines the look of console and menus. Press Enter to restart the game and apply the changes."
	HelpMessage(20)="Open advanced preferences configuration menu."
	MenuList(1)="Auto Aim"
	MenuList(2)="Joystick Enabled"
	MenuList(3)="Mouse Sensitivity"
	MenuList(4)="Mouse Smoothing"
	MenuList(5)="Invert Mouse"
	MenuList(6)="LookSpring"
	MenuList(7)="Always MouseLook"
	MenuList(8)="Auto Slope Look"
	MenuList(9)="Weapon Flash"
	MenuList(10)="Crosshair"
	MenuList(11)="Weapon Hand"
	MenuList(12)="Dodging"
	MenuList(13)="Customize Controls"
	MenuList(14)="Prioritize Weapons"
	MenuList(15)="No Auto Weapon Switch"
	MenuList(16)="HUD Configuration"
	MenuList(17)="View Bob"
	MenuList(18)="Net Speed"
	MenuList(19)="Console"
	MenuList(20)="Advanced Options"
	MenuTitle="OPTIONS MENU"
}
