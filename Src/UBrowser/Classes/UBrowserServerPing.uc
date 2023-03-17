//=============================================================================
// UBrowserServerPing: Query an Unreal server for its details
//=============================================================================
class UBrowserServerPing extends UdpLink;

var UBrowserServerList	Server;

var IpAddr				ServerIPAddr;
var float				ElapsedTime;
var name				QueryState;
var bool				bInitial;
var bool				bJustThisServer;
var bool				bNoSort;
var int					PingAttempts;
var int					AttemptNumber;
var int					BindAttempts;

var localized string	AdminEmailText;
var localized string	AdminNameText;
var localized string	ChangeLevelsText;
var localized string	MultiplayerBotsText;
var localized string	FragLimitText;
var localized string	TimeLimitText;
var localized string	GameModeText;
var localized string	GameTypeText;
var localized string	GameVersionText;
var localized string	GameSubVersionText;
var localized string	WorldLogText;
var localized string	TrueString;
var localized string	FalseString;
var localized string	MapFileString,DLLString,DLLVerString,WebURLString,ServerOSString,GameClassString;

// config
var config int			MaxBindAttempts;
var config int			BindRetryTime;
var config int			PingTimeout;

function ValidateServer()
{
	if (Server.ServerPing != Self)
	{
		//Log("ORPHANED: "$Self,'UBrowser');
		Destroy();
	}
}

function StartQuery(name S, int InPingAttempts)
{
	QueryState = S;
	ValidateServer();
	ServerIPAddr.Port = Server.QueryPort;
	GotoState('Resolving');
	PingAttempts=InPingAttempts;
	AttemptNumber=1;
}

function Resolved( IpAddr Addr )
{
	ServerIPAddr.Addr = Addr.Addr;

	GotoState('Binding');
}

function bool GetNextValue(string In, out string Out, out string Result)
{
	local int i;
	local bool bFoundStart;

	Result = "";
	bFoundStart = False;

	for (i=0; i<Len(In); i++)
	{
		if (bFoundStart)
		{
			if (Mid(In, i, 1) == "\\")
			{
				Out = Right(In, Len(In) - i);
				return True;
			}
			else
			{
				Result = Result $ Mid(In, i, 1);
			}
		}
		else
		{
			if (Mid(In, i, 1) == "\\")
			{
				bFoundStart = True;
			}
		}
	}

	return False;
}

final function string LocalizeBoolValue(string Value)
{
	if (Value ~= "True")
		return TrueString;

	if (Value ~= "False")
		return TrueString;

	return Value;
}

function AddRule(string Rule, string Value)
{
	local UBrowserRulesList  RulesList;

	ValidateServer();

	for (RulesList = UBrowserRulesList(Server.RulesList.Next); RulesList != None; RulesList = UBrowserRulesList(RulesList.Next))
		if (RulesList.Rule == Rule)
			return; // Rule already exists

	// Add the rule
	RulesList = UBrowserRulesList(Server.RulesList.Append(class'UBrowserRulesList'));
	RulesList.Rule = Rule;
	RulesList.Value = Value;
}
function AddRuleX(string Rule, string Value)
{
	local UBrowserRulesList  RulesList;

	ValidateServer();

	// Add the rule
	RulesList = UBrowserRulesList(Server.RulesList.Append(class'UBrowserRulesList'));
	RulesList.Rule = Rule;
	RulesList.Value = Value;
}

state Binding
{
Begin:
	if ( !BindPort(2000+Rand(4000), true) )
	{
		Log("UBrowserServerPing: Port failed to bind.  Attempt "$BindAttempts,'UBrowser');
		BindAttempts++;

		ValidateServer();
		if (BindAttempts == MaxBindAttempts)
			Server.PingDone(bInitial, bJustThisServer, False, bNoSort);
		else
			GotoState('BindFailed');
	}
	else
	{
		GotoState(QueryState);
	}
}

state BindFailed
{
	event Timer()
	{
		GotoState('Binding');
	}

Begin:
	SetTimer(BindRetryTime, False);
}

state GetStatus
{
	final function string SplitDLLVer( string S )
	{
		local int i;
		local string v;

		i = InStr(S,"/");
		if( i==-1 )
			return S;
		else
		{
			v = Mid(S,i+1);
			S = Left(S,i);
		}
		return ReplaceStr(ReplaceStr(DLLVerString,"%ls",S),"%i",v);
	}
	event ReceivedText( IpAddr Addr, string Text )
	{
		local string Value,StrValue;
		local string In;
		local string Out;
		local byte ID;
		local bool bOK,bNoMoreValues;
		local UBrowserPlayerList PlayerEntry;

		ValidateServer();

		In = Text;
		do
		{
			bOK = GetNextValue(In, Out, Value);
			In = Out;
			if (Left(Value, 7) == "player_")
			{
				bNoMoreValues = True;
				ID = Int(Right(Value, Len(Value) - 7));

				PlayerEntry = Server.PlayerList.FindID(ID);
				if (PlayerEntry == None)
					PlayerEntry = UBrowserPlayerList(Server.PlayerList.Append(class'UBrowserPlayerList'));
				PlayerEntry.PlayerID = ID;

				bOK = GetNextValue(In, Out, Value);
				In = Out;
				PlayerEntry.PlayerName = Value;
			}
			else if (Left(Value, 6) == "frags_")
			{
				ID = Int(Right(Value, Len(Value) - 6));

				bOK = GetNextValue(In, Out, Value);
				In = Out;
				PlayerEntry = Server.PlayerList.FindID(ID);
				PlayerEntry.PlayerFrags = Int(Value);
			}
			else if (Left(Value, 5) == "ping_")
			{
				ID = Int(Right(Value, Len(Value) - 5));

				bOK = GetNextValue(In, Out, Value);
				In = Out;
				PlayerEntry = Server.PlayerList.FindID(ID);
				PlayerEntry.PlayerPing = Int(Right(Value, len(Value) - 1));  // leading space
			}
			else if (Left(Value, 5) == "team_")
			{
				ID = Int(Right(Value, Len(Value) - 5));

				bOK = GetNextValue(In, Out, Value);
				In = Out;
				PlayerEntry = Server.PlayerList.FindID(ID);
				PlayerEntry.PlayerTeam = Value;
			}
			else if (Left(Value, 5) == "skin_")
			{
				ID = Int(Right(Value, Len(Value) - 5));

				bOK = GetNextValue(In, Out, Value);
				In = Out;
				PlayerEntry = Server.PlayerList.FindID(ID);
				PlayerEntry.PlayerSkin = GetItemName(Value);
			}
			else if (Left(Value, 5) == "mesh_")
			{
				ID = Int(Right(Value, Len(Value) - 5));

				bOK = GetNextValue(In, Out, Value);
				In = Out;
				PlayerEntry = Server.PlayerList.FindID(ID);
				PlayerEntry.PlayerMesh = GetItemName(Value);
			}
			else if (Value == "final")
			{
				Server.StatusDone(True);
				return;
			}
			else if (Value ~= "gamever")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(GameVersionText, Value);
				In = Out;
			}
			else if (Value ~= "gametype")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(GameTypeText, Value);
				In = Out;
			}
			else if (Value ~= "gameclass")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(GameClassString, Value);
				In = Out;
			}
			else if (Value ~= "gamemode")
			{
				bOK = GetNextValue(In, Out, Value);
				// AddRule(GameModeText, Value); <- No reason for this rule as it's hardcoded to openplaying.
				In = Out;
			}
			else if (Value ~= "timelimit")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(TimeLimitText, Value);
				In = Out;
			}
			else if (Value ~= "fraglimit")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(FragLimitText, Value);
				In = Out;
			}
			else if (Value ~= "MultiplayerBots")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(MultiplayerBotsText, LocalizeBoolValue(Value));
				In = Out;
			}
			else if (Value ~= "ChangeLevels")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(ChangeLevelsText, LocalizeBoolValue(Value));
				In = Out;
			}
			else if (Value ~= "AdminName")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(AdminNameText, Value);
				In = Out;
			}
			else if (Value ~= "AdminEMail")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(AdminEmailText, Value);
				In = Out;
			}
			else if (Value ~= "WorldLog")
			{
				bOK = GetNextValue(In, Out, Value);
				// AddRule(WorldLogText, LocalizeBoolValue(Value)); <- Not really intresting eighter.
				In = Out;
			}
			else if (Value ~= "mapfilename")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(MapFileString,Value);
				In = Out;
			}
			else if (Value == "DLL")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(DLLString,SplitDLLVer(Value));
				In = Out;
			}
			else if (Value == "servurl")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(WebURLString,Value);
				In = Out;
			}
			else if (Value == "OS")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(ServerOSString,Value);
				In = Out;
			}
			else if ( bNoMoreValues )
				Continue;
			else if ( Value~="gamename" || Value~="mingamever" || Value~="location" || Value=="liburl"
			 || Value~="hostname" || Value~="shortname" || Value~="hostport" || Value=="gamesubver"
			 || Value~="mapname" || Value~="numplayers" || Value~="maxplayers"
			 || Value~="gamemode" || Value~="queryid" || Value ~= "gamever" ) // Standard values we dont need.
			{
				bOK = GetNextValue(In, Out, Value);
				In = Out;
			}
			else
			{
				StrValue = Caps(Left(Value,1))$Mid(Value,1);
				bOK = GetNextValue(In, Out, Value);
				AddRuleX(StrValue,Value);
				In = Out;
			}
		}
		until(!bOK);
	}

	event Timer()
	{
		if (AttemptNumber < PingAttempts)
		{
			Log("Timed out getting player replies.  Attempt "$AttemptNumber,'UBrowser');
			AttemptNumber++;
			GotoState(QueryState);
		}
		else
		{
			Server.StatusDone(False);
			Log("Timed out getting player replies.  Giving Up",'UBrowser');
		}
	}
Begin:
	// Player info

	ValidateServer();
	if (Server.PlayerList != None)
	{
		Server.PlayerList.DestroyList();
	}
	Server.PlayerList = New(None) class'UBrowserPlayerList';
	Server.PlayerList.SetupSentinel();

	if (Server.RulesList != None)
	{
		Server.RulesList.DestroyList();
	}
	Server.RulesList = New(None) class'UBrowserRulesList';
	Server.RulesList.SetupSentinel();

	SendText( ServerIPAddr, "\\status\\" );
	SetTimer(PingTimeout + Rand(200)/100, False);
}

state GetInfo
{
	event ReceivedText(IpAddr Addr, string Text)
	{
		local string Temp;
		local int i;
		local int l,DLLCount;

		Disable('Tick');

		ValidateServer();
		Server.Ping = 1000*ElapsedTime;
		Server.HostName = Server.IP;
		Server.SetGamePort(0);
		Server.MapName = "";
		Server.GameType = "";
		Server.GameMode = "";
		Server.NumPlayers = 0;
		Server.MaxPlayers = 0;
		Server.GameVer = 0;
		Server.MinGameVer = 0;
		Server.LibraryWebPage = Server.Default.LibraryWebPage;
		Server.ServerWebPage = "";
		Array_Size(Server.Libaries,0);

		l = Len(Text);

		i=InStr(Text, "\\hostname\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 10);
			Server.HostName = Left(Temp, InStr(Temp, "\\"));
		}
		else
		{
			// Invalid ping response
			Disable('Tick');

			Server.Ping = 9999;
			Server.bNeverPinged = True;
			Server.PingDone(bInitial, bJustThisServer, False, bNoSort);
			return;
		}

		i=InStr(Text, "\\hostport\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 10);
			Server.SetGamePort(Int(Left(Temp, InStr(Temp, "\\"))));
		}

		i=InStr(Text, "\\mapname\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 9);
			Server.MapName = Left(Temp, InStr(Temp, "\\"));
		}

		i=InStr(Text, "\\gametype\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 10);
			Server.GameType = Left(Temp, InStr(Temp, "\\"));
		}

		i=InStr(Text, "\\numplayers\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 12);
			Server.NumPlayers = Int(Left(Temp, InStr(Temp, "\\")));
		}

		i=InStr(Text, "\\maxplayers\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 12);
			Server.MaxPlayers = Int(Left(Temp, InStr(Temp, "\\")));
		}

		i=InStr(Text, "\\gamemode\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 10);
			Server.GameMode = Left(Temp, InStr(Temp, "\\"));
		}

		Temp = Text;
		while( true )
		{
			i=InStr(Temp, "\\DLL\\");
			if( i==-1 )
				break;
			Temp = Mid(Temp, i+5);
			Server.Libaries[DLLCount++] = Left(Temp, InStr(Temp, "\\"));
		}

		i=InStr(Text, "\\gamever\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 9);
			Server.GameVerStr = Left(Temp, InStr(Temp, "\\"));
			Server.GameVer = int(Server.GameVerStr);
		}

		i=InStr(Text, "\\mingamever\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 12);
			Server.MinGameVer = Int(Left(Temp, InStr(Temp, "\\")));
		}

		i=InStr(Text, "\\liburl\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 8);
			Server.LibraryWebPage = Left(Temp, InStr(Temp, "\\"));
		}

		i=InStr(Text, "\\servurl\\");
		if (i >= 0)
		{
			Temp = Right(Text, l - i - 9);
			Server.ServerWebPage = Left(Temp, InStr(Temp, "\\"));
		}

		Server.PingDone(bInitial, bJustThisServer, True, bNoSort);
	}

	event Tick(Float DeltaTime)
	{
		ElapsedTime = ElapsedTime + DeltaTime;
	}

	event Timer()
	{
		ValidateServer();
		if (AttemptNumber < PingAttempts)
		{
			Log("Ping Timeout from "$Server.IP$".  Attempt "$AttemptNumber,'UBrowser');
			AttemptNumber++;
			GotoState(QueryState);
		}
		else
		{
			Log("Ping Timeout from "$Server.IP$" Giving Up",'UBrowser');

			Server.Ping = 9999;
			Server.SetGamePort(0);
			Server.MapName = "";
			Server.GameType = "";
			Server.GameMode = "";
			Server.NumPlayers = 0;
			Server.MaxPlayers = 0;

			Disable('Tick');

			Server.PingDone(bInitial, bJustThisServer, False, bNoSort);
		}
	}

Begin:
	ElapsedTime = 0;
	Enable('Tick');
	SendText( ServerIPAddr, "\\info\\" );
	SetTimer(PingTimeout + Rand(200)/100, False);
}

state Resolving
{
Begin:
	Resolve( Server.IP );
}

defaultproperties
{
	AdminEmailText="Admin Email"
	AdminNameText="Admin Name"
	ChangeLevelsText="Change Levels"
	MultiplayerBotsText="Bots in Multiplayer"
	FragLimitText="Frag Limit"
	TimeLimitText="Time Limit"
	GameModeText="Game Mode"
	GameTypeText="Game Type"
	GameVersionText="Game Version"
	GameSubVersionText="Game SubVersion"
	WorldLogText="ngStats World Stat-Logging"
	TrueString="Enabled"
	FalseString="Disabled"
	MapFileString="Map Filename"
	DLLString="C++ Library"
	DLLVerString="%ls (ver %i)"
	WebURLString="Website URL"
	ServerOSString="Server OS"
	GameClassString="Game Class"
	MaxBindAttempts=5
	BindRetryTime=10
	PingTimeout=5
}
