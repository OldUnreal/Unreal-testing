//=============================================================================
// CarcassBloodPool.
// Blood pool for CreatureCarcass. //Heavily modified by []KAOS[]Casey. I had a TON of revisions.
//=============================================================================
class CarcassBloodPool expands Scorch;


var bool bTickin;
var bool bShow;
var Texture T;
var float Z;
var bool bGreen;
var vector RandVect;
var float AdditionRate;
var Float MaxDrawScale;

#exec TEXTURE IMPORT NAME=ModulatedMask FILE=Textures\ModulatedMask.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=RBloodSplat FILE=Textures\RBloodPool.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GBloodSplat FILE=Textures\GBloodPool.pcx GROUP=BloodDecal


simulated function PreBeginPlay()
{


	if (class'GameInfo'.Default.bVeryLowGore)//Turn off Blood with low gore.
		destroy();

	if (Class'Scorch'.Default.DecalLifeSpan<0)
		SetTimer(1.0, false); //Default, disappear a few seconds after no render.
	else
		LifeSpan=fmax(0,Class'Scorch'.Default.DecalLifeSpan); //Stay around as long as the user wants. 0 = Forever.
	MaxDrawScale=1.5;
	if (Owner != None)
		if (Owner.collisionradius+Owner.Collisionheight < 100)
			MaxDrawScale=((Owner.collisionradius+(Owner.Collisionheight))*0.01);
		else if (Owner.collisionradius+Owner.Collisionheight > 100 &&
				 Owner.collisionradius+Owner.Collisionheight <1000 )
			MaxDrawScale=((Owner.collisionradius+(Owner.Collisionheight))*0.018);
		else if (Owner.collisionradius+Owner.Collisionheight > 1000 )
			MaxDrawScale=((Owner.collisionradius+(Owner.Collisionheight))*0.03);

	if (MaxDrawScale<6)
		AdditionRate=MaxDrawScale*0.0011;
	else AdditionRate=MaxDrawScale*0.0035;

	RandVect=Vrand();
}

simulated function PostBeginPlay()
{
	SetPhysics(PHYS_Falling);
	Velocity.Z = -1000;
	bTickin = true;

}
simulated function Green()
{
	bGreen=True;
}
simulated function Landed( vector HitNormal )
{
	Velocity = vect(0,0,0);
	SetPhysics(PHYS_None);
	setcollision(false,false,false);

	AttachToSurface();
}

simulated function AttachToSurface()
{
	if (AttachDecal(100,RandVect) == None)
		Destroy();
}

simulated function Tick( float DeltaTime)
{
	if (!bTickin)
		return;
	if (!bShow && Z >= 0.0  )
	{

		if (bGreen)
			Texture=texture'GBloodSplat';
		else Texture=texture'RBloodSplat';
		bshow=True;
	}

	if (Owner == none)
		bTickin=false;

	if ( Z < MaxDrawScale && Bshow && Z > 0.000000 )
	{
		DetachDecal();
		Drawscale=Z;
		AttachDecal(100,RandVect);
		Z += AdditionRate;

	}
	else Z += AdditionRate;
}

defaultproperties
{
	Z=-0.150000
	Texture=Texture'UnrealShare.BloodDecal.ModulatedMask'
	CollisionRadius=1.000000
	CollisionHeight=1.000000
	bCollideWorld=True
}
