//=============================================================================
// Dispatcher: receives one trigger (corresponding to its name) as input,
// then triggers a set of specifid events with optional delays.
//=============================================================================
class Dispatcher extends Triggers;

#exec Texture Import File=Textures\Dispatch.pcx Name=S_Dispatcher Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() name  OutEvents[24]; // Events to generate.
var() float OutDelays[24]; // Relative delays before generating events.
var int i;                // Internal counter.

//=============================================================================
// Dispatcher logic.

//
// When dispatcher is triggered...
//
function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	gotostate('Dispatch');
}

//
// Dispatch events.
//
state Dispatch
{
	function Reset()
	{
		enable('Trigger');
		gotostate('');
	}

Begin:
	disable('Trigger');
	for ( i=0; i<ArrayCount(OutEvents); i++ )
	{
		if ( OutEvents[i] != '' )
		{
			Sleep( OutDelays[i] );
			TriggerEvent(OutEvents[i],Self,Instigator);
		}
	}
	enable('Trigger');
}

//
// Dispatch editor API.
//
event DrawEditorSelection( Canvas C )
{
	local byte j;
	local Actor A;

	for ( j=0; j<ArrayCount(OutEvents); ++j )
		if( OutEvents[j]!='' )
		{
			foreach AllActors(Class'Actor',A,OutEvents[j])
				C.Draw3DLine(MakeColor(255,0,255),Location,A.Location);
		}
}

defaultproperties
{
	bEditorSelectRender=true
	Texture=S_Dispatcher
}
