//========================================================
// Unreal Procedural Mesh
// Written by Marco
//========================================================
Class ProceduralMesh extends FluidInfo
	Native;

var pointer<class UProcPrimitive*> ProcData;

var() Mesh SourceModel;
var() float	Dampening; // should be less than < 1.0f
var() float MovementClamp[2]; // Limit of movement
var() float ForceClamp[2]; // Pling force limitator
var() float ForceAttenuation; // Pling force multiplier
var() float Noise; // Noise force multiplier
var() float NoiseForce[2]; // Noise force range
var() float NoiseTimer[2]; // Frequency of noise
var transient float NoiseCounter;
var() enum EProcMeshType
{
	MT_Water, // Wave only along surface normal axis (faster).
	MT_Deform, // Wave freely (slower).
} ProcType;
var() bool bAnimate; // Allow mesh to animate freely.

// Reset the fluid model with new parms etc...
native final function ResetModel();

// support fluid funcs
// Ripple water at a particlar location.
native final function ProcPling(vector Position, vector Strength, float Radius );

simulated function bool Footstep( Pawn Other )
{
	local vector V;

	if( (Level.TimeSeconds-LastRenderedTime)<1.f ) // Make sure its recently rendered.
	{
		V = Other.Location;
		V.Z = Location.Z;
		ProcPling(V,vect(0,0,-7)+Other.Velocity*0.07,Other.CollisionRadius*0.8);
	}
	return false;
}

simulated function Touch( Actor Other )
{
	local float Str;

	if( (Level.TimeSeconds-LastRenderedTime)>1.f ) // Make sure its recently rendered.
		return;
	if( Other.bIsPawn )
		Str = Other.Mass*0.0008f;
	else Str = 0.02f;
	ProcPling(Other.Location,Other.Velocity*Str,FMax(Other.CollisionRadius,5.f)*2.f);
}

defaultproperties
{
	bHidden=False
	bNoDelete=True
	DrawType=DT_Mesh
	RemoteRole=ROLE_None
	bUseMeshCollision=True
	bCollideActors=True

	Dampening=0.5
	MovementClamp(0)=-50.0
	MovementClamp(1)=50.0
	ForceClamp(0)=-4.0
	ForceClamp(1)=4.0
	Noise=1
	NoiseForce(0)=-1.0
	NoiseForce(1)=1.0
	NoiseTimer(0)=0.05
	NoiseTimer(1)=0.15
	ProcType=MT_Water
	ForceAttenuation=0.4
}