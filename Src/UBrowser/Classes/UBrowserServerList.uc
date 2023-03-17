//=============================================================================
// UBrowserServerList
//		Stores a server entry in an Unreal Server List
//=============================================================================

class UBrowserServerList extends UWindowList;

// Valid for sentinel only
var	UBrowserServerListWindow	Owner;
var int					TotalServers;
var int					TotalPlayers;
var int					TotalMaxPlayers;
var bool				bNeedUpdateCount;

// Config
var globalconfig int			MaxSimultaneousPing;

// Master server variables
var string				IP;
var int					QueryPort, VerifiedGamePort;
var string				Category;		// Master server categorization
var string				GameName;		// Unreal, Unreal Tournament

// State of the ping
var UBrowserServerPing	ServerPing;
var bool				bPinging;
var bool				bPingFailed;
var bool				bPinged;
var bool				bNoInitalPing;
var bool				bNeverPinged;
var bool				bOldServer;

// Rules and Lists
var UBrowserRulesList	RulesList;
var UBrowserPlayerList  PlayerList;

// Unreal server variables
var bool				bLocalServer;
var float				Ping;
var string				HostName;
var int					GamePort;
var string				MapName;
var string				GameType;
var string				GameMode;
var int					NumPlayers;
var int					MaxPlayers;
var int					GameVer;
var string					GameVerStr;
var int					MinGameVer;
var array<string>			Libaries;
var string				LibraryWebPage,ServerWebPage;

function DestroyListItem()
{
	Owner = None;

	if (ServerPing != None)
	{
		if ( GetPlayerOwner().GetEntryLevel().XLevel==ServerPing.XLevel || GetPlayerOwner().XLevel==ServerPing.XLevel )
			ServerPing.Destroy();
		ServerPing = None;
	}
	Super.DestroyListItem();
}

final function SetGamePort( int NewPort, optional bool bVerified )
{
	if( bVerified )
	{
		VerifiedGamePort = NewPort;
		GamePort = NewPort;
	}
	else if( VerifiedGamePort==-1 )
		GamePort = NewPort;
}
final function bool ValidGamePort()
{
	return (GamePort>0);
}

function QueryFinished(UBrowserServerListFactory Fact, bool bSuccess, optional string ErrorMsg)
{
	Owner.QueryFinished(Fact, bSuccess, ErrorMsg);
}


// Functions for server list entries only.
function PingServer(bool bInitial, bool bJustThisServer, bool bNoSort)
{
	// Log("Pinging Server: "$IP$", bNoSort is: "$bNoSort);

	// Create the UdpLink to ping the server
	ServerPing = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserServerPing');
	ServerPing.Server = Self;
	ServerPing.StartQuery('GetInfo', 2);
	ServerPing.bInitial = bInitial;
	ServerPing.bJustThisServer = bJustThisServer;
	ServerPing.bNoSort = bNoSort;
	bPinging = True;
}

function ServerStatus()
{
	// Create the UdpLink to ping the server
	ServerPing = GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserServerPing');
	ServerPing.Server = Self;
	ServerPing.StartQuery('GetStatus', 2);
//	Log("Starting Info Query for "$IP);
}

function StatusDone(bool bSuccess)
{
	// Destroy the UdpLink
	if ( GetPlayerOwner().GetEntryLevel().XLevel==ServerPing.XLevel || GetPlayerOwner().XLevel==ServerPing.XLevel )
		ServerPing.Destroy();
	ServerPing = None;

	RulesList.Sort();
	PlayerList.Sort();
}

function CancelPing()
{
	if (bPinging && ServerPing != None && ServerPing.bJustThisServer)
		PingDone(False, True, False, True);
}

function PingDone(bool bInitial, bool bJustThisServer, bool bSuccess, bool bNoSort)
{
	local UBrowserServerListWindow W;
	local UBrowserServerList OldSentinel;

	// Destroy the UdpLink
	if (ServerPing != None)
	{
		if ( GetPlayerOwner().GetEntryLevel().XLevel==ServerPing.XLevel || GetPlayerOwner().XLevel==ServerPing.XLevel )
			ServerPing.Destroy();
	}
	ServerPing = None;

	bPinging = False;
	bPingFailed = !bSuccess;
	bPinged = True;

	if (bSuccess)
		bNeverPinged = False;

	if (!bNoSort)
	{
		OldSentinel = UBrowserServerList(Sentinel);

		if (bPingFailed)
			Remove();
		else
			OldSentinel.MoveItemSorted(Self);
	}

	if (Sentinel != None)
	{
		UBrowserServerList(Sentinel).bNeedUpdateCount = True;

		if (bInitial)
			ConsiderForSubsets();
	}

	if (!bJustThisServer)
		if (OldSentinel != None)
		{
			W = OldSentinel.Owner;

			if (W.bPingSuspend)
			{
				W.bPingResume = True;
				W.bPingResumeIntial = bInitial;
			}
			else
				OldSentinel.PingNext(bInitial, bNoSort);
		}
}

function ConsiderForSubsets()
{
	local UBrowserSubsetList l;

	for (l = UBrowserSubsetList(UBrowserServerList(Sentinel).Owner.SubsetList.Next); l != None; l = UBrowserSubsetList(l.Next))
	{
		l.SubsetFactory.ConsiderItem(Self);
	}
}

// Functions for sentinel only

function InvalidatePings()
{
	local UBrowserServerList l;

	for (l = UBrowserServerList(Next); l != None; l = UBrowserServerList(l.Next))
		l.Ping = 9999;
}

function PingServers(bool bInitial, bool bNoSort)
{
	local UBrowserServerList l;

	bPinging = False;

	for (l = UBrowserServerList(Next); l != None; l = UBrowserServerList(l.Next))
	{
		l.bPinging = False;
		l.bPingFailed = False;
		l.bPinged = False;
	}

	PingNext(bInitial, bNoSort);
}

function PingNext(bool bInitial, bool bNoSort)
{
	local int TotalPinging;
	local UBrowserServerList l;
	local bool bDone;

	TotalPinging = 0;

	Owner.TotalPinged = 0;
	Owner.TotalServers = 0;

	bDone = True;
	for (l = UBrowserServerList(Next); l != None; l = UBrowserServerList(l.Next))
	{
		if (l.bPinged)
			Owner.TotalPinged++;
		Owner.TotalServers++;

		if (!l.bPinged)
			bDone = False;
		if (l.bPinging)
			TotalPinging ++;
	}

	if (bDone)
	{
		bPinging = False;
		Owner.PingFinished();
	}
	else if (TotalPinging < MaxSimultaneousPing)
	{
		for (l = UBrowserServerList(Next); l != None; l = UBrowserServerList(l.Next))
		{
			if (		!l.bPinging
					&&	!l.bPinged
					&&	(!bInitial || !l.bNoInitalPing)
					&&	TotalPinging < MaxSimultaneousPing
			   )
			{
				TotalPinging ++;
				l.PingServer(bInitial, False, bNoSort);
			}

			if (TotalPinging >= MaxSimultaneousPing)
				break;
		}
	}
}

function UBrowserServerList FindExistingServer(string FindIP, int FindQueryPort)
{
	local UWindowList l;

	for (l = Next; l != None; l = l.Next)
	{
		if (UBrowserServerList(l).IP == FindIP && UBrowserServerList(l).QueryPort == FindQueryPort)
			return UBrowserServerList(l);
	}
	return None;
}

function PlayerPawn GetPlayerOwner()
{
	return UBrowserServerList(Sentinel).Owner.GetPlayerOwner();
}

function UWindowList CopyExistingListItem(Class<UWindowList> ItemClass, UWindowList SourceItem)
{
	local UBrowserServerList L;

	L = UBrowserServerList(Super.CopyExistingListItem(ItemClass, SourceItem));

	L.bLocalServer	= UBrowserServerList(SourceItem).bLocalServer;
	L.IP			= UBrowserServerList(SourceItem).IP;
	L.VerifiedGamePort = UBrowserServerList(SourceItem).VerifiedGamePort;
	L.QueryPort		= UBrowserServerList(SourceItem).QueryPort;
	L.Ping		= UBrowserServerList(SourceItem).Ping;
	L.HostName		= UBrowserServerList(SourceItem).HostName;
	L.GamePort		= UBrowserServerList(SourceItem).GamePort;
	L.MapName		= UBrowserServerList(SourceItem).MapName;
	L.GameType		= UBrowserServerList(SourceItem).GameType;
	L.GameMode		= UBrowserServerList(SourceItem).GameMode;
	L.NumPlayers	= UBrowserServerList(SourceItem).NumPlayers;
	L.MaxPlayers	= UBrowserServerList(SourceItem).MaxPlayers;
	L.Libaries		= UBrowserServerList(SourceItem).Libaries;
	L.GameVer		= UBrowserServerList(SourceItem).GameVer;
	L.MinGameVer	= UBrowserServerList(SourceItem).MinGameVer;
	L.GameVerStr	= UBrowserServerList(SourceItem).GameVerStr;
	L.LibraryWebPage = UBrowserServerList(SourceItem).LibraryWebPage;
	L.ServerWebPage	= UBrowserServerList(SourceItem).ServerWebPage;
	return L;
}

function bool Compare(UWindowList T, UWindowList B)
{
	return UBrowserServerList(Sentinel).Owner.Grid.Compare(UBrowserServerList(T), UBrowserServerList(B));
}

function UWindowList Append(Class<UWindowList> C)
{
	local UWindowList L;

	L = Super.Append(C);
	UBrowserServerList(Sentinel).bNeedUpdateCount = True;
	return L;
}

function Remove()
{
	local UBrowserServerList S;

	S = UBrowserServerList(Sentinel);
	Super.Remove();

	if (S != None)
		S.bNeedUpdateCount = True;
}

// Sentinel only
function UpdateServerCount()
{
	local UBrowserServerList l;

	TotalServers = 0;
	TotalPlayers = 0;
	TotalMaxPlayers = 0;

	for (l = UBrowserServerList(Next); l != None; l = UBrowserServerList(l.Next))
	{
		TotalServers++;
		TotalPlayers += l.NumPlayers;
		TotalMaxPlayers += l.MaxPlayers;
	}
}

function bool ShowThisItem()
{
	return !bNeverPinged;
}

final function bool ValidateClientDLLs( UWindowWindow W )
{
	local int Find;
	local string S,Lib;
	local bool bFound,bHasVer;
	local UBrowserLibPageWindow LW;

	foreach Libaries(Lib)
	{
		bFound = false;
		Find = InStr(Lib,"/");
		bHasVer = (Find>0);
		foreach GetLocalPlayerPawn().AllLibaries(S,LIBFLAG_AllLibs)
		{
			if( bHasVer )
			{
				if( !(S~=Left(Lib,Len(S))) )
					continue;
				S = S$"/"$Localize("public","LinkVersion",S);
			}
			if( S~=Lib )
			{
				bFound = true;
				break;
			}
		}
		if( bFound )
			continue;
		LW = UBrowserLibPageWindow(W.Root.CreateWindow(class'UBrowserLibPageWindow',W.Root.WinWidth/2-250,W.Root.WinHeight/3-50,500,400,,true));
		S = Lib;
		if( bHasVer )
			S = Left(S,Find)$Mid(S,Find+1);
		LW.SetDLLInfo(Lib,LibraryWebPage$S$".html",bHasVer);
		return false;
	}
	return true;
}

defaultproperties
{
	MaxSimultaneousPing=10
	LibraryWebPage="www.oldunreal.com/libs/"
	VerifiedGamePort=-1
}