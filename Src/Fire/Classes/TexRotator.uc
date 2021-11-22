// Rotate a texture.
// Written by .:..:
Class TexRotator extends TexModifier
	Native;

enum ETexRotationType
{
	TR_FixedRotation,
	TR_ConstantlyRotating,
	TR_OscillatingRotation
};
var(Material) ETexRotationType TexRotationType;
var(Material) float Rotation; // Constant/rotationrate
var(Material) float UOffset; // Rotation center offset
var(Material) float VOffset;
var(Material) float OscillationRate; // Speed of oscillation
var(Material) float OscillationAmplitude; // Size of oscillation
var transient const bool bWasFixedRot;
var transient float CurrentAngle;
var transient int RenderAngle;

defaultproperties
{
	TexRotationType=TR_FixedRotation
}
