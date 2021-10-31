//=============================================================================
// SubWebManager.
// The real webadmin manager.
// Accept connections, tell what data to send etc...
// Coded by .:..:
//=============================================================================
class SubWebManager expands WebObjectBase
	Config(WebServer);

struct AccountsType
{
	var() config string Username,Password;
	var() config byte Privileges;
};
struct ConnectionTest
{
	var string IP;
	var byte Count;
};

var bool bMessageSpectatorInit;
var() config bool bLogLoginErrors; // Should log webadmin login failures from random clients.
var() config array<AccountsType> Accounts;
var() config byte MaxLoginAttempts; // Maximum failed login attempts allowed from one IP/map.

var WebAdminManager WebManager;
var LevelInfo Level;
var MessagingSpectator TheWebSpec;
var Engine GameEnginePtr;

var transient array<ConnectionTest> LoginList;

function InitManager()
{
	ForEach AllObjects(Class'Engine',GameEnginePtr)
		Break; // Find our active gameengine.
}
function SpawnMessageSpec()
{
	if( TheWebSpec==None )
		TheWebSpec = Level.Spawn(Class'MessagingSpectator',,,vect(0,0,0),,,,true);
}
function ManageTick( float Delta )
{
	if( !bMessageSpectatorInit )
	{
		bMessageSpectatorInit = True;
		SpawnMessageSpec();
	}
}

// Return the class of weblink
function Class<WebServer> GetWebLinkClass()
{
	Return Class'WebServer';
}

// Try to login client.
function bool LoginClient( WebQuery Q )
{
	local int i;

	if( Q.User=="" )
		return false;
	For( i=(Array_Size(Accounts)-1); i>=0; --i )
	{
		if( Accounts[i].Username~=Q.User && Accounts[i].Password~=Q.Password )
		{
			Q.UserPrivileges = Accounts[i].Privileges;
			Return True;
		}
	}
	Return False;
}

function CheckRJA( WebQuery Q, bool bFailedLogin )
{
	local int i;

	for( i=(Array_Size(LoginList)-1); i>=0; --i )
		if( LoginList[i].IP==Q.Connection.AddressString )
		{
			if( bFailedLogin )
			{
				++LoginList[i].Count;
				if( bLogLoginErrors && LoginList[i].Count>=MaxLoginAttempts )
					Log("Blocking IP-address '"$Q.Connection.AddressString$"' from accessing webserver for the rest of the map.",'WebServer');
			}
			else Array_Remove(LoginList,i);
			return;
		}
	if( bFailedLogin )
	{
		i = Array_Size(LoginList);
		LoginList[i].IP = Q.Connection.AddressString;
		LoginList[i].Count = 1;
	}
}

function bool IgnoreRequest( WebConnection C )
{
	local int i;

	if( MaxLoginAttempts>0 )
	{
		for( i=(Array_Size(LoginList)-1); i>=0; --i )
			if( LoginList[i].IP==C.AddressString )
				return (LoginList[i].Count>=MaxLoginAttempts);
	}
	return false;
}

// Process received data from client
function ProcessData( WebQuery Q )
{
	local string S;
	local int i;

	if( !LoginClient(Q) )
	{
		if( bLogLoginErrors && Q.User!="" )
			Log("Invalid login attempt from '"$Q.Connection.AddressString$"', User: '"$Q.User$"' Pass: '"$Q.Password$"', Requested URL: '"$Q.URL$"'",'WebServer');
		if( MaxLoginAttempts>0 )
			CheckRJA(Q,true);
		Q.SendHTTPError(401);
		return;
	}
	if( MaxLoginAttempts>0 )
		CheckRJA(Q,false);

	if( Level.NextURL!="" )
	{
		Q.LocalizeWebPage("MapSwitchingPage");
		Return;
	}

	S = Q.URL;
	if( Left(S,1)=="/" )
		S = Mid(S,1);

	if( Q.bIsPost )
	{
		i = InStr(S,"?");
		if( i>=0 )
		{
			ProcessPostData(Q,Mid(S,i+1));
			S = Left(S,i);
		}
	}

	// Allow to download image file.
	if( Right(S,4)~=".ico" || Right(S,4)~=".bmp" || Right(S,4)~=".jpg" || Right(S,4)~=".gif" || Right(S,4)~=".png" )
	{
		Q.ContentType = "image/"$Right(S,3);
		Q.IncludeFile(S);
		return;
	}

	// Download CSS style sheet
	if( Right(S,4)~=".css" )
	{
		Q.ContentType = "text/"$Right(S,3);
		Q.IncludeFile(S);
		return;
	}

	if( Left(S,4)=="Mod_" ) // Load mod page
	{
		S = Mid(S,4);
		i = InStr(S,"/");
		if( i>0 )
			S = Left(S,i);
		i = InStr(S,"|");
		if( i>0 )
			S = Left(S,i);
		LoadModPage(S,Q);
	}
	else if( Left(S,8)=="MapList_" ) // Load maplist page
	{
		S = Mid(S,8);
		i = InStr(S,"/");
		if( i>0 )
			S = Left(S,i);
		Class'MapListPage'.Default.DoMapList = S;
		Q.LocalizeWebPage("MapLConfigPage");
	}
	else Q.LocalizeWebPage(S); // Localize web page.
}

function LoadModPage( string S, WebQuery Q )
{
	local class<WebPageContent> C;

	C = Class<WebPageContent>(DynamicLoadObject(S,Class'Class'));
	if( C!=None && !C.Default.bStandardForm )
	{
		if( C.Static.AllowAccess(Q) )
			C.Static.LoadUpClassContent(Q);
		else C.Static.NotEnoughPrivileges(Q);
	}
	else
	{
		Q.MiscInfo = S;
		Q.LocalizeWebPage("ModConfigPage");
	}
}

// Posted data
function ProcessPostData( WebQuery Q, string ReceiverClass )
{
	local class<WebPageContent> WPG;

	WPG = Class<WebPageContent>(DynamicLoadObject(ReceiverClass,Class'Class'));
	if( WPG!=None && WPG.Static.AllowAccess(Q) )
		WPG.Static.ProcessReceivedData(Q);
}

defaultproperties
{
	Accounts.Add((Username="Admin",Password="Admin",Privileges=255))
	MaxLoginAttempts=10
	bLogLoginErrors=true
}
