//=============================================================================
// SpinnerProjectile.
//=============================================================================
class SpinnerProjectile expands Projectile;

#exec AUDIO IMPORT FILE="Sounds\Spinner\Shoot2.wav"  NAME="Fire"   GROUP="Spinner"
#exec AUDIO IMPORT FILE="Sounds\Spinner\Impact3.wav" NAME="Hit"    GROUP="Spinner"

auto simulated state Flying
{
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		if ( Spinner( Other ) == None )
		{
			if ( Role == ROLE_Authority )
				Explode( HitLocation, Normal(Velocity) );
			else Destroy();
		}
	}
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Explode( Location, HitNormal );
		if ( Level.NetMode != NM_DedicatedServer )
			Spawn(class'SpinnerAcid',,,Location, rotator(HitNormal));
	}
	function MakeSound()
	{
		PlaySound( ImpactSound );
		MakeNoise( 1.0 );
	}
	simulated function Explode( vector HitLocation, vector HitNormal )
	{
		local EnergyBurst e;

		MakeSound();
		HurtRadius( Damage * DrawScale, 240 * DrawScale, 'corroded', MomentumTransfer * DrawScale, Location );
		if( Level.NetMode != NM_DedicatedServer )
		{
			e = spawn( class 'EnergyBurst', , , HitLocation + HitNormal * 9 );
			e.RemoteRole = ROLE_None;
		}
		Destroy();
	}

	simulated function BeginState()
	{
		if( ScriptedPawn( Instigator ) != None )
			Speed = ScriptedPawn( Instigator ).ProjectileSpeed;
		Velocity = Vector( Rotation ) * speed;
		Velocity.z += 200;  // Lob vertical component
		if( Level.NetMode != NM_DedicatedServer )
			PlaySound( SpawnSound );
		if( Region.zone.bWaterZone )
			Velocity *= 0.7;
	}

Begin:
	Sleep( LifeSpan - 0.3 ); //self destruct after 7.0 seconds
	Explode( Location, vect(0,0,0) );
}

defaultproperties
{
     speed=300.000000
     MaxSpeed=500.000000
     Damage=30.000000
     MomentumTransfer=20000
     SpawnSound=Sound'UPak.Spinner.Fire'
     ImpactSound=Sound'UPak.Spinner.Hit'
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=7.300000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UPak.SpEffect.SpEffect.e8_a00'
     DrawScale=0.500000
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=149
     LightHue=165
     LightSaturation=186
     LightRadius=4
     bBounce=True
}
