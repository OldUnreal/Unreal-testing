//=============================================================================
// Admin GUI ClientWindow
//=============================================================================
class AdminGUIManBanClientW extends UWindowDialogClientWindow;

var UWindowFramedWindow MainWin;
var() localized string PlayerNameTxt,PlayerIpTxt,InsertBanTxt;

var UWindowSmallCloseButton CloseButton;
var UWindowSmallButton InsertBanButton;
var UWindowEditControl IPStartE[4],IPEndE[4],PlNameE;
var UWindowLabelControl NameTxt,IPTxt,RangeTxt;
var UWindowCheckbox IPRangeCheck;

function Created()
{
	local byte i;

	Super.Created();
	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', 0, 0, 48, 16));
	InsertBanButton = UWindowSmallButton(CreateWindow(class'UWindowSmallButton', 0, 0, 50, 16));
	InsertBanButton.SetText(InsertBanTxt);
	InsertBanButton.Register(Self);

	PlNameE = UWindowEditControl(CreateControl(class'UWindowEditControl',0,0,140,10));
	PlNameE.SetFont(F_Normal);
	PlNameE.SetNumericOnly(False);
	PlNameE.SetMaxLength(80);
	PlNameE.SetHistory(True);
	PlNameE.EditBoxWidth = 140;
	PlNameE.SetValue("Player");

	IPRangeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox',0,0,16,16));
	IPRangeCheck.Register(Self);

	NameTxt = UWindowLabelControl(CreateControl(class'UWindowLabelControl',0,0,180,10));
	NameTxt.SetFont(F_Normal);
	NameTxt.Align = TA_Left;
	NameTxt.SetText(PlayerNameTxt);

	IPTxt = UWindowLabelControl(CreateControl(class'UWindowLabelControl',0,0,180,10));
	IPTxt.SetFont(F_Normal);
	IPTxt.Align = TA_Left;
	IPTxt.SetText(PlayerIpTxt);

	RangeTxt = UWindowLabelControl(CreateControl(class'UWindowLabelControl',0,0,50,10));
	RangeTxt.SetFont(F_Normal);
	RangeTxt.Align = TA_Left;
	RangeTxt.SetText("End range");

	for ( i=0; i<4; i++ )
	{
		IPStartE[i] = UWindowEditControl(CreateControl(class'UWindowEditControl',0,0,22,10));
		IPStartE[i].SetFont(F_Normal);
		IPStartE[i].SetNumericOnly(True);
		IPStartE[i].SetMaxLength(3);
		IPStartE[i].SetHistory(False);
		IPStartE[i].EditBoxWidth = 20;
		IPStartE[i].SetValue("0");
		IPEndE[i] = UWindowEditControl(CreateControl(class'UWindowEditControl',0,0,22,10));
		IPEndE[i].SetFont(F_Normal);
		IPEndE[i].SetNumericOnly(True);
		IPEndE[i].SetMaxLength(3);
		IPEndE[i].SetHistory(False);
		IPEndE[i].EditBoxWidth = 20;
		IPEndE[i].SetValue("0");
		IPEndE[i].EditBox.bCanEdit = False;
	}
	Resized();
}
function SetStatus( string Status )
{
	if ( MainWin!=None )
		MainWin.StatusBarText = Status;
}
function Resized()
{
	local byte i;

	CloseButton.WinLeft = WinWidth-72;
	CloseButton.WinTop = WinHeight-26;
	InsertBanButton.WinLeft = 10;
	InsertBanButton.WinTop = WinHeight-26;
	NameTxt.WinTop = 10;
	NameTxt.WinLeft = 4;
	NameTxt.WinWidth = WinWidth-8;
	PlNameE.WinTop = 28;
	PlNameE.WinLeft = WinWidth/2-PlNameE.WinWidth/2;
	IPTxt.WinTop = 50;
	IPTxt.WinLeft = Max(PlNameE.WinLeft-10,6);
	IPRangeCheck.WinTop = 85;
	IPRangeCheck.WinLeft = 8;
	for ( i=0; i<4; i++ )
	{
		IPStartE[i].WinTop = 64;
		IPStartE[i].WinLeft = PlNameE.WinLeft+5+i*28;
		IPEndE[i].WinTop = 84;
		IPEndE[i].WinLeft = IPStartE[i].WinLeft;
	}
	RangeTxt.WinTop = 84;
	RangeTxt.WinLeft = IPEndE[3].WinLeft+29;
}
function Notify(UWindowDialogControl C, byte E)
{
	local string S,N;
	local int i;

	if ( E==DE_Click && C==InsertBanButton )
	{
		S = byte(IPStartE[0].GetValue())$"."$byte(IPStartE[1].GetValue())$"."$byte(IPStartE[2].GetValue())$"."$byte(IPStartE[3].GetValue());
		if ( IPRangeCheck.bChecked )
			S = S$"-"$byte(IPEndE[0].GetValue())$"."$byte(IPEndE[1].GetValue())$"."$byte(IPEndE[2].GetValue())$"."$byte(IPEndE[3].GetValue());
		N = PlNameE.GetValue();
		for ( i=InStr(N," "); i>=0; i=InStr(N," ") )
			N = Left(N,i)$"_"$Mid(N,i+1);
		Root.Console.Viewport.Actor.Admin("UBanInsert"@N@S);
		return;
	}
	else if ( E==DE_Click && C==IPRangeCheck )
	{
		for ( i=0; i<4; i++ )
			IPEndE[i].EditBox.bCanEdit = IPRangeCheck.bChecked;
		return;
	}
	Super.Notify(C,E);
}

defaultproperties
{
	PlayerNameTxt="Client name (for banlisting purposes only):"
	PlayerIpTxt="Client IP address (or IP range if desired):"
	InsertBanTxt="Insert ban"
	bLeaveOnscreen=True
}
