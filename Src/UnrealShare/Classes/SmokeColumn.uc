//=============================================================================
// SmokeColumn.
//=============================================================================
class SmokeColumn extends AnimSpriteEffect
	transient;

#exec OBJ LOAD FILE=Textures\SmokeCol.utx PACKAGE=UnrealShare.SmokeColm

defaultproperties
{
	NumFrames=16
	Pause=0.070000
	i=1
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.000000
	DrawType=DT_SpriteAnimOnce
	Style=STY_Translucent
	Texture=Texture'UnrealShare.SmokeColm.sc_a00'
	DrawScale=1.300000
	bMeshCurvy=False
	LightType=LT_None
	bCorona=False
}
