class FadeShadow expands Decal;

#exec TEXTURE IMPORT NAME=fshadow FILE=Textures\Decals\shadow_2.pcx LODSET=2 ALPHATRICK=1

var Actor LightSource;
var Vector OldOwnerLocation;

function AttachToSurface()
{
}

function Destroyed()
{
	Super.Destroyed();

	//if ( PlayerShadow(Owner) != None )
	//	PlayerShadow(Owner).FadeShadow = None;
}

function Tick(float DeltaTime)
{
	local Actor HitActor;
	local Vector HitNormal,HitLocation, ShadowStart, ShadowDir;

	if ( (Owner == None) || (Owner.Owner == None) )
	{
		Destroy();
		return;
	}

	ScaleGlow -= DeltaTime;

	if ( OldOwnerLocation == Owner.Owner.Location )
		return;
	OldOwnerLocation = Owner.Owner.Location;

	DetachDecal();

	if ( Owner.Owner.bHidden || (Owner.Owner.Mesh == None) )
	{
		Destroy();
		return;
	}

	if ( ScaleGlow < 0.05 )
	{
		Destroy();
		return;
	}
	if ( LightSource == None )
		return;

	ShadowDir = Normal(Owner.Owner.Location - LightSource.Location);

	if ( ShadowDir.Z > 0 )
		ShadowDir.Z *= -1;

	ShadowStart = Owner.Owner.Location + Owner.Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0,0,300), ShadowStart, false);

	if ( HitActor == None )
		return;

	SetLocation(HitLocation, rotator(HitNormal));
	AttachDecal(10, ShadowDir);
}

defaultproperties
{
	MultiDecalLevel=3
	DrawScale=+0.65
	Texture=texture'Unrealshare.fshadow'
	LifeSpan=+1.0
	ScaleGlow=+1.0
}
