//=============================================================================
// MeltedPuddle.
//=============================================================================
class MeltedPuddle expands Decoration;

function PostBeginPlay()
{
	LoopAnim( 'Flat' );
}

defaultproperties
{
     bStatic=False
     bStasis=False
     Physics=PHYS_Falling
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealI.MiniBlob'
     DrawScale=0.100000
     ScaleGlow=0.100000
     bMeshEnviroMap=True
     CollisionRadius=0.100000
     CollisionHeight=0.100000
     bCollideWorld=True
}
