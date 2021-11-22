//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CutSeq ]
//
// This class has little use except to make the code a little neater.  I've 
// moved all debug tracking code to here to simply error/status messages 
//
//=============================================================================

class CutSeq expands Triggers;

// Import all of the Icons

#forceexec Texture Import File=Textures\cs_fov.pcx Name=CS_FOV Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_pawn.pcx NAME=CS_PAWN Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_player.pcx NAME=CSPLAYER Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_action.pcx NAME=CSACTION Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_shotlist.pcx NAME=CSSHOTLIST Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_trigger.pcx NAME=CSTRIGGER Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_wrap.pcx NAME=CSWRAP Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_camera.pcx NAME=CSCAMERA Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_adjust.pcx NAME=CSADJUST Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_event.pcx NAME=CSEVENT Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_patrol.pcx NAME=CSPATROL Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_flag.pcx NAME=CSFLAG Group=UDS Mips=Off Flags=2
#forceexec Texture Import File=Textures\cs_text.pcx NAME=CSTEXT Group=UDS Mips=Off Flags=2


function CSTrackAction(coerce string action)
{
	local CSPlayer P;

	foreach AllActors(class 'CSPlayer',p)
	{
		P.CSLastAction = action;
	}
}

function CSLog(coerce string msg)
{

	local CSPlayer P;

	// Write it out to the Log

	Log("[C/S Engine]: "$msg);
	
	foreach AllActors(class 'CSPlayer',p)
	{
		P.CS_AddDebug(msg);
	}

}

defaultproperties
{
     Texture=S_Trigger
}
