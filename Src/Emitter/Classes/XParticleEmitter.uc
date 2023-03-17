// Particle Emitter base
// All these classes written by .:..:
Class XParticleEmitter extends Actor
	Native
	Abstract;

#EXEC TEXTURE IMPORT FILE="Textures\S_Emitter.bmp" NAME="S_Emitter" GROUP="Icons" MIPS=off FLAGS=2 TEXFLAGS=0

// Range structs
struct export IntRange
{
	var() int Min,Max;
	
	cpptext
	{
		inline INT GetValue() const
		{
			return (Min==Max ? Min : Min+(appRand() % (Max-Min)));
		}
	}
};
struct export ByteRange
{
	var() byte Min,Max;
	
	cpptext
	{
		inline BYTE GetValue() const
		{
			return (Min==Max ? Min : Min+(appRand() % (Max-Min)));
		}
	}
};
struct export FloatRange
{
	var() float Min,Max;
	
	cpptext
	{
		inline FLOAT GetValue() const
		{
			return (Min==Max ? Min : Min+(Max-Min)*appFrand());
		}
	}
};
struct export RangeVector
{
	var() FloatRange X,Y,Z;
	
	cpptext
	{
		inline FVector GetValue() const
		{
			return FVector(X.GetValue(), Y.GetValue(), Z.GetValue());
		}
	}
};

struct export ParticleSndType
{
	var() Sound Sounds[8];
	var() FloatRange SndPitch,SndRadius,SndVolume;
	var byte SndCount;
	
	cpptext
	{
		void PlaySoundEffect( const FVector &Location, ULevel* Level ) const;
		void InitSoundList();
	}
};
enum EHitEventType
{
	HIT_DoNothing, // Do nothing on impact
	HIT_Destroy, // Destroy particle on impact
	HIT_StopMovement, // Self explainotory
	HIT_Bounce, // Bounce off wall/water on impact
	HIT_Script // Call UScript event on impact
};

// Natively updated variables, do not touch.
var transient const int ActiveCount;
var transient const editconst bool bHasInitialized,bIsTransientEmitter,bIsInternalEmitter;
var const noedsave bool bDestruction; // Emitter is about to be killed!

var transient const editconst XParticleEmitter ParentEmitter,CombinerList,TransientEmitters;  // List of combiner particle emitters
var pointer<class FParticlesDataBase*> PartPtr;
var transient const uint LastUpdateTime;
var transient const float EmitterLifeSpan;

var bool bUSNotifyParticles; // Call NotifyNewParticle whenever a particle has been spawned.
var bool bNotifyNetReceive; // Call PostNetNotify when a new packet has been received.
var bool bUSModifyParticles; // Call GetParticleProps when a new particle is about to be spawned.
var(EmVisibility) bool bNotOnPortals; // Don't show up in mirrors or warp portals.

simulated native(1770) final function SetParticlesProps( optional float Speed, optional float Scale );
simulated native(1771) final iterator function AllParticles( out actor Actor ); // Iterate through all alive particles, WARNING: these are NOT in level actors.

function PreBeginPlay()
{
	if ( Level.NetMode==NM_DedicatedServer && RemoteRole==ROLE_None )
		Destroy(); // Destruct on dedicated server whenever its possible.
}
simulated function BeginPlay()
{
	if ( (bNoDelete || bStatic) && RemoteRole==ROLE_None )
		Role = ROLE_Authority; // Give client authority over actor.
}

Event PostNetNotify();
Event NotifyNewParticle( Actor Other ); // Warning; these are not actual in level actors!
Event GetParticleProps( Actor Particle, out vector Pos, out vector Vel, out rotator Ro ); // Modify newly spawning particle position/velocity/rotation.

// Adjust HitLocation to change particle location.
simulated event ParticleWallHit( Actor Particle, vector HitNormal, out vector HitLocation )
{
	Particle.bHidden = true; // Destroys the particle
}
simulated event ParticleZoneHit( Actor Particle, ZoneInfo OtherZone )
{
	if( OtherZone.bWaterZone )
		Particle.bHidden = true; // Destroys the particle
}

private function LoadActor() // Force actor to exist.
{
	Spawn(Class'EmitterGarbageCollector');
	Spawn(Class'EmitterRC');
}

defaultproperties
{
	RemoteRole=ROLE_None
	bNoDelete=True
	bHidden=False
	bStasis=True
	bForceStasis=True
	Texture=Texture'S_Emitter'
	RenderIteratorClass=Class'EmitterRendering'
	bUnlit=true
	bHandleOwnCorona=true
}
