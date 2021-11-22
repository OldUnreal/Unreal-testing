//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CSFemale ]
//
// Simply a subclass (it's 100% exact to the original Unreal Code) for handling players.
//=============================================================================

class CSFemale expands CSHuman 
   abstract;

defaultproperties
{
     drown=Sound'UnrealShare.Female.mdrown2fem'
     breathagain=Sound'UnrealShare.Female.hgasp3fem'
     HitSound3=Sound'UnrealShare.Female.linjur3fem'
     HitSound4=Sound'UnrealShare.Female.hinjur4fem'
     Die2=Sound'UnrealShare.Female.death3cfem'
     Die3=Sound'UnrealShare.Female.death2afem'
     Die4=Sound'UnrealShare.Female.death4cfem'
     GaspSound=Sound'UnrealShare.Female.lgasp1fem'
     UWHit1=Sound'UnrealShare.Female.FUWHit1'
     UWHit2=Sound'UnrealShare.Male.MUWHit2'
     LandGrunt=Sound'UnrealShare.Female.lland1fem'
     CarcassType=Class'UnrealShare.FemaleBody'
     JumpSound=Sound'UnrealShare.Female.jump1fem'
     HitSound1=Sound'UnrealShare.Female.linjur1fem'
     HitSound2=Sound'UnrealShare.Female.linjur2fem'
     Die=Sound'UnrealShare.Female.death1dfem'
}
