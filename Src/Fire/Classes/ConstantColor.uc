// A single colored bitmap.
class ConstantColor extends Texture
	native;

var(Color) const Color Color1;

native final function SetColor( Color NewColor, optional Color NewColor2 ); // NewColor2 is only used by FadeColor.

defaultproperties
{
	Color1=(R=255,G=255,B=255,A=255)
	bParametric=true
	bFractical=true
	Format=TEXF_P8
	UBits=0
	VBits=0
	USize=1
	VSize=1
	UClamp=1
	VClamp=1
}