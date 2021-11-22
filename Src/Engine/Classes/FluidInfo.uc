//========================================================
// FluidInfo
//========================================================
Class FluidInfo extends Info
	native
	abstract;

simulated function PostBeginPlay()
{
	if( RemoteRole==ROLE_None )
		Role = ROLE_Authority; // Client authority.

	if( Level.NetMode==NM_DedicatedServer )
		SetCollision(false); // Disable collision on dedicated servers.
}

// A pawn stepped while touching this actor, return true to behave as water surface.
simulated function bool Footstep( Pawn Other )
{
	return false;
}

defaultproperties
{
	bHidden=false
	RemoteRole=ROLE_None
	bNoDelete=true
	bCollideActors=true
	bUseMeshCollision=true
}