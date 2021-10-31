class UBrowserHTMLArea expands UWindowHTMLTextArea;

var UBrowserNewsWindow NewsWin;

function ProcessURL(string URL)
{
	if ( Left(URL, 10) ~= "httpunr://" )
		NewsWin.OpenUpLink(Mid(URL,10));
	else Super.ProcessURL(URL);
}

defaultproperties
{
	bNoKeyboard=False
}
