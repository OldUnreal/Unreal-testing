Class GrassDecoSchool extends GrassDeco;

#exec Texture Import File=Textures\JGrassSchool.pcx Name=I_GrassSchool Mips=Off Flags=2

var() float GrassRadius; // Circular radius to which this should spawn grass pieces at.
var() byte NumGrass; // Number of grass pieces to spawn around.
var() float TestHeight; // Max trace height to test.
var() float MaxDepth; // Max trace depth to which it can spawn grass at.
var() float ScaleVariation; // Random scaling (0.05 = +/-5% DrawScale applied to this actor).
var() array<Texture> Variants; // Texture variants (including this school actor owner skin).

simulated function BeginPlay()
{
	local int i,j;
	local vector Start,End,HL,HN;
	local GrassDecoChild D;
	local Texture T;
	local float Scale;

	if( Level.NetMode==NM_DedicatedServer || NumGrass==0 || Skin==None )
		return;
	
	Variants.Add(Skin);
	for( i=(NumGrass + 10); i>=0; --i )
	{
		if( T==None )
		{
			T = Variants[Rand(Variants.Size())];
			if( T==None )
				continue;
		}
		Start = Normal(Construct<Vector>(FRand()-0.5f,FRand()-0.5f,0.f)) * FRand() * GrassRadius;
		Start.Z = Location.Z + TestHeight;
		End = Start;
		End.Z = Location.Z - MaxDepth;
		if( Trace(HL,HN,End,Start,false)==None || HN.Z<0.77f )
			continue;
		
		Scale = (ScaleVariation!=0.f) ? (DrawScale * (1.f + ScaleVariation*(FRand()-0.5f))) : DrawScale;
		D = Spawn(class'GrassDecoChild',,,HL+vect(0,0,0.5f)*T.VSize*Scale);
		if( D==None )
			continue;
		
		D.Skin = T;
		D.Style = Style;
		D.DrawScale = Scale;
		D.DrawScale3D = DrawScale3D;
		D.WaveOffset = WaveOffset;
		D.WaveFrequency = WaveFrequency;
		D.WaveStrength = WaveStrength;
		D.WavePhase = WavePhase + (WaveRandPhase*FRand());
		D.DistanceHigh = DistanceHigh;
		D.DistanceLow = DistanceLow;
		D.DistanceLowScale = DistanceLowScale;
		D.NearMaxPitchAngle = NearMaxPitchAngle;
		T = None;
		if( ++j==NumGrass )
			break;
	}
	Super.BeginPlay();
}

event DrawEditorSelection( Canvas C )
{
	C.DrawBox(MakeColor(128,255,128), 0, Construct<Vector>(Location.X-GrassRadius,Location.Y-GrassRadius,Location.Z-MaxDepth), Construct<Vector>(Location.X+GrassRadius,Location.Y+GrassRadius,Location.Z+TestHeight));
}

defaultproperties
{
	GrassRadius=128
	NumGrass=12
	Texture=Texture'I_GrassSchool'
	TestHeight=48
	MaxDepth=64
	bEditorSelectRender=true
	ScaleVariation=0.05
}