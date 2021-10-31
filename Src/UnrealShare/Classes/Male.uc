//=============================================================================
// Male.
//=============================================================================
class Male extends Human
			abstract;

#exec AUDIO IMPORT FILE="Sounds\Male\deathc1.wav" NAME="MDeath1" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\deathc3.wav" NAME="MDeath3" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\deathc4.wav" NAME="MDeath4" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\injurL2.wav" NAME="MInjur1" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\injurL04.wav" NAME="MInjur2" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\injurM04.wav" NAME="MInjur3" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\injurH5.wav" NAME="MInjur4" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\drownM02.wav" NAME="MDrown1" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\gasp02.wav" NAME="MGasp1" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\hgasp1.wav" NAME="MGasp2" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\jump1.wav" NAME="MJump1" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\UWinjur41.wav" NAME="MUWHit1" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\UWinjur42.wav" NAME="MUWHit2" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\lland01.wav" NAME="lland01" GROUP="Male"

function PlayDying(name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;
	local carcass carc;

	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();

	if ( DamageType == 'Suicided' )
	{
		PlayAnim('Dead7', 0.7, 0.1);
		return;
	}

	if ( FRand() < 0.15 )
	{
		PlayAnim('Dead2',0.7,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.7) && !class'GameInfo'.Default.bVeryLowGore )
	{
		if ( (hitLoc.Z > Location.Z) && (FRand() < 0.65) )
		{
			PlayAnim('Dead5',0.7,0.1);
			if ( Level.NetMode != NM_Client )
			{
				carc = Spawn(class 'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rotang(16.48,0,90) );
				if (carc != None)
				{
					carc.Initfor(self);
					carc.Velocity = Velocity + VSize(Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
					ViewTarget = carc;
				}
				carc = Spawn(class 'CreatureChunks');
				if (carc != None)
				{
					carc.Mesh = mesh 'CowBody1';
					carc.Initfor(self);
					carc.Velocity = Velocity + VSize(Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				}
				carc = Spawn(class 'Arm1',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rotang(16.48,0,90) );
				if (carc != None)
				{
					carc.Initfor(self);
					carc.Velocity = Velocity + VSize(Velocity) * VRand();
					carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				}
			}
		}
		else
			PlayAnim('Dead1', 0.7, 0.1);
		return;
	}

	// check for head hit
	if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight)) && !class'GameInfo'.Default.bVeryLowGore )
	{
		DamageType = 'Decapitated';
		PlayAnim('Dead4', 0.7, 0.1);
		if ( Level.NetMode != NM_Client )
		{
			carc = Spawn(class 'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rotang(16.48,0,90) );
			if (carc != None)
			{
				carc.Initfor(self);
				carc.Velocity = Velocity + VSize(Velocity) * VRand();
				carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
				ViewTarget = carc;
			}
		}
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	if (Abs(dotp) > 0.71) //then hit in front or back
		PlayAnim('Dead3', 0.7, 0.1);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			PlayAnim('Dead6', 0.7, 0.1);
		else
			PlayAnim('Dead7', 0.7, 0.1);
	}
}

function PlayGutHit(float tweentime)
{
	if ( (AnimSequence == 'GutHit') || (AnimSequence == 'Dead2') )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else if ( FRand() < 0.6 )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('Dead2', tweentime);

}

function PlayHeadHit(float tweentime)
{
	if ( (AnimSequence == 'HeadHit') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('HeadHit', tweentime);
	else
		TweenAnim('Dead3', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead6') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('LeftHit', tweentime);
	else
		TweenAnim('Dead6', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead1') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('RightHit', tweentime);
	else
		TweenAnim('Dead1', tweentime);
}

defaultproperties
{
	drown=MDrown1
	breathagain=MGasp1
	HitSound3=MInjur3
	HitSound4=MInjur4
	Die2=MDeath3
	Die3=MDeath3
	Die4=MDeath4
	GaspSound=MGasp2
	JumpSound=MJump1
	CarcassType=MaleBody
	HitSound1=MInjur1
	HitSound2=MInjur2
	UWHit1=MUWHit1
	UWHit2=MUWHit2
	Die=MDeath1
	LandGrunt=lland01
}
