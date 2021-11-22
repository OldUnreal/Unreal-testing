//=============================================================================
// Admin Access Manager - Simple control class to manage what cheat
// codes a client may use.
//=============================================================================
Class AdminAccessManager extends Info
	NoUserCreate;

var localized string AdminLoginText,AdminLogoutText,CheatUsedStr;

var() globalconfig bool bLogCheatUseage;

struct FConnectionInfo
{
	var string DLFileName;
	var int DLSent,DLTotalSize;
	var NetConnection CON;
};

function AdminLogin( PlayerPawn Other )
{
	Other.bAdmin = true;
	Log(ReplaceStr(AdminLoginText,"%ls",Other.GetHumanName()),Class.Name);
}
function AdminLogout( PlayerPawn Other )
{
	if( Other==None || !Other.bAdmin )
		return;
	Other.bAdmin = false;
	Log(ReplaceStr(AdminLogoutText,"%ls",Other.GetHumanName()),Class.Name);
}
function bool AtCapacity( bool bSpectator, out string Error )
{
	if( Level.NetMode==NM_StandAlone )
		return false;
	if( bSpectator && (Level.Game.NumSpectators>=Level.Game.MaxSpectators) )
	{
		Error = "Max spectators exceeded";
		return true;
	}
	else if( !bSpectator && Level.Game.MaxPlayers>0 && (Level.Game.NumPlayers>=Level.Game.MaxPlayers) )
	{
		Error = Level.Game.MaxedOutMessage;
		return true;
	}
	return false;
}
function bool CanExecuteCheat( PlayerPawn Other, name N )
{
	if( !Other.bAdmin && NetConnection(Other.Player)!=None )
		return false;
	if( bLogCheatUseage )
		Log(ReplaceStr(ReplaceStr(CheatUsedStr,"%ls",Other.GetHumanName()),"%c",string(N)),Class.Name);
	return true;
}
function bool CanExecuteCheatStr( PlayerPawn Other, name N, string Parms )
{
	if( !Other.bAdmin && NetConnection(Other.Player)!=None )
		return false;
	if( bLogCheatUseage )
		Log(ReplaceStr(ReplaceStr(CheatUsedStr,"%ls",Other.GetHumanName()),"%c",N@Parms),Class.Name);
	return true;
}

function InitGame( string Options, out string Error );

function GetConnections( optional PlayerPawn Executer )
{
	local NetConnection CON;
	local NetConnection DLCON;
	local string IP;
	local string Options;
	local string InName;
	local string StateString;
	local string ConString;
	local byte ConState;
	local int Port;
	local int X,Y;
	local string FileName;
	local int Sent;
	local int TotalSize;
	local array<FConnectionInfo> CacheInfo;
	local float percent;
	local string Output;
	local bool bGotDownloaders,bDownloader;

	ForEach Level.AllConnections(CON)
	{
		IP=Level.GetConIP(CON,Port);
		Options="?"$Level.GetConOpts(CON);

		if (CON.Actor == None)
			InName = Level.Game.ParseOption(Options,"Name");
		else InName = CON.Actor.GetHumanName();

		ConState = Level.GetConState(CON);

		if (ConState < 2)
			continue; //No need to broadcast..
		else if (ConState == 2)
			StateString = "Pending";
		else StateString = "Open";

		if (CON.Actor == None) //check for connections without actors(downloading or connecting)
		{
			if (!bGotDownloaders)
			{
				// if we do this here, we iterate the list once, instead of how many times there are new connections.
				ForEach Level.AllDownloaders(DLCON,FileName,Sent,TotalSize)
				{
					CacheInfo[Y].CON = DLCON;
					CacheInfo[Y].DLFileName = Filename;
					CacheInfo[Y].DLSent = Sent/1024;
					CacheInfo[Y].DLTotalSize = TotalSize/1024;
					++Y;
				}
				bGotDownloaders=True;
			}
			for ( X=0; X<Y; X++ ) //X is used again to determine wich array index on this iteration with downloader.
			{
				if( CacheInfo[X].CON==CON )
				{
					ConString="(Downloading)";
					bDownloader=True;
					break;
				}
			}
			if ( !bDownloader )
				ConString="(Connecting)";//Always connecting, if not downloading.
		}
		if (bDownloader)
		{
			Percent = (float(CacheInfo[X].DLSent)/float(CacheInfo[X].DLTotalSize))*100;//convert to float to fix division errors
			Output = "Conn #"$CON$":"@IP$":"$Port@InName@"Down:"@CacheInfo[X].DLFileName@CacheInfo[X].DLSent$"/"$CacheInfo[X].DLTotalSize$"kb"@percent$"%"@"State:"@StateString@ConString;
			bDownloader = False;//reset
		}
		else
		{
			Output = "Conn #"$CON$":"@IP$":"$Port@InName@"State:"@StateString;
			if( CON.Actor!=None && CON.Actor.bAdmin )
				Output = Output$"(Admin)";
		}
		Log(Output,Class.Name);
		if( Executer!=None )
			Executer.ClientMessage(Output);
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
	AdminLoginText="Administrator %ls logged in"
	AdminLogoutText="Administrator %ls logged out"
	CheatUsedStr="%ls used admin/cheat command: %c"
}
