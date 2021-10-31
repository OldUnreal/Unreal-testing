class UMenuHelpMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem Context, EpicURL, SupportURL, AboutButton;

var localized string ContextName;
var localized string ContextHelp;

var localized string AboutName;
var localized string AboutHelp;

var localized string EpicGamesURLName;
var localized string EpicGamesURLHelp;

var localized string SupportURLName;
var localized string SupportURLHelp;

function Created()
{
	Super.Created();

	Context = AddMenuItem(ContextName, None);
	AddMenuItem("-", None);
	AboutButton = AddMenuItem(AboutName, None);
	SupportURL = AddMenuItem(SupportURLName, None);
	AddMenuItem("-", None);
	EpicURL = AddMenuItem(EpicGamesURLName, None);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	local UMenuMenuBar MenuBar;

	MenuBar = UMenuMenuBar(GetMenuBar());

	switch (I)
	{
	case Context:
		Context.bChecked = !Context.bChecked;
		MenuBar.ShowHelp = !MenuBar.ShowHelp;
		if (Context.bChecked)
		{
			if ( UMenuRootWindow(Root)!=None && UMenuRootWindow(Root).StatusBar!=None )
				UMenuRootWindow(Root).StatusBar.ShowWindow();
		}
		else if ( UMenuRootWindow(Root) != None && UMenuRootWindow(Root).StatusBar!=None )
			UMenuRootWindow(Root).StatusBar.HideWindow();
		MenuBar.SaveConfig();
		break;
	case AboutButton:
		Root.CreateWindow(Class'UnrealCreditsWindow', 100, 100, 200, 200, Self, True);
		break;
	case EpicURL:
		GetPlayerOwner().ConsoleCommand("start http://www.epicgames.com/");
		break;
	case SupportURL:
		GetPlayerOwner().ConsoleCommand("start http://www.oldunreal.com/");
		break;
	}
	Super.ExecuteItem(I);
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case Context:
		UMenuMenuBar(GetMenuBar()).SetHelp(ContextHelp);
		break;
	case EpicURL:
		UMenuMenuBar(GetMenuBar()).SetHelp(EpicGamesURLHelp);
		break;
	case SupportURL:
		UMenuMenuBar(GetMenuBar()).SetHelp(SupportURLHelp);
		break;
	case AboutButton:
		UMenuMenuBar(GetMenuBar()).SetHelp(AboutHelp);
		break;
	}
	Super.Select(I);
}

defaultproperties
{
	ContextName="&Context Help"
	ContextHelp="Enable and disable this context help area at the bottom of the screen."
	EpicGamesURLName="About &Epic Games"
	EpicGamesURLHelp="Click to open Epic Games webpage!"
	SupportURLName="Technical Support"
	SupportURLHelp="Click to open the technical support web page at Oldunreal."
	AboutName="&About"
	AboutHelp="See the credits about who created this game."
}
