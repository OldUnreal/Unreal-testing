// Written by .:..:
// The "destination" for the JumpPad
Class UJumpDest extends LiftCenter;

var UJumpPad Start;
var UJumpPadEnd End;

function PostBeginPlay()
{
	local byte i;
	local Actor St,En;
	local int RF,D;

	For( i=0; i<16; i++ )
	{
		if ( Paths[i]==-1 )
			Continue;
		describeSpec(Paths[i],St,En,RF,D);
		if ( UJumpPad(En) )
		{
			Start = UJumpPad(En);
			Paths[i] = -1;
		}
		else if ( UJumpPadEnd(En) )
			End = UJumpPadEnd(En);
	}
}
function Actor SpecialHandling(Pawn Other)
{
	return End;
}

// Only bind towards jump destination
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	if( UJumpPadEnd(End)!=None && UJumpPad(End)==None )
		return Super.EdPathBuildExec(End,ForcedDistance);
	return PATHING_Proscribe;
}

// Make JumpPad draw trajectory.
function DrawEditorSelection( Canvas C )
{
	local UJumpPad J;

	foreach AllActors(Class'UJumpPad',J)
		if( J.LiftTag==LiftTag && !J.bSelected )
			J.DrawEditorSelection(C);
}

defaultproperties
{
	ExtraCost=20
	bStatic=True
	bEditorSelectRender=True
	RemoteRole=ROLE_None
	Texture=Texture'S_SpawnP'
}