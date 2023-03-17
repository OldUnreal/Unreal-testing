class UMenuVideoClientWindow extends UMenuPageWindow;

var localized int EditAreaWidth; // Maximal width of a control that indicates a modifiable value
var float LabelTextAreaWidth;    // Maximal width of label text

// Driver
var bool bInitialized;

var UWindowComboControl VideoCombo;
var string Driver;
var localized string DriverText;
var localized string DriverHelp;

// Resolution
var UWindowComboControl ResolutionCombo;
var localized string ResolutionText;
var localized string ResolutionHelp;

var bool bFullScreen,bSupportsBorderless;

// Show Decals
var UWindowCheckbox BorderlessFSCheck;
var localized string BorderlessFSText;
var localized string BorderlessFSHelp;

var string OldSettings;

// Show Decals
var UWindowCheckbox ShowWindowedCheck;
var localized string ShowWindowedText;
var localized string ShowWindowedHelp;

// Color Depth
var UWindowComboControl ColorDepthCombo;
var localized string ColorDepthText;
var localized string ColorDepthHelp;
var localized string BitsText;

// Texture Detail
var UWindowComboControl TextureDetailCombo;
var localized string TextureDetailText;
var localized string TextureDetailHelp;
var localized string Details[3];
var int OldTextureDetail;

// Skin Detail
var UWindowComboControl SkinDetailCombo;
var localized string SkinDetailText;
var localized string SkinDetailHelp;
var int OldSkinDetail;

// Brightness
var UWindowHSliderControl BrightnessSlider;
var localized string BrightnessText;
var localized string BrightnessHelp;

// GUI Scale
var UWindowComboControl ScaleCombo;
var localized string ScaleText;
var localized string ScaleHelp;

var localized string ScaleSizes[2];

// HUD Scale
var localized string HUDScaleText;
var localized string HUDScaleHelp;

// Mouse Speed
var UWindowHSliderControl MouseSlider;
var localized string MouseText;
var localized string MouseHelp;

// GUI Skin
var UWindowComboControl GuiSkinCombo;
var localized string GuiSkinText;
var localized string GuiSkinHelp;

var float ControlOffset;

var UWindowMessageBox ConfirmSettings, ConfirmDriver, ConfirmWorldTextureDetail, ConfirmSkinTextureDetail;
var localized string ConfirmSettingsTitle;
var localized string ConfirmSettingsText;
var localized string ConfirmSettingsCancelTitle;
var localized string ConfirmSettingsCancelText;
var localized string ConfirmTextureDetailTitle;
var localized string ConfirmTextureDetailText;
var localized string ConfirmDriverTitle;
var localized string ConfirmDriverText;

// Pawn Shadow decals
var UWindowComboControl PawnShadowCombo;
var localized string PawnShadowText;
var localized string PawnShadowHelp;
var localized string PawnShadowList[6];
var int OldShadowCmb;

// Pawn Shadow view distance
var UWindowComboControl ShadowDistanceCombo;
var localized string ShadowDistanceText;
var localized string ShadowDistanceHelp;
var localized string ShadowDistanceOpts[6];

// Show Decals
var UWindowCheckbox ShowDecalsCheck;
var localized string ShowDecalsText;
var localized string ShowDecalsHelp;

// Show specular lighting
var UWindowCheckbox ShowSpecularCheck;
var localized string ShowSpecularText;
var localized string ShowSpecularHelp;

// Min Desired Frame Rate
var UWindowEditControl MinFramerateEdit;
var localized string MinFramerateText;
var localized string MinFramerateHelp;

// Dynamic Lights
var UWindowCheckbox DynamicLightsCheck;
var localized string DynamicLightsText;
var localized string DynamicLightsHelp;

// Weapon Flash
var UWindowCheckbox WeaponFlashCheck;
var localized string WeaponFlashText;
var localized string WeaponFlashHelp;

// WideScreen (unused, replaced with FOV, preserved for binary compatibility with possible custom old classes)
var UWindowHSliderControl WideScreenSlider;
var localized string WideScreenText;
var localized string WideScreenHelp;

// FOV Angle
var UWindowEditControl FovAngleEdit;
var localized string FovAngleText;
var localized string FovAngleHelp;

// Deco shadows
var UWindowCheckbox DecoShadowsCheck;
var localized string DecoShadowsText;
var localized string DecoShadowsHelp;

// Flat shading
var UWindowCheckbox FlatShadingCheck;
var localized string FlatShadingText;
var localized string FlatShadingHelp;

// Curved surfaces (unused since 227j again)!
var UWindowCheckbox CurvyMeshCheck;
var localized string CurvyMeshText;
var localized string CurvyMeshHelp;

// Use Precache
var UWindowCheckbox UsePrecacheCheck;
var localized string UsePrecacheText;
var localized string UsePrecacheHelp;
var string UsePrecachePropertyName;

var bool bSupportsNoFiltering;

// Trilinear Filtering
var UWindowCheckbox TrilinearFilteringCheck;
var localized string TrilinearFilteringText;
var localized string TrilinearFilteringHelp;

// NoSmooth mode
var UWindowCheckbox NoSmoothRenderCheck;
var localized string NoSmoothRenderText;
var localized string NoSmoothRenderHelp;

// Enable HD textures
var UWindowCheckbox HDTexturesCheck;
var localized string HDTexturesText;
var localized string HDTexturesHelp;

// Anisotropic Filtering
var UWindowComboControl AnisotropicFilteringCombo;
var localized string AnisotropicFilteringText;
var localized string AnisotropicFilteringHelp;
var localized string AnisotropicFilteringModes[2];
var string AnisotropicFilteringComboOptions;

// Antialiasing
var UWindowComboControl AntialiasingCombo;
var localized string AntialiasingText;
var localized string AntialiasingHelp;
var localized string AntialiasingModes[3];
var string AntialiasingComboOptions;

// Vertical Synchronization
var UWindowComboControl VSyncCombo;
var localized string VSyncText;
var localized string VSyncHelp;
var localized string VSyncModes[3];
var string VSyncComboOptions;

// Skybox fog mode
var UWindowComboControl SkyFogCombo;
var localized string SkyFogText;
var localized string SkyFogHelp;

// Lightmap LOD
var UWindowHSliderControl LightLODSlider;
var localized string LightLODText;
var localized string LightLODHelp;

var localized string NotAvailableText;

function Created()
{
	local int ControlWidth, ControlLeft;
	local int i;
	local string NextLook, NextDesc;

	Super.Created();

	ControlWidth = EditAreaWidth;
	ControlLeft = (WinWidth - ControlWidth) / 2;

	// Video Driver
	VideoCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	VideoCombo.SetText(DriverText);
	VideoCombo.SetHelpText(DriverHelp);
	VideoCombo.SetFont(F_Normal);
	VideoCombo.SetEditable(False);
	ControlOffset += 25;

	// Fullscreen
	ShowWindowedCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	ShowWindowedCheck.SetText(ShowWindowedText);
	ShowWindowedCheck.SetHelpText(ShowWindowedHelp);
	ShowWindowedCheck.SetFont(F_Normal);
	ShowWindowedCheck.Align = TA_Left;
	ControlOffset += 25;

	// Borderless fullscreen.
	bSupportsBorderless = !(Left(GetLocalPlayerPawn().ConsoleCommand("get ini:Engine.Engine.ViewportManager UseDesktopFullScreen"),12)~="Unrecognized");
	if( bSupportsBorderless )
	{
		BorderlessFSCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
		BorderlessFSCheck.SetText(BorderlessFSText);
		BorderlessFSCheck.SetHelpText(BorderlessFSHelp);
		BorderlessFSCheck.SetFont(F_Normal);
		BorderlessFSCheck.Align = TA_Left;
		ControlOffset += 25;
	}

	// Resolution
	ResolutionCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ResolutionCombo.SetText(ResolutionText);
	ResolutionCombo.SetHelpText(ResolutionHelp);
	ResolutionCombo.SetFont(F_Normal);
	ResolutionCombo.SetEditable(False);
	ControlOffset += 25;

	// color depth
	ColorDepthCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ColorDepthCombo.SetText(ColorDepthText);
	ColorDepthCombo.SetHelpText(ColorDepthHelp);
	ColorDepthCombo.SetFont(F_Normal);
	ColorDepthCombo.SetEditable(False);
	ControlOffset += 25;

	// FOV
	FovAngleEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	FovAngleEdit.SetText(FovAngleText);
	FovAngleEdit.SetHelpText(FovAngleHelp);
	FovAngleEdit.SetFont(F_Normal);
	FovAngleEdit.SetNumericOnly(true);
	FovAngleEdit.SetNumericFloat(true);
	FovAngleEdit.Align = TA_Left;
	ControlOffset += 25;

	// Texture Detail
	TextureDetailCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	TextureDetailCombo.SetText(TextureDetailText);
	TextureDetailCombo.SetHelpText(TextureDetailHelp);
	TextureDetailCombo.SetFont(F_Normal);
	TextureDetailCombo.SetEditable(False);
	ControlOffset += 25;

	// The display names are localized.  These strings match the enums in UnCamMgr.cpp.
	TextureDetailCombo.AddItem(Details[0], "High");
	TextureDetailCombo.AddItem(Details[1], "Medium");
	TextureDetailCombo.AddItem(Details[2], "Low");

	// Skin Detail
	SkinDetailCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SkinDetailCombo.SetText(SkinDetailText);
	SkinDetailCombo.SetHelpText(SkinDetailHelp);
	SkinDetailCombo.SetFont(F_Normal);
	SkinDetailCombo.SetEditable(False);
	SkinDetailCombo.AddItem(Details[0], "High");
	SkinDetailCombo.AddItem(Details[1], "Medium");
	SkinDetailCombo.AddItem(Details[2], "Low");
	ControlOffset += 25;

	// Brightness
	BrightnessSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	BrightnessSlider.bNoSlidingNotify = True;
	BrightnessSlider.SetRange(1, 10, 1);
	BrightnessSlider.SetText(BrightnessText);
	BrightnessSlider.SetHelpText(BrightnessHelp);
	BrightnessSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// GUI Mouse speed
	MouseSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	MouseSlider.bNoSlidingNotify = True;
	MouseSlider.SetRange(40, 500, 5);
	MouseSlider.SetText(MouseText);
	MouseSlider.SetHelpText(MouseHelp);
	MouseSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// GUI Scale
	ScaleCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ScaleCombo.SetText(ScaleText);
	ScaleCombo.SetHelpText(ScaleHelp);
	ScaleCombo.SetFont(F_Normal);
	ScaleCombo.SetEditable(False);
	ScaleCombo.AddItem(ScaleSizes[0], "10");
	ScaleCombo.AddItem(ScaleSizes[1], "20");
	ControlOffset += 25;

	GuiSkinCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	GuiSkinCombo.SetText(GuiSkinText);
	GuiSkinCombo.SetHelpText(GuiSkinHelp);
	GuiSkinCombo.SetFont(F_Normal);
	GuiSkinCombo.SetEditable(False);
	ControlOffset += 25;
	i=0;
	GetPlayerOwner().GetNextIntDesc("UWindowLookAndFeel", 0, NextLook, NextDesc);
	while ( (NextLook != "") && (i < 32) )
	{
		GuiSkinCombo.AddItem(NextDesc, NextLook);
		i++;
		GetPlayerOwner().GetNextIntDesc("UWindowLookAndFeel", i, NextLook, NextDesc);
	}
	GuiSkinCombo.Sort();

	// Min Desired Framerate
	MinFramerateEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, 1));
	MinFramerateEdit.SetText(MinFramerateText);
	MinFramerateEdit.SetHelpText(MinFramerateHelp);
	MinFramerateEdit.SetFont(F_Normal);
	MinFramerateEdit.SetNumericOnly(True);
	MinFramerateEdit.SetMaxLength(3);
	MinFramerateEdit.Align = TA_Left;
	ControlOffset += 25;

	// Show Decals
	ShowDecalsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	ShowDecalsCheck.SetText(ShowDecalsText);
	ShowDecalsCheck.SetHelpText(ShowDecalsHelp);
	ShowDecalsCheck.SetFont(F_Normal);
	ShowDecalsCheck.Align = TA_Left;
	ControlOffset += 25;

	// Dynamic Lights
	DynamicLightsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	DynamicLightsCheck.SetText(DynamicLightsText);
	DynamicLightsCheck.SetHelpText(DynamicLightsHelp);
	DynamicLightsCheck.SetFont(F_Normal);
	DynamicLightsCheck.Align = TA_Left;
	ControlOffset += 25;

	// Show Decals
	ShowSpecularCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	ShowSpecularCheck.SetText(ShowSpecularText);
	ShowSpecularCheck.SetHelpText(ShowSpecularHelp);
	ShowSpecularCheck.SetFont(F_Normal);
	ShowSpecularCheck.Align = TA_Left;
	ControlOffset += 25;

	// Weapon Flash
	WeaponFlashCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	WeaponFlashCheck.SetText(WeaponFlashText);
	WeaponFlashCheck.SetHelpText(WeaponFlashHelp);
	WeaponFlashCheck.SetFont(F_Normal);
	WeaponFlashCheck.Align = TA_Left;
	ControlOffset += 25;

	// Pawn shadows
	PawnShadowCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	PawnShadowCombo.SetText(PawnShadowText);
	PawnShadowCombo.SetHelpText(PawnShadowHelp);
	PawnShadowCombo.SetFont(F_Normal);
	PawnShadowCombo.SetEditable(False);
	ControlOffset += 25;
	for (i = 0; i < ArrayCount(PawnShadowList); ++i)
		PawnShadowCombo.AddItem(PawnShadowList[i], string(i));

	// Decoration shadows
	DecoShadowsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	DecoShadowsCheck.SetText(DecoShadowsText);
	DecoShadowsCheck.SetHelpText(DecoShadowsHelp);
	DecoShadowsCheck.SetFont(F_Normal);
	DecoShadowsCheck.Align = TA_Left;
	ControlOffset += 25;

	// Pawn shadow view distance
	ShadowDistanceCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	ShadowDistanceCombo.SetText(ShadowDistanceText);
	ShadowDistanceCombo.SetHelpText(ShadowDistanceHelp);
	ShadowDistanceCombo.SetFont(F_Normal);
	ShadowDistanceCombo.SetEditable(False);
	ControlOffset += 25;
	for (i = 0; i < ArrayCount(ShadowDistanceOpts); ++i)
		ShadowDistanceCombo.AddItem(ShadowDistanceOpts[i], string(i));

	// Flat shading
	FlatShadingCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	FlatShadingCheck.SetText(FlatShadingText);
	FlatShadingCheck.SetHelpText(FlatShadingHelp);
	FlatShadingCheck.SetFont(F_Normal);
	FlatShadingCheck.Align = TA_Left;
	ControlOffset += 25;

	// Curvy surfaces
	/*CurvyMeshCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	CurvyMeshCheck.SetText(CurvyMeshText);
	CurvyMeshCheck.SetHelpText(CurvyMeshHelp);
	CurvyMeshCheck.SetFont(F_Normal);
	CurvyMeshCheck.Align = TA_Left;
	ControlOffset += 25;*/

	// Skybox fog detail
	SkyFogCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	SkyFogCombo.SetText(SkyFogText);
	SkyFogCombo.SetHelpText(SkyFogHelp);
	SkyFogCombo.SetFont(F_Normal);
	SkyFogCombo.SetEditable(False);
	ControlOffset += 25;
	SkyFogCombo.AddItem(Class'UnrealVideoMenu'.Default.SkyFogDetail[0], "FOGDETAIL_High");
	SkyFogCombo.AddItem(Class'UnrealVideoMenu'.Default.SkyFogDetail[1], "FOGDETAIL_Low");
	SkyFogCombo.AddItem(Class'UnrealVideoMenu'.Default.SkyFogDetail[2], "FOGDETAIL_None");

	// GUI Mouse speed
	LightLODSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, 1));
	LightLODSlider.bNoSlidingNotify = True;
	LightLODSlider.SetRange(0, 8, 1);
	LightLODSlider.SetText(LightLODText);
	LightLODSlider.SetHelpText(LightLODHelp);
	LightLODSlider.SetFont(F_Normal);
	ControlOffset += 25;

	// Use Precache
	UsePrecacheCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	UsePrecacheCheck.SetText(UsePrecacheText);
	UsePrecacheCheck.SetHelpText(UsePrecacheHelp);
	UsePrecacheCheck.SetFont(F_Normal);
	UsePrecacheCheck.Align = TA_Left;
	ControlOffset += 25;

	// Trilinear Filtering
	TrilinearFilteringCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	TrilinearFilteringCheck.SetText(TrilinearFilteringText);
	TrilinearFilteringCheck.SetHelpText(TrilinearFilteringHelp);
	TrilinearFilteringCheck.SetFont(F_Normal);
	TrilinearFilteringCheck.Align = TA_Left;
	ControlOffset += 25;
	
	// NoSmooth render
	NoSmoothRenderCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	NoSmoothRenderCheck.SetText(NoSmoothRenderText);
	NoSmoothRenderCheck.SetHelpText(NoSmoothRenderHelp);
	NoSmoothRenderCheck.SetFont(F_Normal);
	NoSmoothRenderCheck.Align = TA_Left;
	ControlOffset += 25;
	
	// HD Textures
	HDTexturesCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	HDTexturesCheck.SetText(HDTexturesText);
	HDTexturesCheck.SetHelpText(HDTexturesHelp);
	HDTexturesCheck.SetFont(F_Normal);
	HDTexturesCheck.Align = TA_Left;
	ControlOffset += 25;

	// Anisotropic Filtering
	AnisotropicFilteringCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	AnisotropicFilteringCombo.SetText(AnisotropicFilteringText);
	AnisotropicFilteringCombo.SetHelpText(AnisotropicFilteringHelp);
	AnisotropicFilteringCombo.SetFont(F_Normal);
	AnisotropicFilteringCombo.SetEditable(false);
	ControlOffset += 25;

	// Antialiasing
	AntialiasingCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	AntialiasingCombo.SetText(AntialiasingText);
	AntialiasingCombo.SetHelpText(AntialiasingHelp);
	AntialiasingCombo.SetFont(F_Normal);
	AntialiasingCombo.SetEditable(false);
	ControlOffset += 25;

	// Vertical Synchronization
	VSyncCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, 1));
	VSyncCombo.SetText(VSyncText);
	VSyncCombo.SetHelpText(VSyncHelp);
	VSyncCombo.SetFont(F_Normal);
	VSyncCombo.SetEditable(false);
	ControlOffset += 25;

	ListAvailableVideoDrivers();
	LoadAvailableSettings();
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 220;
	DesiredHeight = ControlOffset;
}

function WindowShown()
{
	super.WindowShown();
	LoadAvailableSettings();
}

function LoadAvailableSettings()
{
	local float Brightness;
	local PlayerPawn P;
	local string CurrentDepth;
	local string ParseString, OptionStr;
	local UWindowComboListItem ListItem;
	local int i;

	bInitialized = False;
	P = GetPlayerOwner();

	LoadVideoDriverSettings();
	ShowWindowedCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager StartupFullscreen"));

	ParseString = P.ConsoleCommand("GetRes");
	for (
		ListItem = UWindowComboListItem(ResolutionCombo.List.Items.Next);
		ListItem != none && GetNextValue(ParseString, OptionStr) && ListItem.Value == OptionStr;
		ListItem = UWindowComboListItem(ListItem.Next))
	{}
	if (ListItem != none || Len(ParseString) > 0)
	{
		ResolutionCombo.Clear();
		ParseString = P.ConsoleCommand("GetRes");
		while (GetNextValue(ParseString, OptionStr))
			ResolutionCombo.AddItem(OptionStr);
	}
	ResolutionCombo.SetValue(P.ConsoleCommand("GetCurrentRes"));

	if( bSupportsBorderless )
	{
		BorderlessFSCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseDesktopFullScreen"));
		if( BorderlessFSCheck.bChecked )
		{
			ShowWindowedCheck.bDisabled = true;
			ResolutionCombo.SetDisabled(true);
		}
	}

	ParseString = P.ConsoleCommand("GetColorDepths");
	for (
		ListItem = UWindowComboListItem(ColorDepthCombo.List.Items.Next);
		ListItem != none && GetNextValue(ParseString, OptionStr) && ListItem.Value2 == OptionStr;
		ListItem = UWindowComboListItem(ListItem.Next))
	{}
	if (ListItem != none || Len(ParseString) > 0)
	{
		ColorDepthCombo.Clear();
		ParseString = P.ConsoleCommand("GetColorDepths");
		while (GetNextValue(ParseString, OptionStr))
			ColorDepthCombo.AddItem(OptionStr @ BitsText, OptionStr);
	}
	CurrentDepth = P.ConsoleCommand("GetCurrentColorDepth");
	ColorDepthCombo.SetValue(CurrentDepth @ BitsText, CurrentDepth);

	FovAngleEdit.SetValue(string(FClamp(P.MainFOV, 0, 170)));
	GuiSkinCombo.SetSelectedIndex(Max(GuiSkinCombo.FindItemIndex2(Root.LookAndFeelClass, True), 0));
	OldTextureDetail = Max(0, TextureDetailCombo.FindItemIndex2(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetail")));
	TextureDetailCombo.SetSelectedIndex(OldTextureDetail);
	OldSkinDetail = Max(0, SkinDetailCombo.FindItemIndex2(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager SkinDetail")));
	SkinDetailCombo.SetSelectedIndex(OldSkinDetail);
	i = Max(0, SkyFogCombo.FindItemIndex2(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager SkyBoxFogMode")));
	SkyFogCombo.SetSelectedIndex(i);
	Brightness = int(float(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness")) * 10);
	BrightnessSlider.SetValue(Brightness);
	MouseSlider.SetValue(Root.Console.MouseScale * 100);
	ScaleCombo.SetSelectedIndex(Max(ScaleCombo.FindItemIndex2(string(int(Root.GUIScale*10))), 0));
	MinFramerateEdit.EditBox.Value = string(int(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager MinDesiredFrameRate")));
	ShowDecalsCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager Decals"));
	ShowSpecularCheck.bChecked = !P.Level.bDisableSpeclarLight;
	DynamicLightsCheck.bChecked = !bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager NoDynamicLights"));
	WeaponFlashCheck.bChecked = !P.bNoFlash;
	LoadPawnShadowSettings();
	FlatShadingCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager FlatShading"));
	//CurvyMeshCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager CurvedSurfaces"));
	LightLODSlider.SetValue(int(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager LightMapLOD")));
	LoadConditionallySupportedSettings();

	bInitialized = True;
}

function string GetVideoDriverClassName()
{
	local string CurrentDriver, S;

	CurrentDriver = GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice Class");
	// Get class name from class'...'
	if (Divide(CurrentDriver, "'", S, CurrentDriver) && Divide(CurrentDriver, "'", CurrentDriver, S))
		return CurrentDriver;

	return "";
}

function ListAvailableVideoDrivers()
{
	local string NextDesc, NextDefault;
	local string ClassLeft, ClassRight;

	VideoCombo.Clear();

	foreach GetPlayerOwner().IntDescIterator(string(class'Engine.RenderDevice'), NextDefault, NextDesc, true)
	{
		if (Len(NextDesc) == 0)
		{
			if (!Divide(NextDefault, ".", ClassLeft, ClassRight))
				continue;
			NextDesc = Localize(ClassRight, "ClassCaption", ClassLeft);
		}
		VideoCombo.AddItem(NextDesc, NextDefault);
	}

	VideoCombo.Sort();
}

function LoadVideoDriverSettings()
{
	local string CurrentDriver, S;
	local RenderDevice Renderer;
	local int i;
	local bool bNotAvailable;

	CurrentDriver = GetVideoDriverClassName();
	if (Len(CurrentDriver) == 0)
	{
		bNotAvailable = true;
		foreach AllObjects(class'Engine.RenderDevice', Renderer)
		{
			CurrentDriver = string(Renderer.Class);
			break;
		}
	}

	if (Len(CurrentDriver) > 0)
	{
		i = VideoCombo.FindItemIndex2(CurrentDriver);
		if (i >= 0)
		{
			VideoCombo.SetSelectedIndex(i);
			if (bNotAvailable)
				VideoCombo.SetValue("*" @ VideoCombo.GetValue());
		}
		else
		{
			while (Divide(CurrentDriver, ".", S, CurrentDriver)) {}
			VideoCombo.SetValue("*" @ CurrentDriver);
		}
	}
	else
		VideoCombo.SetValue("");
}

function LoadPawnShadowSettings()
{
	if (!class'GameInfo'.default.bCastShadow)
		OldShadowCmb = 0;
	else if (!class'GameInfo'.default.bUseRealtimeShadow)
		OldShadowCmb = 1;
	else if (
		class'PawnShadow'.default.ShadowDetailRes < 8 ||
		(class'PawnShadow'.default.ShadowDetailRes & (class'PawnShadow'.default.ShadowDetailRes - 1)) != 0) // not a power of 2
	{
		OldShadowCmb = 2;
		// Note: this property can't be changed by console command Set in an online game
		class'PawnShadow'.default.ShadowDetailRes = 128;
		class'ObjectShadow'.static.UpdateAllShadows(GetLevel(), true);
		class'PawnShadow'.static.StaticSaveConfig();
	}
	else if (class'PawnShadow'.default.ShadowDetailRes <= 128)
		OldShadowCmb = 2;
	else if (class'PawnShadow'.default.ShadowDetailRes == 256)
		OldShadowCmb = 3;
	else if (class'PawnShadow'.default.ShadowDetailRes == 512)
		OldShadowCmb = 4;
	else if (class'PawnShadow'.default.ShadowDetailRes >= 1024)
		OldShadowCmb = 5;

	if (OldShadowCmb <= 5)
		PawnShadowCombo.SetSelectedIndex(OldShadowCmb);
	else
	{
		PawnShadowCombo.EditBox.Value = PawnShadowList[5];
		PawnShadowCombo.EditBox.Value2 = "5";
	}

	DecoShadowsCheck.bChecked = class'GameInfo'.default.bDecoShadows;

	ShadowDistanceCombo.SetDisabled(!class'GameInfo'.default.bCastShadow && !class'GameInfo'.default.bDecoShadows);
	if( Class'ObjectShadow'.Default.OcclusionDistance<=0.01f )
		ShadowDistanceCombo.SetSelectedIndex(5);
	else if( Class'ObjectShadow'.Default.OcclusionDistance<=0.75f )
		ShadowDistanceCombo.SetSelectedIndex(0);
	else if( Class'ObjectShadow'.Default.OcclusionDistance<=1.5f )
		ShadowDistanceCombo.SetSelectedIndex(1);
	else if( Class'ObjectShadow'.Default.OcclusionDistance<=2.5f )
		ShadowDistanceCombo.SetSelectedIndex(2);
	else if( Class'ObjectShadow'.Default.OcclusionDistance<=4.5f )
		ShadowDistanceCombo.SetSelectedIndex(3);
	else ShadowDistanceCombo.SetSelectedIndex(4);
}

function LoadConditionallySupportedSettings()
{
	local PlayerPawn P;
	local string CurrentDriver, DriverClassName, DriverPackageName, S;
	local Property DriverProperty;
	local Object DriverPropertyEnum;
	local string PropertyOptions;
	local array<string> DisplayedOptions;
	local string CurrentValue;
	local bool BoolValue;
	local int IntValue;
	local int i, OptionsCount;
	local bool bNoFiltering, bSupportedSetting;
	local string FilteringPrefix;

	P = GetPlayerOwner();

	CurrentDriver = GetVideoDriverClassName();
	if (Len(CurrentDriver) == 0)
	{
		UsePrecacheCheck.bDisabled = true;
		UsePrecacheCheck.bChecked = false;
		TrilinearFilteringCheck.bDisabled = true;
		TrilinearFilteringCheck.bChecked = false;
		AnisotropicFilteringCombo.SetDisabled(true);
		AnisotropicFilteringCombo.SetValue(NotAvailableText);
		AntialiasingCombo.SetDisabled(true);
		AntialiasingCombo.SetValue(NotAvailableText);
		VSyncCombo.SetDisabled(true);
		VSyncCombo.SetValue(NotAvailableText);
		return;
	}

	Divide(CurrentDriver, ".", DriverPackageName, DriverClassName);

	// Use Precache
	BoolValue = false;
	if (BoolProperty(FindObj(class'Property', CurrentDriver $ ".UsePrecache")) != none)
	{
		UsePrecachePropertyName = "UsePrecache";
		BoolValue = bool(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice UsePrecache"));
	}
	else if (BoolProperty(FindObj(class'Property', CurrentDriver $ ".Precache")) != none)
	{
		UsePrecachePropertyName = "Precache";
		BoolValue = bool(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice Precache"));
	}
	else
		UsePrecachePropertyName = "";

	UsePrecacheCheck.bDisabled = Len(UsePrecachePropertyName) == 0;
	UsePrecacheCheck.bChecked = BoolValue;

	// Texture filtering options
	bSupportsNoFiltering = BoolProperty(FindObj(class'Property', CurrentDriver $ ".NoFiltering")) != none;
	if (bSupportsNoFiltering)
		bNoFiltering = bool(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice NoFiltering"));

	// Trilinear Filtering
	TrilinearFilteringCheck.bDisabled = BoolProperty(FindObj(class'Property', CurrentDriver $ ".UseTrilinear")) == none;
	if (bNoFiltering || TrilinearFilteringCheck.bDisabled)
		TrilinearFilteringCheck.bChecked = false;
	else
		TrilinearFilteringCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice UseTrilinear"));
	
	// NoSmooth rendering
	NoSmoothRenderCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseNoSmoothWorld"));
	
	// HD Textures
	HDTexturesCheck.bChecked = bool(P.ConsoleCommand("get ini:Engine.Engine.ViewportManager UseHDTextures"));

	// Anisotropic Filtering
	bSupportedSetting = false;
	if (Property(FindObj(class'Property', CurrentDriver $ ".MaxAnisotropy")) != none)
	{
		bSupportedSetting = true;
		PropertyOptions = "MaxAnisotropy=0";
		Array_Size(DisplayedOptions, 0);
		OptionsCount = 0;
		DisplayedOptions[OptionsCount++] = AnisotropicFilteringModes[0];
		IntValue = 0;
		if (!bNoFiltering)
			IntValue = int(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice MaxAnisotropy"));
		if (IntValue > 1)
			CurrentValue = ReplaceStr(AnisotropicFilteringModes[1], "%N", string(IntValue));
		else
			CurrentValue = AnisotropicFilteringModes[0];

		if (bSupportsNoFiltering)
			FilteringPrefix = "NoFiltering=False,";
		for (i = 0; i < 4; ++i)
		{
			PropertyOptions @= FilteringPrefix $ "MaxAnisotropy=" $ (2 << i);
			DisplayedOptions[OptionsCount++] = ReplaceStr(AnisotropicFilteringModes[1], "%N", string(2 << i));
		}
	}
	else
		CurrentValue = NotAvailableText;

	if (AnisotropicFilteringComboOptions != PropertyOptions)
	{
		AnisotropicFilteringCombo.Clear();
		AnisotropicFilteringComboOptions = PropertyOptions;
		i = 0;
		while (GetNextValue(PropertyOptions, S))
			AnisotropicFilteringCombo.AddItem(DisplayedOptions[i++], S);
	}
	AnisotropicFilteringCombo.SetDisabled(!bSupportedSetting);
	AnisotropicFilteringCombo.SetValue(CurrentValue);

	// Antialiasing
	bSupportedSetting = false;
	PropertyOptions = "";
	CurrentValue = NotAvailableText;
	Array_Size(DisplayedOptions, 0);
	OptionsCount = 0;
	if (Property(FindObj(class'Property', CurrentDriver $ ".NumAASamples")) != none)
	{
		bSupportedSetting = true;

		if (BoolProperty(FindObj(class'Property', CurrentDriver $ ".UseAA")) != none)
		{
			BoolValue = bool(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice UseAA"));
			if (Property(FindObj(class'Property', CurrentDriver $ ".NumAASamples")) != none)
			{
				PropertyOptions = "UseAA=False";
				DisplayedOptions[OptionsCount++] = AntialiasingModes[0];
				for (i = 0; i < 3; ++i)
				{
					PropertyOptions @= "UseAA=True,NumAASamples=" $ (2 << i);
					DisplayedOptions[OptionsCount++] = ReplaceStr(AntialiasingModes[2], "%N", string(2 << i));
				}
				if (BoolValue)
					IntValue = int(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice NumAASamples"));
				if (BoolValue && IntValue > 1)
					CurrentValue = ReplaceStr(AntialiasingModes[2], "%N", string(IntValue));
				else
					CurrentValue = AntialiasingModes[0];
			}
			else
			{
				PropertyOptions = "UseAA=False UseAA=True";
				DisplayedOptions[OptionsCount++] = AntialiasingModes[0];
				DisplayedOptions[OptionsCount++] = AntialiasingModes[1];
				CurrentValue = DisplayedOptions[int(BoolValue)];
			}
		}
		else
		{
			PropertyOptions = "NumAASamples=0";
			DisplayedOptions[OptionsCount++] = AntialiasingModes[0];
			for (i = 0; i < 3; ++i)
			{
				PropertyOptions @= "NumAASamples=" $ (2 << i);
				DisplayedOptions[OptionsCount++] = ReplaceStr(AntialiasingModes[2], "%N", string(2 << i));
			}
			IntValue = int(P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice NumAASamples"));
			if (IntValue > 1)
				CurrentValue = ReplaceStr(AntialiasingModes[2], "%N", string(IntValue));
			else
				CurrentValue = AntialiasingModes[0];
		}
	}

	if (AntialiasingComboOptions != PropertyOptions)
	{
		AntialiasingCombo.Clear();
		AntialiasingComboOptions = PropertyOptions;
		i = 0;
		while (GetNextValue(PropertyOptions, S))
			AntialiasingCombo.AddItem(DisplayedOptions[i++], S);
	}
	AntialiasingCombo.SetDisabled(!bSupportedSetting);
	AntialiasingCombo.SetValue(CurrentValue);

	// V-Sync
	PropertyOptions = "";
	CurrentValue = NotAvailableText;
	IntValue = -1;
	DriverProperty = Property(FindObj(class'Property', CurrentDriver $ ".UseVSync"));
	if (ByteProperty(DriverProperty) != none)
	{
		CurrentValue = P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice UseVSync");
		DriverPropertyEnum = FindObj(class'Enum', CurrentDriver $ ".VSyncs");
		if (DriverPropertyEnum != none &&
			FindEnumOption(DriverPropertyEnum, "Off") >= 0 &&
			FindEnumOption(DriverPropertyEnum, "On") >= 0)
		{
			PropertyOptions = "UseVSync=Off UseVSync=On";
			if (FindEnumOption(DriverPropertyEnum, "Adaptive") >= 0)
				PropertyOptions @= "UseVSync=Adaptive";

			if (CurrentValue ~= "Off")
				IntValue = 0;
			else if (CurrentValue ~= "On")
				IntValue = 1;
			else if (CurrentValue ~= "Adaptive")
				IntValue = 2;
		}
	}
	else if (BoolProperty(DriverProperty) != none)
	{
		PropertyOptions = "UseVSync=False UseVSync=True";
		CurrentValue = P.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice UseVSync");
		IntValue = int(bool(CurrentValue));
	}

	if (VSyncComboOptions != PropertyOptions)
	{
		VSyncCombo.Clear();
		VSyncComboOptions = PropertyOptions;
		i = 0;
		while (GetNextValue(PropertyOptions, S))
			VSyncCombo.AddItem(VSyncModes[i++], S);
	}
	VSyncCombo.SetDisabled(IntValue < 0);
	if (IntValue >= 0)
		VSyncCombo.SetValue(VSyncModes[IntValue]);
	else
		VSyncCombo.SetValue(CurrentValue);
}

function int FindEnumOption(Object EnumObject, string Option)
{
	local int i;
	local name EnumeratorName;

	while (true)
	{
		EnumeratorName = GetEnum(EnumObject, i);
		if (EnumeratorName == '')
			return -1;
		if (Option ~= string(EnumeratorName))
			return i;
		++i;
	}
}

function bool GetNextValue(out string ValueList, out string Value)
{
	if (Len(ValueList) == 0)
		return false;
	if (Divide(ValueList, " ", Value, ValueList))
		return true;
	Value = ValueList;
	ValueList = "";
	return true;
}

function ResolutionChanged(float W, float H)
{
	Super.ResolutionChanged(H, H);
	if (GetPlayerOwner().ConsoleCommand("GetCurrentRes") != ResolutionCombo.GetValue())
		LoadAvailableSettings();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, CheckboxWidth;
	local int LabelHSpacing, LabelAreaWidth, RightSpacing;
	local float LabelTextAreaWidth;

	Super.BeforePaint(C, X, Y);

	LabelTextAreaWidth = 0;
	VideoCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ShowWindowedCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	if( BorderlessFSCheck )
		BorderlessFSCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ResolutionCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	FovAngleEdit.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ColorDepthCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	TextureDetailCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SkinDetailCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	BrightnessSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ScaleCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	MouseSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	GuiSkinCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	PawnShadowCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ShowDecalsCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ShadowDistanceCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	ShowSpecularCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	DynamicLightsCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	WeaponFlashCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	MinFramerateEdit.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	DecoShadowsCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	FlatShadingCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	//CurvyMeshCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	LightLODSlider.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	SkyFogCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	UsePrecacheCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	TrilinearFilteringCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	NoSmoothRenderCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	HDTexturesCheck.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	AnisotropicFilteringCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	AntialiasingCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);
	VSyncCombo.GetMinTextAreaWidth(C, LabelTextAreaWidth);

	LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth) / 3;
	RightSpacing = VScrollbarWidth() + 3;
	if (LabelHSpacing < RightSpacing)
		LabelHSpacing = (WinWidth - LabelTextAreaWidth - EditAreaWidth - RightSpacing) / 2;
	LabelAreaWidth = LabelTextAreaWidth + LabelHSpacing;
	ControlWidth = LabelAreaWidth + EditAreaWidth;
	CheckboxWidth = ControlWidth - EditAreaWidth + 16;
	ControlLeft = LabelHSpacing;

	VideoCombo.SetSize(ControlWidth, 1);
	VideoCombo.WinLeft = ControlLeft;
	VideoCombo.EditBoxWidth = EditAreaWidth;

	ShowWindowedCheck.SetSize(CheckboxWidth, 1);
	ShowWindowedCheck.WinLeft = ControlLeft;

	if( BorderlessFSCheck )
	{
		BorderlessFSCheck.SetSize(CheckboxWidth, 1);
		BorderlessFSCheck.WinLeft = ControlLeft;
	}

	ResolutionCombo.SetSize(ControlWidth, 1);
	ResolutionCombo.WinLeft = ControlLeft;
	ResolutionCombo.EditBoxWidth = EditAreaWidth;

	FovAngleEdit.SetSize(ControlWidth, 1);
	FovAngleEdit.WinLeft = ControlLeft;
	FovAngleEdit.EditBoxWidth = EditAreaWidth;

	ColorDepthCombo.SetSize(ControlWidth, 1);
	ColorDepthCombo.WinLeft = ControlLeft;
	ColorDepthCombo.EditBoxWidth = EditAreaWidth;

	TextureDetailCombo.SetSize(ControlWidth, 1);
	TextureDetailCombo.WinLeft = ControlLeft;
	TextureDetailCombo.EditBoxWidth = EditAreaWidth;

	SkinDetailCombo.SetSize(ControlWidth, 1);
	SkinDetailCombo.WinLeft = ControlLeft;
	SkinDetailCombo.EditBoxWidth = EditAreaWidth;

	BrightnessSlider.SetSize(ControlWidth, 1);
	BrightnessSlider.SliderWidth = EditAreaWidth;
	BrightnessSlider.WinLeft = ControlLeft;

	ScaleCombo.SetSize(ControlWidth, 1);
	ScaleCombo.WinLeft = ControlLeft;
	ScaleCombo.EditBoxWidth = EditAreaWidth;

	MouseSlider.SetSize(ControlWidth, 1);
	MouseSlider.SliderWidth = EditAreaWidth;
	MouseSlider.WinLeft = ControlLeft;

	GuiSkinCombo.SetSize(ControlWidth, 1);
	GuiSkinCombo.WinLeft = ControlLeft;
	GuiSkinCombo.EditBoxWidth = EditAreaWidth;

	PawnShadowCombo.SetSize(ControlWidth, 1);
	PawnShadowCombo.WinLeft = ControlLeft;
	PawnShadowCombo.EditBoxWidth = EditAreaWidth;

	ShowDecalsCheck.SetSize(CheckboxWidth, 1);
	ShowDecalsCheck.WinLeft = ControlLeft;

	ShadowDistanceCombo.SetSize(ControlWidth, 1);
	ShadowDistanceCombo.WinLeft = ControlLeft;
	ShadowDistanceCombo.EditBoxWidth = EditAreaWidth;

	ShowSpecularCheck.SetSize(CheckboxWidth, 1);
	ShowSpecularCheck.WinLeft = ControlLeft;

	DynamicLightsCheck.SetSize(CheckboxWidth, 1);
	DynamicLightsCheck.WinLeft = ControlLeft;

	WeaponFlashCheck.SetSize(CheckboxWidth, 1);
	WeaponFlashCheck.WinLeft = ControlLeft;

	MinFramerateEdit.EditBoxWidth = 30;
	MinFramerateEdit.SetSize(ControlWidth - EditAreaWidth + MinFramerateEdit.EditBoxWidth, 1);
	MinFramerateEdit.WinLeft = ControlLeft;

	DecoShadowsCheck.SetSize(CheckboxWidth, 1);
	DecoShadowsCheck.WinLeft = ControlLeft;

	FlatShadingCheck.SetSize(CheckboxWidth, 1);
	FlatShadingCheck.WinLeft = ControlLeft;

	//CurvyMeshCheck.SetSize(CheckboxWidth, 1);
	//CurvyMeshCheck.WinLeft = ControlLeft;

	SkyFogCombo.SetSize(ControlWidth, 1);
	SkyFogCombo.WinLeft = ControlLeft;
	SkyFogCombo.EditBoxWidth = EditAreaWidth;

	LightLODSlider.SetSize(ControlWidth, 1);
	LightLODSlider.SliderWidth = EditAreaWidth;
	LightLODSlider.WinLeft = ControlLeft;

	UsePrecacheCheck.SetSize(CheckboxWidth, 1);
	UsePrecacheCheck.WinLeft = ControlLeft;

	TrilinearFilteringCheck.SetSize(CheckboxWidth, 1);
	TrilinearFilteringCheck.WinLeft = ControlLeft;

	NoSmoothRenderCheck.SetSize(CheckboxWidth, 1);
	NoSmoothRenderCheck.WinLeft = ControlLeft;

	HDTexturesCheck.SetSize(CheckboxWidth, 1);
	HDTexturesCheck.WinLeft = ControlLeft;

	AnisotropicFilteringCombo.SetSize(ControlWidth, 1);
	AnisotropicFilteringCombo.WinLeft = ControlLeft;
	AnisotropicFilteringCombo.EditBoxWidth = EditAreaWidth;

	AntialiasingCombo.SetSize(ControlWidth, 1);
	AntialiasingCombo.WinLeft = ControlLeft;
	AntialiasingCombo.EditBoxWidth = EditAreaWidth;

	VSyncCombo.SetSize(ControlWidth, 1);
	VSyncCombo.WinLeft = ControlLeft;
	VSyncCombo.EditBoxWidth = EditAreaWidth;
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
		case ResolutionCombo:
		case ColorDepthCombo:
			SettingsChanged();
			break;
		case FovAngleEdit:
			FovAngleChanged();
			break;
		case TextureDetailCombo:
			TextureDetailChanged();
			break;
		case SkinDetailCombo:
			SkinDetailChanged();
			break;
		case BrightnessSlider:
			BrightnessChanged();
			break;
		case ScaleCombo:
			ScaleChanged();
			break;
		case MouseSlider:
			MouseChanged();
			break;
		case ShowDecalsCheck:
			DecalsChanged();
			break;
		case ShowSpecularCheck:
			SpecularChanged();
			break;
		case DynamicLightsCheck:
			DynamicChanged();
			break;
		case WeaponFlashCheck:
			WeaponFlashChanged();
			break;
		case MinFramerateEdit:
			MinFramerateChanged();
			break;
		case PawnShadowCombo:
			ShadowsChanged(0);
			break;
		case DecoShadowsCheck:
			ShadowsChanged(1);
			break;
		case ShadowDistanceCombo:
			ShadowsChanged(2);
			break;
		case FlatShadingCheck:
			FlatShadingChanged();
			break;
		/*case CurvyMeshCheck:
			CurvySurfsChanged();
			break;*/
		case SkyFogCombo:
			SkyFogDetailChanged();
			break;
		case LightLODSlider:
			LightLODChange();
			break;
		case UsePrecacheCheck:
			UsePrecacheChanged();
			break;
		case TrilinearFilteringCheck:
			TrilinearFilteringChanged();
			break;
		case NoSmoothRenderCheck:
			NoSmoothRenderChanged();
			break;
		case HDTexturesCheck:
			HDTexturesChanged();
			break;
		case AnisotropicFilteringCombo:
			AnisotropicFilteringChanged();
			break;
		case AntialiasingCombo:
			AntialiasingChanged();
			break;
		case VSyncCombo:
			VSyncChanged();
			break;
		case VideoCombo:
			VideoComboChanged();
			break;
		case ShowWindowedCheck:
			ShowWindowedChanged();
			break;
		case BorderlessFSCheck:
			if( BorderlessFSCheck )
				ShowWindowedChanged();
			break;
		}
		break;
	}
}

function SettingsChanged()
{
	local string NewSettings;

	if (bInitialized)
	{
		OldSettings = GetPlayerOwner().ConsoleCommand("GetCurrentRes")$"x"$GetPlayerOwner().ConsoleCommand("GetCurrentColorDepth");
		NewSettings = ResolutionCombo.GetValue()$"x"$ColorDepthCombo.GetValue2();

		if (NewSettings != OldSettings)
		{
			GetPlayerOwner().ConsoleCommand("SetRes "$NewSettings);
			LoadAvailableSettings();
			ConfirmSettings = MessageBox(ConfirmSettingsTitle, ConfirmSettingsText, MB_YesNo, MR_No, MR_None, 10);
		}
	}
}

function WideScreenChange(); // unused, replaced with FovAngleChanged

function FovAngleChanged()
{
	GetPlayerOwner().UpdateWideScreen(FClamp(float(FovAngleEdit.GetValue()), 1, 170));
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if (W == ConfirmSettings)
	{
		ConfirmSettings = none;
		if (Result != MR_Yes)
		{
			GetPlayerOwner().ConsoleCommand("SetRes "$OldSettings);
			LoadAvailableSettings();
			MessageBox(ConfirmSettingsCancelTitle, ConfirmSettingsCancelText, MB_OK, MR_OK, MR_OK);
		}
	}
	if (W == ConfirmSkinTextureDetail)
	{
		if (Result == MR_Yes)
			OldSkinDetail = SkinDetailCombo.GetSelectedIndex();
		else
			SkinDetailCombo.SetSelectedIndex(OldSkinDetail);
	}
	if (W == ConfirmWorldTextureDetail)
	{
		if (Result == MR_Yes)
			OldTextureDetail = TextureDetailCombo.GetSelectedIndex();
		else
			TextureDetailCombo.SetSelectedIndex(OldTextureDetail);
	}
}

function TextureDetailChanged()
{
	if (bInitialized)
	{
		TextureDetailSet();
		if ( TextureDetailCombo.GetSelectedIndex() < OldTextureDetail )
			ConfirmWorldTextureDetail = MessageBox(ConfirmTextureDetailTitle, ConfirmTextureDetailText, MB_YesNo, MR_No, MR_None);
		else
			OldTextureDetail = TextureDetailCombo.GetSelectedIndex();
	}
}

function TextureDetailSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail" @ TextureDetailCombo.GetValue2());
}

function SkinDetailChanged()
{
	if (bInitialized)
	{
		SkinDetailSet();
		if ( SkinDetailCombo.GetSelectedIndex() < OldSkinDetail )
			ConfirmSkinTextureDetail = MessageBox(ConfirmTextureDetailTitle, ConfirmTextureDetailText, MB_YesNo, MR_No, MR_None);
		else
			OldSkinDetail = SkinDetailCombo.GetSelectedIndex();
	}
}

function SkinDetailSet()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager SkinDetail" @ SkinDetailCombo.GetValue2());
}

function SkyFogDetailChanged()
{
	if (bInitialized)
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager SkyBoxFogMode" @ SkyFogCombo.GetValue2());
}

function BrightnessChanged()
{
	if (bInitialized)
	{
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness" @ (BrightnessSlider.Value / 10));
		GetPlayerOwner().ConsoleCommand("FLUSH");
	}
}

function ScaleChanged()
{
	if (bInitialized)
	{
		Root.SetScale(float(ScaleCombo.GetValue2())/10);
		Root.SaveConfig();
	}
}

function MouseChanged()
{
	if (bInitialized)
	{
		Root.Console.MouseScale = (MouseSlider.Value / 100);
		Root.Console.SaveConfig();
	}
}

function DecalsChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager Decals" @ ShowDecalsCheck.bChecked);
}

function LightLODChange()
{
	if (bInitialized)
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager LightMapLOD" @ int(LightLODSlider.Value));
}

function SpecularChanged()
{
	GetPlayerOwner().Level.bDisableSpeclarLight = !ShowSpecularCheck.bChecked;
	GetPlayerOwner().Level.SaveConfig();
}

function DynamicChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager NoDynamicLights" @ !DynamicLightsCheck.bChecked);
}

function WeaponFlashChanged()
{
	GetPlayerOwner().bNoFlash = !WeaponFlashCheck.bChecked;
}

function FlatShadingChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager FlatShading" @ FlatShadingCheck.bChecked);
}

function CurvySurfsChanged()
{
	//GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager CurvedSurfaces" @ CurvyMeshCheck.bChecked);
}

function MinFramerateChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager MinDesiredFrameRate" @ MinFramerateEdit.EditBox.Value);
}

function UsePrecacheChanged()
{
	local bool bChecked;

	bChecked = UsePrecacheCheck.bChecked;
	bInitialized = false;
	LoadConditionallySupportedSettings();
	bInitialized = true;

	if (Len(UsePrecachePropertyName) > 0)
	{
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice" @ UsePrecachePropertyName @ bChecked);
		UsePrecacheCheck.bChecked = bChecked;
	}
}

function TrilinearFilteringChanged()
{
	local bool bChecked;

	bChecked = TrilinearFilteringCheck.bChecked;
	bInitialized = false;
	LoadConditionallySupportedSettings();
	if (!TrilinearFilteringCheck.bDisabled)
	{
		if (bSupportsNoFiltering && bChecked)
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice NoFiltering False");
		GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice UseTrilinear" @ bChecked);
		LoadConditionallySupportedSettings(); // refreshes Trilinear Filtering & Anisotropic Filtering
	}
	bInitialized = true;
}

function NoSmoothRenderChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager UseNoSmoothWorld "$string(NoSmoothRenderCheck.bChecked));
}

function HDTexturesChanged()
{
	GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.ViewportManager UseHDTextures "$string(HDTexturesCheck.bChecked));
}

function AnisotropicFilteringChanged()
{
	local string SelectedOption;

	SelectedOption = AnisotropicFilteringCombo.GetValue2();
	bInitialized = false;
	LoadConditionallySupportedSettings();
	if (AnisotropicFilteringCombo.FindItemIndex2(SelectedOption) >= 0)
	{
		SetVideoDriverProperties(SelectedOption);
		GetPlayerOwner().ConsoleCommand("FLUSH");
		LoadConditionallySupportedSettings(); // refreshes Trilinear Filtering & Anisotropic Filtering
	}
	bInitialized = true;
}

function AntialiasingChanged()
{
	local string SelectedOption;
	local int SelectedOptionIndex;

	SelectedOption = AntialiasingCombo.GetValue2();
	bInitialized = false;
	LoadConditionallySupportedSettings();
	SelectedOptionIndex = AntialiasingCombo.FindItemIndex2(SelectedOption);
	if (SelectedOptionIndex >= 0)
	{
		SetVideoDriverProperties(SelectedOption);
		GetPlayerOwner().ConsoleCommand("FLUSH");
		AntialiasingCombo.SetSelectedIndex(SelectedOptionIndex);
	}
	bInitialized = true;
}

function VSyncChanged()
{
	local string SelectedOption;
	local int SelectedOptionIndex;

	SelectedOption = VSyncCombo.GetValue2();
	bInitialized = false;
	LoadConditionallySupportedSettings();
	SelectedOptionIndex = VSyncCombo.FindItemIndex2(SelectedOption);
	if (SelectedOptionIndex >= 0)
	{
		SetVideoDriverProperties(SelectedOption);
		VSyncCombo.SetSelectedIndex(SelectedOptionIndex);
		GetPlayerOwner().ConsoleCommand("FLUSH");
	}
	bInitialized = true;
}

function VideoComboChanged()
{
	Driver = VideoCombo.GetValue2();
	class'UMenuVideoClientWindow'.default.Driver = Driver;
}

function ShowWindowedChanged()
{
	local PlayerPawn P;

	P = GetPlayerOwner();

	if( bSupportsBorderless )
	{
		P.ConsoleCommand("SET INI:Engine.Engine.ViewportManager UseDesktopFullScreen " $ BorderlessFSCheck.bChecked);
		if( BorderlessFSCheck.bChecked )
		{
			ShowWindowedCheck.bDisabled = true;
			ResolutionCombo.SetDisabled(true);
			return;
		}
		ShowWindowedCheck.bDisabled = false;
		ResolutionCombo.SetDisabled(false);
		return;
	}
	P.ConsoleCommand("ENDFULLSCREEN");
	if (ShowWindowedCheck.bChecked)
		P.ConsoleCommand("TOGGLEFULLSCREEN");

	bFullScreen = ShowWindowedCheck.bChecked;

	P.ConsoleCommand("SET INI:Engine.Engine.ViewportManager StartupFullscreen " $ ShowWindowedCheck.bChecked);
	P.SaveConfig();
}

function ShadowsChanged(byte Idx)
{
	local PlayerPawn P;
	local int i;

	P = GetPlayerOwner();

	switch (Idx)
	{
	case 0:
		i = PawnShadowCombo.GetSelectedIndex();
		if (i >= 0 && i != OldShadowCmb)
		{
			OldShadowCmb = i;
			if (i == 0 || i > 5)
				P.ConsoleCommand("Set Engine.GameInfo bCastShadow false");
			else
			{
				P.ConsoleCommand("set Engine.GameInfo bCastShadow true");
				P.ConsoleCommand("set Engine.GameInfo bUseRealtimeShadow " $ (i >= 2));
				if (i >= 2)
				{
					// Note: this property can't be changed by console command Set in an online game
					class'PawnShadow'.default.ShadowDetailRes = 128 << (i - 2); // 128, 256, 512
					class'PawnShadow'.static.StaticSaveConfig();
				}
			}
			class'ObjectShadow'.static.UpdateAllShadows(GetLevel(), true);
		}
		break;
	case 1:
		P.ConsoleCommand("set Engine.GameInfo bDecoShadows" @ DecoShadowsCheck.bChecked);
		class'ObjectShadow'.static.UpdateAllShadows(GetLevel(), true);
		break;
	case 2:
		switch( ShadowDistanceCombo.GetSelectedIndex() )
		{
		case 0:
			Class'ObjectShadow'.Default.OcclusionDistance = 0.5f;
			break;
		case 1:
			Class'ObjectShadow'.Default.OcclusionDistance = 1.f;
			break;
		case 2:
			Class'ObjectShadow'.Default.OcclusionDistance = 2.f;
			break;
		case 3:
			Class'ObjectShadow'.Default.OcclusionDistance = 4.f;
			break;
		case 4:
			Class'ObjectShadow'.Default.OcclusionDistance = 8.f;
			break;
		default:
			Class'ObjectShadow'.Default.OcclusionDistance = 0.f;
			break;
		}
		Class'ObjectShadow'.static.StaticSaveConfig();
		class'ObjectShadow'.static.UpdateAllShadows(GetLevel(), true);
		break;
	}

	ShadowDistanceCombo.SetDisabled(!class'GameInfo'.default.bCastShadow && !class'GameInfo'.default.bDecoShadows);
}

function SetVideoDriverProperties(string AssignmentList)
{
	local string Assignment, PropertyName, Value;

	AssignmentList $= ",";
	while (Divide(AssignmentList, ",", Assignment, AssignmentList))
		if (Divide(Assignment, "=", PropertyName, Value) && Len(PropertyName) > 0)
			GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice" @ PropertyName @ Value);
}

function SaveConfigs()
{
	Root.Console.SaveConfig();
	Super.SaveConfigs();
	if (GuiSkinCombo.GetValue2() != Root.LookAndFeelClass)
		Root.ChangeLookAndFeel(GuiSkinCombo.GetValue2());
}

defaultproperties
{
	EditAreaWidth=110

	DriverText="Video Driver"
	DriverHelp="This is the current video driver. Press the Restart button to apply changes."

	ShowWindowedText="Show Fullscreen"
	ShowWindowedHelp="Whether Unreal should use fullscreen mode."

	BorderlessFSText="Fake Fullscreen"
	BorderlessFSHelp="Unreal should run game in fake fullscreen (borderless windowed) mode."

	ResolutionText="Resolution"
	ResolutionHelp="Select a new screen resolution."

	ColorDepthText="Color Depth"
	ColorDepthHelp="Select a new color depth."
	BitsText="bit"

	TextureDetailText="World Texture Detail"
	TextureDetailHelp="Change the texture detail of world geometry.  Use a lower texture detail to improve game performance."
	Details(0)="High"
	Details(1)="Medium"
	Details(2)="Low"

	SkinDetailText="Skin Detail"
	SkinDetailHelp="Change the detail of player skins.  Use a lower skin detail to improve game performance."

	BrightnessText="Brightness"
	BrightnessHelp="Adjust display brightness."

	ScaleText="Font Size"
	ScaleHelp="Adjust the size of elements in the User Interface."
	ScaleSizes(0)="Normal"
	ScaleSizes(1)="Double"

	HUDScaleText="HUD Scaling"
	HUDScaleHelp="Adjust the size of the in-game Heads-up-Display."

	MouseText="GUI Mouse Speed"
	MouseHelp="Adjust the speed of the mouse in the User Interface."

	GuiSkinText="GUI Skin"
	GuiSkinHelp="Change the look of the User Interface windows to a custom skin."

	ConfirmSettingsTitle="Confirm Video Settings Change"
	ConfirmSettingsText="Are you sure you wish to keep these new video settings?"
	ConfirmSettingsCancelTitle="Video Settings Change"
	ConfirmSettingsCancelText="Your previous video settings have been restored."
	ConfirmTextureDetailTitle="Confirm Texture Detail"
	ConfirmTextureDetailText="Increasing texture detail above its default value may degrade performance on some machines."
	ConfirmDriverTitle="Change Video Driver"
	ConfirmDriverText="Do you want to restart Unreal with the selected video driver?"

	PawnShadowText="Pawn shadows"
	PawnShadowHelp="Detail of shadows that pawns should cast on ground (changes will take effect after mapchange)."
	PawnShadowList(0)="None"
	PawnShadowList(1)="Blob"
	PawnShadowList(2)="Realtime Low Res"
	PawnShadowList(3)="Realtime Med Res"
	PawnShadowList(4)="Realtime High Res"
	PawnShadowList(5)="Realtime Ultra Res"

	ShowDecalsText="Show Decals"
	ShowDecalsHelp="If checked, impact and gore decals will be used in game."

	ShowSpecularText="Enable Specular Lights"
	ShowSpecularHelp="If checked, allow game render meshes old style lighting."

	ShadowDistanceText="Shadow draw distance"
	ShadowDistanceHelp="Draw distance of pawn/decoration realtime shadows."
	ShadowDistanceOpts(0)="Low (-50 %)"
	ShadowDistanceOpts(1)="Medium"
	ShadowDistanceOpts(2)="Long (2x)"
	ShadowDistanceOpts(3)="High (4x)"
	ShadowDistanceOpts(4)="Ultra (8x)"
	ShadowDistanceOpts(5)="Unlimited"

	MinFramerateText="Min Desired Framerate"
	MinFramerateHelp="If your framerate falls below this value, Unreal will reduce special effects to increase the framerate."

	DynamicLightsText="Use Dynamic Lighting"
	DynamicLightsHelp="If checked, dynamic lighting will be used in game."

	WeaponFlashText="Weapon Flash"
	WeaponFlashHelp="If checked, your screen will flash when you fire your weapon."

	FovAngleText="FOV Angle"
	FovAngleHelp="Horizontal FOV (field of view) angle in degrees"

	DecoShadowsText="Decoration shadows"
	DecoShadowsHelp="Whether decorations should cast shadows to the ground."

	FlatShadingText="Mesh flat shading"
	FlatShadingHelp="Allow specific meshes render with flat shading lighting."

	CurvyMeshText="Curvy meshes"
	CurvyMeshHelp="Allow specific meshes render with some curved surfaces."

	UsePrecacheText="Precache Content"
	UsePrecacheHelp="Use this option for precaching map content (such as sounds and textures)."

	TrilinearFilteringText="Trilinear Filtering"
	TrilinearFilteringHelp="Trilinear texture filtering."
	
	NoSmoothRenderText="NoSmooth view filtering"
	NoSmoothRenderHelp="Disable world view texture smoothing (for that retro view mode)"
	
	HDTexturesText="Use HD Textures"
	HDTexturesHelp="Allow game to run with new HD textures when in hi-res mode."

	AnisotropicFilteringText="Anisotropic Filtering"
	AnisotropicFilteringHelp="Anisotropic texture filtering."
	AnisotropicFilteringModes(0)="Off"
	AnisotropicFilteringModes(1)="%Nx"

	AntialiasingText="Antialiasing"
	AntialiasingHelp="Antialiasing mode."
	AntialiasingModes(0)="Off"
	AntialiasingModes(1)="On"
	AntialiasingModes(2)="%Nx"

	VSyncText="Vertical Synchronization"
	VSyncHelp="Vertical synchronization"
	VSyncModes(0)="Off"
	VSyncModes(1)="On"
	VSyncModes(2)="Adaptive"

	NotAvailableText="Not available"
	ControlOffset=20.000000

	SkyFogText="Sky fog mode"
	SkyFogHelp="Change how volumetric fog is being rendered on skybox."

	LightLODText="Lightmap LOD"
	LightLODHelp="Change the lighting LOD aggressiveness on world (lower meaning it will cut down light framerate on complex scenes)."
}
