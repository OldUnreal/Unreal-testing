//=============================================================================
// TransitionDecoration.
//=============================================================================
class TransitionDecoration expands Decoration;

auto state Started
{
	function BeginState()
	{
	}

Begin:
	FinishANim();
	PlayAnim( 'CockGun', 0.3 );
	FinishAnim();
	PlayAnim( 'PistolWhip', 0.3 );
	FinishAnim();
	LoopAnim( 'Breath2', 0.3 );
	Sleep( Rand( 4 ) + FRand() );
	FinishAnim();
	PlayAnim( 'StillLook', 0.3 );
	FinishAnim();
	PlayAnim( 'Punch', 0.3 );
	LoopAnim( 'Breath2', 0.3 );
	Sleep( Rand( 4 ) + FRand() );
	Goto( 'Begin' );
}

defaultproperties
{
     bStatic=False
     bStasis=False
     AnimSequence=CockGun
     AnimRate=0.300000
     DrawType=DT_Mesh
     Texture=Texture'UnrealShare.GoldSkin'
     Mesh=LodMesh'UnrealShare.Brute1'
     AmbientGlow=70
     bUnlit=True
     bMeshEnviroMap=True
     CollisionRadius=52.000000
     CollisionHeight=52.000000
     bCollideWorld=True
     LightType=LT_Flicker
     LightBrightness=255
     LightHue=170
     LightSaturation=96
     LightRadius=32
}
