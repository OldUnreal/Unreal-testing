//=============================================================================
// VoiceController.
//=============================================================================
class VoiceController expands Info;

struct PhraseData
{
	var() float PhraseDuration;		// Approximate length of this sound
	var() Name AssociatedState;		// State in Pawn that's associated with playing this sound
	var() Sound SoundName;			// The sound itself
	var Pawn LastSaidBy;			// Who said this last? More repetition avoiding
	var byte bRecentlyPlayed;		// Was message recently sent? Avoid repetition
	var byte bActive;				// Is this Phrase active?  0 = Off, 1 = On
};

var Pawn CurrentSpeaker;

var() PhraseData PhraseArray[ 20 ];
var PhraseData CurrentPhrase;

var int CurrentPhraseNumber;
var int MaxPhraseArrayContents;

function BeginPlay()
{
	MaxPhraseArrayContents = 19;
}

function bool InitiatePlay( Pawn SoundGeneratedBy )
{
	CurrentSpeaker = SoundGeneratedBy;

	if( FindPhrase() )
		return true;
	else return false;
}

function Finished()
{
	PhraseArray[ CurrentPhraseNumber ].LastSaidBy = CurrentSpeaker;
	InvalidateCurrentPhrase();
}
	
function bool FindPhrase()
{
	local int PhraseIncrementer;
	
	for( PhraseIncrementer = 0; PhraseIncrementer <= MaxPhraseArrayContents; PhraseIncrementer++ )
	{
		if( PhraseArray[ PhraseIncrementer ].SoundName != none )
		{
			if( PhraseArray[ PhraseIncrementer ].bRecentlyPlayed == 0 )
			{
				if( PhraseArray[ PhraseIncrementer ].AssociatedState == CurrentSpeaker.GetStateName() )
				{
					if( PhraseArray[ PhraseIncrementer ].LastSaidBy != CurrentSpeaker )
					{
						ActivatePhrase( PhraseIncrementer );
						return true;
					}
				}
			}
		}
	}
	return false;
}

function ActivatePhrase( int PhraseNumber )
{
	PhraseArray[ PhraseNumber ].bActive = 1;
	CurrentPhraseNumber = PhraseNumber;
}

function bool IsPhraseValid()
{
	if( PhraseArray[ CurrentPhraseNumber ].bActive == 1 )
		return true;
	else return false;
}

function InvalidateCurrentPhrase()
{
	PhraseArray[ CurrentPhraseNumber ].bActive = 0;
}

function Sound GetCurrentSoundName()
{
	if( IsPhraseValid() )
		return PhraseArray[ CurrentPhraseNumber ].SoundName;
	else return none;
}

function float GetCurrentSoundDuration()
{
	if( IsPhraseValid() )
		return PhraseArray[ CurrentPhraseNumber ].PhraseDuration;
	else return 0;
}

function name GetCurrentPhraseAssociatedState()
{
	if( IsPhraseValid() )
		return PhraseArray[ CurrentPhraseNumber ].AssociatedState;
	else return '';
}

function Pawn GetCurrentPhraseLastSaidBy()
{
	if( IsPhraseValid() )
		return PhraseArray[ CurrentPhraseNumber ].LastSaidBy;
	else return none;
}

function bool GetCurrentPhraseStatus()
{
	if( PhraseArray[ CurrentPhraseNumber ].bRecentlyPlayed == 0 )
		return false;
	else return true;
}

defaultproperties
{
     PhraseArray(0)=(PhraseDuration=3.000000,AssociatedState=WarnFriends)
     PhraseArray(1)=(PhraseDuration=3.500000,AssociatedState=AcknowledgeWarning)
     PhraseArray(2)=(PhraseDuration=2.000000,AssociatedState=AcknowledgeWarning)
}
