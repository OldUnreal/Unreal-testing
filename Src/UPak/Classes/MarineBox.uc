//=============================================================================
// MarineBox.
//=============================================================================
class MarineBox expands SteelBox;

var bool bChainedExplosion, bDestroy;
var class<Inventory> ContentArray[ 3 ];
var() int Health;

function PostBeginPlay()
{
	if( Health == 0 )
		Health = 30;
	
	ContentArray[0] = Class<Inventory>(Contents);
	ContentArray[1] = Class<Inventory>(Content2);
	ContentArray[2] = Class<Inventory>(Content3);
}

auto state active
{
	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Instigator = InstigatedBy;
		if (Health<0) Return;
		if ( Instigator != None )
			MakeNoise(1.0);
		bBobbing = false;
		Health -= NDamage;
		if (Health <0) 	
		{
			skinnedFrag( class'UMSFragment', texture'JDropBox1', Vect( 2000, 0, 0 ), 1.0, 7 );
			Destroy();
		}
		else 
		{
			SetPhysics(PHYS_Falling);
			Momentum.Z = 1000;
			Velocity=Momentum*0.016;
		}
	
	}
Begin:
}

// jc: override Destroyed function to allow for multiple crate contents (and give them velocity)

function Destroyed()
{
	local actor dropped, A;
	local int Incrementer;
	
	if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) )
		Pawn(Base).DropDecoration();
	
	if( Contents != none && !Level.bStartup )
	{
		for( Incrementer = 0; Incrementer <= 2; Incrementer++ )
		{
			if( ContentArray[Incrementer] != none )
			{
				dropped = Spawn( ContentArray[Incrementer] );
				if (Dropped != None)
				{
					dropped.RemoteRole = ROLE_DumbProxy;
					dropped.SetPhysics( PHYS_Falling );
					Dropped.Velocity = VRand()*(75+FRand()*150.0+100.0 + (250)/80);
					dropped.bCollideWorld = true;
				}
				if( Inventory( Dropped ) != none )
					Inventory( Dropped ).GotoState( 'Pickup', 'Dropped' );
			}
		}
	}
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, None );
}

defaultproperties
{
     Health=30
     Mesh=LodMesh'UPak.dropbox'
     CollisionRadius=51.000000
     CollisionHeight=50.000000
}
