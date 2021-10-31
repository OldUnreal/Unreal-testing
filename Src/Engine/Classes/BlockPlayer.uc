//=============================================================================
// BlockPlayers prevents players from passing, but allows monsters and projectiles to cross.
//=============================================================================
class BlockPlayer extends Keypoint;

event EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	SetCollision(true, bBlockActors, bBlockPlayers);
} 

defaultproperties
{
	bBlockPlayers=True
}
