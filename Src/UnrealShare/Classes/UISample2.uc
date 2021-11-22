class UISample2 extends UIParticleTest;

#exec obj load file=..\Textures\GenFX.utx package=GenFX

defaultproperties
{
	Particle_Main(0)=(SpeedVariance=40.000000,ParticleSpeed=15.000000)
	Particle_Main(1)=(SpeedVariance=120.000000,ParticleSpeed=15.000000)
	Particle_Main(2)=(SpeedVariance=13.000000,ParticleSpeed=15.000000)
	Particle_Main(3)=(SpeedVariance=23.000000,ParticleSpeed=15.000000)
	Particle_Display(0)=(ParticleTexture=Texture'GenFX.LensFlar.1')
	Particle_Display(1)=(ParticleTexture=Texture'GenFX.LensFlar.1')
	Particle_Display(2)=(ParticleTexture=Texture'GenFX.LensFlar.1')
	Particle_Display(3)=(ParticleTexture=Texture'GenFX.LensFlar.1')
	Particle_Size(0)=(ParticleDrawScale=0.250000)
	Particle_Size(1)=(ParticleDrawScale=0.250000)
	Particle_Size(2)=(ParticleDrawScale=0.250000)
	Particle_Size(3)=(ParticleDrawScale=0.250000)
	Particle_Fading(0)=(CanFadeOut=True,CanFadeIn=True)
	Particle_Fading(1)=(CanFadeOut=True,CanFadeIn=True)
	Particle_Fading(2)=(CanFadeOut=True,CanFadeIn=True)
	Particle_Fading(3)=(CanFadeOut=True,CanFadeIn=True)
	Particle_Physics(0)=(bCanAccelerate=True,AccelerateFactor=(X=-47.000000,Y=12.000000,Z=12.000000),TerminalVelocity=(X=-300.000000,Y=200.000000))
	Particle_Physics(1)=(bCanAccelerate=True,AccelerateFactor=(X=71.000000,Y=-24.000000),TerminalVelocity=(X=100.000000,Y=-234.000000))
	Particle_Physics(2)=(bCanAccelerate=True,AccelerateFactor=(X=-13.000000,Y=-34.000000),TerminalVelocity=(X=-400.000000,Y=-300.000000))
	Particle_Physics(3)=(bCanAccelerate=True,AccelerateFactor=(X=-74.000000,Y=42.000000),TerminalVelocity=(X=-400.000000,Y=15.000000))
	Particle_Collision(0)=(ParticlesUseCollision=True,ParticleCollideWorld=True,DestroyWhenColideWorld=True)
	Particle_Collision(1)=(ParticlesUseCollision=True,ParticleCollideWorld=True,DestroyWhenColideWorld=True)
	Particle_Collision(2)=(ParticlesUseCollision=True,ParticleCollideWorld=True,DestroyWhenTouch=True,DestroyWhenColideWorld=True,DestroyWhenLand=True)
	Particle_Collision(3)=(ParticlesUseCollision=True,ParticleCollideWorld=True,DestroyWhenColideWorld=True)
	Particle_Bounce(2)=(CanBounce=True,EndlessBounce=True)
	NumTemplates=4
	SelectionMethod=SELECT_Random
	BurstMethod=BURST_Random
	Intensity=18.000000
	EffectArea=(X=16.000000,Y=16.000000)
	LineOfSightCheck=True
	Physics=PHYS_Rotating
	Rotation=(Pitch=24432,Roll=-664)
	bFixedRotationDir=True
	RotationRate=(Pitch=6400,Yaw=6400,Roll=6400)
}
