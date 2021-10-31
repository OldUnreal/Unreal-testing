//=============================================================================
// Projectile blast projector based decals.
//=============================================================================
Class DecalProjector extends Projector
	Transient;

var bool bStartedLife;
var(Decal) GlobalConfig Float DecalLifeSpan;

simulated function PostBeginPlay();

simulated final function AttachDecalOf( class<Decal> DClass )
{
	ProjectorScale = DClass.Default.DrawScale*0.5f;
	ProjectTexture = DClass.Default.Texture;
	ProjectStyle = DClass.Default.Style;
	AttachPrjDecal();
	if (DecalLifeSpan<0)
 		SetTimer(1.0, false); //Default
 	else LifeSpan = fmax(0,DecalLifeSpan);
}

simulated function Timer()
{
	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
		if ( Level.bDropDetail )
			SetTimer(5.0 + 2 * FRand(), false);
		else
			SetTimer(18.0 + 5 * FRand(), false);
		return;
	}
	if ( Level.bDropDetail )
	{
		if ( (Level.TimeSeconds - LastRenderedTime > 0.35) || (FRand() < 0.2) )
			Destroy();
		else SetTimer(1.0, false);
	}
	else if ( (Level.TimeSeconds - LastRenderedTime)<1 )
		SetTimer(5.0, false);
	else Destroy();
}

simulated function Touch( Actor Other )
{
	if( !Other.bHidden && Other.DrawType==DT_Mesh && Other.Mesh!=None && (Other.bStatic || Other.bNoDelete) )
		AttachActor(Other);
}

defaultproperties
{
	DecalLifeSpan=-1.0
	MaxDistance=60
}