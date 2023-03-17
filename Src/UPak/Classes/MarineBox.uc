//=============================================================================
// MarineBox.
//=============================================================================
class MarineBox expands SteelBox;

#exec MESH IMPORT MESH=dropbox ANIVFILE=MODELS\CARGO\dropbox_a.3d DATAFILE=MODELS\CARGO\dropbox_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=dropbox X=0 Y=00 Z=000

#exec MESH SEQUENCE MESH=dropbox SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=dropbox SEQ=DROPBOX STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jdropbox1 FILE=MODELS\CARGO\dropbox.PCX GROUP=Skins FLAGS=2 // mat1

#exec MESHMAP NEW   MESHMAP=dropbox MESH=dropbox
#exec MESHMAP SCALE MESHMAP=dropbox X=1.05 Y=1.05 Z=2.625

#exec MESHMAP SETTEXTURE MESHMAP=dropbox NUM=1 TEXTURE=Jdropbox1

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
