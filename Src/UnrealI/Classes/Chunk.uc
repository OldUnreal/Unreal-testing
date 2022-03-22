//=============================================================================
// Chunk.
//=============================================================================
class Chunk extends Projectile;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Flak\flachit1.wav" NAME="Hit1" GROUP="Flak"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Flak\flachit3.wav" NAME="Hit3" GROUP="Flak"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Flak\flachit5.wav" NAME="Hit5" GROUP="Flak"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Flak\chunkhit.wav" NAME="ChunkHit" GROUP="Flak"

var bool bDelayTime;

function PostBeginPlay()
{
	local vector X,Y,Z;

	GetAxes(Rotation,X,Y,Z);
	Velocity = Normal(X+Y*(FRand()*0.2-0.1)+Z*(FRand()*0.2-0.1)) * (Speed + (FRand() * 200 - 100));
	if (Region.zone.bWaterZone)
		SetPhysics(PHYS_Falling);
	Super.PostBeginPlay();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if ( (Chunk(Other) == None) && (bDelayTime || (Other != Instigator)) )
	{
		speed = VSize(Velocity);
		If ( speed > 200 )
		{
			if ( Role == ROLE_Authority )
				Other.TakeDamage(damage, instigator,HitLocation,
								 (MomentumTransfer * Velocity/speed), 'shredded' );
			if ( FRand() < 0.5 )
				PlaySound(Sound 'ChunkHit',, 2.0,,1000);
		}
		Destroy();
	}
}

simulated function Timer()
{
	Destroy();
}

simulated function Landed( Vector HitNormal )
{
	SetPhysics(PHYS_None);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local float Rand;
	local SmallSpark s;

	if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
	{
		if ( Level.NetMode != NM_Client )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');
		Destroy();
		return;
	}
	if ( Physics != PHYS_Falling )
	{
		bDelayTime = true;
		SetPhysics(PHYS_Falling);
		if ( !Level.bDropDetail && (Level.Netmode != NM_DedicatedServer) && !Region.Zone.bWaterZone )
		{
			if ( FRand() < 0.5 )
			{
				s = Spawn(Class'SmallSpark',,,Location+HitNormal*5,rotator(HitNormal));
				s.RemoteRole = ROLE_None;
			}
			else Spawn(class'WallCrack',,,Location, rotator(HitNormal));
		}
	}
	Velocity = 0.8*(( Velocity dot HitNormal ) * HitNormal * (-1.8 + FRand()*0.8) + Velocity);   // Reflect off Wall w/damping
	SetRotation(rotator(Velocity));
	speed = VSize(Velocity);
	if ( speed > 100 )
	{
		MakeNoise(0.3);
		Rand = FRand();
		if (Rand < 0.33)	PlaySound(sound 'Hit1', SLOT_Misc,0.6,,1000);
		else if (Rand < 0.66) PlaySound(sound 'Hit3', SLOT_Misc,0.6,,1000);
		else PlaySound(sound 'Hit5', SLOT_Misc,0.6,,1000);
	}
	else
	{
		bBounce = False;
		SetTimer(1.0,False);
	}
}

simulated function zonechange(Zoneinfo NewZone)
{
	if (NewZone.bWaterZone)
		SetPhysics(PHYS_Falling);
}

defaultproperties
{
	MyDamageType=shredded
	speed=2500.000000
	MaxSpeed=2700.000000
	Damage=17.000000
	MomentumTransfer=10000
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=3.000000
	bUnlit=True
	bNoSmooth=True
	bMeshCurvy=False
	bBounce=True
	NetPriority=6.000000
	
	// Marco: Disabled this because chunks are plentiful and doesn't need exact position.
	bNetInitialVelocity=false
	bNetInitExactLocation=false
}
