//by Punish3r
class RainEmitter extends Atmospheric;

#EXEC TEXTURE IMPORT NAME=Drip FILE=Textures\Drip.pcx GROUP=Skins

defaultproperties
{
	Particle_Main(0)=(ParticleLifeTime=16.000000,ParticleLifeTimeVariance=0.000000,SpeedVariance=12.000000,ParticleSpeed=14.000000)
	Particle_Display(0)=(bUnlitParticle=True,bUseMesh=True,PraticleMesh=Mesh'UnrealShare.UIpSpark',ParticleTexture=Texture'Unrealshare.Drip')
	Particle_Size(0)=(ParticleDrawScale=0.175000,ParticleDrawScaleVariance=0.100000,MinSize=0.000000,MaxSize=0.000000)
	Particle_Fading(0)=(CanFadeIn=True,InitailScaleGlow=0.000000,FadeOutTime=0.000000,FadeOutScaleFactor=0.000000,FadeInTime=0.750000,FadeInScaleFactor=0.100000)
	Particle_Collision(0)=(ParticlesUseCollision=True,CollideWithActors=True,ParticleCollideWorld=True,DestroyWhenTouch=True,DestroyWhenColideWorld=True,DestroyWhenLand=True,DestroyWhenTouchWater=True,bSpawnEffectOnDestroy=True,DestroyEffect=Class'UnrealShare.RainDropSplash')
	Particle_Bounce(0)=(BounceRatio=0.000000,BounceModifier=0.000000,BounceNum=0)
	Particle_Buoyance(0)=(ParticleBuoyancy=0.000000,ParticleMass=0.000000)
	Particle_Mesh(0)=(FaceObject=FACE_Velocity)
	Particle_Physics(0)=(ParticlePhysics=PHYS_Falling)
	NumTemplates=1
	Intervall=0.010000
	Intensity=2.000000
	ParticleProjForward=0.000000
	BeforeDieSleep=0.500000
	WaitPause=0.500000
}
