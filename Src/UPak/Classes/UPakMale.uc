//=============================================================================
// UPakMale.
//=============================================================================
class UPakMale expands UPakPlayer;

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
	if ( (Velocity.Z > 250) && (FRand() < 0.7) && !Level.Game.bVeryLowGore )
	{
		if ( (hitLoc.Z > Location.Z) && (FRand() < 0.65) )
		{
			PlayAnim('Dead5',0.7,0.1);
			if ( Level.NetMode != NM_Client )
			{
				carc = Spawn(class 'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
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
				carc = Spawn(class 'Arm1',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
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
	if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight))
		 && !Level.Game.bVeryLowGore )
	{
		DamageType = 'Decapitated';
		PlayAnim('Dead4', 0.7, 0.1);
		if ( Level.NetMode != NM_Client )
		{
			carc = Spawn(class 'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
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
     drown=Sound'UnrealShare.Male.MDrown1'
     breathagain=Sound'UnrealShare.Male.MGasp1'
     HitSound3=Sound'UnrealShare.Male.MInjur3'
     HitSound4=Sound'UnrealShare.Male.MInjur4'
     Die2=Sound'UnrealShare.Male.MDeath3'
     Die3=Sound'UnrealShare.Male.MDeath3'
     Die4=Sound'UnrealShare.Male.MDeath4'
     GaspSound=Sound'UnrealShare.Male.MGasp2'
     UWHit1=Sound'UnrealShare.Male.MUWHit1'
     UWHit2=Sound'UnrealShare.Male.MUWHit2'
     LandGrunt=Sound'UnrealShare.Male.lland01'
     CarcassType=Class'UnrealShare.MaleBody'
     JumpSound=Sound'UnrealShare.Male.MJump1'
     AirControl=0.050000
     HitSound1=Sound'UnrealShare.Male.MInjur1'
     HitSound2=Sound'UnrealShare.Male.MInjur2'
     Die=Sound'UnrealShare.Male.MDeath1'
}
