//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_ZoomFOV ]
//
// Zooms the FOV in and out.
//
//=============================================================================

class CS_ZoomFOV expands CutSeq;

var() float TargetFOV;     // What final FOV to stop at
var() float FOVIncrement;  // How much to change the FOV by at a time
var() float IncrementTime; // How long between each increment

var float CurFOV;
var CSPlayer player;

function Trigger(actor Other, pawn EventInstigator)
{
    local CSPlayer p;
    CsLog("Triggered.");

    foreach AllActors(class'CSPlayer', p) {
	player = p;
    } 		

    CurFOV = player.DesiredFOV;
    if ( TargetFOV < CurFOV )
	FOVIncrement = - FOVIncrement;
    
    GotoState('Zooming');
}

state Zooming
{
    function Timer() {
	if (((FOVIncrement > 0) && (CurFOV >= TargetFOV))
	    || ((FOVIncrement < 0) && (CurFOV <= TargetFOV))) 
	{	    
	    Disable('Timer');
	    GotoState('');
	    return;
	}

	CurFOV += FOVIncrement;
	player.SetDesiredFOV(CurFOV);
    }

Begin:
    SetTimer(IncrementTime, True);
}

defaultproperties
{
     TargetFOV=90.000000
     FOVIncrement=1.000000
     IncrementTime=0.075000
	Texture=CS_FOV
}
