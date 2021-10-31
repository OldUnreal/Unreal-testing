//=============================================================================
// HudOverlay: Can be used to draw custom overlay on the HUD.
//=============================================================================
class HudOverlay extends Actor
	abstract
	native;

var HUD myHUD;
var() bool bPostRender,bPreRender;

simulated event PreRender( canvas Canvas );
simulated event PostRender( canvas Canvas );

simulated function Destroyed()
{
	if( myHUD!=None )
	{
		myHUD.RemoveOverlay(Self);
		myHUD = None;
	}
}

defaultproperties
{
	bPostRender=True
	RemoteRole=ROLE_None
	bHidden=True
	bOnlyOwnerRelevant=true
}