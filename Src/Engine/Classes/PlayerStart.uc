//=============================================================================
// Player start location.
//=============================================================================
class PlayerStart extends NavigationPoint
			native;

#exec Texture Import File=Textures\S_Player.pcx Name=S_Player Mips=Off Flags=2

// Players on different teams are not spawned in areas with the
// same TeamNumber unless there are more teams in the level than
// team numbers.
var() byte TeamNumber;
var() bool bSinglePlayerStart;
var() bool bCoopStart;
var() bool bEnabled;

function Trigger( actor Other, pawn EventInstigator )
{
	bEnabled = !bEnabled;
}

function PlayTeleportEffect(actor Incoming, bool bOut)
{
	Level.Game.PlayTeleportEffect(Incoming, bOut, Level.Game.bDeathMatch );
}

defaultproperties
{
	bEnabled=true
	bSinglePlayerStart=True
	bCoopStart=True
	bDirectional=True
	Texture=S_Player
	SoundVolume=128
	CollisionRadius=+00018.000000
	CollisionHeight=+00040.000000
	bCollideWhenPlacing=True
}
