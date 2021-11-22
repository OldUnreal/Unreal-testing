//=============================================================================
// UPakHealth.
//=============================================================================
class UPakHealth expands Health;

var() bool bRespawnInSP;
// This needs to be tested; I need to remove the Tick function and see if it works without it. Until then, this is just a hack to make
// sure the health in the spaceship actually falls out of the glass container when the glass is broken.

function Bump( actor Other )
{
	local float speed, oldZ;
	
	if( ( Other != None && !Other.IsA( 'Pawn' ) ) )
	{
		oldZ = Velocity.Z;
		speed = VSize(Other.Velocity);
		Velocity = Other.Velocity * FMin(120.0, 20 + speed)/FMax(speed,1);
		if ( Physics == PHYS_None )
			Velocity.Z = 25;
		else Velocity.Z = oldZ;
		SetPhysics(PHYS_Falling);
	}
}


singular function BaseChange()
{
	local float decorMass, decorMass2;

	decormass= FMax(1, Mass);
	if( Velocity.Z < -500 )
		TakeDamage( (1-Velocity.Z/30),Instigator,Location,vect(0,0,0) , 'crushed');

	if( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	else if( (Pawn(base) != None) && (Pawn(Base).CarriedDecoration != self) )
	{
		Base.TakeDamage( (1-Velocity.Z/400)* decormass/Base.Mass,Instigator,Location,0.5 * Velocity , 'crushed');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else if( Decoration(Base)!=None && Velocity.Z<-500 )
	{
		decorMass2 = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((1 - decorMass/decorMass2 * Velocity.Z/30), Instigator, Location, 0.2 * Velocity, 'stomped');
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else
	{
		SetPhysics( PHYS_Falling );
		instigator = None;
	}
}


//
// Set up respawn waiting if desired.
//
function SetRespawn()
{
	GotoState('Sleeping');
}


State Sleeping
{
	ignores Touch;

	function BeginState()
	{
		SetPhysics( PHYS_None );
		BecomePickup();
		bHidden = true;
	}
	function EndState()
	{
		local int i;

		bSleepTouch = false;
		for ( i=0; i<4; i++ )
			if ( (Touching[i] != None) && Touching[i].IsA('Pawn') )
				bSleepTouch = true;
	}			
Begin:
	Sleep( ReSpawnTime );
	PlaySound( RespawnSound );	
	Level.Game.PlaySpawnEffect(self);
	Sleep( 0.3 );
	SetPhysics( Default.Physics );
	GoToState( 'Pickup' );
}

defaultproperties
{
     RespawnTime=10.000000
     bCollideWorld=True
     RotationRate=(Yaw=0)
     DesiredRotation=(Yaw=0)
}
