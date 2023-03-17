class UMenuHUDConfigCW extends UMenuPageWindow;

var int HUDConfigSliderY, HUDConfigSliderScale, CrosshairSliderY;

// HUD Config
var UWindowHSliderControl HUDConfigSlider;
var localized string HUDConfigText;
var localized string HUDConfigHelp;
var() texture HUDIcon[6],CrosshairTex[6];

// Crosshair
var UWindowHSliderControl CrosshairSlider;
var localized string CrosshairText;
var localized string CrosshairHelp;

var UWindowEditControl CrosshairScaleEditBox;
var localized string CrosshairScaleText;
var localized string CrosshairScaleHelp;

// HUD Scale
var UWindowEditControl HUDScaleEditBox;

var bool bInitialized;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight, ControlOffset;
	local int CenterWidth, CenterPos;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	DesiredWidth = 220;
	DesiredHeight = 160;
	ControlOffset = 20;

	// HUD Config
	HUDConfigSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	HUDConfigSlider.SetRange(0, 5, 1);
	HUDConfigSlider.SetText(HUDConfigText);
	HUDConfigSlider.SetHelpText(HUDConfigHelp);
	HUDConfigSlider.SetFont(F_Normal);
	HUDConfigSliderY = ControlOffset+15;
	HUDConfigSliderScale = DesiredWidth - 10;
	ControlOffset+=(HUDConfigSliderScale+26);

	// Crosshair
	CrosshairSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', CenterPos, ControlOffset, CenterWidth, 1));
	CrosshairSlider.SetRange(0, 5, 1);
	CrosshairSlider.SetText(CrosshairText);
	CrosshairSlider.SetHelpText(CrosshairHelp);
	CrosshairSlider.SetFont(F_Normal);
	CrosshairSliderY = ControlOffset+15;
	ControlOffset+=45;
	
	ControlWidth = Class'UMenuVideoClientWindow'.Default.EditAreaWidth;
	ControlLeft = (WinWidth - ControlWidth) / 2;
	
	// Crosshair Scale
	CrosshairScaleEditBox = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	CrosshairScaleEditBox.SetText(CrosshairScaleText);
	CrosshairScaleEditBox.SetHelpText(CrosshairScaleHelp);
	CrosshairScaleEditBox.SetFont(F_Normal);
	CrosshairScaleEditBox.SetNumericOnly(true);
	CrosshairScaleEditBox.SetNumericFloat(true);
	CrosshairScaleEditBox.Align = TA_Left;
	ControlOffset+=25;
	
	// HUD Scale
	HUDScaleEditBox = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	HUDScaleEditBox.SetText(Class'UMenuVideoClientWindow'.Default.HUDScaleText);
	HUDScaleEditBox.SetHelpText(Class'UMenuVideoClientWindow'.Default.HUDScaleHelp);
	HUDScaleEditBox.SetFont(F_Normal);
	HUDScaleEditBox.SetNumericOnly(true);
	HUDScaleEditBox.SetNumericFloat(true);
	HUDScaleEditBox.Align = TA_Left;
	ControlOffset+=25;
	
	LoadAvailableSettings();
	bInitialized = true;
}

function WindowShown()
{
	super.WindowShown();
	bInitialized = false;
	LoadAvailableSettings();
	bInitialized = true;
}

function LoadAvailableSettings()
{
	local int HudMode;
	
	HudMode = GetPlayerOwner().myHUD.HudMode;
	if ( HudMode < 0 && HudMode >= ArrayCount(HudIcon) )
		HudMode = 0;
	HUDConfigSlider.SetValue(HudMode);
	CrosshairSlider.SetValue(GetPlayerOwner().myHUD.Crosshair);
	CrosshairScaleEditBox.SetValue(string(Class'HUD'.Default.CrosshairScale));
	HUDScaleEditBox.SetValue(string(Class'HUD'.Default.HudScaler));
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, LabelHSpacing, LabelAreaWidth, RightSpacing;
	local float LabelTextAreaWidth;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	HUDConfigSlider.SetSize(CenterWidth, 1);
	HUDConfigSlider.SliderWidth = 90;
	HUDConfigSlider.WinLeft = CenterPos;

	CrosshairSlider.SetSize(CenterWidth, 1);
	CrosshairSlider.SliderWidth = 90;
	CrosshairSlider.WinLeft = CenterPos;
	
	CrosshairScaleEditBox.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	HUDScaleEditBox.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	
	// Setup for editbox width.
	LabelHSpacing = (WinWidth - LabelTextAreaWidth - Class'UMenuVideoClientWindow'.Default.EditAreaWidth) / 3;
	RightSpacing = VScrollbarWidth() + 3;
	if (LabelHSpacing < RightSpacing)
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - Class'UMenuVideoClientWindow'.Default.EditAreaWidth - RightSpacing) / 2;
	LabelAreaWidth = LabelTextAreaWidth + LabelHSpacing;
	ControlWidth = LabelAreaWidth + Class'UMenuVideoClientWindow'.Default.EditAreaWidth;
	ControlLeft = LabelHSpacing;
	
	CrosshairScaleEditBox.SetSize(ControlWidth, 1);
	CrosshairScaleEditBox.WinLeft = ControlLeft;
	CrosshairScaleEditBox.EditBoxWidth = Class'UMenuVideoClientWindow'.Default.EditAreaWidth;
	
	HUDScaleEditBox.SetSize(ControlWidth, 1);
	HUDScaleEditBox.WinLeft = ControlLeft;
	HUDScaleEditBox.EditBoxWidth = Class'UMenuVideoClientWindow'.Default.EditAreaWidth;
}

function Paint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	Super.Paint(C, X, Y);

	// draw HUD format icon
	DrawStretchedTextureSegment( C, (WinWidth - HUDConfigSliderScale) / 2, HUDConfigSliderY, HUDConfigSliderScale, HUDConfigSliderScale, 0, 0, HUDIcon[HUDConfigSlider.Value].USize, HUDIcon[HUDConfigSlider.Value].VSize, HUDIcon[HUDConfigSlider.Value]);

	// DrawCrosshair
	DrawClippedTexture(C, CenterPos, CrosshairSliderY, CrosshairTex[Clamp(GetPlayerOwner().myHUD.Crosshair,0,ArrayCount(CrosshairTex)-1)]);
}

function Notify(UWindowDialogControl C, byte E)
{
	if( !bInitialized )
		return;

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case CrosshairSlider:
			CrosshairChanged();
			break;
		case HUDConfigSlider:
			HUDConfigChanged();
			break;
		case CrosshairScaleEditBox:
			CrossScaleChanged();
			break;
		case HUDScaleEditBox:
			HUDScaleChanged();
			break;
		}
	}
}


function CrosshairChanged()
{
	GetPlayerOwner().myHUD.Crosshair = int(CrosshairSlider.Value);
}

function HUDConfigChanged()
{
	GetPlayerOwner().myHUD.HudMode = int(HUDConfigSlider.Value);
}

function CrossScaleChanged()
{
	if (CrosshairScaleEditBox.GetValue()!="")
	{
		Class'HUD'.Default.CrosshairScale = FClamp(float(CrosshairScaleEditBox.GetValue()), 0.1f, 8.f);
		if( GetPlayerOwner().MyHUD )
			GetPlayerOwner().MyHUD.CrosshairScale = Class'HUD'.Default.CrosshairScale;
		Class'HUD'.Static.StaticSaveConfig();
	}
}

function HUDScaleChanged()
{
	if (HUDScaleEditBox.GetValue()!="")
	{
		Class'HUD'.Default.HudScaler = FClamp(float(HUDScaleEditBox.GetValue()), 1.f, 16.f);
		if( GetPlayerOwner().MyHUD )
			GetPlayerOwner().MyHUD.HudScaler = Class'HUD'.Default.HudScaler;
		Class'HUD'.Static.StaticSaveConfig();
	}
}

function SaveConfigs()
{
	GetPlayerOwner().SaveConfig();
	GetPlayerOwner().myHUD.SaveConfig();
	Super.SaveConfigs();
}

defaultproperties
{
	HUDConfigText="HUD Layout"
	HUDConfigHelp="Use the left and right arrow keys to select a Heads Up Display configuration."
	HUDIcon(0)=Texture'HD_Hud1'
	HUDIcon(1)=Texture'HD_Hud2'
	HUDIcon(2)=Texture'HD_Hud3'
	HUDIcon(3)=Texture'HD_Hud4'
	HUDIcon(4)=Texture'HD_Hud5'
	HUDIcon(5)=Texture'HD_Hud6'
	CrosshairTex(0)=Texture'Crosshair1'
	CrosshairTex(1)=Texture'Crosshair2'
	CrosshairTex(2)=Texture'Crosshair3'
	CrosshairTex(3)=Texture'Crosshair4'
	CrosshairTex(4)=Texture'Crosshair5'
	CrosshairTex(5)=Texture'Crosshair7'
	CrosshairText="Crosshair Style"
	CrosshairHelp="Choose the crosshair appearing at the center of your screen."
	CrosshairScaleText="Crosshair Scale"
	CrosshairScaleHelp="Scaling of the crosshair on HUD."
}
