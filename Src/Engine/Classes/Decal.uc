//=============================================================================
// Projectile blast decals.
//=============================================================================
class Decal expands Actor
			native;		

// properties
var() int MultiDecalLevel;
var() bool bAttachPanningSurfs,bAttachUnlitSurfs;
var() bool bNoDecalProjector; // Prevent decal from turning into a projector.

// native stuff.
var const transient array<int> SurfList;
var const transient Model SurfModel;

simulated native function Texture AttachDecal( float TraceDistance, optional vector DecalDir ); // trace forward and attach this decal to surfaces.
simulated native function DetachDecal(); // detach this decal from all surfaces.

simulated event PostBeginPlay()
{
	AttachToSurface();
}

simulated function AttachToSurface()
{
	if (AttachDecal(100) == None)	// trace 100 units ahead in direction of current rotation
		Destroy();
}

simulated event Destroyed()
{
	DetachDecal();
	Super.Destroyed();
}

event Update(Actor L);

simulated event OnSubLevelChange( LevelInfo PrevLevel )
{
	DetachDecal();
	AttachToSurface();
}

defaultproperties
{
	DrawScale=1
	DrawType=DT_None
	MultiDecalLevel=4
	RemoteRole=ROLE_None
	bUnlit=true
	Physics=PHYS_None
	bNetTemporary=true
	bNetOptional=true
	bGameRelevant=true
	CollisionRadius=+0.00000
	CollisionHeight=+0.00000
	bStatic=false
	bStasis=false
	bHighDetail=true
	Style=STY_Modulated
	bAttachUnlitSurfs=true
	bProjectorDecal=false
}