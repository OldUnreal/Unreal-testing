//=============================================================================
// GLFirePuff.
//=============================================================================
class GLFirePuff expands SpriteSmokePuff;

#exec TEXTURE IMPORT NAME=SK_a00 FILE=MODELS\GLAUNCHER\SK_a00.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a01 FILE=MODELS\GLAUNCHER\SK_a01.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a02 FILE=MODELS\GLAUNCHER\SK_a02.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a03 FILE=MODELS\GLAUNCHER\SK_a03.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a04 FILE=MODELS\GLAUNCHER\SK_a04.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a05 FILE=MODELS\GLAUNCHER\SK_a05.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a06 FILE=MODELS\GLAUNCHER\SK_a06.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a07 FILE=MODELS\GLAUNCHER\SK_a07.pcx GROUP=Puff
#exec TEXTURE IMPORT NAME=SK_a08 FILE=MODELS\GLAUNCHER\SK_a08.pcx GROUP=Puff

simulated function Tick( float DeltaTime )
{
	ScaleGlow -= 0.01;
}
simulated function PostBeginPlay()
{
	Velocity = Vect(0,0,1)*RisingRate;
}

defaultproperties
{
     RisingRate=80.000000
     Texture=Texture'UPak.Puff.SK_a00'
     DrawScale=0.600000
     ScaleGlow=0.750000
}
