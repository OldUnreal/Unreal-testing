// Drains lifespan from particles.
Class KillParticleForce extends XParticleForces
	Native
	clientonly;

#EXEC TEXTURE IMPORT FILE="Textures\S_KillForce.bmp" NAME="S_KillForce" GROUP="Icons" MIPS=off FLAGS=2 TEXFLAGS=0

var() float LifeTimeDrainAmount; // How much particle lifetime will this drain (in seconds).

defaultproperties
{
	LifeTimeDrainAmount=4
	Texture=Texture'S_KillForce'
}