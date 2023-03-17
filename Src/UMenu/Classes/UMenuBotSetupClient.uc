class UMenuBotSetupClient extends UMenuBotSetupBase;

var transient BotInfo BotInfo; // pre-227k: no need to spawn this actor.
var class<BotInfo> BotInfoClass;
var bool bClassesLoaded;

function LoadBots()
{
	local int i;
	local int NumBots;

	BotInfoClass = class<BotInfo>(DynamicLoadObject("UnrealI.BotInfo", class'Class'));

	NumBots = Int(UMenuBotConfigBase(OwnerWindow).NumBotsEdit.GetValue());

	// Add the bots into the combo
	for (i=0; i<NumBots; i++)
		BotCombo.AddItem(BotWord@string(i+1), String(i));
}

function ResetBots()
{
	BotInfoClass.Static.ResetConfig();

	Initialized = False;
	ConfigureBot = 0;
	BotCombo.SetSelectedIndex(0);
	LoadCurrent();
	UseSelected();
	Initialized = True;
}

function LoadClasses()
{
	local string NextBotClass,NextBotDesc;

	if( bClassesLoaded )
		return;
	bClassesLoaded = true;
	ClassCombo.Clear();
	foreach class'Actor'.Static.IntDescIterator(string(class'Bots'),NextBotClass,NextBotDesc,true)
		ClassCombo.AddItem(NextBotDesc, NextBotClass, 0);
	ClassCombo.Sort();
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	BotInfoClass.Static.StaticSaveConfig();
}

function LoadCurrent()
{
	local int i;

	NameEdit.SetValue(BotInfoClass.Default.BotNames[ConfigureBot]);
	i = TeamCombo.FindItemIndex2(string(BotInfoClass.Default.BotTeams[ConfigureBot]));
	if (i == -1)
		i = 255;
	TeamCombo.SetSelectedIndex(i);
	ClassCombo.SetSelectedIndex(Max(ClassCombo.FindItemIndex2(BotInfoClass.Default.BotClasses[ConfigureBot], True), 0));
	ClassChanged();
	SkinCombo.SetSelectedIndex(Max(SkinCombo.FindItemIndex2(BotInfoClass.Default.BotSkins[ConfigureBot], True), 0));
	FaceCombo.SetSelectedIndex(0);
	BotSkillSlider.SetValue(BotInfoClass.Default.BotSkills[ConfigureBot]*2);
	BotAccurSlider.SetValue(BotInfoClass.Default.BotAccuracy[ConfigureBot]*10+10);
	BotCombatStyleSlider.SetValue(BotInfoClass.Default.CombatStyle[ConfigureBot]+10);
	BotAlertnessSlider.SetValue(BotInfoClass.Default.Alertness[ConfigureBot]*10+10);
	BotCampingSlider.SetValue(BotInfoClass.Default.Camping[ConfigureBot]*10);
	FavoriteWeaponCombo.SetSelectedIndex(Max(FavoriteWeaponCombo.FindItemIndex2(BotInfoClass.Default.PrefereredWeapon[ConfigureBot], True), 0));

	if( NewPlayerClass )
		UpdateMeshWindow(NewPlayerClass.default.Mesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));
}

function NameChanged()
{
	if (Initialized)
	{
		BotInfoClass.Default.BotNames[ConfigureBot] = NameEdit.GetValue();
	}
}

function UseSelected()
{
	if (Initialized)
	{
		// store the stuff in the required botinfo
		BotInfoClass.Default.BotClasses[ConfigureBot] = ClassCombo.GetValue2();
		BotInfoClass.Default.BotSkins[ConfigureBot] = SkinCombo.GetValue2();
		BotInfoClass.Default.BotTeams[ConfigureBot] = int(TeamCombo.GetValue2());
		BotInfoClass.Default.BotSkills[ConfigureBot] = BotSkillSlider.GetValue()*0.5;
		BotInfoClass.Default.BotAccuracy[ConfigureBot] = (BotAccurSlider.GetValue()-10.f)*0.1;
		BotInfoClass.Default.CombatStyle[ConfigureBot] = BotCombatStyleSlider.GetValue()-10.f;
		BotInfoClass.Default.Alertness[ConfigureBot] = (BotAlertnessSlider.GetValue()-10.f)*0.1;
		BotInfoClass.Default.Camping[ConfigureBot] = BotCampingSlider.GetValue()*0.1;
		BotInfoClass.Default.PrefereredWeapon[ConfigureBot] = FavoriteWeaponCombo.GetValue2();
	}

	// setup the mesh window appropriately
	// MeshWindow.SetMeshString(NewPlayerClass.Default.SelectionMesh); // UGold - Smirftsch
	UpdateMeshWindow(NewPlayerClass.default.Mesh, SkinCombo.GetValue2(), FaceCombo.GetValue2(), int(TeamCombo.GetValue2()));
}

function SaveConfigs()
{
	Super(UMenuDialogClientWindow).SaveConfigs();
	BotInfoClass.Static.StaticSaveConfig();
}

defaultproperties
{
}
