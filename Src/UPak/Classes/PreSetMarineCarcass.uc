//=============================================================================
// PreSetMarineCarcass.
//=============================================================================
class PreSetMarineCarcass expands SpaceMarineCarcass;

function PostBeginPlay()
{
	SetPhysics( PHYS_Falling );
	PrePivot = vect( 0, 0, 0 );
	SetCollisionSize(class'SpaceMarine'.Default.CollisionRadius + 4, class'SpaceMarine'.default.CollisionHeight);
	if ( !SetLocation(Location) )
	{
		SetCollisionSize(CollisionRadius - 4, CollisionHeight);
	}
}

function tick( float DeltaTime )
{
	SetPhysics( PHYS_Falling );
}

defaultproperties
{
     MultiSkins(1)=Texture'UPak.Skins.Jmarine3'
     MultiSkins(2)=Texture'UPak.Skins.Jmarine4'
     CollisionHeight=30.000000
}
