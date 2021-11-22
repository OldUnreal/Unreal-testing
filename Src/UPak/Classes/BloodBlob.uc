//=============================================================================
// BloodBlob.
//=============================================================================
class BloodBlob expands Decoration;

function HitWall( vector HitNormal, Actor Wall )
{
	Spawn( class'BloodBurst',,, Location, Rotation );
}

simulated function Tick( float DeltaTime )
{
	Spawn( class'BloodTrail',,, Location, Rotation );
	DrawScale -= 0.01;
	
	if( DrawScale >= 0.1 )
	{
		Spawn( class'BloodBurst',,, Location, Rotation );
	}
}

defaultproperties
{
     bStatic=False
     bStasis=False
     Physics=PHYS_Falling
     LifeSpan=40.000000
     AnimSequence=BlobProj
     DrawType=DT_Mesh
     Texture=Texture'UnrealShare.Skins.RedSkin'
     Skin=Texture'UnrealShare.Skins.RedSkin'
     Mesh=LodMesh'UnrealI.MiniBlob'
     DrawScale=0.500000
     bGameRelevant=True
     MultiSkins(0)=Texture'UnrealShare.Skins.RedSkin'
}
