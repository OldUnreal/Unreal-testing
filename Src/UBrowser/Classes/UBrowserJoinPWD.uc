//=============================================================================
// UBrowserJoinPWD.
//=============================================================================
class UBrowserJoinPWD expands UWindowDialogClientWindow
	Config(User);

var UWindowEditControl EditBox;
var UWindowSmallCloseButton CloseButton;
var UWindowSmallButton JoinButton,SaveButton;
var UBrowserServerGrid Grid;
var string JoinAddress,JoinShortURL;
var UBrowserServerList JoiningServerInfo;
struct PasswordArrayType
{
	var() private config string SavedPassword,SavedURL;
};
// Leave offset 0 unused so "evil" servers can't steal password num 0.
var private config PasswordArrayType SavedPasswords[32];
var() private config int SavedOffset;

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
	local byte i;

	Super.Notify(C, E);
	if ( Grid==None )
		Return;
	if ( (E==DE_EnterPressed && C==EditBox) || (E==DE_Click && C==JoinButton) )
	{
		if( JoiningServerInfo!=None )
			Grid.AddRecentServer(JoiningServerInfo);
		Grid.JoinWithPassword(JoinAddress,EditBox.GetValue());
		UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).Close();
	}
	else if ( E==DE_Click && C==SaveButton )
	{
		if ( EditBox.GetValue()=="" )
		{
			For( i=0; i<ArrayCount(SavedPasswords); i++ )
			{
				if ( SavedPasswords[i].SavedURL!="" && SavedPasswords[i].SavedURL~=JoinShortURL )
				{
					SavedPasswords[i].SavedPassword = "";
					SavedPasswords[i].SavedURL = "";
					SaveConfig();
					Return;
				}
			}
			Return;
		}
		Log("Saved password '"$EditBox.GetValue()$"' for server"@JoinShortURL,'UBrowser');
		For( i=0; i<ArrayCount(SavedPasswords); i++ )
		{
			if ( SavedPasswords[i].SavedURL!="" && SavedPasswords[i].SavedURL~=JoinShortURL )
			{
				SavedPasswords[i].SavedPassword = EditBox.GetValue();
				SaveConfig();
				Return;
			}
		}
		For( i=1; i<ArrayCount(SavedPasswords); i++ )
		{
			if ( SavedPasswords[i].SavedURL=="" )
			{
				SavedPasswords[i].SavedPassword = EditBox.GetValue();
				SavedPasswords[i].SavedURL = JoinShortURL;
				SaveConfig();
				Return;
			}
		}
		// All entries are full, start overwriting the old ones.
		SavedPasswords[SavedOffset].SavedPassword = EditBox.GetValue();
		SavedPasswords[SavedOffset].SavedURL = JoinShortURL;
		SavedOffset++;
		if ( SavedOffset>=ArrayCount(SavedPasswords) )
			SavedOffset = 1;
		SaveConfig();
	}
}
function ReceiveAddressInfo( string IPAddr )
{
	local byte i;

	For( i=0; i<ArrayCount(SavedPasswords); i++ )
	{
		if ( SavedPasswords[i].SavedURL!="" && SavedPasswords[i].SavedURL~=IPAddr )
		{
			EditBox.SetValue(SavedPasswords[i].SavedPassword);
			Break;
		}
	}
	JoinShortURL = IPAddr;
	JoinAddress = IPAddr;
}

Static function bool MakeClientJoinWithP( string ServerAddress, PlayerPawn Other, optional string AddOpt )
{
	local byte i;

	if ( ViewPort(Other.Player)==None )
		Return False;
	For( i=0; i<ArrayCount(Default.SavedPasswords); i++ )
	{
		if ( Default.SavedPasswords[i].SavedURL!="" && Default.SavedPasswords[i].SavedURL~=ServerAddress )
		{
			Other.ClientTravel("unreal://"$ServerAddress$"?Password="$Default.SavedPasswords[i].SavedPassword$AddOpt, TRAVEL_Absolute, false);
			Return True;
		}
	}
	Return False;
}

defaultproperties
{
}