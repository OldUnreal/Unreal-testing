//=============================================================================
// RainDropSparks.
//=============================================================================
class RainDropSparks extends RainDropComponents;

defaultproperties
{
	Particle_Main(0)=(ParticleLifeTime=0.500000,ParticleLifeTimeVariance=0.000000,SpeedVariance=40.000000,ParticleSpeed=80.000000)
	Particle_Display(0)=(bUnlitParticle=True,ParticleTexture=Texture'UnrealShare.raindropspark')
	Particle_Size(0)=(ParticleDrawScale=0.025000,ParticleDrawScaleVariance=0.000000,MinSize=0.000000,MaxSize=0.000000)
	Particle_Fading(0)=(CanFadeOut=True,InitailScaleGlow=0.500000,FadeOutScaleFactor=0.100000,FadeInTime=0.000000,FadeInScaleFactor=0.000000)
	Particle_Physics(0)=(ParticlePhysics=PHYS_Falling)
	Particle_Collision(0)=(ParticleCollisonRadius=0.000000,ParticleCollisonHeight=0.000000)
	Particle_Bounce(0)=(BounceRatio=0.000000,BounceModifier=0.000000,BounceNum=0)
	Particle_Buoyance(0)=(ParticleBuoyancy=0.000000,ParticleMass=0.000000)
	Particle_RandomRotation(0)=(bRandomizeRotation=True,bRandPitch=True,bRandYaw=True,bRandRoll=True,MinRotation=(Pitch=-4096,Yaw=-4096,Roll=-4096),MaxRotation=(Pitch=4096,Yaw=4096,Roll=4096),bAlignRotator=true)
	AdvancedSpawning(0)=(bSpawnOnSurface=True,bAlignSpawnSurface=true)
	Particle_Destination(0)=(DestinationActor=DA_Self)
	NumTemplates=1
	NewIntervall=1.000000
	NewIntensity=0.000000
	Intervall=0.005000
	ParticlesLimit=6
	ParticleProjForward=0.000000
	BeforeDieSleep=0.500000
	WaitPause=0.500000
}
