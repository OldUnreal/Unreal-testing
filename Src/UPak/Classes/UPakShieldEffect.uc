//=============================================================================
// UPakShieldEffect.
//=============================================================================
class UPakShieldEffect expands ShieldBeltEffect;

var float LastDrawScale;

simulated function Tick( float DeltaTime )
{
	if( bHidden )
		bHidden = false;
	else if( FRand() < 0.2 && !bHidden )
		bHidden = true;
	if( Owner==None || Owner.bDeleteMe || (Owner.bIsPawn && Pawn( Owner ).Health<=0) )
		Destroy();
	if( Owner.ScaleGlow < 1.5 )
		Owner.ScaleGlow += 0.01;
	else
	{
		Owner.Style = STY_Normal;
		if( LifeSpan <= 0 )
			LifeSpan = 4.5;
		if( Fatness > 135 )
			Fatness -=0.5;
		if( ScaleGlow > 0.15 )
			ScaleGlow -= 0.01;
	}	
	if( Fatness > 129 )
		Fatness -= 0.75;
}

simulated function Timer()
{
	bMeshEnviroMap = false;
	Texture = none;
	bHidden = true;
	Destroy();
}

simulated function Destroyed()
{
	Super(Effects).Destroyed();
}

function PostBeginPlay()
{
	Mesh = Owner.Mesh;
	SetCollisionSize( Owner.CollisionRadius, Owner.CollisionHeight );
}

state OwnerFadeIn
{
	function BeginState()
	{
		Fatness = 129;
	}
	
	function Tick( float DeltaTime )
	{
		if( Pawn( Owner ) != none )
		{
			if( Pawn( Owner ).Health <= 0 )
				Destroy();
			if( bHidden )
				bHidden = false;
			else if( FRand() < 0.2 && !bHidden )
				bHidden = true;
		}
		else Destroy();
	}
}

defaultproperties
{
     ScaleGlow=1.000000
     Fatness=240
	 Texture=FireTexture'BeamTexture'
}
