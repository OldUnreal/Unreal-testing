//=============================================================================
// ExplodingWall.
//=============================================================================
class ExplodingWall extends Effects;

#exec Texture Import File=Models\Exp001.pcx  Name=s_Exp Mips=Off Flags=2

var() float ExplosionSize;
var() float ExplosionDimensions;
var() float WallParticleSize;
var() float WoodParticleSize;
var() float GlassParticleSize;
var() int NumWallChunks;
var() int NumWoodChunks;
var() int NumGlassChunks;
var() texture WallTexture;
var() texture WoodTexture;
var() texture GlassTexture;
var() int Health;
var() name ActivatedBy[5];
var() sound BreakingSound;
var() bool bTranslucentGlass;
var() bool bUnlitGlass;

var int BACKUP_Health;
var bool BACKUP_Collision;
var Sound BACKUP_AmbientSound;

function PreBeginPlay()
{
	BACKUP_Collision = bCollideActors;
	BACKUP_Health = Health;
	BACKUP_AmbientSound = AmbientSound;
	DrawType = DT_None;
	Super.PreBeginPlay();
}

Auto State Exploding
{
	singular function Trigger( actor Other, pawn EventInstigator )
	{
		Explode(EventInstigator, Vector(Rotation));
	}

	singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
								  Vector momentum, name damageType)
	{
		local int i;
		local bool bAbort;

		if ( bOnlyTriggerable )
			return;

		if ( DamageType != 'All' )
		{
			bAbort = true;
			for ( i=0; i<5; i++ )
				if (DamageType==ActivatedBy[i])
				{
					bAbort=False;
					break;
				}
			if ( bAbort )
				return;
		}
		Health -= NDamage;
		if ( Health <= 0 )
			Explode(instigatedBy, Momentum);
	}

	function Explode( pawn EventInstigator, vector Momentum)
	{
		local int i;
		local Fragment s;

		TriggerEvent(Event,Instigator,Instigator);

		Instigator = EventInstigator;
		if ( Instigator != None )
			MakeNoise(1.0);

		PlaySound(BreakingSound, SLOT_None,2.0);

		for (i=0 ; i<NumWallChunks ; i++)
		{
			s = Spawn( class 'WallFragments',,,Location+ExplosionDimensions*VRand());
			if ( s != None )
			{
				s.CalcVelocity(vect(0,0,0),ExplosionSize);
				s.DrawScale = WallParticleSize;
				s.Skin = WallTexture;
			}
		}
		for (i=0 ; i<NumWoodChunks ; i++)
		{
			s = Spawn( class 'WoodFragments',,,Location+ExplosionDimensions*VRand());
			if ( s != None )
			{
				s.CalcVelocity(vect(0,0,0),ExplosionSize);
				s.DrawScale = WoodParticleSize;
				s.Skin = WoodTexture;
			}
		}
		for (i=0 ; i<NumGlassChunks ; i++)
		{
			s = Spawn( class 'GlassFragments', Owner,,Location+ExplosionDimensions*VRand());
			if ( s != None )
			{
				s.CalcVelocity(Momentum, ExplosionSize);
				s.DrawScale = GlassParticleSize;
				s.Skin = GlassTexture;
				s.bUnlit = bUnlitGlass;
				if (bTranslucentGlass) s.Style = STY_Translucent;
			}
		}
		GoToState('Inactive');
	}
	function Reset()
	{
		Health = BACKUP_Health;
	}
}

state Inactive
{
Ignores Trigger,TakeDamage;

	function BeginState()
	{
		SetCollision(false);
		bHidden = true;
		AmbientSound = None;
		LightType = LT_None;
	}
	function Reset()
	{
		SetCollision(BACKUP_Collision);
		Health = BACKUP_Health;
		AmbientSound = BACKUP_AmbientSound;
		GoToState('Exploding');
	}
}

defaultproperties
{
	ExplosionSize=+00200.000000
	ExplosionDimensions=+00120.000000
	WallParticleSize=+00001.000000
	WoodParticleSize=+00001.000000
	GlassParticleSize=+00001.000000
	NumWallChunks=10
	NumWoodChunks=3
	ActivatedBy(0)=exploded
	DrawType=DT_Sprite
	Texture=UnrealShare.s_Exp
	DrawScale=+00000.300000
	CollisionRadius=+00032.000000
	CollisionHeight=+00032.000000
	bCollideActors=True
	bCollideWorld=True
	bNetTemporary=false
	bProjTarget=True
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy
}
