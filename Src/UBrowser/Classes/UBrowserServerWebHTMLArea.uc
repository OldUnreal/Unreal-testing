class UBrowserServerWebHTMLArea expands UWindowHTMLTextArea;

var UBrowserServerWebWin PageOwner;

function ProcessURL(string URL)
{
	Log("Clicked Link: >>"$URL$"<<",'UBrowser');

	if ( Left(URL, 7) ~= "mailto:" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if ( Left(URL, 7) ~= "http://" )
		PageOwner.OpenWebsite(Mid(URL,7));
	if ( Left(URL, 6) ~= "ftp://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if ( Left(URL, 10) ~= "httpunr://" )
		GetPlayerOwner().ConsoleCommand("start http://"$Mid(URL,10));
	if ( Left(URL, 9) ~= "telnet://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if ( Left(URL, 9) ~= "gopher://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if ( Left(URL, 4) ~= "www." )
		PageOwner.OpenWebsite(URL);
	if ( Left(URL, 4) ~= "ftp." )
		GetPlayerOwner().ConsoleCommand("start ftp://"$URL);
	else if ( Left(URL, 9) ~= "unreal://" )
		LaunchUnrealURL(URL);
	else PageOwner.OpenChildURL(URL);
}

defaultproperties
{
}