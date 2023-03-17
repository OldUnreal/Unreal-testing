//=============================================================================
// Projectile.
//
// A delayed-hit projectile moves around for some time after it is created.
// An instant-hit projectile acts immediately.
//=============================================================================
class Projectile extends Actor
	abstract
	native;

#exec Texture Import File=Textures\S_Camera.pcx Name=S_Camera Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Projectile variables.

// Motion information.
var() float    Speed;               // Initial speed of projectile.
var() float    MaxSpeed;            // Limit on speed of projectile (0 means no limit)

// Damage attributes.
var() float    Damage;
var() int	   MomentumTransfer; // Momentum imparted by impacting projectile.
var() name	   MyDamageType;

// Projectile sound effects
var() sound    SpawnSound;		// Sound made when projectile is spawned.
var() sound	   ImpactSound;		// Sound made when projectile hits something.
var() sound    MiscSound;		// Miscellaneous Sound.

var() float		ExploWallOut;	// distance to move explosions out from wall

// explosion decal
var() class<Decal> ExplosionDecal;

var() bool		bPostRender2D; // 227j: Should call PostRender2D on this projectile when visible.

var transient Actor LastHitActor;
var transient Actor Shadow;

//==============
// Encroachment
function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;

	return false;
}

//==============
// Touching
simulated singular function Touch(Actor Other)
{
	local vector HitNormal,HitLocation;

	if ( Other.bWorldGeometry || Other.IsA('BlockAll') )
	{
		LastHitActor = Other;
		if( Other.TraceThisActor(Location,OldLocation,HitLocation,HitNormal,GetExtent(),bTraceHitBoxes) )
		{
			SetLocation(HitLocation);
			HitWall( HitNormal, Other);
		}
		else if( !Other.HasMeshHitBoxes() )
			HitWall( Normal(Location - Other.Location), Other);
		LastHitActor = None;
		return;
	}
	if ( Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers) )
	{
		//get exact hitlocation
		if( Other.TraceThisActor(Location+Velocity,OldLocation,HitLocation,,GetExtent(),bTraceHitBoxes) )
		{
			if ( Other.bIsPawn && !Pawn(Other).AdjustHitLocation(HitLocation, Velocity) )
				return;
			LastHitActor = Other;
			ProcessTouch(Other, HitLocation);
		}
		else if( !Other.HasMeshHitBoxes() )
		{
			LastHitActor = Other;
			ProcessTouch(Other, Other.Location + Other.CollisionRadius * Normal(Location - Other.Location));
		}
		LastHitActor = None;
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	//should be implemented in subclass
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	LastHitActor = Wall;
	if ( Role == ROLE_Authority )
	{
		if ( Wall.bIsMover && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ( (ExplosionDecal!=None) && EffectIsRelevant(Location) )
		Spawn(ExplosionDecal,self,,Location, rotator(HitNormal));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Destroy();
}

simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;
}

// Additional 227g functions:
// Hurt actors within the radius while ensuring that LastHitActor is damaged.
native final function HurtRadiusProj( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation );

simulated final function bool EffectIsRelevant( vector SpawnLocation, optional bool bForceDedicated )
{
	local PlayerPawn P;
	local bool bResult;

	if ( Level.NetMode == NM_DedicatedServer )
		return bForceDedicated;
	if ( Level.NetMode != NM_Client )
		bResult = true;
	else if ( PlayerPawn(Instigator)!=None && Viewport(PlayerPawn(Instigator).Player)!=None )
		return true;
	else if ( SpawnLocation == Location )
		bResult = (Level.TimeSeconds-LastRenderedTime < 3);
	else if ( (Instigator != None) && (Level.TimeSeconds-Instigator.LastRenderedTime < 3) )
		bResult = true;
	if ( bResult )
	{
		P = Level.GetLocalPlayerPawn();
		if ( P == None )
			bResult = false;
		else if ( (Vector(P.CalcCameraRotation) Dot (SpawnLocation - P.CalcCameraLocation)) < 0.0 )
			bResult = (VSize(P.CalcCameraLocation - SpawnLocation) < 1000);
	}
	return bResult;
}
simulated final function Texture GetHitTexture() // Get the impact texture on HitWall
{
	local vector Dir;
	local Texture T;
	local int F;

	Dir = Normal(Velocity);
	if( !TraceSurfHitInfo(Location-Dir*5.f,Location+Dir*50.f,,,T,F) || (F & PF_FakeBackdrop)!=0 ) // Did not hit or did hit skybox texture.
		return None;
	return T;
}

function PostLoadGame()
{
	ShadowModeChange();
}

// Called by C++ codes BeginPlay.
simulated function ShadowModeChange()
{
	if( !bNoDynamicShadowCast )
	{
		if( !Class'GameInfo'.Default.bCastShadow || !Class'GameInfo'.Default.bDecoShadows )
		{
			if( Shadow )
			{
				Shadow.Destroy();
				Shadow = None;
			}
		}
		else if( !Shadow )
			Shadow = Spawn(Class'ProjectileShadow',Self);
	}
}

simulated event OnSubLevelChange( LevelInfo PrevLevel )
{
	if( Shadow )
		Shadow.SendToLevel(Level, Location);
}

// Called when bPostRender2D is enabled and this projectile is in front side of the camera.
// Pos.X/Y are screen position, Pos.Z is the depth scaling 1 -> 0
simulated event PostRender2D( canvas Canvas, vector Pos );

simulated function Reset()
{
	Destroy();
}

defaultproperties
{
	MaxSpeed=+02000.000000
	bDirectional=True
	DrawType=DT_Mesh
	Texture=S_Camera
	SoundVolume=0
	CollisionRadius=+00000.000000
	CollisionHeight=+00000.000000
	bCollideActors=True
	bCollideWorld=True
	bNetTemporary=true
	bGameRelevant=true
	bReplicateInstigator=true
	Physics=PHYS_Projectile
	LifeSpan=+00140.000000
	NetPriority=+00006.000000
	bIsProjectile=True
	CollisionFlag=COLLISIONFLAG_Projectile
	bTraceHitBoxes=true
	bNoDynamicShadowCast=true
	bNetInitialVelocity=true
	bNetInitExactLocation=true
}