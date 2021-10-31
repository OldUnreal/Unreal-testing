//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_SETFOV ]
//
// Sets the FOV on the camera.
//
//=============================================================================
class CS_SetFOV expands CutSeq;

var() float FieldOfView;

function Trigger(actor Other, pawn EventInstigator)
{
    local CSPlayer p;
    CsLog("Triggered.");

    foreach AllActors(class'CSPlayer', p) 
	p.SetDesiredFOV(FieldOfView);
}

defaultproperties
{
     FieldOfView=90.000000
	Texture=CS_FOV
}
