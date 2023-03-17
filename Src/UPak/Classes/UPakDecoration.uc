//=============================================================================
// UPakDecoration.
//=============================================================================
class UPakDecoration expands Decoration;

function Destroyed()
{
	local actor dropped;
	local class<actor> tempClass;

	if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) )
		Pawn(Base).DropDecoration();
	if( Contents && !Level.bStartup )
	{
		tempClass = Contents;
		if( Content2 ) tempClass = Content2;
		if( Content3 ) tempClass = Content3;
		dropped = Spawn(tempClass);
		dropped.RemoteRole = ROLE_DumbProxy;
		dropped.SetPhysics(PHYS_Falling);
		dropped.bCollideWorld = true;
		if ( inventory(dropped) != None )
			inventory(dropped).GotoState('Pickup', 'Dropped');
	}	

	if( Event != '' )
		TriggerEvent(Event,Self, None);
			
	Destroyed();
}

defaultproperties
{
}
