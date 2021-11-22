//=============================================================================
// SkyZoneInfo.
//=============================================================================
class SkyZoneInfo extends ZoneInfo
	native;

var() vector RelativeMovementSpeed; // 227j: Make this skybox move relative to your camera position.
var() vector RelativeOffset; // 227j: The absolute center offset of the player camera to world origin.

event DrawEditorSelection( Canvas C )
{
	if( RelativeMovementSpeed!=vect(0,0,0) )
	{
		C.Draw3DLine(MakeColor(255,255,64), RelativeOffset, Location);
		C.DrawBox(MakeColor(255,32,32), 0, RelativeOffset+vect(6,6,6), RelativeOffset-vect(6,6,6));
	}
}

defaultproperties
{
	bZoneBasedFog=true
	bEditorSelectRender=true
}
