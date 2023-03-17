//=============================================================================
// UBrowserJoinPWD.
//=============================================================================
class UBrowserJoinPWD expands UWindowDialogClientWindow;

var UWindowEditControl EditBox;
var UWindowSmallCloseButton CloseButton;
var UWindowSmallButton JoinButton,SaveButton;
var UBrowserServerGrid Grid;
var string JoinAddress,JoinShortURL;
var UBrowserServerList JoiningServerInfo;

function Created()
{
	Super.Created();

	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', 225, WinHeight-24, 48, 16));
	JoinButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', 20, WinHeight-24, 75, 16));
	JoinButton.SetText("Join game");
	JoinButton.Register(Self);
	SaveButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', 115, WinHeight-24, 90, 16));
	SaveButton.SetText("Save password");
	SaveButton.Register(Self);

	EditBox = UWindowEditControl(CreateControl(class'UWindowEditControl',20,5,WinWidth-40,10));
	EditBox.SetFont(F_Normal);
	EditBox.SetNumericOnly(False);
	EditBox.SetMaxLength(150);
	EditBox.SetHistory(True);
	EditBox.SetText("Password:");
	EditBox.EditBoxWidth = (WinWidth-40)/3*2;
}
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	if ( !Grid )
		return;
	if ( (E==DE_EnterPressed && C==EditBox) || (E==DE_Click && C==JoinButton) )
	{
		if( JoiningServerInfo )
			Grid.AddRecentServer(JoiningServerInfo);
		Grid.JoinWithPassword(JoinAddress,EditBox.GetValue());
		EditBox.SetValue("");
		UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).Close();
	}
	else if ( E==DE_Click && C==SaveButton )
		Class'Engine'.Static.StorePassword(JoinShortURL,EditBox.GetValue());
}
function ReceiveAddressInfo( string IPAddr )
{
	EditBox.SetValue("");
	JoinShortURL = IPAddr;
	JoinAddress = IPAddr;
}

defaultproperties
{
}