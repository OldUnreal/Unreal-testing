//=============================================================================
// UBrowserServerGrid - base class for server listings
//=============================================================================
class UBrowserServerGrid extends UWindowGrid;

#exec TEXTURE IMPORT NAME=Highlight FILE=Textures\Highlight.bmp GROUP="Icons" FLAGS=2 MIPS=OFF

var UBrowserRightClickMenu Menu;
var UWindowGridColumn Server, Ping, MapName, Players, SortByColumn, ip, port, Vers;
var bool bSortDescending;
var localized string ServerName, PingName, MapNameName, PlayersName, VersionName;

var UBrowserServerList SelectedServer;
var int Count;

var float TimePassed;
var int AutoPingInterval;
var UBrowserServerList OldPingServer;

function Created()
{
	Super.Created();

	RowHeight = 12;

	CreateColumns();

	Menu = UBrowserRightClickMenu(Root.CreateWindow(class'UBrowserRightClickMenu', 0, 0, 100, 100));
	Menu.HideWindow();
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if (Menu != None && Menu.bWindowVisible)
		Menu.HideWindow();
}

function CreateColumns()
{
	Server	= AddColumn(ServerName, 300);
	Ping		= AddColumn(PingName, 30);
	MapName	= AddColumn(MapNameName, 100);
	Players	= AddColumn(PlayersName, 50);
	Vers		= AddColumn(VersionName, 50);

	ip = AddColumn("IP", 100);
	port = AddColumn("Port", 30);

	SortByColumn = Ping;
}

function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local UBrowserServerList List;
	local float Y;
	local int Visible;
	local int Skipped;
	local int TopMargin;
	local int BottomMargin;

	C.Font = Root.Fonts[F_Normal];


	List = UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).List;

	if (List == None)
		Count = 0;
	else
		Count = List.CountShown();

	if (bShowHorizSB)
		BottomMargin = LookAndFeel.Size_ScrollbarWidth;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);

	VertSB.SetRange(0, Count+1, Visible);
	TopRow = VertSB.Pos;

	Skipped = 0;

	List = UBrowserServerList(List.Next);

	if (List != None)
	{
		Y = 1;

		while ((Y < RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && (List != None))
		{
			if (Skipped >= VertSB.Pos)
			{
				// Draw highlight
				if (List == SelectedServer)
					Column.DrawStretchedTexture( C, 0, Y-1 + TopMargin, Column.WinWidth, RowHeight + 1, Texture'Highlight');

				switch (Column)
				{
				case Server:
					Column.ClipText( C, 2, Y + TopMargin, List.HostName );
					break;
				case Ping:
					Column.ClipText( C, 2, Y + TopMargin, Int(List.Ping) );
					break;
				case MapName:
					Column.ClipText( C, 2, Y + TopMargin, List.MapName );
					break;
				case Players:
					Column.ClipText( C, 2, Y + TopMargin, List.NumPlayers$"/"$List.MaxPlayers );
					break;
				case Vers:
					Column.ClipText( C, 2, Y + TopMargin, List.GameVerStr );
					break;

				case ip:
					Column.ClipText( C, 2, Y + TopMargin, List.IP);
					break;
				case port:
					Column.ClipText( C, 2, Y + TopMargin, List.QueryPort );
					break;

				}

				Y = Y + RowHeight;
			}
			Skipped ++;

			List = UBrowserServerList(List.Next);
		}
	}
}

function SortColumn(UWindowGridColumn Column)
{
	if (SortByColumn == Column)
		bSortDescending = !bSortDescending;
	else
		bSortDescending = False;

	SortByColumn = Column;

	UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).List.Sort();
}

function Tick(float DeltaTime)
{
	local UBrowserServerListWindow W;

	W = UBrowserServerListWindow(GetParent(class'UBrowserServerListWindow'));

	if (W.PingState == PS_Done && SelectedServer == None)
	{
		SelectedServer = UBrowserServerList(W.List.Next);
		if (SelectedServer == None || SelectedServer.bPinging)
			SelectedServer = None;
		else
			UBrowserServerListWindow(GetParent(class'UBrowserServerListWindow')).AutoInfo(SelectedServer);
	}

	if (W.PingState == PS_Done)
	{
		TimePassed = TimePassed + DeltaTime;

		if (TimePassed >= AutoPingInterval)
		{
			TimePassed = 0;

			if (SelectedServer != OldPingServer)
			{
				if (OldPingServer != None)
					OldPingServer.CancelPing();
				OldPingServer = SelectedServer;
			}

			if (SelectedServer != None && !SelectedServer.bPinging)
				SelectedServer.PingServer(False, True, True);
		}
	}
}

function SelectRow(int Row)
{
	local UBrowserServerList S;

	S = GetServerUnderRow(Row);

	if (SelectedServer != S)
	{
		if (S != None)
			UBrowserServerListWindow(GetParent(class'UBrowserServerListWindow')).AutoInfo(S);
		TimePassed = 0;
	}

	if (S != None)
		SelectedServer = S;
}

function RightClickRow(int Row, float X, float Y)
{
	local float MenuX, MenuY;

	WindowToGlobal(X, Y, MenuX, MenuY);
	Menu.WinLeft = MenuX;
	Menu.WinTop = MenuY;
	Menu.List = GetServerUnderRow(Row);
	Menu.Grid = Self;
	Menu.ShowWindow();
}

function UBrowserServerList GetServerUnderRow(int Row)
{
	local int i;
	local UBrowserServerList List;

	List = UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).List;
	if (List != None)
	{
		i = 0;
		List = UBrowserServerList(List.Next);
		while (List != None)
		{
			if (i == Row)
				return List;

			List = UBrowserServerList(List.Next);
			i++;
		}
	}
	return None;
}

function int GetSelectedRow()
{
	local int i;
	local UBrowserServerList List;

	List = UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).List;
	if (List != None)
	{
		i = 0;
		List = UBrowserServerList(List.Next);
		while (List != None)
		{
			if (List == SelectedServer)
				return i;

			List = UBrowserServerList(List.Next);
			i++;
		}
	}
	return -1;
}

function DoubleClickRow(int Row)
{
	local UBrowserServerList Server;

	Server = GetServerUnderRow(Row);

	if (SelectedServer != Server) return;

	if( Server && Server.ValidGamePort() )
	{
		if( !Server.ValidateClientDLLs(Self) )
			return;
		AddRecentServer(Server);
		GetPlayerOwner().ClientTravel("unreal://"$Server.IP$":"$Server.GamePort$UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).URLAppend, TRAVEL_Absolute, false);

		GetParent(class'UWindowFramedWindow').Close();
		Root.Console.CloseUWindow();
	}
}
function JoinWithPassword( string ServerAddress, string Pass )
{
	local UBrowserJoinPW W;

	GetPlayerOwner().ClientTravel("unreal://"$ServerAddress$"?Password="$Pass, TRAVEL_Absolute, false);
	W = UBrowserJoinPW(GetParent(class'UBrowserJoinPW'));
	if ( W!=None )
		W.Close();
	Root.Console.CloseUWindow();
}
function MouseLeaveColumn(UWindowGridColumn Column)
{
	ToolTip("");
}

function KeyDown(int Key, float X, float Y)
{
	switch (Key)
	{
	case 0x74: // IK_F5;
		Refresh();
		break;
	case 0x26: // IK_Up
		SelectRow(Clamp(GetSelectedRow() - 1, 0, Count - 1));
		VertSB.Show(GetSelectedRow());
		break;
	case 0x28: // IK_Down
		SelectRow(Clamp(GetSelectedRow() + 1, 0, Count - 1));
		VertSB.Show(GetSelectedRow());
		break;
	case 0x0D: // IK_Enter:
		DoubleClickRow(GetSelectedRow());
		break;
	default:
		Super.KeyDown(Key, X, Y);
		break;
	}
}

function bool Compare(UBrowserServerList T, UBrowserServerList B)
{
	switch (SortByColumn)
	{
	case Server:
		return ByName(T, B);
	case Ping:
		return ByPing(T, B);
	case MapName:
		return ByMap(T, B);
	case Players:
		return ByPlayers(T, B);
	case Vers:
		return ByGameVer(T, B);
	case ip:
		return ByIPAddress(T, B);
	case port:
		return ByIPGamePort(T, B);
	default:
		return True;
	}
}

function bool ByPing(UBrowserServerList T, UBrowserServerList B)
{
	local bool bResult;

	if (B == None) return True;

	if (T.Ping < B.Ping)
	{
		bResult = True;
	}
	else if (T.Ping > B.Ping)
	{
		bResult = False;
	}
	else
	{
		bResult = (T.HostName < B.HostName);
	}

	if (bSortDescending)
		bResult = !bResult;

	return bResult;
}

function bool ByName(UBrowserServerList T, UBrowserServerList B)
{
	local int Result;

	if (B == None) return True;
	if (T.Ping == 9999) return False;
	if (B.Ping == 9999) return True;

	Result = CompareStrings(T.HostName, B.HostName);
	if (Result == 0)
		return T.Ping < B.Ping;

	if (bSortDescending)
		return Result > 0;
	return Result < 0;
}

final function int CompareStrings(string S1, string S2)
{
	class'GameInfo'.static.StripColorCodes(S1);
	class'GameInfo'.static.StripColorCodes(S2);
	if (Caps(S1) < Caps(S2))
		return -1;
	if (Caps(S2) < Caps(S1))
		return 1;
	if (S1 < S2)
		return -1;
	if (S2 < S1)
		return 1;
	return 0;
} 

function bool ByMap(UBrowserServerList T, UBrowserServerList B)
{
	local bool bResult;

	if (B == None) return True;

	if (T.Ping == 9999) return False;
	if (B.Ping == 9999) return True;

	if (T.MapName < B.MapName)
	{
		bResult = True;
	}
	else if (T.MapName > B.MapName)
	{
		bResult = False;
	}
	else
	{
		return (T.Ping < B.Ping);
	}

	if (bSortDescending)
		bResult = !bResult;

	return bResult;
}

function bool ByPlayers(UBrowserServerList T, UBrowserServerList B)
{
	local bool bResult;

	if (B == None) return True;

	if (T.Ping == 9999) return False;
	if (B.Ping == 9999) return True;

	if (T.NumPlayers > B.NumPlayers)
	{
		bResult = True;
	}
	else if (T.NumPlayers < B.NumPlayers)
	{
		bResult = False;
	}
	else
	{
		if (T.MaxPlayers > B.MaxPlayers)
		{
			bResult = True;
		}
		else if (T.MaxPlayers < B.MaxPlayers)
		{
			bResult = False;
		}
		else
		{
			return (T.Ping < B.Ping);
		}
	}

	if (bSortDescending)
		bResult = !bResult;

	return bResult;
}
function bool ByGameVer(UBrowserServerList T, UBrowserServerList B)
{
	local bool bResult;

	if (B == None) return True;

	if (T.Ping == 9999) return False;
	if (B.Ping == 9999) return True;

	if (T.GameVerStr > B.GameVerStr)
		bResult = True;
	else if (T.GameVerStr < B.GameVerStr)
		bResult = False;
	else if (T.NumPlayers>B.NumPlayers)
		bResult = True;
	else if (T.NumPlayers<B.NumPlayers)
		bResult = False;
	else if (T.MaxPlayers>B.MaxPlayers)
		bResult = True;
	else if (T.MaxPlayers<B.MaxPlayers)
		bResult = False;
	else return (T.Ping < B.Ping);

	if (bSortDescending)
		bResult = !bResult;

	return bResult;
}
function bool ByIPAddress(UBrowserServerList T, UBrowserServerList B)
{
	local bool bResult;

	if (B == None) return True;
	if (T.Ping == 9999) return False;
	if (B.Ping == 9999) return True;

	if (T.IP < B.IP)
		bResult = True;
	else if (T.IP > B.IP)
		bResult = False;
	else return (T.Ping < B.Ping);

	if (bSortDescending)
		bResult = !bResult;

	return bResult;
}
function bool ByIPGamePort(UBrowserServerList T, UBrowserServerList B)
{
	local bool bResult;

	if (B == None) return True;
	if (T.Ping == 9999) return False;
	if (B.Ping == 9999) return True;

	if ( T.QueryPort<B.QueryPort )
		bResult = True;
	else if ( T.QueryPort>B.QueryPort )
		bResult = False;
	else return (T.Ping < B.Ping);
	if (bSortDescending)
		return !bResult;
	return bResult;
}

function ShowInfo(UBrowserServerList List)
{
	UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).ShowInfoX(List);
}
function PasswordJoinMenu(UBrowserServerList List)
{
	local UBrowserJoinPW PWWindow;

	if ( SelectedServer==None || !List.ValidateClientDLLs(Self) )
		Return;

	PWWindow = UBrowserJoinPW(Root.FindChildWindow(class'UBrowserJoinPW'));

	if (Server == None) return;

	if ( PWWindow==None)
	{
		PWWindow = UBrowserJoinPW(Root.CreateWindow(class'UBrowserJoinPW',10,40,295,80));
		PWWindow.BringToFront();
	}
	else
	{
		PWWindow.BringToFront();
	}
	PWWindow.WindowTitle = "Join with password - "$List.HostName;
	PWWindow.EditArea.Grid = Self;
	PWWindow.EditArea.JoiningServerInfo = SelectedServer;
	PWWindow.EditArea.ReceiveAddressInfo(SelectedServer.IP$":"$SelectedServer.GamePort);
}
final function AddRecentServer( UBrowserServerList List )
{
	UBrowserRecentServers(UBrowserMainClientWindow(GetParent(class'UBrowserMainClientWindow')).Recent.Page).AddRecentServer(List);
}
function JoinAServer( UBrowserServerList List, bool bSpectateIt )
{
	local string Cl;

	if ( List!=None && List.ValidGamePort() )
	{
		if( !List.ValidateClientDLLs(Self) )
			return;
		AddRecentServer(List);
		if ( bSpectateIt )
			Cl = "?Class="$string(Class'UnrealSpectator');
		else Cl = "?Class="$Class'UnrealPlayerMenu'.Default.ClassString;
		GetPlayerOwner().ClientTravel("unreal://"$List.IP$":"$List.GamePort$UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).URLAppend$Cl, TRAVEL_Absolute, false);

		GetParent(class'UWindowFramedWindow').Close();
		Root.Console.CloseUWindow();
	}
}
function Refresh()
{
	UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).Refresh();
}

function RefreshServer()
{
	TimePassed = AutoPingInterval;
}

function RePing()
{
	UBrowserServerListWindow(GetParent(Class'UBrowserServerListWindow')).RePing();
}

final function OpenServerWebsite( UBrowserServerList List )
{
	local UBrowserServerWebWin LW;
	local int X,Y;

	if ( List!=None && Len(List.ServerWebPage)!=0 )
	{
		X = Root.WinWidth*0.8;
		Y = Root.WinHeight*0.9;
		LW = UBrowserServerWebWin(Root.CreateWindow(class'UBrowserServerWebWin',Root.WinWidth/2-X/2,Root.WinHeight/2-Y/2,X,Y,,true));
		LW.WindowTitle = LW.Default.WindowTitle@"-"@List.HostName;
		LW.OpenWebsite(List.ServerWebPage,true);
	}
}

defaultproperties
{
	ServerName="Server"
	PingName="Ping"
	MapNameName="Map Name"
	PlayersName="Players"
	VersionName="Version"
	AutoPingInterval=5
}