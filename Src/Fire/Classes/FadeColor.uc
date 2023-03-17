// Fade between 2 different colors.
Class FadeColor extends ConstantColor
	native;

enum EColorFadeType
{
	FC_Linear,
	FC_Sinusoidal,
};

var(Color) const Color Color2;
var(Color) float FadePeriod;
var(Color) float FadePhase;
var(Color) EColorFadeType ColorFadeType;

var transient float CurrentTime, CurrentValue; // Range 0 - 1 (Color1 vs Color2)
var bool bPaused; // Don't have engine update CurrentValue.

defaultproperties
{
	ColorFadeType=FC_Linear
	Color2=(A=255)
	FadePeriod=1
}