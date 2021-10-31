//=============================================================================
// UPakDecoration.
//=============================================================================
class UPakDecoration expands Decoration;

function Destroyed()
{
	local actor dropped, A;
	local class<actor> tempClass;

	if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) )
		Pawn(Base).DropDecoration();
	if( (Contents!=None) && !Level.bStartup )
	{
		tempClass = Contents;
		if (Content2!=None ) tempClass = Content2;
		if (Content3!=None ) tempClass = Content3;
		dropped = Spawn(tempClass);
		dropped.RemoteRole = ROLE_DumbProxy;
		dropped.SetPhysics(PHYS_Falling);
		dropped.bCollideWorld = true;
		if ( inventory(dropped) != None )
			inventory(dropped).GotoState('Pickup', 'Dropped');
	}	

	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, None );
			
	Destroyed();
}

defaultproperties
{
}
