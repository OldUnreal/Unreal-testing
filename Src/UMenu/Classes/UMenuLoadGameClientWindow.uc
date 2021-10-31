class UMenuLoadGameClientWindow extends UMenuSlotClientWindow;

var UMenuRaisedButton RestartButton;
var localized string RestartText;
var localized string RestartHelp;

function Created()
{
	local int ButtonWidth, ButtonLeft, ButtonTop;

	Super.Created();

	ButtonWidth = WinWidth - 30;
	ButtonLeft = (WinWidth - ButtonWidth)/2;

	ButtonTop = 25 + 25*10;
	RestartButton = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
	RestartButton.SetText(RestartText @ GetLevel().TitleOrName());
	RestartButton.SetHelpText(RestartHelp);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft;

	Super.BeforePaint(C, X, Y);

	ButtonWidth = WinWidth - 30;
	ButtonLeft = (WinWidth - ButtonWidth)/2;

	RestartButton.SetSize(ButtonWidth, 1);
	RestartButton.WinLeft = ButtonLeft;
	RestartButton.WinTop = WinHeight-28;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_Click:
		if ( C == RestartButton )
		{
			Root.GetPlayerOwner().ReStartLevel();
			Close();
			return;
		}

		if ( UMenuRaisedButton(C)==None )
		{
			return;
		}

		GetPlayerOwner().ClientTravel( "?load="$UMenuRaisedButton(C).Index, TRAVEL_Absolute, false);
		GetParent(Class'UWindowFramedWindow',false).Close();
		Root.Console.CloseUWindow();
		break;
	}
}

defaultproperties
{
	BottonSpace=29
	RestartText="Restart"
	RestartHelp="Press to restart the current level."
}
