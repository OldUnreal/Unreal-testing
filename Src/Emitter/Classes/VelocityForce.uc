// Adds velocity to particles.
Class VelocityForce extends XParticleForces
	Native
	clientonly;

#EXEC TEXTURE IMPORT FILE="Textures\S_VelForce.bmp" NAME="S_VelocityForce" GROUP="Icons" MIPS=off FLAGS=2 TEXFLAGS=0

var() vector VelocityToAdd;

// Bitmask
var() bool bChangeAcceleration; // Change acceleration instead of velocity.
var() bool bInstantChange; // Should instantly change the velocity/acceleration to this speed or just add it to current.

defaultproperties
{
	Texture=Texture'S_VelocityForce'
}