class WebServer expands TcpLink
	Config(WebServer);

var WebAdminManager Manager;
var SubWebManager SubWeb;

var config int ListenPort;
var config int MaxConnections;

var string ServerURL;

var int ConnectionCount;

function InitilizeLink()
{
	if( !BindPort(ListenPort) )
		Log("Failed to bind to port"@ListenPort$", aborted.",'WebServer');
	else Listen();
}

event GainedChild( Actor C )
{
	Super.GainedChild(C);
	ConnectionCount++;

	// if too many connections, close down listen.
	if(MaxConnections > 0 && ConnectionCount > MaxConnections && LinkState == STATE_Listening)
	{
		Log("Too many connections - closing down Listen.",'WebServer');
		Close();
	}
}

event LostChild( Actor C )
{
	Super.LostChild(C);
	ConnectionCount--;

	// if closed due to too many connections, start listening again.
	if(ConnectionCount <= MaxConnections && LinkState != STATE_Listening)
	{
		Log("Listening again - connections have been closed.",'WebServer');
		Listen();
	}
}

defaultproperties
{
     ListenPort=8080
     MaxConnections=30
     AcceptClass=Class'WebConnection'
}