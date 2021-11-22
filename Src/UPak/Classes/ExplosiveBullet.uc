//=============================================================================
// ExplosiveBullet.uc
// $Date: 4/28/99 2:18p $
// $Revision: 3 $
//=============================================================================
class ExplosiveBullet expands Projectile;

// ================================================================================================
// Flying State
// ================================================================================================

auto state Flying
{
	function BeginState()
	{
		Velocity = Vector( Rotation ) * speed;
		PlaySound( SpawnSound );
	}
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		if( !Other.IsA( 'Pawn' ) )
			Other.TakeDamage(30, instigator,HitLocation, vect( 0, 0, 0 ), 'Exploded');
		else BlowUp( HitLocation );
	}
	simulated function HitWall (vector HitNormal, actor Wall)
	{
		LastHitActor = Wall;
		if ( Role == ROLE_Authority )
		{
			if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');

			MakeNoise(1.0);
		}
		BlowUp( Location );
	}
	simulated function BlowUp( Vector HitLocation )
	{
		local vector HitNormal;
		local WallHitEffect WallHit;
		
		HitNormal = Normal( HitLocation - Location );
		Spawn( class'UPakExplosion2',,, HitLocation, Rotation );
		
		if (EffectIsRelevant(Location) )
			Spawn(ExplosionDecal,self,,Location, rotator(HitNormal));
		
		WallHit = Spawn( class'CARWallHitEffect3',,, HitLocation + HitNormal * 9, Rotator( HitNormal ) );
		WallHit.DrawScale -= FRand();
		
		if( Instigator.IsA( 'SpaceMarine' ) )
			HurtRadius( 2, 100, 'exploded', 25000, HitLocation );
		else HurtRadius( 55, 100, 'exploded', 25000, HitLocation );
		Destroy();
	}	
}	

defaultproperties
{
     speed=50000.000000
     MaxSpeed=50000.000000
     Damage=15.000000
     RemoteRole=ROLE_SimulatedProxy
     Mesh=LodMesh'UPak.CARbullet'
     ExplosionDecal=class'SmallBlastMark'
}
