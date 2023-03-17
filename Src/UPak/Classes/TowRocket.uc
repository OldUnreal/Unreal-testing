//=============================================================================
// TowRocket.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class TowRocket expands UPakRocket;

var repnotify vector RepPos,RepVeloC;

replication
{
	// Variables the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		RepPos,RepVeloC;
}

simulated function OnRepNotify( name Property )
{
	if( Property=='RepPos' )
		SetLocation(RepPos);
	else if( Property=='RepVeloC' )
	{
		Velocity = RepVeloC;
		SetRotation(rotator(RepVeloC));
	}
}
simulated function Tick( float DeltaTime )
{
	local SpriteSmokePuff b;
	local Bubbletrail bb;
	local float TempVelocity;
	
	if( Level.NetMode==NM_DedicatedServer )
		Return;

	TempVelocity = VSize( Velocity );
	if( TempVelocity > 1200 && bSmoking && AnimSequence!='Fly' )
	{
		LoopAnim( 'Fly' );
	}
	if( NextSmoke>Level.TimeSeconds )
		Return;
	NextSmoke = Level.TimeSeconds+0.025;
	if ( bSmoking )		
	{
		LoopAnim( 'Fly' );
		b = Spawn( class'RisingSpriteSmokePuff',,, Location );
		b.RemoteRole = ROLE_None;
		b.LifeSpan = 1.5 + Rand( 8.5 );
		b.DrawScale += FRand();
	}
	else if ( bBubbling )
	{
		LoopAnim( 'Wings' );
		RotationRate.Roll = 90000;
		bb = Spawn( class'BubbleTrail',,,Location );
		bb.RemoteRole = ROLE_None;
		bb.ScaleGlow = 0.5;
	}
}
simulated function Timer()
{
	local rotator newRot;
	
	if( (Level.NetMode==NM_Client && !bNetOwner) || !Owner )
		Return;
	if( Owner.bIsPawn )
	{
		if( Owner.bIsPlayerPawn )
			newRot = Pawn(Owner).ViewRotation;
		else if( Pawn(Owner).Enemy && Pawn(Owner).Enemy.Health>0 && Pawn(Owner).CanSee(Pawn(Owner).Enemy) )
		{
			newRot = GetAimRotation(Pawn(Owner).Enemy);
			newRot.Yaw = FixedTurnTo(Rotation.Yaw, newRot.Yaw, 3500);
			newRot.Pitch = FixedTurnTo(Rotation.Pitch, newRot.Pitch, 3500);
		}
		else newRot = Rotation;
		newRot.Roll = Rotation.Roll + 12768;
		SetRotation( newRot );	
	}
	Velocity = VSize( Velocity ) * Vector( Rotation );
	if( Level.NetMode!=NM_Client )
	{
		RepPos = Location;
		RepVeloC = Velocity;
	}
}
final function int FixedTurnTo( int Src, int Dest, int Delta )
{
	Dest = (Dest - Src) & 65535;
	if( Dest>=32768 )
		Dest-=65536;
	return (Src + Clamp(Dest,-Delta,Delta)) & 65535;
}
function rotator GetAimRotation( Actor Other )
{
	local vector V;
	
	V = Other.Location;
	if( VSizeSq(V-Location)>Square(500.f) )
	{
		V += Other.Velocity;
		if( !FastTrace(Other.Location,V) || !FastTrace(V,Location) )
			V = Other.Location;
	}
	return rotator(V-Location);
}

// ================================================================================================
// Flying State
// ================================================================================================

auto state Flying
{
	simulated function BeginState()
	{
		SetTimer( 0.2, True );
		Super.BeginState();
	}
	simulated function Explode( vector HitLocation, vector HitNormal )
	{
		if( Level.NetMode==NM_Client )
			Return;
		
		if( Owner != None && Pawn(Owner) != None && (RocketLauncher(Pawn(Owner).Weapon) != none ) && ( !RocketLauncher( Pawn(Owner).Weapon ).bRJDisabled ) )
			ControlledHurtRadius( Damage, 340.0, 'exploded', MomentumTransfer, HitLocation );
		else ControlledHurtRadiusNoRJ( Damage, 340.0, 'exploded', MomentumTransfer, HitLocation );
	 	Destroy();
	}
}

function HitWall (vector HitNormal, actor Wall)
{
	LastHitActor = Wall;
	if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
		Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');
	MakeNoise(1.0);
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
}
simulated function Destroyed()
{
	local UPakBurst UPB;

	if( Level.NetMode!=NM_DedicatedServer )
	{
		if ( (ExplosionDecal!=None) && EffectIsRelevant(Location) )
			Spawn(ExplosionDecal,self,,Location, rotator(-Velocity));
		UPB = spawn( class'UPakBurst');
		UPB.RemoteRole = ROLE_None;
		Spawn(class'UPakExplosion1',,,,RotRand(True)).RemoteRole = ROLE_None;
	}
	Super.Destroyed();
}

defaultproperties
{
	MomentumTransfer=9500
	bNetTemporary=False
	bAlwaysRelevant=True
	AmbientSound=Sound'UPak.RocketLauncher.RocketLoop2'
	bProjTarget=False
	bFixedRotationDir=False
	bRotateToDesired=True
}