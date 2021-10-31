//=============================================================================
// ShieldBeltEffect.
//=============================================================================
class ShieldBeltEffect extends Effects
	NoUserCreate;

var Texture LowDetailTexture;

simulated function Destroyed()
{
	if ( Level.NetMode!=NM_Client && Owner!=None && !Owner.bDeleteMe )
		Owner.SetDefaultDisplayProperties();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if ( !Level.bHighDetailMode && ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_Client)) )
	{
		Timer();
		bHidden = true;
		SetTimer(1.0, true);
	}
}

simulated function Timer()
{
	bHidden = true;
	Owner.SetDisplayProperties(Owner.Style, LowDetailTexture, false, true);
}

simulated function Tick(float DeltaTime)
{
	if ( Level.NetMode==NM_DedicatedServer )
	{
		Disable('Tick');
		Return;
	}
	if ( Fatness>Default.Fatness )
		Fatness = Max(Default.Fatness, Fatness - 130 * DeltaTime );
	if ( Owner!=None )
	{
		bHidden = Owner.bHidden;
		PrePivot = Owner.PrePivot;
		DrawScale = Owner.DrawScale;
	}
}

defaultproperties
{
	LowDetailTexture=Texture'GoldSkin'
	bAnimByOwner=True
	bNetTemporary=False
	bTrailerSameRotation=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=None
	ScaleGlow=0.50
	AmbientGlow=64
	Fatness=157
	bUnlit=True
	bMeshEnviroMap=True
	bOwnerNoSee=True
	bCarriedItem=True
}
