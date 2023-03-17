// Written by .:..:
// The jump pad end point.
Class UJumpPadEnd extends LiftExit;

function PostBeginPlay();
simulated function Touch( Actor Other );
function Reset();

function Actor SpecialHandling(Pawn Other)
{
	return Self;
}

// Only bind with other pathnodes.
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	if( LiftCenter(End)==None && End.CanBindWith(Self) )
		return PATHING_Normal;
	return PATHING_Proscribe;
}

defaultproperties
{
	RemoteRole=ROLE_None
	Texture=Texture'UnrealShare.S_SpawnP'
}