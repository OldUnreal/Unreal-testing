//=============================================================================
// FrozenMesh.
//=============================================================================
class FrozenMesh expands Decoration;

var ShieldBeltEffect myEffect;

function PostBeginPlay()
{
	MyEffect = Spawn(class'UPakShieldEffect', Self,,Location, Rotation); 
	MyEffect.Mesh = Mesh;
	MyEffect.DrawScale = Drawscale;
	MyEffect.Fatness = 250;
}

defaultproperties
{
     bStatic=False
     bStasis=False
     AnimSequence=Dead
     AnimFrame=0.900000
     DrawType=DT_Mesh
     Mesh=LodMesh'UnrealShare.Nali1'
     CollisionRadius=24.000000
     CollisionHeight=48.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
