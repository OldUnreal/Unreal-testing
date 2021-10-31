//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_PlayerResetMove ]
//
// This actor will stop a player from moving.
//=============================================================================

class CS_PlayerResetMove expands CutSeq;

function Trigger(actor Other, pawn EventInstigator)
{

   CSTrackAction("CS_PlayerResetMove");
   CSPlayer(EventInstigator).ResetScriptedMove();

}

defaultproperties
{
	Texture=CS_PAWN
}
