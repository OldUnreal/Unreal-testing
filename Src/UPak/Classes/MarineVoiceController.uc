//=============================================================================
// MarineVoiceController.
//=============================================================================
class MarineVoiceController expands VoiceController;

var Pawn Marine;
var Pawn Receiver;
var bool bReceiverInRange;
var VoiceController PhraseDirector;


function Pawn FindReceiver()
{
	local SpaceMarine Marine;
	local Actor HitActor;
	local vector HitNormal, HitLocation;
		
	foreach allactors( class'SpaceMarine', Marine )
	{
		if( Marine != Self && !Marine.bCommunicating )
		{
			Receiver = Marine;
		}
	} 
	if( Receiver != None )
	{
		HitActor = Trace( HitLocation, HitNormal, Receiver.Location, Location, True );
		if ( HitActor == Self || HitActor == Receiver )
		{
//			log( ">>> HitActor Was: "$HitActor );
			bReceiverInRange = True;
		}
		else
		{
			bReceiverInRange = False;
		}
	}
	return Receiver;
}


state BroadcastingSound
{
	function BeginState()
	{
//		log( "* "$Self$" spawned at "$Level.TimeSeconds );
		Receiver = FindReceiver();
		Receiver.GotoState( 'ReceiveIncomingMessage', 'Receiving' );
	}

	function EndState()
	{
		bReceiverInRange = False;
	}
}


function Broadcast()
{
	if( Receiver != none && InitiatePlay( Marine ) )
	{
		Marine.PlaySound( GetCurrentSoundName(), SLOT_Talk,, False );
	}
}	


function Pawn GetRecevier()
{
	return Receiver;
}

defaultproperties
{
     PhraseArray(1)=(AssociatedState=ReceiveIncomingMessage)
     PhraseArray(2)=(AssociatedState=ReceiveIncomingMessage)
}
