class UMenuModMenu expands UWindowPulldownMenu;

var UMenuModMenuList ModList;
var(Text) localized string CantUseTitle,CantUseInfo;

function SetupMods(UMenuModMenuList InModList)
{
	local UMenuModMenuList I;
	ModList = InModList;

	for (I = UMenuModMenuList(ModList.Next); I != None; I = UMenuModMenuList(I.Next))
		I.MenuItem = AddMenuItem(I.MenuCaption, None);
}

function Select(UWindowPulldownMenuItem I)
{
	local UMenuModMenuList L;

	for (L = UMenuModMenuList(ModList.Next); L != None; L = UMenuModMenuList(L.Next))
		if (I == L.MenuItem)
			UMenuMenuBar(GetMenuBar()).SetHelp(L.MenuHelp);

	Super.Select(I);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	local UMenuModMenuList L;
	local UMenuModMenuItem Item;

	for (L = UMenuModMenuList(ModList.Next); L != None; L = UMenuModMenuList(L.Next))
		if (I == L.MenuItem)
		{
			if( GetLevel().NetMode==NM_Client )
			{
				MessageBox(CantUseTitle,CantUseInfo,MB_OK,MR_OK);
				break;
			}
			Item = new Class<UMenuModMenuItem>(DynamicLoadObject(L.MenuItemClassName, class'Class'));
			Item.MenuItem = I;
			Item.Setup();
			Item.Execute();
		}

	Super.ExecuteItem(I);
}

defaultproperties
{
	CantUseTitle="Note: Mod menu"
	CantUseInfo="You can't use mod menu items during online play."
}
