class UISample1 extends UIParticleTest;

#exec obj load file=..\Textures\GenFX.utx package=GenFX

defaultproperties
{
	Particle_Main(0)=(bDefineSpeedAsVector=True,BaseSpeed=(X=100.000000,Y=-50.000000,Z=-120.000000),SpeedVariance=40.000000,ParticleSpeed=15.000000)
	Particle_Display(0)=(ParticleTexture=Texture'GenFX.LensFlar.1')
	Particle_Size(0)=(ParticleDrawScale=0.250000)
	Particle_Fading(0)=(CanFadeOut=True,CanFadeIn=True)
	Particle_Physics(0)=(bCanAccelerate=True,AccelerateFactor=(X=-87.000000,Y=152.000000,Z=52.000000),TerminalVelocity=(X=-200.000000,Y=500.000000,Z=240.000000))
	Particle_Collision(0)=(ParticlesUseCollision=False,ParticleCollideWorld=False,DestroyWhenColideWorld=False)
	NumTemplates=1
	SelectionMethod=SELECT_Random
	BurstMethod=BURST_Random
	Intensity=18.000000
	EffectArea=(X=16.000000,Y=16.000000)
	LineOfSightCheck=True
}
