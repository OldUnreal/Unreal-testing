class DecoShadowStatic extends Projector
	NoUserCreate
	transient;

var bool bOptionalUpdate;
var transient ShadowBitMap PLShadow;

simulated function PostBeginPlay();

simulated function BeginPlay()
{
	Super.BeginPlay();
	ShadowModeChange();
}

simulated function Tick( float Delta )
{
	UpdateShadow();
	//if (bOptionalUpdate && !bDeleteMe) - Marco: Optional update lags the fuck out of maps like SkaarjTower/SkaarjCastle.
		Disable('Tick');
}

simulated function UpdateShadow()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation, ShadowStart;
	local float Distance;
	local bool bInvisible;

	if ( !Owner || Owner.bDeleteMe)
	{
		Destroy();
		Return;
	}

	DeattachPrjDecal();
	SetRotation(rotang(-90,0,0));
	ShadowStart = Owner.Location;
	ShadowStart.Z-=(Owner.CollisionHeight-5);
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0, 0, 200), Location, false, vect(0.8,0.8,0)*Owner.CollisionRadius);

	if( !HitActor )
	{
		Destroy();
		return;
	}

	Distance = FMax(Owner.Location.Z - Owner.CollisionHeight - HitLocation.Z, 0.f);

	if( PLShadow )
	{
		ProjectorScale = FMax(Owner.CollisionRadius, 18.f) * (16.f / class'DecoShadow'.default.ShadowDetailRes);
		PLShadow.ShadowScale = 0.75 / ProjectorScale;
		PLShadow.Gradience = Min(Distance + 100, 255);
		if (PLShadow.Gradience == 255)
			bInvisible = true;
	}
	else
	{
		ProjectorScale = 0.75 * Owner.CollisionRadius/70.f * class'DecoShadow'.default.ShadowScaling *
			(1.f - Distance / FMin(2 * Owner.CollisionRadius, 155.0));
		if (ProjectorScale <= 0)
			bInvisible = true;
	}

	bOptionalUpdate =
		bOptionalUpdate &&
		class'DecoShadow'.default.bOptimizeTracing &&
		(!HitActor.bIsMover || HitActor.Brush == none);

	SetLocation(HitLocation + vect(0, 0, 20));
	if (!bInvisible)
		AttachPrjDecal();
}

simulated function Destroyed()
{
	if( PLShadow!=None )
	{
		PLShadow.SetActor(None);
		Level.FreeObject(PLShadow);
		PLShadow = None;
	}
	Super.Destroyed();
}

simulated function Touch( Actor Other )
{
	if( bProjectActors && !Other.bHidden && Other.DrawType==DT_Mesh && Other.Mesh!=None && Other!=Owner )
		AttachActor(Other);
}

simulated function ShadowModeChange()
{
	if( class'GameInfo'.default.bUseRealtimeShadow )
	{
		if( !PLShadow )
		{
			PLShadow = Level.AllocateObj(Class'ShadowBitMap');
			PLShadow.SetActor(Owner);
			PLShadow.ProjectDirection = rotang(90,0,0);
			ProjectTexture = PLShadow;
			PLShadow.StaticLevel = 1;
		}
		PLShadow.SetShadowRes(class'DecoShadow'.default.ShadowDetailRes, class'DecoShadow'.default.ShadowDetailRes);
		PLShadow.Softness = class'DecoShadow'.static.GetShadowSoftness();
	}
	else if( PLShadow )
	{
		PLShadow.SetActor(None);
		Level.FreeObject(PLShadow);
		PLShadow = none;
		ProjectTexture = default.ProjectTexture;
	}
	VisibilityRadius = Default.VisibilityRadius * Class'ObjectShadow'.Default.OcclusionDistance;
	
	bOptionalUpdate = false;
	UpdateShadow();
	bOptionalUpdate = false;
}

defaultproperties
{
	ProjectTexture=Texture'BlobShadow'
	ProjectorScale=0.50
	ProjectStyle=STY_None
	bCollideActors=false
	bOptionalUpdate=true
	bBuildStaticMap=true
	VisibilityRadius=3000
}