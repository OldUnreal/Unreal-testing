//=============================================================================
// InterpolationPoint.
//=============================================================================
class InterpolationPoint extends Keypoint
			native;

// Sprite.
#exec Texture Import File=Textures\IntrpPnt.pcx Name=S_Interp Mips=Off Flags=2

// Number in sequence sharing this tag.
var() int    Position;
var() float  RateModifier;
var() float  GameSpeedModifier;
var() float  FovModifier;
var() bool   bEndOfPath;
var() bool   bSkipNextPath;
var() float  ScreenFlashScale;
var() vector ScreenFlashFog;

// Other points in this interpolation path.
var noedsave InterpolationPoint Prev, Next;

//
// At start of gameplay, link all matching interpolation points together.
//
simulated function BeginPlay()
{
	Super.BeginPlay();

	LinkInterpolation();
}

// Called on editor aswell when you preview path.
simulated event LinkInterpolation()
{
	// Try to find previous.
	foreach AllActors( class 'InterpolationPoint', Prev, Tag )
		if ( Prev.Position == Position-1 )
			break;
	if( Prev )
		Prev.Next = Self;

	// Try to find next.
	foreach AllActors( class 'InterpolationPoint', Next, Tag )
		if ( Next.Position == Position+1 )
			break;
	if( !Next )
		foreach AllActors( class 'InterpolationPoint', Next, Tag )
			if ( Next.Position == 0 )
				break;
	if( Next )
		Next.Prev = Self;
}

//
// Verify that we're linked up.
//
function PostBeginPlay()
{
	Super.PostBeginPlay();
	//log( "Interpolation point" @ Tag @ Position $ ":" );
	//if( Prev != None )
	//	log( "   Prev # " $ Prev.Position );
	//if( Next != None )
	//	log( "   Next # " $ Next.Position );
}

//
// When reach an interpolation point.
//
simulated function InterpolateEnd( actor Other )
{
	if( bEndOfPath )
		Other.InterpolationEnded();
}

defaultproperties
{
	RateModifier=1
	GameSpeedModifier=1
	FovModifier=1
	bStatic=False
	bDirectional=True
	Texture=S_Interp
	bEndOfPath=False
	bSkipNextPath=False
	ScreenFlashScale=1
	ScreenFlashFog=(X=0,Y=0,Z=0)
	RemoteRole=ROLE_None
	bNoDelete=True
}
