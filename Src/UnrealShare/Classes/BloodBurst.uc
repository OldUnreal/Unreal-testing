//=============================================================================
// BloodBurst.
//=============================================================================
class BloodBurst extends Blood2;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim  ( 'Burst', 0.2 );
	SetRotation( RotRand() );
}

defaultproperties
{
	DrawScale=0.400000
	AmbientGlow=80
	bOwnerNoSee=true
}
