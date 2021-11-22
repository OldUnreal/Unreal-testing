//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_OutText ]
//
// Display some text on the screen
//=============================================================================

class CS_OutText expands CutSeq;

var() string WhatToSay;

function Trigger(actor Other, pawn EventInstigator)
{

	local CSPlayer P;
	
	CSTrackAction("CS_OutText");
   
	foreach AllActors(class'CSPlayer',P)
	  p.ClientMessage(WhatToSay);


}

defaultproperties
{
	Texture=CSTEXT
}
