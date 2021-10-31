//=============================================================================
// UBrowserServerWebCW
//=============================================================================
class UBrowserServerWebCW extends UWindowDialogClientWindow;

var localized string RefreshString;
var UBrowserServerWebHTMLArea HTMLTextArea;
var UWindowSmallButton Next,Prev,Refresh;
var UBrowserServerWebWin PageOwner;

function Created()
{
	Super.Created();
	HTMLTextArea = UBrowserServerWebHTMLArea(CreateWindow(Class'UBrowserServerWebHTMLArea',0,32,WinWidth,WinHeight-32));

	Prev = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', 4, 4, 20, 16));
	Prev.SetText("<<");
	Prev.Register(Self);

	Next = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', 28, 4, 20, 16));
	Next.SetText(">>");
	Next.Register(Self);

	Refresh = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', 52, 4, 90, 16));
	Refresh.SetText(RefreshString);
	Refresh.Register(Self);
}
function Resized()
{
	HTMLTextArea.SetSize(WinWidth, WinHeight-32);
}
function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, 0, WinWidth, 32, T);
}
function BeforePaint(Canvas C, float X, float Y)
{
	Prev.bDisabled = (PageOwner.HistoryOffset<=0);
	Next.bDisabled = (PageOwner.HistoryOffset>=(PageOwner.HistoryCount-1));
}
function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	if ( E==DE_Click )
	{
		Switch(C)
		{
		case Prev:
			if( !Prev.bDisabled )
				PageOwner.HistoryPrevious();
			Break;
		case Next:
			if( !Next.bDisabled )
				PageOwner.HistoryNext();
			Break;
		case Refresh:
			PageOwner.ReloadPage();
			Break;
		}
	}
}

defaultproperties
{
	RefreshString="Refresh page"
}