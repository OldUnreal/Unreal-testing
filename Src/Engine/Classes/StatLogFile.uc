//=============================================================================
// Logs game events for stat collection
//
// Logs to a file.
//=============================================================================
class StatLogFile extends StatLog
	native
	NoUserCreate;

// OldUnreal File Encoding support
enum EFileEncoding
{
	// Plain ANSI single-byte encoding
	FILE_ENCODING_ANSI,
	// Windows UTF-16LE encoding without a BOM
	FILE_ENCODING_UTF16LE,
	// Windows UTF-16 encoding with a BOM
	FILE_ENCODING_UTF16LE_BOM,
	// UTF-8 encoding without a BOM
	FILE_ENCODING_UTF8,
	// UTF-8 encoding with a BOM
	FILE_ENCODING_UTF8_BOM
};

var EFileEncoding Encoding; // must be set before calling OpenLog
var bool bWatermark;

// Internal
var pointer<class FArchiveUnicodeWriterHelper*> LogAr;

// Configs
var string StatLogFile;
var string StatLogFinal;

// File Manipulation
native final function OpenLog();
native final function CloseLog();
native final function Watermark( string EventString );
native final function string GetChecksum();
native final function string GetPlayerChecksum( string PlayerName, string Secret );
native final function FileFlush();
native final function FileLog( string EventString );

// Logging.
function StartLog()
{
	local string FileName;
	local string AbsoluteTime;

	AbsoluteTime = GetShortAbsoluteTime();
	if (!bWorld)
	{
		FileName = LocalLogDir$"\\"$GameName$"."$LocalStandard$"."$AbsoluteTime$"."$Level.Game.GetServerPort();
		StatLogFile = FileName$".tmp";
		StatLogFinal = FileName$".log";
	}
	else
	{
		FileName = WorldLogDir$"\\"$GameName$"."$WorldStandard$"."$AbsoluteTime$"."$Level.Game.GetServerPort();
		StatLogFile = FileName$".tmp";
		StatLogFinal = FileName$".log";
		bWatermark = True;
	}

	OpenLog();
}

function StopLog()
{
	FlushLog();
	CloseLog();
}

function FlushLog()
{
	FileFlush();
}

function LogEventString( string EventString )
{
	if ( bWatermark )
		Watermark( EventString );
	FileLog( EventString );
	FlushLog();
}

// Return a logfile name if relevant.
function string GetLogFileName()
{
	return StatLogFinal;
}

function LogPlayerConnect(Pawn Player)
{
	local string Checksum;

	if ( bWorld )
	{
		if ( Player.PlayerReplicationInfo.bIsABot )
			Checksum = "IsABot";
		else
			Checksum = GetPlayerChecksum( Player.PlayerReplicationInfo.PlayerName, PlayerPawn(Player).ngWorldSecret );
		LogEventString( GetTimeStamp()$Chr(9)$"player"$Chr(9)$"Connect"$Chr(9)$Player.PlayerReplicationInfo.PlayerName$Chr(9)$Player.PlayerReplicationInfo.PlayerID$Chr(9)$Checksum );
		LogPlayerInfo( Player );
	}
	else Super.LogPlayerConnect( Player );
}

function LogGameEnd( string Reason )
{
	if ( bWorld )
	{
		bWatermark = False;
		LogEventString(GetTimeStamp()$Chr(9)$"game_end"$Chr(9)$Reason$Chr(9)$GetChecksum()$"");
	}
	else Super.LogGameEnd(Reason);
}

defaultproperties
{
	Encoding=FILE_ENCODING_UTF16LE
	StatLogFile="..\\Logs\\unreal.ngStats.Unknown.log"
}