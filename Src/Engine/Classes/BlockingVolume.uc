//=============================================================================
// BlockingVolume:  a bounding volume
// used to block certain classes of actors
// primary use is to provide collision for non-zero extent traces around static meshes 
//=============================================================================
class BlockingVolume extends Volume
	native
	NoUserCreate;

cpptext
{
	bool ShouldTrace( DWORD TraceFlags, AActor* SourceActor );
}

var int BlockingFlags; // While bClassBlocker=false only collide with matching CollisionFlag actors.
var int ScriptFilterFlags; // If actor has matching collisionflag, it will call ShouldBlock event.

var() bool bClassBlocker; // Only collide with BlockedClasses actors.
var() Array< class<Actor> > BlockedClasses; // Only valid if bClassBlocker is true
var() bool	BlockFlags_PlayerPawn,
			BlockFlags_ScriptedPawn,
			BlockFlags_Bots,
			BlockFlags_Projectile,
			BlockFlags_Decoration,
			BlockFlags_Misc; // Custom blocking flags if bClassBlocker disabled.

event OnPropertyChange( name Property, name ParentProperty )
{
	BlockingFlags = 0;
	if( !bClassBlocker )
	{
		if( BlockFlags_Misc )
			BlockingFlags = {COLLISIONGROUP_Everything & ~(COLLISIONFLAG_PlayerPawn | COLLISIONFLAG_ScriptedPawn | COLLISIONFLAG_Bots | COLLISIONFLAG_Projectile | COLLISIONFLAG_Decoration)};
		if( BlockFlags_PlayerPawn )
			BlockingFlags = BlockingFlags | COLLISIONFLAG_PlayerPawn;
		if( BlockFlags_ScriptedPawn )
			BlockingFlags = BlockingFlags | COLLISIONFLAG_ScriptedPawn;
		if( BlockFlags_Bots )
			BlockingFlags = BlockingFlags | COLLISIONFLAG_Bots;
		if( BlockFlags_Projectile )
			BlockingFlags = BlockingFlags | COLLISIONFLAG_Projectile;
		if( BlockFlags_Decoration )
			BlockingFlags = BlockingFlags | COLLISIONFLAG_Decoration;
	}
	if( Property=='BlockFlags_Projectile' )
		bBlockZeroExtentTraces = BlockFlags_Projectile;
}

simulated event bool ShouldBlock( Actor Other, int TraceFlags )
{
	return true; // Return true to block.
}

defaultproperties
{
	bWorldGeometry=true
	bCollideActors=True
	bBlockActors=True
	bBlockZeroExtentTraces=false
	
	BlockFlags_PlayerPawn=true
	BlockFlags_ScriptedPawn=true
	BlockFlags_Bots=true
	BlockFlags_Decoration=true
	BlockFlags_Misc=true
	BlockingFlags=(COLLISIONGROUP_Everything & ~COLLISIONFLAG_Projectile)
	
	BrushColor=(R=255,G=255,B=64)
	CollisionFlag=COLLISIONFLAG_Keypoints
}