//=======================================================
// Used by Net driver for logging and banning players
//=======================================================
Class SecurityData extends Object
	Native
	Config(Security);

struct export BanEntry
{
	var config string ClientIP;
	var config string ClientName;
	var config string ClientID;
	var config string ClientIdentNr;
	var transient dword IPStart,IPEnd;
	
	cpptext
	{
		inline UBOOL IPIsInRange( DWORD CompIP ) const
		{
			return (CompIP>=IPStart && CompIP<=IPEnd);
		}
		void ParseIPAddress(const TCHAR* InStr);
		inline void SetIPAddress( DWORD InAddr )
		{
			IPStart = IPEnd = InAddr;
		}
		const TCHAR* IPToStr() const;

		inline UBOOL IsRangeBan() const
		{
			return (IPStart!=IPEnd);
		}
		inline UBOOL ClientMatch( DWORD IP, const TCHAR* IDA, const TCHAR* IDB ) const
		{
			return (IPIsInRange(IP) || (ClientID.Len() && (ClientID==IDA || ClientIdentNr==IDB)));
		}
		const TCHAR* GetReadableName() const;
	}
};
struct export TempBanEntry
{
	var string ClientName;
	var string ClientID,ClientIdentNr;
	var dword IPAddress;
	
	cpptext
	{
		inline UBOOL ClientMatch( DWORD IP, const TCHAR* IDA, const TCHAR* IDB ) const
		{
			return (IPAddress==IP || (ClientID.Len() && (ClientID==IDA || ClientIdentNr==IDB)));
		}
		inline UBOOL ClientMatchAll( DWORD IP, const TCHAR* IDA, const TCHAR* IDB ) const
		{
			return (IPAddress==IP && ClientID==IDA && ClientIdentNr==IDB);
		}
		const TCHAR* GetIPStr() const;
	}
};

struct export ClientLogEntry
{
	var config string PlayerNames;
	var config string PlayerIP;
	var config string ClientID;
	var config string ClientIdentNr;
	var transient dword IPAddress;
	
	cpptext
	{
		inline UBOOL ClientMatch( DWORD IP, const TCHAR* IDA, const TCHAR* IDB ) const
		{
			return ( (!ClientID.Len() && IPAddress == IP) || (ClientID.Len() && (ClientID == IDA || ClientIdentNr == IDB)));
		}
		void UpgradeEntry();
	}
};

var config array<BanEntry> BanList; // Globally banned clients
var array<TempBanEntry> TempBanList; // Temporarily banned clients for rest of the map only.
var config array<ClientLogEntry> LogList; // Logged clients list
var() config int MaxIPLogLen; // Maximum log entries for player aliases (0 = no limit).
var() config int MaxAliases; // Maximum alias names stored for each player (valid range 1-32).

defaultproperties
{
	MaxIPLogLen=5000
	MaxAliases=16
}