class UWindowConsoleClientWindow extends UWindowDialogClientWindow;

var UWindowConsoleTextAreaControl TextArea;
var UWindowEditControl	EditControl;
var UWindowCheckbox BoxShowColors,BoxShowChatMsg,BoxShowScriptWarns;
var UWindowLabelControl ShowColLabel,ShowChatLabel,ShowScriptWarnLabel;
var() localized string ShowColorsText,ShowChatText,ShowWarningText;

function Created()
{
	TextArea = UWindowConsoleTextAreaControl(CreateWindow(class'UWindowConsoleTextAreaControl', 0, 16, WinWidth/3, WinHeight-32));
	BoxShowColors = UWindowCheckbox(CreateWindow(class'UWindowCheckbox', 2, 1, 16, 16));
	BoxShowColors.bChecked = Root.Console.bConsoleShowColors;
	BoxShowColors.NotifyWindow = Self;
	
	ShowColLabel = UWindowLabelControl(CreateWindow(class'UWindowLabelControl', 25, 2, WinWidth/3-25, 8));
	ShowColLabel.SetText(ShowColorsText);
	
	BoxShowChatMsg = UWindowCheckbox(CreateWindow(class'UWindowCheckbox', WinWidth/3, 1, 16, 16));
	BoxShowChatMsg.bChecked = Root.Console.bConsoleLogChatOnly;
	BoxShowChatMsg.NotifyWindow = Self;
	
	ShowChatLabel = UWindowLabelControl(CreateWindow(class'UWindowLabelControl', WinWidth/3+25, 2, WinWidth/3-28, 8));
	ShowChatLabel.SetText(ShowChatText);
	
	BoxShowScriptWarns = UWindowCheckbox(CreateWindow(class'UWindowCheckbox', WinWidth/3*2, 1, 16, 16));
	BoxShowScriptWarns.bChecked = Root.Console.bLogScriptWarnings;
	BoxShowScriptWarns.NotifyWindow = Self;
	
	ShowScriptWarnLabel = UWindowLabelControl(CreateWindow(class'UWindowLabelControl', WinWidth/3*2+25, 2, WinWidth/3-28, 8));
	ShowScriptWarnLabel.SetText(ShowWarningText);
	
	EditControl = UWindowEditControl(CreateControl(class'UWindowEditControl', 0, WinHeight-16, WinWidth, 16));
	EditControl.SetFont(F_Normal);
	EditControl.SetNumericOnly(False);
	EditControl.SetMaxLength(400);
	EditControl.SetHistorySave('CmdHistory');
}

function Notify(UWindowDialogControl C, byte E)
{
	local string s;
	Super.Notify(C, E);

	if ( C==BoxShowColors )
	{
		Root.Console.bConsoleShowColors = BoxShowColors.bChecked;
		Root.Console.SaveConfig();
		return;
	}
	else if ( C==BoxShowChatMsg )
	{
		Root.Console.bConsoleLogChatOnly = BoxShowChatMsg.bChecked;
		Root.Console.SaveConfig();
		return;
	}
	else if ( C==BoxShowScriptWarns )
	{
		Root.Console.LogHandler.SetEnabled(Root.Console.bLogScriptWarnings);
		Root.Console.bLogScriptWarnings = BoxShowScriptWarns.bChecked;
		Root.Console.SaveConfig();
		return;
	}
	switch (E)
	{
	case DE_EnterPressed:
		switch (C)
		{
		case EditControl:
			if (EditControl.GetValue() != "")
			{
				s = EditControl.GetValue();
				Root.Console.Message( None, "> "$s, 'Console' );
				EditControl.Clear();
				if ( !Root.Console.ConsoleCommand( s ) )
					Root.Console.Message( None, Localize("Errors","Exec","Core"), 'Console' );
			}
			break;
		}
		break;
	case DE_WheelUpPressed:
		switch (C)
		{
		case EditControl:
			TextArea.VertSB.Scroll(-1);
			break;
		}
		break;
	case DE_WheelDownPressed:
		switch (C)
		{
		case EditControl:
			TextArea.VertSB.Scroll(1);
			break;
		}
		break;
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	BoxShowColors.SetSize(16,16);
	ShowColLabel.SetSize(WinWidth/3-25,12);
	
	BoxShowChatMsg.SetSize(16,16);
	BoxShowChatMsg.WinLeft = WinWidth/3;
	
	ShowChatLabel.SetSize(WinWidth/3-25,12);
	ShowChatLabel.WinLeft = WinWidth/3+25;
	
	BoxShowScriptWarns.SetSize(16,16);
	BoxShowScriptWarns.WinLeft = WinWidth/3*2;
	
	ShowScriptWarnLabel.SetSize(BoxShowScriptWarns.WinLeft-25,12);
	ShowScriptWarnLabel.WinLeft = BoxShowScriptWarns.WinLeft+25;

	EditControl.SetSize(WinWidth, 17);
	EditControl.WinLeft = 0;
	EditControl.WinTop = WinHeight - EditControl.WinHeight;
	EditControl.EditBoxWidth = WinWidth;

	TextArea.SetSize(WinWidth, WinHeight - EditControl.WinHeight-16);
}
function Paint(Canvas C, float X, float Y)
{
	LookAndFeel.DrawClientArea(Self, C);
	DrawStretchedTexture(C, 0, 16, WinWidth, WinHeight-16, Texture'BlackTexture');
}

defaultproperties
{
	ShowColorsText="Show console messages in colors"
	ShowChatText="Log only chat messages"
	ShowWarningText="Log script errors"
}
