class PawnShadowX extends Projector
	NoUserCreate
	transient;

var transient vector OldOwnerLocation;
var transient bool bOptionalUpdate;
var transient ShadowBitMap PLShadow;

simulated function PostBeginPlay()
{
	SetRotation(rotang(-90,0,0));
}

simulated function BeginPlay()
{
	Super.BeginPlay();
	ShadowModeChange();
}

simulated final function bool IsViewActor()
{
	local PlayerPawn P;

	P = GetLocalPlayerPawn();
	return (P!=None && (P.ViewTarget==Owner || P==Owner));
}

simulated event Tick( float Delta )
{
	UpdateShadow();
}

simulated function UpdateShadow()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation, ShadowStart;
	local float Distance;
	local bool bInvisible, bHitMovingBrush;

	if ( Owner==None || Owner.bDeleteMe )
	{
		Destroy();
		Return;
	}

	if( (Level.TimeSeconds-FMax(LastRenderedTime,Owner.LastRenderedTime))>1.f && !IsViewActor() )
	{
		if( bHasAttached )
		{
			DeattachPrjDecal();
			bOptionalUpdate = false;
		}
		return;
	}

	if( Owner.Style==STY_Translucent || Owner.bHidden || Owner.DrawType==DT_None || !Owner.Mesh )
	{
		if (bHasAttached)
			DeattachPrjDecal();
		bOptionalUpdate = false;
		return;
	}

	if( class'PawnShadow'.default.bOptimizeTracing && bOptionalUpdate && Owner.Location == OldOwnerLocation )
		return;

	OldOwnerLocation = Owner.Location;
	if (bHasAttached)
		DeattachPrjDecal();

	ShadowStart = Owner.Location;
	ShadowStart.Z-=(Owner.CollisionHeight-5);
	if( PLShadow )
		Distance = 200.f;
	else Distance = 500.f;
	
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0, 0, 1)*Distance, ShadowStart, false, vect(0.9, 0.9, 0) * Owner.CollisionRadius);

	if( !HitActor )
	{
		bOptionalUpdate = true;
		return;
	}

	Distance = FMax(Owner.Location.Z - Owner.CollisionHeight - HitLocation.Z, 0.f) / Distance;

	if( PLShadow )
	{
		ProjectorScale = FMax(Owner.CollisionRadius, 16.f) * (12.f / class'PawnShadow'.default.ShadowDetailRes);
		PLShadow.ShadowScale = 0.75 / ProjectorScale;
		PLShadow.Gradience = Min((Distance*155.f) + 100, 255);
		if (PLShadow.Gradience == 255)
			bInvisible = true;
	}
	else
	{
		ProjectorScale = Owner.CollisionRadius/35.f * class'PawnShadow'.default.ShadowScaling * (1.f - Distance);
		if (ProjectorScale <= 0)
			bInvisible = true;
	}

	HitLocation += vect(0, 0, 20);
	bHitMovingBrush = HitActor.bIsMover && HitActor.Brush != none;
	bOptionalUpdate = Location == HitLocation && !bHitMovingBrush;

	SetLocation(HitLocation);

	if (bInvisible)
		return;
	AttachPrjDecal();
	
	if (HitActor != Level && !bHitMovingBrush)
		AttachActor(HitActor);
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
			PLShadow.StaticLevel = 0;
		}
		PLShadow.SetShadowRes(class'PawnShadow'.default.ShadowDetailRes, class'PawnShadow'.default.ShadowDetailRes);
		PLShadow.Softness = class'PawnShadow'.static.GetShadowSoftness();
	}
	else if( PLShadow )
	{
		PLShadow.SetActor(None);
		Level.FreeObject(PLShadow);
		PLShadow = none;
		ProjectTexture = default.ProjectTexture;
	}
	VisibilityRadius = Default.VisibilityRadius * Class'ObjectShadow'.Default.OcclusionDistance;
	
	OldOwnerLocation = vect(1,2,3);
	bOptionalUpdate = false;
	UpdateShadow();
	bOptionalUpdate = false;
}

defaultproperties
{
	ProjectTexture=Texture'BlobShadow'
	DrawScale=0.50
	RemoteRole=ROLE_None
	ProjectStyle=STY_None
	bCollideActors=false
	MaxDistance=155.0
	VisibilityRadius=1200
}