// Suck any nearby particles toward some point - Idea by Shadow
Class ParticleConcentrateForce extends XParticleForces
	Native
	clientonly;

#EXEC TEXTURE IMPORT FILE="Textures\S_SuckForce.bmp" NAME="S_ConcentrateForce" GROUP="Icons" MIPS=off FLAGS=2 TEXFLAGS=0

var() vector CenterPointOffset; // Sucking point center.
var() float DrainSpeed;
var() bool bSetsAcceleration; // Sets acceleration instead of adding to velocity on particles.
var(ParticleDistanceDrain) bool bActorDistanceSuckIn; // The closer actor is, than higher speed it gets.
var(ParticleDistanceDrain) float MaxDistance; // The maximum distance (beyond this distance it wont have any effect on the particle)

defaultproperties
{
	DrainSpeed=200
	Texture=Texture'S_ConcentrateForce'
}