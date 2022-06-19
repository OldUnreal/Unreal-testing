class UMenuCoopGameRulesCWindow extends UMenuGameRulesCWindow;

// Friendly Fire
var UWindowCheckbox FriendlyFire;
var localized string FriendlyFireText;
var localized string FriendlyFireHelp;

// Instant Weapon Respawn
var UWindowCheckbox InstantWeaponRespawn;
var localized string InstantWeaponRespawnText;
var localized string InstantWeaponRespawnHelp;

// Instant Item Respawn
var UWindowCheckbox InstantItemRespawn;
var localized string InstantItemRespawnText;
var localized string InstantItemRespawnHelp;

function Created()
{
	local float ControlWidth, ControlLeft, ControlRight;

	Super.Created();

	InitLayoutParams(ControlWidth, ControlLeft, ControlRight);
	
	// Friendly Fire
	FriendlyFire = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	FriendlyFire.SetText(FriendlyFireText);
	FriendlyFire.SetHelpText(FriendlyFireHelp);
	FriendlyFire.SetFont(F_Normal);
	FriendlyFire.Align = TA_Right;
	ControlOffset += 25;
	
	// Instant Weapon Respawn
	InstantWeaponRespawn = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	InstantWeaponRespawn.SetText(InstantWeaponRespawnText);
	InstantWeaponRespawn.SetHelpText(InstantWeaponRespawnHelp);
	InstantWeaponRespawn.SetFont(F_Normal);
	InstantWeaponRespawn.Align = TA_Right;
	ControlOffset += 25;
	
	// Instant Item Respawn
	InstantItemRespawn = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, 1));
	InstantItemRespawn.SetText(InstantItemRespawnText);
	InstantItemRespawn.SetHelpText(InstantItemRespawnHelp);
	InstantItemRespawn.SetFont(F_Normal);
	InstantItemRespawn.Align = TA_Right;
	ControlOffset += 25;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float ControlWidth, ControlLeft, ControlRight;

	Super.BeforePaint(C, X, Y);

	InitLayoutParams(ControlWidth, ControlLeft, ControlRight);

	FriendlyFire.WinLeft = ControlLeft;
	FriendlyFire.AutoWidth(C);
	
	InstantWeaponRespawn.WinLeft = ControlLeft;
	InstantWeaponRespawn.AutoWidth(C);
	
	InstantItemRespawn.WinLeft = ControlLeft;
	InstantItemRespawn.AutoWidth(C);
}

function Notify(UWindowDialogControl C, byte E)
{
	if (!Initialized)
		return;

	Super.Notify(C, E);

	switch (E)
	{
	case DE_Change:
		switch (C)
		{
		case FriendlyFire:
			FriendlyFireChanged();
			break;

		case InstantWeaponRespawn:
			InstantWeaponRespawnChanged();
			break;

		case InstantItemRespawn:
			InstantItemRespawnChanged();
			break;
		}
	}
}

function FriendlyFireChanged()
{
	if( class<CoopGame>(BotmatchParent.GameClass) )
		class<CoopGame>(BotmatchParent.GameClass).default.bNoFriendlyFire = !FriendlyFire.bChecked;
}

function InstantWeaponRespawnChanged()
{
	if( class<CoopGame>(BotmatchParent.GameClass) )
		class<CoopGame>(BotmatchParent.GameClass).default.bInstantWeaponRespawn = InstantWeaponRespawn.bChecked;
}

function InstantItemRespawnChanged()
{
	if( class<CoopGame>(BotmatchParent.GameClass) )
		class<CoopGame>(BotmatchParent.GameClass).default.bInstantItemRespawn = InstantItemRespawn.bChecked;
}

function LoadCurrentValues()
{
	super.LoadCurrentValues();
	if( class<CoopGame>(BotmatchParent.GameClass) )
	{
		FriendlyFire.bChecked = !class<CoopGame>(BotmatchParent.GameClass).default.bNoFriendlyFire;
		InstantWeaponRespawn.bChecked = class<CoopGame>(BotmatchParent.GameClass).default.bInstantWeaponRespawn;
		InstantItemRespawn.bChecked = class<CoopGame>(BotmatchParent.GameClass).default.bInstantItemRespawn;
	}
}

defaultproperties
{
	FriendlyFireText="Friendly Fire"
	FriendlyFireHelp="If checked, friendly fire damage is allowed"
	InstantWeaponRespawnText="Instant Weapon Respawn"
	InstantWeaponRespawnHelp="If checked, weapons will be respawned instantly"
	InstantItemRespawnText="Instant Item Respawn"
	InstantItemRespawnHelp="If checked, items will be respawned instantly"
}
