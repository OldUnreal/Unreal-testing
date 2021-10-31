Class WebQuery extends WebObjectBase
	native
	transient;

const WebAdminVersion="1.000.2";

var byte UserPrivileges;	// Filled at login.
var string User,Password,URL; // Login information.

var string Header;			// Header information
var array<byte> Data;		// Other received bytes in raw format.
var int DataSize;			// Amount of data expected after header now.
var pointer<TMultiMap<FString,FString>*> DataMap; // Map of received variables.
var string UpFileName;		// Uploaded binary file name.
var string FileTrailing;	// Temp data.

var WebConnection Connection;
var SubWebManager Manager;

// Temporary storage.
var array<byte> PendingSend; // Bytes of data to send to client.
var byte PendingData[255];	// Next packet to send.
var int PendingCount;		// Next packet to send byte count.

var string ContentType,		// The data type server is sending the client (added to header).
			MiscInfo;		// Forward %MODBASED% call to this class.

var bool bHeaderReceived,	// Header has been completely received (but all data may not have been received yet).
		bCompleted,			// Header and all data has been received.
		bIsPost,			// User is sending data to server.
		bHeaderAtached,		// Header has been attached already with the data to send (if not, native codes will do that during SendData).
		bReceivedBinary;	// Received data from client is binary data.

// *** Web request ***
// Raw data received from client.
final native(1180) function ReceivedBytes( out byte B[255], int Count );

// Get sent data from client.
final native(1181) function string GetValue( string ID, optional string DefaultValue /* ="" */ );

// Get all received variables.
final native(1182) iterator function AllValues( out string ID, optional out string Value, optional string Prefix /* ="" */ );

// Get multivalues received with same ID.
final native(1183) iterator function MultiValue( string ID, out string Value );

// *** Web response ***
// Include a binary file from Unreal/WebServer folder.
final native(1184) function IncludeFile( string FileName );

// Send a single line of text.
final native(1185) function SendTextLine( string Line, optional bool bNewLine /* =true */ );

// Parse special characters so that they aren't confused with other HTML codes (used for plain text fields).
static final native(1186) function string ParseSafeText( string Text );

// Read a web page from a localization file.
final native(1187) function LocalizeWebPage( string Section );

// Will call SendBunch multiple times until all bytes has been sent (returns true if all was sent, otherwise it would be wise to wait one tick).
final native(1188) function bool SendData();

// *** File Functions ***
/* Returns whatever if security setting is enabled on server, Type:
0 - File writing
1 - Preferences. */
final native(1189) function bool SettingsEnabled( byte Type );

// Save the data file that was uploaded to server, returns false if not valid Unreal package.
final native(1190) function bool SaveFileUpload( optional string PackageName /* =UpFileName */ );

// List uploaded packages.
final native(1191) iterator function UploadedFiles( out string FileName, optional out array<name> MissingRef );

// Move an uploaded package to proper directory.
final native(1192) function bool MovePackage( string FileName );

// Get preferences for a category.
final native(1193) function GetPreferences( out array<PreferencesInfo> Prefs, optional string Category /* ="Advanced Options"*/ );

// Get variables for a class.
final native(1194) function bool GetVariables( string ClassName, string Category, out array<VariableInfo> Prefs );
final native(1195) function bool SetVariable( string ClassName, string VarName, string Value, bool bImmediate );

final function Reset()
{
	User = "";
	Password = "";
	Header = "";
	ContentType = Default.ContentType;
	Array_Size(Data,0);
	bHeaderReceived = false;
	bCompleted = false;
	bIsPost = false;
	bHeaderAtached = false;
	Connection = None;
}

final function SendHTTPError( int Code )
{
	switch( Code )
	{
	case 400:
		SendTextLine("HTTP/1.1 400 Bad Request");
		SendTextLine("");
		SendTextLine("<TITLE>400 Bad Request</title><h1>400 Bad Request</h1>If you got this error from a standard web browser, please post on www.oldunreal.com forums and submit a bug report.");
		break;
	case 401:
		SendTextLine("HTTP/1.1 401 Unauthorized");
		SendTextLine("WWW-authenticate: basic realm=\"Unreal Remote Admin\"");
		SendTextLine("");
		SendTextLine("<title>401 Unauthorized</title>");
		SendTextLine("<h1>401 Unauthorized</h1>");
		break;
	case 404:
		SendTextLine("HTTP/1.1 404 Object Not Found");
		SendTextLine("");
		SendTextLine("<title>404 File Not Found</title><h1>404 File Not Found</h1>The URL you requested was not found.");
		break;
	default:
		SendTextLine("<title>"$Code$"</title><h1>"$Code$"</h1>");
		return;
	}
	bHeaderAtached = true;
}

event SendBunch()
{
	Connection.SendBinary(PendingCount, PendingData);
}

static final function string GetWebAdminVersion()
{
	return WebAdminVersion;
}

defaultproperties
{
	ContentType="text/html"
}
