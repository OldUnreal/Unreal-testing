// Particle forces actor.
// Note: in order to this to work on an Emitter you NEED to add this actor to Emitter's Forces list!
Class XParticleForces extends Actor
	Abstract
	Native
	DependsOn(XParticleEmitter);

var() float EffectingRadius;
var() BoundingBox EffectingBox;
var() XParticleEmitter.FloatRange EffectPartLifeTime; // Only effect particles within this lifetime range.
var transient name OldTagName; // Editor use only.

// Bitmask
var() bool bEnabled; // Force is enabled?
var() bool bUseBoxForcePosition; // Use box force position instead of radius.

function PreBeginPlay()
{
	if ( Level.NetMode==NM_DedicatedServer && RemoteRole==ROLE_None )
		Destroy(); // Destruct on dedicated server whenever its possible.
}
simulated function BeginPlay()
{
	local Actor A;

	if ( (bNoDelete || bStatic) && RemoteRole==ROLE_None )
	{
		Role = ROLE_Authority; // Important!
		if( Level.NetMode==NM_Client && AttachTag!='' ) // Client attach actor.
			foreach AllActors(Class'Actor',A,AttachTag)
			{
				SetBase(A);
				break;
			}
	}
}
simulated function Trigger( Actor Other, Pawn EventInstigator )
{
	bEnabled = !bEnabled;
}

defaultproperties
{
	bEnabled=True
	EffectPartLifeTime=(Min=0,Max=1)
	EffectingRadius=300
	EffectingBox=(Min=(X=-200,Y=-200,Z=-200),Max=(X=200,Y=200,Z=200))
	RemoteRole=ROLE_None
	bNoDelete=True
	bHidden=True
	bStasis=True
	bForceStasis=True
}