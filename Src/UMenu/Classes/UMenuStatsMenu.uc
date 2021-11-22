class UMenuStatsMenu extends UWindowPulldownMenu;

var UWindowPulldownMenuItem ViewLocal, ViewGlobal, About, About2;

var localized string ViewLocalName;
var localized string ViewLocalHelp;
var localized string ViewGlobalName;
var localized string ViewGlobalHelp;
var localized string AboutName;
var localized string AboutHelp;
var localized string About2Name;
var localized string About2Help;

function Created()
{
	Super.Created();

	// Add menu items.
	ViewLocal = AddMenuItem(ViewLocalName, None);
	ViewGlobal = AddMenuItem(ViewGlobalName, None);
	AddMenuItem("-", None);
	About = AddMenuItem(AboutName, None);
	About2 = AddMenuItem(About2Name, None);
}

function ExecuteItem(UWindowPulldownMenuItem I)
{
	/*
	switch(I)
	{
	case ViewLocal:
		class'StatLog'.Static.BatchLocal();
		break;
	case ViewGlobal:
		GetPlayerOwner().ConsoleCommand("start http://ut.ngworldstats.com/");
		break;
	case About:
		class'StatLog'.Static.BrowseRelativeLocalURL("..\\NetGamesUSA.com\\ngStats\\html\\Help_Using_ngStats.html");
		break;
	case About2:
		GetPlayerOwner().ConsoleCommand("start http://ut.ngworldstats.com/FAQ/");
		break;
	}

	Super.ExecuteItem(I); // removed in UGold - Smirftsch
	*/
}

function Select(UWindowPulldownMenuItem I)
{
	switch (I)
	{
	case ViewLocal:
		UMenuMenuBar(GetMenuBar()).SetHelp(ViewLocalHelp);
		break;
	case ViewGlobal:
		UMenuMenuBar(GetMenuBar()).SetHelp(ViewGlobalHelp);
		break;
	case About:
		UMenuMenuBar(GetMenuBar()).SetHelp(AboutHelp);
		break;
	case About2:
		UMenuMenuBar(GetMenuBar()).SetHelp(About2Help);
		break;
	}

	Super.Select(I);
}

defaultproperties
{
	ViewLocalName="View Local ngStats"
	ViewLocalHelp="View your game statistics accumulated in single player and practice games."
	ViewGlobalName="View Global ngWorldStats"
	ViewGlobalHelp="View your game statistics accumulated online."
	AboutName="Help with &ngStats"
	AboutHelp="Get information about local stat logging."
	About2Name="Help with &ngWorldStats"
	About2Help="Get information about global stat logging."
}
