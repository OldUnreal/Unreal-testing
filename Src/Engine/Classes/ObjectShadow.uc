class ObjectShadow extends Decal
	Config(User)
	Abstract
	transient;

#exec TEXTURE IMPORT NAME=BlobShadow FILE=Textures\BlobShadow.pcx LODSET=2 FLAGS=MODULATED

var() globalconfig float OcclusionDistance; // 0 = no limit, 0.5 = half the distance, 2 = double distance etc...
var() config int ShadowDetailRes; // Must be a value in power of 2
var() config bool bOptimizeTracing;
var() float ShadowScaling;
var bool bUseDefaultCollisionSize;
var transient vector OldOwnerLocation;
var transient bool bOptionalUpdate;
var transient ShadowBitMap PLShadow;

simulated function BeginPlay()
{
	Super.BeginPlay();
	ShadowModeChange();
}

function AttachToSurface();

function Timer();

simulated event Tick( float Delta )
{
	UpdateShadow();
}

simulated function UpdateShadow()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation, ShadowStart;
	local float Distance;
	local bool bInvisible;

	if( !Owner || Owner.bDeleteMe )
	{
		Destroy();
		Return;
	}

	if( Owner.Style==STY_Translucent || Owner.bHidden || Owner.DrawType==DT_None || !Owner.Mesh )
	{
		DetachDecal();
		bOptionalUpdate = false;
		return;
	}

	if (bOptimizeTracing && bOptionalUpdate && Owner.Location == OldOwnerLocation )
		return;

	OldOwnerLocation = Owner.Location;
	DetachDecal();

	ShadowStart = Owner.Location;
	ShadowStart.Z-=(Owner.CollisionHeight-5);
	if( PLShadow )
		Distance = 200.f;
	else Distance = 500.f;
	
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0, 0, 1)*Distance, ShadowStart, false);

	if( !HitActor )
	{
		bOptionalUpdate = true;
		return;
	}

	Distance = FMax(Owner.Location.Z - Owner.CollisionHeight - HitLocation.Z, 0.f) / Distance;

	if( PLShadow )
	{
		DrawScale = FMax(bUseDefaultCollisionSize ? Owner.Default.CollisionRadius : Owner.CollisionRadius, 16.f) * (12.f / ShadowDetailRes);
		PLShadow.ShadowScale = 1.f / DrawScale;
		PLShadow.Gradience = Min((Distance*155.f) + 100, 255);
		if (PLShadow.Gradience == 255)
			bInvisible = true;
	}
	else
	{
		DrawScale = (bUseDefaultCollisionSize ? Owner.Default.CollisionRadius : Owner.CollisionRadius)/35.f * ShadowScaling * (1.f - Distance);
		if (DrawScale <= 0)
			bInvisible = true;
	}

	HitLocation += HitNormal;
	bOptionalUpdate = Location == HitLocation && (!HitActor.bIsMover || HitActor.Brush == none);

	SetLocation(HitLocation, rotator(HitNormal));
	if (!bInvisible)
		AttachDecal(30, vect(1,0,0));
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

simulated static final function byte GetShadowSoftness()
{
	if( Default.ShadowDetailRes<=64 )
		return 0;
	switch( Default.ShadowDetailRes )
	{
	case 128:
		return 1;
	case 256:
		return 2;
	case 512:
		return 3;
	default:
		return 4;
	}
}

static function UpdateAllShadows(LevelInfo Level, optional bool bUpdateDetail)
{
	local Actor A;
	
	foreach Level.AllActors(class'Actor',A,,,true)
		A.ShadowModeChange();
}

simulated function ShadowModeChange()
{
	OldOwnerLocation = vect(1,2,3);
	
	if( class'GameInfo'.default.bUseRealtimeShadow )
	{
		if( !PLShadow )
		{
			PLShadow = Level.AllocateObj(Class'ShadowBitMap');
			PLShadow.SetActor(Owner);
			PLShadow.ProjectDirection = rotang(90,0,0);
			Texture = PLShadow;
			PLShadow.StaticLevel = 0;
		}
		PLShadow.SetShadowRes(Default.ShadowDetailRes, Default.ShadowDetailRes);
		PLShadow.Softness = GetShadowSoftness();
	}
	else if( PLShadow )
	{
		PLShadow.SetActor(None);
		Level.FreeObject(PLShadow);
		PLShadow = none;
		Texture = default.Texture;
	}
	VisibilityRadius = Default.VisibilityRadius * Class'ObjectShadow'.Default.OcclusionDistance;
	
	bOptionalUpdate = false;
	UpdateShadow();
	bOptionalUpdate = false;
}

defaultproperties
{
	MultiDecalLevel=3
	Texture=Texture'BlobShadow'
	DrawScale=0.50
	ShadowScaling=1
	bAttachPanningSurfs=True
	ShadowDetailRes=128
	bOptimizeTracing=True
	bNoDecalProjector=true
	VisibilityRadius=1500
	Style=STY_None
	OcclusionDistance=1
}