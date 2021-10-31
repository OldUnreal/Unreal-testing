//=============================================================================
// WebAdminManager.
// Web admin manager actor (Only actor which should be added to ServerActors.
//=============================================================================
class WebAdminManager expands Info
	Config(WebServer);

var WebServer XWebLink;
var SubWebManager SubWeb;
var() globalconfig string SubWebClass;
var() globalconfig bool bEnabled;

function PostBeginPlay()
{
	SetTimer(0.1,False);
}
function Timer()
{
	local class<SubWebManager> XSWClass;
	
	if(!bEnabled)
	{
		Log("Webserver is not enabled.  Set bEnabled to True in Advanced Options.",'WebServer');
		Destroy();
		return;
	}
	Log("Initializing WebAdmin for current map",'WebServer');
	if( SubWebClass!="" )
		XSWClass = Class<SubWebManager>(DynamicLoadObject(SubWebClass,Class'Class'));
	if( XSWClass==None )
		XSWClass = Class'SubWebManager';
	SubWeb = New(Self,'WebManager')XSWClass;
	SubWeb.WebManager = Self;
	SubWeb.Level = Level;
	SubWeb.InitManager();
	XWebLink = Spawn(SubWeb.GetWebLinkClass(),Self);
	XWebLink.Manager = Self;
	XWebLink.SubWeb = SubWeb;
	XWebLink.InitilizeLink();
}
function Tick( float Delta )
{
	if( SubWeb!=None )
		SubWeb.ManageTick(Delta);
}

defaultproperties
{
	SubWebClass="UWebAdmin.SubWebManager"
}
