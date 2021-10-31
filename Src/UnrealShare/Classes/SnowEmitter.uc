//by Punish3r
class SnowEmitter extends Atmospheric;

#EXEC TEXTURE IMPORT FILE=Textures\snowflake.pcx NAME=snowflake GROUP="Skins"

defaultproperties
{
	Particle_Main(0)=(ParticleLifeTime=16.000000,ParticleLifeTimeVariance=0.000000,SpeedVariance=80.000000,ParticleSpeed=160.000000)
	Particle_Display(0)=(bUnlitParticle=True,ParticleTexture=Texture'UnrealShare.snowflake')
	Particle_Size(0)=(ParticleDrawScale=0.100000,ParticleDrawScaleVariance=0.050000,MinSize=0.000000,MaxSize=0.000000)
	Particle_Fading(0)=(CanFadeIn=True,InitailScaleGlow=0.000000,FadeOutTime=0.000000,FadeOutScaleFactor=0.000000,FadeInTime=2.000000,FadeInScaleFactor=0.100000)
	Particle_Bounce(0)=(BounceRatio=0.000000,BounceModifier=0.000000,BounceNum=0)
	Particle_Buoyance(0)=(ParticleBuoyancy=0.000000,ParticleMass=0.000000)
	Particle_Misc(0)=(ParticlesUseJerkyness=true,ParticlesJerkyness=48)
	NumTemplates=1
	NewIntervall=1.000000
	NewIntensity=1.000000
	Intervall=0.010000
	ParticleProjForward=0.000000
	BeforeDieSleep=0.500000
	WaitPause=0.500000
}
