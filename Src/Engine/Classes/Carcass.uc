//=============================================================================
// Carcass.
//=============================================================================
class Carcass extends Decoration
			native;

// Sprite.
#exec Texture Import File=Textures\Corpse.pcx Name=S_Corpse Mips=Off Flags=2

// Variables.
var bool bPlayerCarcass;
var() byte flies;
var() byte rats;
var() bool bReducedHeight;
var bool bDecorative;
var bool bSlidingCarcass;
var int CumulativeDamage;
var PlayerReplicationInfo PlayerOwner;
var float FullCollisionHeight;

var Pawn Bugs;

function CreateReplacement()
{
	if (Bugs != None)
		Bugs.Destroy();
}

function Destroyed()
{
	if (Bugs != None)
		Bugs.Destroy();

	Super.Destroyed();
}

function Initfor(actor Other)
{
	//implemented in subclasses
}

function ChunkUp(int Damage)
{
	destroy();
}

static simulated function bool AllowChunk(int N, name A)
{
	return true;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					 Vector momentum, name damageType)
{
	if (bStatic || bDeleteme)
		return;
	if ( !bDecorative )
	{
		bBobbing = false;
		SetPhysics(PHYS_Falling);
	}
	if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
		Momentum.Z *= -1;
	Velocity += 3 * momentum/(Mass + 200);
	if ( DamageType == 'shot' )
		Damage *= 0.4;
	CumulativeDamage += Damage;
	if ( (((Damage > 30) || !IsAnimating()) && (CumulativeDamage > 0.8 * Mass)) || (Damage > 0.4 * Mass)
			|| ((Velocity.Z > 150) && !IsAnimating()) )
		ChunkUp(Damage);
	if ( bDecorative )
		Velocity = vect(0,0,0);
}

function HitWall( vector HitNormal, actor HitWall )
{
	if( Base && Physics!=PHYS_Falling ) // 227k: Could be based on a Pawn or Mover and they moved into a wall, make em fall off...
		SetPhysics(PHYS_Falling);
}

auto state Dying
{
	ignores TakeDamage;

Begin:
	Sleep(0.2);
	GotoState('Dead');
}

state Dead
{
	function Timer()
	{
		if ( Region.Zone.NumCarcasses <= Region.Zone.MaxCarcasses )
		{
			if ( !PlayerCanSeeMe() )
				Destroy();
			else
				SetTimer(2.0, false);
		}
		else
			Destroy();
	}

	function AddFliesAndRats()
	{
	}

	function CheckZoneCarcasses()
	{
	}

	function BeginState()
	{
		if ( bDecorative )
			lifespan = 0.0;
		else
			SetTimer(18.0, false);
	}

Begin:
	FinishAnim();
	Sleep(5.0);
	CheckZoneCarcasses();
	Sleep(7.0);
	if ( !bDecorative && !bHidden && !Region.Zone.bWaterZone && !Region.Zone.bPainZone )
		AddFliesAndRats();
}

defaultproperties
{
	bDecorative=True
	bStatic=False
	DrawType=DT_Mesh
	Texture=S_Corpse
	bMeshCurvy=False
	bStasis=False
	CollisionRadius=+00018.000000
	CollisionHeight=+00004.000000
	bCollideActors=True
	bCollideWorld=True
	bProjTarget=True
	Physics=PHYS_Falling
	Mass=+00180.000000
	Buoyancy=+00105.000000
	LifeSpan=+00180.000000
	AnimSequence=Dead
	AnimFrame=+00000.900000
}
