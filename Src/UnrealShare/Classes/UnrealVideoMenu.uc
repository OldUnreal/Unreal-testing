//=============================================================================
// UnrealVideoMenu
//=============================================================================
class UnrealVideoMenu extends UnrealLongMenu;

var float brightness;
var string CurrentRes;
var string AvailableRes;
var string AvailableShadowRes;
var string MenuValues[20];
var string Resolutions[48];
var const float HUDScalers[7];
var localized string LowText, HighText;
var localized string ShadowDetail[5],SkyFogDetail[3];
var int resNum,ShadowResNum,CurrentShadowRes,CurrentFogMode,CurrentHUDScale;
var int SoundVol, MusicVol, SpeechVol;
var bool bLowTextureDetail, bLowSoundQuality, bRealtimeShadow;
var float WideScreenValue;

function PostBeginPlay()
{
	local string S;
	local float F,Diff,BestDiff;
	local int i;

	Super.PostBeginPlay();
	
	PlayerOwner = GetLocalPlayerPawn();
	GetAvailableRes();
	GetShadowResNum();
	S = Caps(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager SkyBoxFogMode"));
	switch( S )
	{
	case "FOGDETAIL_LOW":
		CurrentFogMode = 1;
		break;
	case "FOGDETAIL_NONE":
		CurrentFogMode = 2;
		break;
	}
	F = Class'HUD'.Default.HudScaler;
	for(i=0; i<ArrayCount(HUDScalers); ++i )
	{
		Diff = Abs(F-HUDScalers[i]);
		if( !i || Diff<BestDiff )
		{
			BestDiff = Diff;
			CurrentHUDScale = i;
		}
	}
}
function bool ProcessLeft()
{
	if ( Selection == 1 )
	{
		Brightness = FMax(0.2, Brightness - 0.1);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$Brightness);
		PlayerOwner.ConsoleCommand("FLUSH");
		return true;
	}
	else if ( Selection == 3 )
	{
		ResNum--;
		if ( ResNum < 0 )
		{
			ResNum = ArrayCount(Resolutions) - 1;
			while ( Resolutions[ResNum] == "" )
			ResNum--;
		}
		MenuValues[3] = Resolutions[ResNum];
		return true;
	}
	else if ( Selection == 4 )
	{
		WideScreenValue = FMax(90, WideScreenValue - 1);
		PlayerOwner.UpdateWideScreen(WideScreenValue);
		return true;
	}
	else if ( Selection == 5 )
	{
		bLowTextureDetail = !bLowTextureDetail;
		if (bLowTextureDetail)
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail Medium");
		else
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail High");
		return true;
	}
	else if ( Selection == 6 )
	{
		MusicVol = Max(0, MusicVol - 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$MusicVol);
		return true;
	}
	else if ( Selection == 7 )
	{
		SoundVol = Max(0, SoundVol - 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume "$SoundVol);
		return true;
	}
	else if ( Selection == 8 )
	{
		SpeechVol = Max(0, SpeechVol - 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice SpeechVolume "$SpeechVol);
		return true;
	}
	else if ( Selection == 9 )
	{
		bLowSoundQuality = !bLowSoundQuality;
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
		return true;
	}
	else if ( Selection == 10 )
	{
		PlayerOwner.bNoVoices = !PlayerOwner.bNoVoices;
		return true;
	}
	else if ( Selection == 11 )
	{
		PlayerOwner.bMessageBeep = !PlayerOwner.bMessageBeep;
		return true;
	}
	else if ( Selection == 12 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager FlatShading False");
		return true;
	}
	else if ( Selection == 13 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager CurvedSurfaces False");
		return true;
	}
	else if ( Selection == 14 )
	{
		PlayerOwner.ConsoleCommand("set Engine.GameInfo bCastShadow False");
		return true;
	}
	else if ( Selection == 15 )
	{
		PlayerOwner.ConsoleCommand("set Engine.GameInfo bDecoShadows False");
		return true;
	}
	else if ( Selection == 16 )
	{
		GetShadowResNum();
		ShadowResNum--;
		if ( ShadowResNum < 0 )
		{
			ShadowResNum = 0;
		}
		SetShadowResNum();
		return true;
	}
	else if ( Selection == 17 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.GameRenderDevice UsePrecache False");
		return true;
	}
	else if ( Selection == 18 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.GameRenderDevice UseTrilinear False");
		return true;
	}
	else if ( Selection == 19 )
	{
		SetSkyFogType(-1);
		return true;
	}
	else if ( Selection == 20 )
	{
		SetHudScale(-1);
		return true;
	}
	return false;
}

function bool ProcessRight()
{
	if ( Selection == 1 )
	{
		Brightness = FMin(1, Brightness + 0.1);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$Brightness);
		PlayerOwner.ConsoleCommand("FLUSH");
		return true;
	}
	else if ( Selection == 3 )
	{
		ResNum++;
		if ( (ResNum >= ArrayCount(Resolutions)) || (Resolutions[ResNum] == "") )
			ResNum = 0;
		MenuValues[3] = Resolutions[ResNum];
		return true;
	}
	else if ( Selection == 4 )
	{
		WideScreenValue = FMin(170, WideScreenValue + 1);
		PlayerOwner.UpdateWideScreen(WideScreenValue);
		return true;
	}
	else if ( Selection == 5 )
	{
		bLowTextureDetail = !bLowTextureDetail;
		if (bLowTextureDetail)
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail Medium");
		else
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail High");
		return true;
	}
	else if ( Selection == 6 )
	{
		MusicVol = Min(255, MusicVol + 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume "$MusicVol);
		return true;
	}
	else if ( Selection == 7 )
	{
		SoundVol = Min(255, SoundVol + 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume "$SoundVol);
		return true;
	}
	else if ( Selection == 8 )
	{
		SpeechVol = Min(255, SpeechVol + 32);
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice SpeechVolume "$SpeechVol);
		return true;
	}
	else if ( Selection == 9 )
	{
		bLowSoundQuality = !bLowSoundQuality;
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
		return true;
	}
	else if ( Selection == 10 )
	{
		PlayerOwner.bNoVoices = !PlayerOwner.bNoVoices;
		return true;
	}
	else if ( Selection == 11 )
	{
		PlayerOwner.bMessageBeep = !PlayerOwner.bMessageBeep;
		return true;
	}
	else if ( Selection == 12 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager FlatShading True");
		return true;
	}
	else if ( Selection == 13 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager CurvedSurfaces True");
		return true;
	}
	else if ( Selection == 14 )
	{
		PlayerOwner.ConsoleCommand("set Engine.GameInfo bCastShadow True");
		return true;
	}
	else if ( Selection == 15 )
	{
		PlayerOwner.ConsoleCommand("set Engine.GameInfo bDecoShadows True");
		return true;
	}
	else if ( Selection == 16 )
	{
		GetShadowResNum();
		ShadowResNum++;
		if ( ShadowResNum > 3)
			ShadowResNum = 3;
		SetShadowResNum();
		return true;
	}
	else if ( Selection == 17 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.GameRenderDevice UsePrecache true");
		return true;
	}
	else if ( Selection == 18 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.GameRenderDevice UseTrilinear true");
		return true;
	}
	else if ( Selection == 19 )
	{
		SetSkyFogType(1);
		return true;
	}
	else if ( Selection == 20 )
	{
		SetHudScale(1);
		return true;
	}
	return false;
}

function bool ProcessSelection()
{
	if ( Selection == 2 )
	{
		PlayerOwner.ConsoleCommand("TOGGLEFULLSCREEN");
		CurrentRes = PlayerOwner.ConsoleCommand("GetCurrentRes");
		GetAvailableRes();
		return true;
	}
	else if ( Selection == 3 )
	{
		PlayerOwner.ConsoleCommand("SetRes "$MenuValues[3]);
		CurrentRes = PlayerOwner.ConsoleCommand("GetCurrentRes");
		GetAvailableRes();
		return true;
	}
	else if ( Selection == 5 )
	{
		bLowTextureDetail = !bLowTextureDetail;
		if (bLowTextureDetail)
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail Medium");
		else
			PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager TextureDetail High");
		return true;
	}
	else if ( Selection == 9 )
	{
		bLowSoundQuality = !bLowSoundQuality;
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowSoundQuality "$bLowSoundQuality);
		return true;
	}
	else if ( Selection == 10 )
	{
		PlayerOwner.bNoVoices = !PlayerOwner.bNoVoices;
		return true;
	}
	else if ( Selection == 11 )
	{
		PlayerOwner.bMessageBeep = !PlayerOwner.bMessageBeep;
		return true;
	}
	else if ( Selection == 12 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager FlatShading"@!bool(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager FlatShading")));
		return true;
	}
	else if ( Selection == 13 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.ViewportManager CurvedSurfaces"@!bool(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager CurvedSurfaces")));
		return true;
	}
	else if ( Selection == 14 )
	{
		PlayerOwner.ConsoleCommand("set Engine.GameInfo bCastShadow"@!bool(PlayerOwner.ConsoleCommand("get Engine.GameInfo bCastShadow")));
		return true;
	}
	else if ( Selection == 15 )
	{
		PlayerOwner.ConsoleCommand("set Engine.GameInfo bDecoShadows"@!bool(PlayerOwner.ConsoleCommand("get Engine.GameInfo bDecoShadows")));
		return true;
	}
	else if ( Selection == 16 )
	{
		SetShadowResNum();
		return true;
	}
	else if ( Selection == 17 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.GameRenderDevice UsePrecache"@!bool(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice UsePrecache")));
		return true;
	}
	else if ( Selection == 18 )
	{
		PlayerOwner.ConsoleCommand("set ini:Engine.Engine.GameRenderDevice UseTrilinear"@!bool(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.GameRenderDevice UseTrilinear")));
		return true;
	}
	else if ( Selection == 19 )
	{
		SetSkyFogType(1);
		return true;
	}
	else if ( Selection == 20 )
	{
		SetHudScale(1);
		return true;
	}
	return false;
}


function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, HelpPanelX;

	DrawBackGround(Canvas, (Canvas.ClipY < 250));
	HelpPanelX = 228;

	Spacing = Clamp(0.04 * Canvas.ClipY, 16, 32);
	StartX = Max(40, 0.5 * Canvas.ClipX - 120);

	DrawTitle(Canvas);
	StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// draw text
	DrawList(Canvas, false, Spacing, StartX, StartY);

	// draw icons
	Brightness = float(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
	DrawSlider(Canvas, StartX + 155, StartY + 1, (10 * Brightness - 2), 0, 1);

	SoundVol = int(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume"));
	MusicVol = int(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"));
	SpeechVol = int(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.AudioDevice SpeechVolume"));
	DrawSlider(Canvas, StartX + 155, StartY + 5*Spacing + 1, MusicVol, 0, 32);
	DrawSlider(Canvas, StartX + 155, StartY + 6*Spacing + 1, SoundVol, 0, 32);
	DrawSlider(Canvas, StartX + 155, StartY + 7*Spacing + 1, SpeechVol, 0, 32);

	SetFontBrightness( Canvas, (Selection == 3) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 2);
	if ( MenuValues[3] ~= CurrentRes )
		Canvas.DrawText("["$MenuValues[3]$"]", false);
	else
		Canvas.DrawText(" "$MenuValues[3], false);
	Canvas.DrawColor = Canvas.Default.DrawColor;

	WideScreenValue=PlayerOwner.MainFOV;
	MenuValues[4] = string(int(WideScreenValue));
	Canvas.SetPos(StartX + 152, StartY + Spacing * 3);
	Canvas.DrawText("["$MenuValues[4]$"]", false);
	Canvas.DrawColor = Canvas.Default.DrawColor;
	
	bLowTextureDetail = PlayerOwner.ConsoleCommand("get ini:Engine.Engine.ViewportManager TextureDetail") != "High";

	SetFontBrightness( Canvas, (Selection == 5) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 4);
	if ( bLowTextureDetail )
		Canvas.DrawText(LowText, false);
	else
		Canvas.DrawText(HighText, false);
	Canvas.DrawColor = Canvas.Default.DrawColor;

	bLowSoundQuality = bool(PlayerOwner.ConsoleCommand("get ini:Engine.Engine.AudioDevice LowSoundQuality"));
	SetFontBrightness( Canvas, (Selection == 9) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 8);
	if ( bLowSoundQuality )
		Canvas.DrawText(LowText, false);
	else
		Canvas.DrawText(HighText, false);
	Canvas.DrawColor = Canvas.Default.DrawColor;

	SetFontBrightness( Canvas, (Selection == 10) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 9);
	Canvas.DrawText(BoolOptionString(!PlayerOwner.bNoVoices), false);

	SetFontBrightness( Canvas, (Selection == 11) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 10);
	Canvas.DrawText(BoolOptionString(PlayerOwner.bMessageBeep), false);

	SetFontBrightness( Canvas, (Selection == 12) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 11);
	Canvas.DrawText(BoolDefPropertyString("ini:Engine.Engine.ViewportManager FlatShading"), false);

	SetFontBrightness( Canvas, (Selection == 13) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 12);
	Canvas.DrawText(BoolDefPropertyString("ini:Engine.Engine.ViewportManager CurvedSurfaces"), false);

	SetFontBrightness( Canvas, (Selection == 14) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 13);
	Canvas.DrawText(BoolDefPropertyString("Engine.GameInfo bCastShadow"), false);

	SetFontBrightness( Canvas, (Selection == 15) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 14);
	Canvas.DrawText(BoolDefPropertyString("Engine.GameInfo bDecoShadows"), false);

	SetFontBrightness( Canvas, (Selection == 16) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 15);
	Canvas.DrawText(ShadowDetail[ShadowResNum]);

	SetFontBrightness( Canvas, (Selection == 17) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 16);
	Canvas.DrawText(BoolDefPropertyString("ini:Engine.Engine.GameRenderDevice UsePrecache"), false);

	SetFontBrightness( Canvas, (Selection == 18) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 17);
	Canvas.DrawText(BoolDefPropertyString("ini:Engine.Engine.GameRenderDevice UseTrilinear"), false);
	
	SetFontBrightness( Canvas, (Selection == 19) );
	Canvas.SetPos(StartX + 152, StartY + Spacing * 18);
	Canvas.DrawText(SkyFogDetail[CurrentFogMode], false);
	
	SetFontBrightness( Canvas, (Selection == 20) );
	DrawSlider(Canvas, StartX + 155, StartY + Spacing*19 + 1, CurrentHUDScale, 0, 1);

	// Draw help panel
	DrawHelpPanel(Canvas, StartY + MenuLength * Spacing, HelpPanelX);
}

function GetAvailableRes()
{
	local int p,i;
	local string ParseString;

	AvailableRes = PlayerOwner.ConsoleCommand("GetRes");
	resNum = 0;
	ParseString = AvailableRes;
	p = InStr(ParseString, " ");
	while ( (ResNum < ArrayCount(Resolutions)) && (p != -1) )
	{
		Resolutions[ResNum] = Left(ParseString, p);
		ParseString = Right(ParseString, Len(ParseString) - p - 1);
		p = InStr(ParseString, " ");
		ResNum++;
	}

	Resolutions[ResNum] = ParseString;
	for ( i=ResNum+1; i< ArrayCount(Resolutions); i++ )
		Resolutions[i] = "";

	CurrentRes = PlayerOwner.ConsoleCommand("GetCurrentRes");
	MenuValues[3] = CurrentRes;
	for ( i=0; i< ResNum+1; i++ )
		if ( MenuValues[3] ~= Resolutions[i] )
		{
			ResNum = i;
			return;
		}

	ResNum = 0;
	MenuValues[3] = Resolutions[0];
}
function GetShadowResNum()
{
	bRealtimeShadow = bool(PlayerOwner.ConsoleCommand("get Engine.GameInfo bUseRealtimeShadow"));
	CurrentShadowRes = int(PlayerOwner.ConsoleCommand("get Engine.PawnShadow ShadowDetailRes"));

	if (!bRealtimeShadow)
		ShadowResNum =0;
	else if (CurrentShadowRes <= 128)
		ShadowResNum=1;
	else if (CurrentShadowRes == 256)
		ShadowResNum=2;
	else if (CurrentShadowRes == 512)
		ShadowResNum=3;
	else if (CurrentShadowRes >= 1024)
		ShadowResNum=4;
}
function SetShadowResNum()
{
	bRealtimeShadow = ShadowResNum > 0;
	if (bRealtimeShadow)
	{
		CurrentShadowRes = 128 << (ShadowResNum - 1);
		class'PawnShadow'.default.ShadowDetailRes = CurrentShadowRes;
		class'PawnShadow'.static.StaticSaveConfig();
	}
	ConsoleCommand("set Engine.GameInfo bUseRealtimeShadow" @ bRealtimeShadow);
	class'ObjectShadow'.static.UpdateAllShadows(PlayerOwner.Level, true);
}
final function SetSkyFogType( int Dir )
{
	CurrentFogMode+=Dir;
	if( CurrentFogMode>2 )
		CurrentFogMode = 0;
	else if( CurrentFogMode<0 )
		CurrentFogMode = 2;
	ConsoleCommand("set ini:Engine.Engine.ViewportManager SkyBoxFogMode"@CurrentFogMode);
}
final function SetHudScale( int Dir )
{
	local int i;
	
	i = CurrentHUDScale+Dir;
	if( i<0 || i>=ArrayCount(HUDScalers) )
		return;
	CurrentHUDScale = i;
	ConsoleCommand("set HUD HudScaler"@HUDScalers[i]);
}

defaultproperties
{
	LowText="Low"
	HighText="High"
	ShadowDetail(0)="Blob"
	ShadowDetail(1)="LowRes"
	ShadowDetail(2)="MedRes"
	ShadowDetail(3)="HighRes"
	ShadowDetail(4)="UltraRes"
	SkyFogDetail(0)="High Detail"
	SkyFogDetail(1)="Low Detail"
	SkyFogDetail(2)="Off"
	MenuLength=20
	HUDScalers(0)=1
	HUDScalers(1)=2
	HUDScalers(2)=3
	HUDScalers(3)=4
	HUDScalers(4)=5
	HUDScalers(5)=6
	HUDScalers(6)=8
	HelpMessage(1)="Adjust display brightness using the left and right arrow keys."
	HelpMessage(2)="Display Unreal in a window. Note that going to a software display mode may remove high detail actors that were visible with hardware acceleration."
	HelpMessage(3)="Use the left and right arrows to select a resolution, and press enter to select this resolution."
	HelpMessage(4)="Use the left and right arrows to adjust Field of View (FoV) for widescreen displays"
	HelpMessage(5)="Use the low texture detail option to improve performance.  Changes to this setting will take effect on the next level change."
	HelpMessage(6)="Adjust the volume of the music using the left and right arrow keys."
	HelpMessage(7)="Adjust the volume of sound effects in the game using the left and right arrow keys."
	HelpMessage(8)="Adjust the volume of speech, taunt and grunt effects in the game using the left and right arrow keys."
	HelpMessage(9)="Use the low sound quality option to improve performance on machines with 32 megabytes or less of memory.  Changes to this setting will take effect on the next level change."
	HelpMessage(10)="If true, you will hear voice messages during gametypes that use them."
	HelpMessage(11)="If true, you will hear a beep when you receive a message."
	HelpMessage(12)="If true, some specific meshes may use flat shading."
	HelpMessage(13)="If true, some specific meshes may use curved surfaces for extra detail."
	HelpMessage(14)="If true, pawns cast shadows. Changes to this setting will take effect on the next level change."
	HelpMessage(15)="if true, decoration cast shadows. Changes to this setting will take effect on the next level change."
	HelpMessage(16)="If blob, use blob shadows, else use realistic shadows with different resolutions. Changes to this setting will take effect on the next level change."
	HelpMessage(17)="Use this option to precaching map content like sounds and textures."
	HelpMessage(18)="Use this option to active/deactivate trilinear filtering."
	HelpMessage(19)="Level of detail for fogging applied onto sky."
	HelpMessage(20)="The scaling of user HUD."
	MenuList(1)="Brightness"
	MenuList(2)="Toggle Fullscreen Mode"
	MenuList(3)="Select Resolution"
	MenuList(4)="Field of View"
	MenuList(5)="Texture Detail"
	MenuList(6)="Music Volume"
	MenuList(7)="Sound Volume"
	MenuList(8)="Speech Volume"
	MenuList(9)="Sound Quality"
	MenuList(10)="Voice Messages"
	MenuList(11)="Message Beep"
	MenuList(12)="Flat Shading"
	MenuList(13)="Curvy Meshes"
	MenuList(14)="Cast Shadows"
	MenuList(15)="Deco Shadows"
	MenuList(16)="Realistic Shadows"
	MenuList(17)="PreCaching Content"
	MenuList(18)="Trilinear Filtering"
	MenuList(19)="Skybox Fogging"
	MenuList(20)="HUD Scale"
	MenuTitle="AUDIO/VIDEO"
}
