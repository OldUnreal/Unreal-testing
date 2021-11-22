// Pan a texture.
// Written by .:..:
Class TexOscillator extends TexModifier
	Native;

enum ETexOscillationType
{
	OT_Pan,
	OT_Stretch
};
var(Material) Float UOscillationRate;
var(Material) Float VOscillationRate;
var(Material) Float UOscillationAmplitude;
var(Material) Float VOscillationAmplitude;
var(Material) ETexOscillationType UOscillationType;
var(Material) ETexOscillationType VOscillationType;
var(Material) float UOffset;
var(Material) float VOffset;
var(Material) float UStretchOffset;
var(Material) float VStretchOffset;

var transient float LastSu,ScalerU;
var transient float LastSv,ScalerV;

defaultproperties
{
	UOscillationAmplitude=0.1
	VOscillationAmplitude=0.1
	UOscillationRate=1
	VOscillationRate=1
}
