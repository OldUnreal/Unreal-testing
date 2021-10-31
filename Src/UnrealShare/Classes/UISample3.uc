class UISample3 extends UIParticleTest;

#exec obj load file=..\Textures\GenFX.utx package=GenFX

defaultproperties
{
	Particle_Main(0)=(bDefineSpeedAsVector=False,ParticleLifeTime=15.000000,SpeedVariance=40.000000,ParticleSpeed=55.000000)
	Particle_Display(0)=(ParticleTexture=Texture'GenFX.LensFlar.1')
	Particle_Size(0)=(ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.120020,ParticleShrink=-0.120020,SizeType=ST_Cycle)
	Particle_Fading(0)=(CanFadeOut=True,CanFadeIn=True)
	Particle_Physics(0)=(bCanAccelerate=False)
	Particle_Collision(0)=(ParticlesUseCollision=False,ParticleCollideWorld=False,DestroyWhenColideWorld=False)
	NumTemplates=1
	SelectionMethod=SELECT_Random
	BurstMethod=BURST_Random
	Intensity=18.000000
	EffectArea=(X=160.000000,Y=16.000000,Z=160)
	LineOfSightCheck=False
}
