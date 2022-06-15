class UMenuBotSetupClient extends UMenuBotSetupBase;

var BotInfo BotInfo;

function LoadBots()
{
	local class<BotInfo> C;
	local int i;
	local int NumBots;

	C = class<BotInfo>(DynamicLoadObject("UnrealI.BotInfo", class'Class'));
	BotInfo = GetEntryLevel().Spawn(C);

	NumBots = Int(UMenuBotConfigBase(OwnerWindow).NumBotsEdit.GetValue());

	// Add the bots into the combo
	for (i=0; i<NumBots; i++)
		BotCombo.AddItem(BotWord@string(i+1), String(i));
}

function ResetBots()
{
	local Class<BotInfo> C;

	C = BotInfo.Class;
	BotInfo.Destroy();

	C.ResetConfig();
	BotInfo = GetEntryLevel().Spawn(C);

	Initialized = False;
	ConfigureBot = 0;
	BotCombo.SetSelectedIndex(0);
	LoadCurrent();
	UseSelected();
	Initialized = True;
}

function LoadClasses()
{
	local int i;
	local int SortWeight;

	for (i=0; i<BotInfo.NumClasses; i++)
		ClassCombo.AddItem(BotInfo.AvailableDescriptions[i], BotInfo.AvailableClasses[i], SortWeight);
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	BotInfo.SaveConfig();
	BotInfo.Destroy();
	BotInfo = None;
}

function LoadCurrent()
{
	local int i;

	NameEdit.SetValue(BotInfo.GetBotName(ConfigureBot));
	i = TeamCombo.FindItemIndex2(string(BotInfo.BotTeams[ConfigureBot]));
	if (i == -1)
		i = 255;
	TeamCombo.SetSelectedIndex(i);
	ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(BotInfo.GetBotClassName(ConfigureBot), True), 0));
	ClassChanged();
	SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(BotInfo.GetBotSkin(ConfigureBot), True), 0));
	FaceCombo.SetSelectedIndex(0);
	BotSkillSlider.SetValue(BotInfo.BotSkills[ConfigureBot]*2);
	BotAccurSlider.SetValue(BotInfo.BotAccuracy[ConfigureBot]*10+10);
	BotCombatStyleSlider.SetValue(BotInfo.CombatStyle[ConfigureBot]+10);
	BotAlertnessSlider.SetValue(BotInfo.Alertness[ConfigureBot]*10+10);
	BotCampingSlider.SetValue(BotInfo.Camping[ConfigureBot]*10);
	FavoriteWeaponCombo.SetSelectedIndex(Max(FavoriteWeaponCombo.FindItemIndex2(BotInfo.PrefereredWeapon[ConfigureBot], True), 0));

	if (NewPlayerClass != none)
		UpdateMeshWindow(NewPlayerClass.default.Mesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));
}

function NameChanged()
{
	if (Initialized)
	{
		BotInfo.SetBotName(NameEdit.GetValue(), ConfigureBot);
	}
}

function UseSelected()
{
	if (Initialized)
	{
		// store the stuff in the required botinfo
		BotInfo.SetBotClass(ClassCombo.GetValue2(), ConfigureBot);
		BotInfo.SetBotSkin(SkinCombo.GetValue2(), ConfigureBot);
		BotInfo.SetBotTeam(Int(TeamCombo.GetValue2()), ConfigureBot);
		BotInfo.BotSkills[ConfigureBot] = BotSkillSlider.GetValue()*0.5;
		BotInfo.BotAccuracy[ConfigureBot] = (BotAccurSlider.GetValue()-10.f)*0.1;
		BotInfo.CombatStyle[ConfigureBot] = BotCombatStyleSlider.GetValue()-10.f;
		BotInfo.Alertness[ConfigureBot] = (BotAlertnessSlider.GetValue()-10.f)*0.1;
		BotInfo.Camping[ConfigureBot] = BotCampingSlider.GetValue()*0.1;
		BotInfo.PrefereredWeapon[ConfigureBot] = FavoriteWeaponCombo.GetValue2();
	}

	// setup the mesh window appropriately
	// MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh); // UGold - Smirftsch
	UpdateMeshWindow(NewPlayerClass.default.Mesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));
}

function SaveConfigs()
{
	Super(UMenuDialogClientWindow).SaveConfigs();
	if( BotInfo )
		BotInfo.SaveConfig();
}

defaultproperties
{
}
