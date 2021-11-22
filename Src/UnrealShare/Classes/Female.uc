//=============================================================================
// Female.
//=============================================================================
class Female extends Human
			abstract;

#exec AUDIO IMPORT FILE="Sounds\Female\mdrown2.wav" NAME="mdrown2fem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\hgasp3.wav"  NAME="hgasp3fem"  GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\linjur2.wav" NAME="linjur1fem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\linjur3.wav" NAME="linjur2fem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\linjur4.wav" NAME="linjur3fem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\hinjur4.wav" NAME="hinjur4fem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\death1d.wav" NAME="death1dfem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\death2a.wav" NAME="death2afem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\death3c.wav" NAME="death3cfem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\death4c.wav" NAME="death4cfem" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\lland1.wav"  NAME="lland1fem"  GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\lgasp1.wav"  NAME="lgasp1fem"  GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\jump1.wav"  NAME="jump1fem"  GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Female\UWhit01.wav" NAME="FUWHit1" GROUP="Female"
#exec AUDIO IMPORT FILE="Sounds\Male\UWinjur42.wav" NAME="MUWHit2" GROUP="Male"

defaultproperties
{
	drown=mdrown2fem
	breathagain=hgasp3fem
	HitSound3=linjur3fem
	HitSound4=hinjur4fem
	Die2=death3cfem
	Die3=death2afem
	Die4=death4cfem
	GaspSound=lgasp1fem
	JumpSound=jump1fem
	CarcassType=FemaleBody
	HitSound1=linjur1fem
	HitSound2=linjur2fem
	LandGrunt=lland1fem
	UWHit1=FUWHit1
	UWHit2=MUWHit2
	Die=death1dfem
	bIsFemale=true
}
