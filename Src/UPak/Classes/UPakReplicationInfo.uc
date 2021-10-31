//=============================================================================
// UPakReplicationInfo.
//=============================================================================
class UPakReplicationInfo expands PlayerReplicationInfo;

var int TestInt;
var int CARKills;
var int RLKills;
var int GLKills;
var int OtherKills;
var int TotalKills;
var int ASMDKills;
var int RifleKills;
var int EightballKills;
var int StingerKills;
var int DispersionKills;
var int AutomagKills;
var int MinigunKills;
var int FlakCannonKills;
var int RazorjackKills;
var int BioRifleKills;

var string NextMap;

replication
{
	Reliable if ( Role == ROLE_Authority )
		TestInt, CARKills, RLKills, GLKills, OtherKills, TotalKills;
}

defaultproperties
{
     bTravel=True
}
