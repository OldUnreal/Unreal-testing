class UBrowserMasterServerFact extends UBrowserServerListFactory;

// Config
var config string MasterServerVersion,MasterServersURL,MasterServersSite;
var config int MasterServersPort;
var config byte LastCheckDay;

function Query(optional bool bBySuperset, optional bool bInitial)
{
	// Update master servers.
	if( Default.LastCheckDay!=GetPlayerOwner().Level.Day )
	{
        Log("Updating list of MasterServers...");
		Default.LastCheckDay = GetPlayerOwner().Level.Day;
		GetPlayerOwner().GetEntryLevel().Spawn(class'UBrowserMServerLink');
		StaticSaveConfig();
	}

	Super.Query();

	QueryFinished(True);
}

static final function UpdateMasterServers( string S )
{
	local int i;
	local string V;

	i = InStr(S,"</VER>");
	if( i==-1 || Default.MasterServerVersion~=Left(S,i) )
		return;

	Default.MasterServerVersion = Left(S,i);
	Log("Received new MasterServer version: "$Default.MasterServerVersion,'UBrowser');

	// Check if should redirect to a new site.
	i = InStr(S,"<MSL>");
	if( i>=0 )
	{
		S = Mid(S,i+5);
		i = InStr(S,"</MSL>");
		if( i==-1 )
			i = Len(S);
		V = Left(S,i);
		S = Mid(S,i+6);

		i = InStr(V,":");
		if( i==-1 )
		{
			Default.MasterServersPort = 80;
			i = InStr(V,"/");
			if( i==-1 )
			{
				Default.MasterServersSite = V;
				Default.MasterServersURL = "/masterserver.txt";
			}
			else
			{
				Default.MasterServersSite = Left(V,i);
				Default.MasterServersURL = Mid(V,i);
			}
		}
		else
		{
			Default.MasterServersSite = Left(V,i);
			V = Mid(V,i+1);
			i = InStr(V,"/");
			if( i==-1 )
			{
				Default.MasterServersPort = int(V);
				Default.MasterServersURL = "/masterserver.txt";
			}
			else
			{
				Default.MasterServersPort = int(Left(V,i));
				Default.MasterServersURL = Mid(V,i);
			}
		}
		Log("Changed masterserver list URL to: "$Default.MasterServersSite$":"$Default.MasterServersPort$Default.MasterServersURL,'UBrowser');
	}

	// Check for new master servers.
	Class'UBrowserGSpyFact'.Static.ApplyNewServers(S);

	StaticSaveConfig();
}

defaultproperties
{
	MasterServersPort=80
	MasterServersSite="www.oldunreal.com"
	MasterServersURL="/masterserver.txt"
}
