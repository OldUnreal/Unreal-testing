// Simple text label component.
Class EdGUI_Label extends EdGUI_Component
	native;

cpptext
{
	UEdGUI_Label() {}
	void Init();
	void Close(UBOOL bRemoved = 0);
}

var() string Caption;
var() color TextColor;
var() byte AlignX,AlignY; // Alignment, 0 = left/top, 1 = center, 2 = right/bottom
var() bool bMultiLine;

defaultproperties
{
	TextColor=(R=0,G=0,B=0,A=255)
}