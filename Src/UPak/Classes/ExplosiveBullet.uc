//=============================================================================
// ExplosiveBullet.uc
// $Date: 4/28/99 2:18p $
// $Revision: 3 $
//=============================================================================
class ExplosiveBullet expands Projectile
	DependsOn(CARifleClip);

#exec MESH IMPORT MESH=CARbullet ANIVFILE=MODELS\CARifle\CARbullet_a.3d DATAFILE=MODELS\CARifle\CARbullet_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CARbullet X=0 Y=0 Z=0 YAW=385

#exec MESH SEQUENCE MESH=CARbullet SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CARbullet SEQ=CARBULLET STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=CARbullet MESH=CARbullet
#exec MESHMAP SCALE MESHMAP=CARbullet X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=CARbullet NUM=0 TEXTURE=JCARammo1

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
