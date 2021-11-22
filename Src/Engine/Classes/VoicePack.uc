//=============================================================================
// VoicePack.
//=============================================================================
class VoicePack extends Info
			abstract;

/*
(exec function to do ServerVoiceMessage, and use in OrdersMenu)
(voicepack configuration for players and bots)
*/

/*
ClientInitialize() sets up playing the appropriate voice segment, and returns a string
 representation of the message
*/
function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex);
function PlayerSpeech(int Type, int Index, int Callsign);

defaultproperties
{
	bStatic=false
	LifeSpan=+10.0
	RemoteRole=ROLE_None
}