//=============================================================================
// TarydiumBarrel.
//=============================================================================
class TarydiumBarrel extends SteelBarrel;

#exec TEXTURE IMPORT NAME=Jsteelbarrel2 FILE=Models\steelbt.pcx GROUP="Skins" Specular=1

var bool bChainedExplosion, bDestroy;

auto state active
{

	function Timer()
	{
		local int NumChunks;
		local SpriteBallExplosion s;
		local RingExplosion3 r;

		Super.Timer();
		if (bStatic || bDeleteme)
			return;
		if (!bDestroy) Return;

		NumChunks = 12;
		s = spawn(class'SpriteBallExplosion');
		r = spawn(class'RingExplosion3',,,Location - Vect(0,0,16),rotang(90,0,0));
		r.PlaySound(r.ExploSound,,6);
		HurtRadius(250, 100, 'destroyed', 0, Location);
		if (bChainedExplosion) NumChunks = 4;
		skinnedFrag(class'Fragment1', texture'JSteelBarrel2', Vect(20000,0,0),1.0, 7);
	}

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		bChainedExplosion = False;
		bDestroy=True;
		if (DamageType=='destroyed')
		{
			SetTimer(FRand()*0.4+0.2,False);
			bChainedExplosion = True;
		}
		else Timer();
		Instigator = InstigatedBy;
		if ( Instigator != None )
			MakeNoise(1.0);
	}

Begin:
}

defaultproperties
{
	Health=1
	Skin=Texture'UnrealShare.Skins.Jsteelbarrel2'
}

