//=============================================================================
// VoiceEvent: Receives trigger messages and plays a gender specific voice
// based on the player's class.
//=============================================================================

class VoiceEvent expands SpecialEvent;

var() sound MaleVoice;
var() sound FemaleVoice;

//-----------------------------------------------------------------------------
// Functions.

function bool IsMale( Pawn Other )
{
	return !Other.bIsFemale;
}

//-----------------------------------------------------------------------------
// States.

// Play a voice.
auto state() PlayVoice
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Sound aVoice;
		local Pawn aPawn;
		local PlayerPawn aPlayer;

		global.Trigger( Self, EventInstigator );
		for( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.NextPawn )
		{
			aPlayer = PlayerPawn( aPawn );
			if( aPawn.bIsPlayer && aPlayer != None )
			{
				if( IsMale( aPawn ) )
					aVoice = MaleVoice;
				else aVoice = FemaleVoice;
				aPlayer.ClientPlaySound( aVoice , SoundSlot );
			}
		}
	}
}

defaultproperties
{
	InitialState=PlayVoice
	SoundSlot=SLOT_Talk
}
