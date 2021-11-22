//=============================================================================
// TransportVolume: Used to teleport all touching actors to a relative other location.
//=============================================================================
class TransportVolume extends Volume
	NoUserCreate;

var vector Offset;

var() Trigger.ETriggerType TeleportType;
var() class<Actor> ClassProximityType; // Class proximity to transport when TeleportType=TT_ClassProximity.
var() bool bTriggerToggle; // If not oneshot, triggering this actor multiple times will toggle if its active or not.
var() bool bOneShot; // If True, all toucing actors gets transported once only, if false, any future touchers gets instantly warped.
var() bool bTransportProjectiles; // Allow this to transport projectiles too.

function BeginPlay()
{
	local Actor A;

	bBlockZeroExtentTraces = bTransportProjectiles;
	
	foreach AllActors(class'Actor',A,Event)
	{
		Offset = A.Location - Location;
		break;
	}
}
function Reset()
{
	SetCollision(false);
}

function Trigger( actor Other, pawn EventInstigator )
{
	if( bTriggerToggle && bCollideActors )
	{
		SetCollision(false);
		return;
	}
	WarpTouchers();
	if( !bOneShot )
		SetCollision(true);
}

function WarpTouchers()
{
	local Actor A;
	local class<Actor> AClass;
	
	switch( TeleportType )
	{
	case TT_PlayerProximity:
	case TT_PawnProximity:
		AClass = Class'Pawn';
		break;
	case TT_ClassProximity:
		AClass = ClassProximityType;
		break;
	}
	if( AClass==None ) AClass = Class'Actor';
	
	foreach AllActors(AClass,A)
		if( Encompasses(A.Location) )
			Touch(A);
}

function Touch( Actor Other )
{
	if( Other.bStatic || !Other.bMovable || Other.bIsMover )
		return;
	switch( TeleportType )
	{
	case TT_PlayerProximity:
		if( !Other.bIsPawn || !Pawn(Other).bIsPlayer )
			return;
		break;
	case TT_PawnProximity:
		if( !Other.bIsPawn )
			return;
		break;
	case TT_ClassProximity:
		if( !ClassIsChildOf(Other.Class, ClassProximityType) )
			return;
		break;
	case TT_Shoot:
		if( !Other.bIsProjectile )
			return;
		break;
	}
	if( (!bTransportProjectiles && Other.bIsProjectile) || Triggers(Other)!=None || Info(Other)!=None || Keypoint(Other)!=None )
		return;

	Other.SetLocation(Other.Location + Offset);
}

event DrawEditorSelection( Canvas C )
{
	local Actor A;

	foreach AllActors(Class'Actor',A,Event)
	{
		C.Draw3DLine(MakeColor(255,0,255),Location,A.Location);
		break;
	}
}

defaultproperties
{
	bCollideActors=false
	bTransportProjectiles=true
	
	BrushColor=(R=239,G=228,B=176)
	CollisionFlag=COLLISIONFLAG_Triggers
	bEditorSelectRender=true
}