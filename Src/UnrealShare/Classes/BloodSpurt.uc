//=============================================================================
// BloodSpurt.
//=============================================================================
class BloodSpurt extends Blood2;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim  ( 'GravSpray2', 0.9 );
}

defaultproperties
{
	DrawScale=0.200000
	ScaleGlow=1.300000
	AmbientGlow=0
}
