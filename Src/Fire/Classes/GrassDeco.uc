Class GrassDeco extends Decoration
	native;

#exec Texture Import File=Textures\JGrass.pcx Name=I_Grass Mips=Off Flags=2

var() float WaveOffset, // Offset range (0 = middle, -1 only waves to left, 1 = only waves to right).
			WaveFrequency, // Speed of waves.
			WaveStrength, // Wave size.
			WavePhase, // Wave time offset.
			WaveRandPhase, // Randomized time offset (setup on startup).
			DistanceHigh, // Distance in UU when this grass texture turns into a regular sprite.
			DistanceLow, // Distance in UU when this grass texture begins to face towards camera and shrink in size.
			DistanceLowScale; // When in low distance, how small will this sprite go.
var() int NearMaxPitchAngle; // Maximum pitch angle that this model can face upwards when near camera.

simulated function BeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer && WaveRandPhase>0.f )
		WavePhase+=WaveRandPhase*FRand();
}

function ZoneChange( ZoneInfo NewZone );
function BaseChange();
function Destroyed();
function GrabbedBy( Pawn Other );

function EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	Skin = Texture(Level.GetSelectedObject(class'Texture'));
	if( Skin!=None )
	{
		if( Skin.bAlphaBlend )
			Style = STY_AlphaBlend;
		DrawScale = 64.f / float(Skin.USize);
		if( HitNormal.Z>0.f )
			SetLocation(HitLocation+vect(0,0,0.5)*Skin.VSize*DrawScale);
	}
}

defaultproperties
{
	WaveOffset=0
	WaveFrequency=3
	WaveStrength=0.25
	WaveRandPhase=0.1
	DistanceHigh=2000
	DistanceLow=60
	DistanceLowScale=0.65
	NearMaxPitchAngle=5000
	
	bStatic=true
	RemoteRole=ROLE_None
	bCollideWorld=false
	bCollideActors=false
	bUseLitSprite=true
	DrawType=DT_Terraform
	Texture=Texture'I_Grass'
}