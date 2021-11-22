//=============================================================================
// MultiWeapWarning.
//=============================================================================
class MultiWeapWarning expands Keypoint;

function Trigger( actor Other, Pawn EventInstigator )
{
	if( PlayerPawn(EventInstigator)!=None && PlayerPawn(EventInstigator).myHUD!=None )
	{
		if( PlayerPawn(EventInstigator).myHUD.IsA( 'UPakHUD' ) )
			UPakHUD( PlayerPawn( EventInstigator ).myHUD ).DisplayHint();
	}
}

defaultproperties
{
}
