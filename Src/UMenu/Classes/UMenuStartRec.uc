class UMenuStartRec expands UMenuPageWindow;

var UWindowEditControl EditBox;
var UWindowSmallButton StartRecButton;
var UWindowSmallCloseButton CancelButton;
var float ButtonWidth;
var() localized string StartRecText,RecordInfo;

const ControlHSpacing = 10;

function Created()
{
	Super.Created();

	StartRecButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ControlHSpacing, WinHeight - 24, 75, 16));
	StartRecButton.SetText(StartRecText);
	CancelButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', WinWidth - 75 - ControlHSpacing, WinHeight - 24, 75, 16));

	EditBox = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlHSpacing, 5, WinWidth - ControlHSpacing * 2, 10));
	EditBox.SetFont(F_Normal);
	EditBox.SetNumericOnly(False);
	EditBox.SetMaxLength(150);
	EditBox.SetHistory(True);
	EditBox.SetText(RecordInfo);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	if ( (E==DE_EnterPressed && C==EditBox) || (E==DE_Click && C==StartRecButton) )
	{
		if( Len(EditBox.GetValue())>0 )
		{
			GetPlayerOwner().bConsoleCommandMessage = true;
			GetPlayerOwner().ConsoleCommand("DEMOREC"@EditBox.GetValue());
			GetPlayerOwner().bConsoleCommandMessage = false;
		}
		ParentWindow.HideWindow();
		Root.Console.CloseUWindow();
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	EditBox.AutoWidth(C);
	EditBox.WinLeft = ControlHSpacing;
	EditBox.EditBoxWidth += WinWidth - 2 * ControlHSpacing - EditBox.WinWidth;
	StartRecButton.AutoWidthBy(C, ButtonWidth);
	CancelButton.AutoWidthBy(C, ButtonWidth);
	CancelButton.WinLeft = WinWidth - CancelButton.WinWidth - ControlHSpacing;
}

defaultproperties
{
	StartRecText="Start demorec"
	RecordInfo="Output file name:"
}