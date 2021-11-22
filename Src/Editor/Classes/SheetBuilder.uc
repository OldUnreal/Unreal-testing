//=============================================================================
// SheetBuilder: Builds a simple sheet.
//=============================================================================
class SheetBuilder extends BrushBuilder;

#exec Texture Import File=Textures\BBSheet.pcx Name=BB_Sheet Mips=Off Flags=2

var() float Height, Width;
var() enum ESheetAxis
{
	AX_Horizontal,
	AX_XAxis,
	AX_YAxis,
} Axis;
var() name GroupName;

event bool Build()
{
	if ( Height<=0 || Width<=0 )
		return BadParameters();

	BeginBrush( false, GroupName );
	if ( Axis==AX_Horizontal )
	{
		Vertex3f(  Width/2,  Height/2, 0 );
		Vertex3f(  Width/2, -Height/2, 0 );
		Vertex3f( -Width/2, -Height/2, 0 );
		Vertex3f( -Width/2,  Height/2, 0 );
	}
	else if ( Axis==AX_XAxis )
	{
		Vertex3f( 0,  Width/2,  Height/2 );
		Vertex3f( 0,  Width/2, -Height/2 );
		Vertex3f( 0, -Width/2, -Height/2 );
		Vertex3f( 0, -Width/2,  Height/2 );
	}
	else
	{
		Vertex3f(  Width/2, 0,  Height/2 );
		Vertex3f( -Width/2, 0,  Height/2 );
		Vertex3f( -Width/2, 0, -Height/2 );
		Vertex3f(  Width/2, 0, -Height/2 );
	}
	Poly4i(+1,0,1,2,3,'Sheet',0x00000108); // PF_TwoSided|PF_NotSolid.
	return EndBrush();
}

defaultproperties
{
	Height=256
	Width=256
	Axis=SHEETAXIS_FloorCeiling
	GroupName=Sheet
	BitmapImage=Texture'BB_Sheet'
	ToolTip="Sheet"
}