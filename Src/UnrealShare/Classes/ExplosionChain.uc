//=============================================================================
// Chain explosion.
//=============================================================================
class ExplosionChain extends Effects;

#exec Texture Import File=Models\Exp001.pcx Name=s_Exp001 Mips=Off Mask=On Flags=2

var() float MomentumTransfer;
var() float Damage;
var() float Size;
var() float Delaytime;

var bool bExploding,BACKUP_Collision;

function PreBeginPlay()
{
	BACKUP_Collision = bCollideActors;
	Texture=None;
	Super.PreBeginPlay();
}

singular function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
							  Vector momentum, name damageType)
{
	if (bOnlyTriggerable && DamageType!='Detonated') Return;

	Instigator = InstigatedBy;
	MakeNoise(1.0);
	GoToState('Exploding');
}

function Trigger( actor Other, pawn EventInstigator )
{
	TakeDamage(10, EventInstigator, Location, Vector(Rotation), 'Detonated');
}

//////////////////////////////////////////////////////////////
state Exploding
{
	ignores TakeDamage;

	function Timer()
	{
		local SpriteBallExplosion f;

		bExploding = true;
		HurtRadius(damage, Damage+100, 'Detonated', MomentumTransfer, Location);
		f = spawn(class'SpriteBallExplosion',,,Location + vect(0,0,1)*16,rotang(90,0,0));
		f.DrawScale = (Damage/100+0.4+FRand()*0.5)*Size;
		GoToState('Inactive');
	}

	function BeginState()
	{
		SetCollision(false);
		bExploding = True;
		SetTimer(DelayTime+FRand()*DelayTime*2, False);
	}
	function Reset()
	{
		GoToState('');
		bExploding = false;
		SetCollision(BACKUP_Collision);
		SetTimer(0,false);
	}
}

state Inactive
{
ignores TakeDamage,Trigger;

	function BeginState()
	{
		SetCollision(false);
	}
	function Reset()
	{
		GoToState('');
		bExploding = false;
		SetCollision(BACKUP_Collision);
	}
}

defaultproperties
{
	MomentumTransfer=+100000.000000
	Damage=+00100.000000
	size=+00001.000000
	DelayTime=+00000.300000
	DrawType=DT_Sprite
	Texture=UnrealShare.s_Exp001
	DrawScale=+00000.400000
	bMeshCurvy=False
	bCollideActors=True
	bCollideWorld=True
	bProjTarget=True
	bNetTemporary=false
	Physics=PHYS_None
	bHidden=true
	RemoteRole=ROLE_None
}