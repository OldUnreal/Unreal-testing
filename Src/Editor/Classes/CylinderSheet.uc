 //=============================================================================
// UnrealExCylinderSheet.
//=============================================================================
class CylinderSheet extends BrushBuilder;

#exec Texture Import File=Textures\BBCylinderSheet.pcx Name=BB_CylinderSheet Mips=Off Flags=2

var() float Radius;
var() int Sides;
var() bool AlignToSide;

var() enum ESheetAxis
{
	AX_Horizontal,
	AX_XAxis,
	AX_YAxis,
} Axis;
var() name GroupName;

event bool Build()
{
	local int i, Ofs;
	local float NewRadius;

	if( Radius<=0 || Sides<=2 )
		return BadParameters();

	NewRadius = Radius;
	if( AlignToSide )
	{
		NewRadius /= cos(pi/Sides);
		Ofs = 1;
	}

	BeginBrush( false, GroupName );
	if( Axis==AX_Horizontal )
	{
		for( i=0; i<Sides; i++ )
			Vertex3f( NewRadius*sin((2*i+Ofs)*pi/Sides), NewRadius*cos((2*i+Ofs)*pi/Sides), 0);
	}
	else if( Axis==AX_XAxis )
	{
		for( i=0; i<Sides; i++ )
			Vertex3f(0, NewRadius*sin((2*i+Ofs)*pi/Sides), NewRadius*cos((2*i+Ofs)*pi/Sides));
	}
	else
	{
		for( i=0; i<Sides; i++ )
			Vertex3f( NewRadius*sin((2*i+Ofs)*pi/Sides), 0, NewRadius*cos((2*i+Ofs)*pi/Sides));
	}

	PolyBegin( Sides, 'Sheet',0x00000108 );

	for( i=0; i<Sides; i++ )
		Polyi( i );

	PolyEnd();

	return EndBrush();
}

defaultproperties
{
	Radius=256.000000
	Sides=8
	AlignToSide=True
	GroupName="CylinderSheet"
	BitmapImage=Texture'BB_CylinderSheet'
	ToolTip="CylinderSheet"
}