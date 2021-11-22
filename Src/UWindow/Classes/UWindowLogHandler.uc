Class UWindowLogHandler extends LogHandler;

var WindowConsole Console;
var color WarningColor;

function bool OnLogLine( name N, string S )
{
	if( Console.ConsoleWindow!=None )
	{
		UWindowConsoleClientWindow(Console.ConsoleWindow.ClientArea).TextArea.AddText("["$N$"]: "$S,WarningColor);
		Console.bDisplayWarning = true;
		Console.WarningTimer = 3.f;
	}
	return false;
}

defaultproperties
{
	bEnabled=false
	LogTypes.Add("ScriptWarning")
	LogTypes.Add("Warning")
	LogTypes.Add("Error")
	LogTypes.Add("ScriptStack")
	WarningColor=(R=181,G=74,B=11)
}