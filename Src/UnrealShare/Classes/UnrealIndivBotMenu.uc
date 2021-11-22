//=============================================================================
// UnrealIndivBotMenu
//=============================================================================
class UnrealIndivBotMenu extends UnrealShortMenu;

var actor RealOwner;
var nowarn bool bSetup, bPulseDown;
var int Num;
var int PlayerClassNum;
var string RealName;
var int  RealTeam;
var int CurrentTeam;
var() globalconfig string Teams[4];
var byte SkinNum;
var string MenuValues[20];
var float ValuesFadeTimes[20];
var	BotInfo BotConfig;
var GameInfo GameType;

function InitConfig(GameInfo G)
{
	GameType = G;
	if ( Level.Game.IsA('DeathMatchGame') )
		BotConfig = DeathMatchGame(Level.Game).BotConfig;
	else
		BotConfig = Spawn(DeathMatchGame(GameType).Default.BotConfigType);
}

function GotoBot(int BotNum)
{
	local int i;
	local string SkinName;
	local texture NewSkin;

	if ( (BotNum < 0) || (BotNum > 15) )
		return;

	SetUpDisplay();

	Num = BotNum;
	for ( i=0; i<BotConfig.NumClasses; i++ )
		if ( BotConfig.GetAvailableClasses(i) ~= BotConfig.GetBotClassName(Num) )
		{
			PlayerClassNum = i;
			break;
		}
	SkinName = BotConfig.GetBotSkin(Num);
	ChangeMesh();
	if ( SkinName != "" )
	{
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
		if ( NewSkin != None )
		{
			Skin = NewSkin;
			BotConfig.SetBotSkin(SkinName, Num);
		}
	}
}

function Destroyed()
{
	Super.Destroyed();
	if ( !Level.Game.IsA('DeathMatchGame') || (BotConfig != DeathMatchGame(Level.Game).BotConfig) )
		BotConfig.Destroy();
}

function FindSkin(int Dir)
{
	local string SkinName, SkinDesc;
	local texture NewSkin;

	SkinName = BotConfig.GetBotSkin(Num);;
	if ( SkinName == "" )
		SkinName = string(Skin);
	GetNextSkin(GetItemName(string(Mesh)), SkinName, Dir, SkinName, SkinDesc);
	if ( SkinName != "" )
	{
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
		if ( NewSkin != None )
		{
			Skin = NewSkin;
			BotConfig.SetBotSkin(SkinName, Num);
		}
	}
}

function ProcessMenuInput( coerce string InputString )
{
	InputString = Left(InputString, 20);
	if ( selection == 2 )
		BotConfig.SetBotName(InputString, Num);
}

function ProcessMenuEscape()
{
	if ( selection == 2 )
		BotConfig.SetBotName(RealName, Num);
	else if ( selection == 6 )
		BotConfig.SetBotTeam(RealTeam, Num);
}

function ProcessMenuUpdate( coerce string InputString )
{
	InputString = Left(InputString, 19);
	if ( selection == 2 )
		BotConfig.SetBotName(InputString$"_", Num);
}

function Menu ExitMenu()
{
	SetOwner(RealOwner);
	Return Super.ExitMenu();
}

function bool ProcessLeft()
{
	local int i;
	local string SkinName;
	local texture NewSkin;

	if ( Selection == 1 )
	{
		Num--;
		if ( Num < 0 )
			Num = 15;

		for ( i=0; i<BotConfig.NumClasses; i++ )
			if ( BotConfig.GetAvailableClasses(i) ~= BotConfig.GetBotClassName(Num) )
			{
				PlayerClassNum = i;
				break;
			}
		SkinName = BotConfig.GetBotSkin(Num);
		ChangeMesh();
		if ( SkinName != "" )
		{
			NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
			if ( NewSkin != None )
			{
				Skin = NewSkin;
				BotConfig.SetBotSkin(SkinName, Num);
			}
		}
	}
	else if ( Selection == 2 )
	{
		RealName = BotConfig.GetBotName(Num);
		BotConfig.SetBotName("_", Num);
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	else if ( selection == 3 )
	{
		PlayerClassNum++;
		if ( PlayerClassNum == BotConfig.NumClasses )
			PlayerClassNum = 0;
		BotConfig.SetBotClass(BotConfig.GetAvailableClasses(PlayerClassNum), Num);
		ChangeMesh();
	}
	else if ( Selection == 4 )
		FindSkin(-1);
	else if ( selection == 5 )
		BotConfig.BotSkills[Num] = FMax(0, BotConfig.BotSkills[Num] - 0.2);
	else if ( Selection == 6 )
	{
		CurrentTeam--;
		if (CurrentTeam < 0)
			CurrentTeam = 3;
		RealTeam = BotConfig.GetBotTeam(Num);
		BotConfig.SetBotTeam(CurrentTeam, Num);
	}
	else
		return false;

	return true;
}

function bool ProcessRight()
{
	local int i;
	local string SkinName;
	local texture NewSkin;

	if ( Selection == 1 )
	{
		Num++;
		if ( Num > 15 )
			Num = 0;

		for ( i=0; i<BotConfig.NumClasses; i++ )
			if ( BotConfig.GetAvailableClasses(i) ~= BotConfig.GetBotClassName(Num) )
			{
				PlayerClassNum = i;
				break;
			}
		SkinName = BotConfig.GetBotSkin(Num);
		ChangeMesh();
		if ( SkinName != "" )
		{
			NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
			if ( NewSkin != None )
			{
				Skin = NewSkin;
				BotConfig.SetBotSkin(SkinName, Num);
			}
		}
	}
	else if ( Selection == 2 )
	{
		RealName = BotConfig.GetBotName(Num);
		BotConfig.SetBotName("_", Num);
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
	else if ( selection == 3 )
	{
		PlayerClassNum--;
		if ( PlayerClassNum < 0 )
			PlayerClassNum = BotConfig.NumClasses - 1;
		BotConfig.SetBotClass(BotConfig.GetAvailableClasses(PlayerClassNum), Num);
		ChangeMesh();
	}
	else if ( Selection == 4 )
		FindSkin(1);
	else if ( selection == 5 )
		BotConfig.BotSkills[Num] = FMin(3.0, BotConfig.BotSkills[Num] + 0.2);
	else if ( Selection == 6 )
	{
		CurrentTeam++;
		if (CurrentTeam > 3)
			CurrentTeam = 0;
		RealTeam = BotConfig.GetBotTeam(Num);
		BotConfig.SetBotTeam(CurrentTeam, Num);
	}
	else
		return false;

	return true;
}

function bool ProcessSelection()
{
	local Menu ChildMenu;

	if ( Selection == 2 )
	{
		RealName = BotConfig.GetBotName(Num);
		BotConfig.SetBotName("_", Num);
		PlayerOwner.Player.Console.GotoState('MenuTyping');
	}
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
	BotConfig.SaveConfig();
}

function MenuTick(float DeltaTime)
{
	local int I;

	Super.MenuTick(DeltaTime);

	// Update FadeTimes.
	if (TitleFadeTime >= 0.0)
		TitleFadeTime += DeltaTime;
	for (I=0; I<24; I++)
		if (MenuFadeTimes[I] >= 0.0)
			MenuFadeTimes[I] += DeltaTime;
	for (I=0; I<20; I++)
		if (ValuesFadeTimes[I] >= 0.0)
			ValuesFadeTimes[I] += DeltaTime;
}

function SetUpDisplay()
{
	local int I;
	local string SkinName;
	local texture NewSkin;

	bSetup = true;

	// Init the FadeTimes.
	// -1.0 means not updated.
	TitleFadeTime = -1.0;
	for (I=0; I<24; I++)
		MenuFadeTimes[I] = -1.0;
	for (I=0; I<20; I++)
		ValuesFadeTimes[I] = -1.0;

	for ( I=0; I<BotConfig.NumClasses; I++ )
		if ( BotConfig.GetAvailableClasses(I) ~= BotConfig.GetBotClassName(Num) )
		{
			PlayerClassNum = I;
			break;
		}

	RealOwner = Owner;
	SetOwner(PlayerOwner);
	SkinName = BotConfig.GetBotSkin(Num);
	ChangeMesh();
	if ( SkinName != "" )
	{
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture'));
		if ( NewSkin != None )
		{
			Skin = NewSkin;
			BotConfig.SetBotSkin(SkinName, Num);
		}
	}
	LoopAnim(AnimSequence);
}

function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing;
	local vector DrawOffset;
	local rotator NewRot;

	if (!bSetup)
		SetUpDisplay();

	// Set menu location.
	PlayerOwner.ViewRotation.Pitch = 0;
	PlayerOwner.ViewRotation.Roll = 0;
	DrawOffset = ((vect(10.0,-5.0,0.0)) >> PlayerOwner.ViewRotation);
	DrawOffset += (PlayerOwner.EyeHeight * vect(0,0,1));
	
	NewRot = PlayerOwner.ViewRotation;
	NewRot.Yaw = Rotation.Yaw;
	SetLocation(PlayerOwner.Location + DrawOffset, NewRot);

	Canvas.DrawActor(Self, false);

	// Draw title.
	DrawFadeTitle(Canvas);

	Spacing = Clamp(0.04 * Canvas.ClipY, 12, 32);
	StartX = Canvas.ClipX/2;
	StartY = Max(40, 0.5 * (Canvas.ClipY - MenuLength * Spacing - 128));

	// Draw text.
	DrawFadeList(Canvas, Spacing, StartX, StartY);

	MenuValues[1] = string(Num);
	MenuValues[2] = BotConfig.GetBotName(Num);
	MenuValues[3] = GetItemName(string(Mesh));
	MenuValues[4] = GetItemName(string(Skin));
	MenuValues[5] = string(BotConfig.BotSkills[Num]);
	MenuValues[6] = Teams[BotConfig.GetBotTeam(Num)];
	DrawFadeValues(Canvas, Spacing, StartX+120, StartY);

	// Draw help panel.
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 0;
	DrawHelpPanel(Canvas, Canvas.ClipY - 64, 228);
}

function DrawFadeValues(canvas Canvas, int Spacing, int StartX, int StartY)
{
	local int i;
	local color DrawColor;

	Canvas.Font = Font'WhiteFont';
	for (i=0; i< MenuLength; i++ )
	{
		if (i == Selection - 1)
		{
			DrawColor.R = PulseTime * 10;
			DrawColor.G = 255;
			DrawColor.B = PulseTime * 10;
		}
		else
		{
			DrawColor.R = 0;
			DrawColor.G = 150;
			DrawColor.B = 0;
		}
		DrawFadeString(Canvas, MenuValues[i + 1], ValuesFadeTimes[i + 1], StartX, StartY + Spacing * i, DrawColor);
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}

function ChangeMesh()
{
	local class<pawn> NewPlayerClass;

	NewPlayerClass = class<pawn>(DynamicLoadObject(BotConfig.GetAvailableClasses(PlayerClassNum), class'Class'));
	if ( NewPlayerClass != None )
	{
		BotConfig.SetBotSkin(string(NewPlayerClass.Default.Skin), Num);
		mesh = NewPlayerClass.Default.mesh;
		skin = NewPlayerClass.Default.skin;
	}
}

defaultproperties
{
	MenuLength=6
	HelpMessage(1)="Which Bot Configuration is being edited. Use left and right arrows to change."
	HelpMessage(2)="Hit enter to edit the name of this bot."
	HelpMessage(3)="Use the left and right arrow keys to change the class of this bot."
	HelpMessage(4)="Use the left and right arrow keys to change the skin of this bot."
	HelpMessage(5)="Adjust the overall skill of this bot by this amount (relative to the base skill for bots)."
	HelpMessage(6)="Type in which team this bot plays on (Red, Blue, Green, or Yellow)."
	Teams(0)="Red"
	Teams(1)="Blue"
	Teams(2)="Green"
	Teams(3)="Gold"
	MenuList(1)="Configuration"
	MenuList(2)="Name"
	MenuList(3)="Class"
	MenuList(4)="Skin"
	MenuList(5)="Skill Adjust"
	MenuList(6)="Team"
	MenuTitle="Artificial Intelligence Configuration"
	bHidden=False
	Physics=PHYS_Rotating
	AnimSequence=Walk
	DrawType=DT_Mesh
	DrawScale=0.10000
	bUnlit=True
	bOnlyOwnerSee=True
	bFixedRotationDir=True
	RotationRate=(Yaw=8000)
	DesiredRotation=(Yaw=30000)
}
