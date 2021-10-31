//========================================================
// Water fluid surface, created by Marco
//========================================================
Class FluidSurfaceInfo extends FluidInfo
	Native;

var pointer<class UFluidPrimitive*> FluidData;
var transient float PockTimer;

struct MeshVertConnect
{
	var const int N;
	var const int O;
};
var native const array<MeshVertConnect> Connects;
var native const array<int> VertLinks;
var native const int InitSize;
var transient const array<byte> ClampedVerts;
var transient array<FluidSurfaceOscillator> Oscillators;
var pointer<struct FFluidSurfaceWorker*> ThreadProc;
var StaticLightData StaticLightD;

var() byte SizeX,SizeY;
var() float XGridSpace,YGridSpace,WaveDamping,WaveRippleRate,FluidSpeedScale,WaveRippletSize,WaveRippletRadius;
var() float XOffset,YOffset,TexXSize,TexYSize; // Texture coordinates and scaling
var() float ZHeight[2]; // Max/Min Z height difference
var() float NoRenderZHeight; // With bUseNoRenderZ enabled, hide the mesh when camera is lower than this point.
var() bool bRenderTwoSided,bSquaredModel,bBSPClampsFluid,bUseNoRenderZ,bComputeLightVis;

var const bool bConnectsInit;

// Reset the fluid model with new size parms etc...
native final function ResetModel();

// Make an impact effect on waves (Position always ignored by Z axis).
native final function PockWaves( vector Pos, float Size, float Depth );

simulated function bool Footstep( Pawn Other )
{
	if( (Level.TimeSeconds-LastRenderedTime)<1.f ) // Make sure its recently rendered.
		PockWaves(Other.Location,Other.CollisionRadius*0.8,12.f);
	return true;
}

simulated function Touch( Actor Other )
{
	local float PDepth;

	if( (Level.TimeSeconds-LastRenderedTime)>1.f ) // Make sure its recently rendered.
		return;
	if( Other.bIsPawn )
		PDepth = FClamp(VSize(Other.Velocity)*Other.Mass*0.0008f,5.f,ZHeight[1]*-1.4f);
	else PDepth = FClamp(VSize(Other.Velocity)*0.02f,5.f,ZHeight[1]*-1.8f);
	PockWaves(Other.Location,FMax(Other.CollisionRadius,XGridSpace*1.25f),-PDepth);
}

defaultproperties
{
	SizeX=16
	SizeY=16
	XGridSpace=12.000000
	YGridSpace=12.000000
	WaveDamping=0.600000
	WaveRippleRate=0.100000
	FluidSpeedScale=1.000000
	WaveRippletSize=0.800000
	TexXSize=1.000000
	TexYSize=1.000000
	ZHeight(0)=40.000000
	ZHeight(1)=-40.000000
	bRenderTwoSided=True
	bHidden=False
	bNoDelete=True
	bRenderMultiEnviroMaps=True
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	Skin=Texture'DefaultTexture'
	bCollideActors=True
	bUseMeshCollision=true
	bComputeLightVis=True
	RenderIteratorClass=Class'FluidSurfaceRI'
}