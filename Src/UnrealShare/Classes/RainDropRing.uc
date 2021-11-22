//=============================================================================
// RainDropRing.
//=============================================================================
class RainDropRing extends RainDropComponents;

defaultproperties
{
	Particle_Main(0)=(ParticleLifeTime=1.250000,ParticleLifeTimeVariance=0.000000)
	Particle_Display(0)=(bUnlitParticle=True,bUseMesh=True,PraticleMesh=Mesh'UnrealShare.UIpWaterRing',ParticleTexture=Texture'UnrealShare.UIpWaterRingSkin')
	Particle_Size(0)=(ParticleDrawScale=0.005000,ParticleDrawScaleVariance=0.001250,ParticleGrowth=0.003500,SizeType=ST_Grow,MinSize=0.000000,MaxSize=0.000000)
	Particle_Fading(0)=(CanFadeOut=True,FadeOutTime=1.000000,FadeOutScaleFactor=0.150000,FadeInTime=0.000000,FadeInScaleFactor=0.000000)
	Particle_Physics(0)=(ParticlePhysics=PHYS_None)
	Particle_Collision(0)=(ParticleCollisonRadius=0.000000,ParticleCollisonHeight=0.000000,StickToWall=True)
	Particle_Bounce(0)=(BounceRatio=0.000000,BounceModifier=0.000000,BounceNum=0)
	Particle_Buoyance(0)=(ParticleBuoyancy=0.000000,ParticleMass=0.000000)
	Particle_Mesh(0)=(FaceObject=FACE_Velocity)
	NumTemplates=1
	NewIntervall=1.000000
	NewIntensity=0.000000
	Intervall=0.005000
	ParticlesLimit=1
	ParticleProjForward=0.000000
	BeforeDieSleep=0.500000
	WaitPause=0.500000
}
