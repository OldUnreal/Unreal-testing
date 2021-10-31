//=============================================================================
// Bleeding.
// Lets people bleed to death. // Recoded for 227 by []KAOS[]Casey
//=============================================================================
class Bleeding expands UnrealBlood
	NoUserCreate;

var int BleedAmount;

function PostBeginPlay()
{
	if ( Role != ROLE_Authority || !Level.Game.bBleedingEnabled)
		Destroy();

	if (Level.Game.BleedingDamageMax != 0 && Level.Game.BleedingDamageMin != 0)
		BleedAmount = Max(Rand(Level.Game.BleedingDamageMax),Level.Game.BleedingDamageMin);
	else BleedAmount=Rand(15);

	if (Owner != None)
	{
		if (Owner.isa('ScriptedPawn') && ScriptedPawn(Owner).bGreenBlood)
			Green();
		SetTimer(Level.TimeDilation + (Rand(3) / Level.TimeDilation),false);
	}
	else Destroy();


}

event destroyed()
{
	if (Pawn(Owner) != none)
		Pawn(Owner).bIsBleeding = False;
	super.destroyed();
}

function Timer()
{
	local Pawn P;
	if (Pawn(Owner) != None && !Owner.bDeleteMe)
	{
		P = Pawn(Owner);
		if ( (BleedAmount <= 0 || P.Health <= 0 ) || !P.bIsBleeding )
		{
			P.bIsBleeding=false;
			Return;
		}
	}
	Else
	{
		Destroy();
		Return;
	}

	if (Role == ROLE_Authority)
	{
		BleedAmount--;

		if (P.Health > 0)
		{
			if ( Level.Game.bBleedingDamageEnabled && P.ReducedDamageType != 'All' )
			{
				if (P.IsA('ScriptedPawn') )
				{
					if (ScriptedPawn(P).ReducedDamagePct < 1.0)
						P.Health--;
				}
				else
					P.Health--;
			}
		}
		if (P.Health <= 0)
		{
			P.bIsBleeding=False;
			P.Died(Instigator, 'bloodloss', Owner.Location);
		}

	}
	if (P != None)
	{
		if (!bGreen)
			Spawn(Class'RedBloodyDrip',Owner,'',Owner.Location+22*VRand(),rot(0,0,0));
		else
			Spawn(Class'GreenBloodyDrip',Owner,'',Owner.Location+22*VRand(),rot(0,0,0));
	}

	SetTimer(Level.TimeDilation + (Rand(3) / Level.TimeDilation),false);
}

function Tick( float DeltaTime )
{
	local Pawn P;

	if (Pawn(Owner) != None && !Owner.bDeleteMe)
		P = Pawn(Owner);
	if (P != None)
	{
		if (P.BleedingActor != Self)
			Destroy();
		if ( P.Health <= 0 || BleedAmount <= 0 )
			P.bisBleeding = False;
	}
	else
		Destroy();
}

defaultproperties
{
     bHidden=True
     Physics=PHYS_Trailer
     bHiddenEd=True
     Style=STY_None
     Texture=None
     DrawScale=0.000000
     ScaleGlow=0.000000
     bUnlit=True
     bNoSmooth=True
     Mass=0.000000
}
