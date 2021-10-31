//=============================================================================
// SkaarjPlayer.
//=============================================================================
class SkaarjPlayer extends UnrealIPlayer;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Male\UWinjur41.wav" NAME="MUWHit1" GROUP="Male"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Male\UWinjur42.wav" NAME="MUWHit2" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\gasp01.wav" NAME="SKPGasp1" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\drown01.wav" NAME="SKPDrown1" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\jump01.wav" NAME="SKPJump1" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Cow\walknc.wav" NAME="walkC" GROUP="Cow"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\injur01.wav" NAME="SKPInjur1" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\injur02.wav" NAME="SKPInjur2" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\injur03.wav" NAME="SKPInjur3" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\injur04.wav" NAME="SKPInjur4" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\death01.wav" NAME="SKPDeath1" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\death02.wav" NAME="SKPDeath2" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\death03.wav" NAME="SKPDeath3" GROUP="Skaarj"
#exec AUDIO IMPORT FILE="Sounds\SkaarjPlayer\land01.wav" NAME="Land1SK" GROUP="Skaarj"

simulated function WalkStep()
{
	local sound step;
	local float decision;

	if ( Level.NetMode==NM_DedicatedServer )
		Return; // We don't preform this on dedicated servers.

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			Step = Footstep1;
		else if (decision < 0.67 )
			Step = Footstep2;
		else
			Step = Footstep3;
	}
	if( step==None )
		return;
	PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
}

simulated function RunStep()
{
	local sound step;
	local float decision;

	if ( (Level.Game != None) && (Level.Game.Difficulty > 1) )
		MakeNoise(0.05 * Level.Game.Difficulty);
	if ( Level.NetMode==NM_DedicatedServer )
		Return; // We don't preform this on dedicated servers.

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			Step = Footstep1;
		else if (decision < 0.67 )
			Step = Footstep2;
		else
			Step = Footstep3;
	}
	if( step==None )
		return;
	PlaySound(step, SLOT_Interact, 2, false, 800.0, 1.0);
}

//-----------------------------------------------------------------------------
// Animation functions

function PlayDodge(eDodgeDir DodgeMove)
{
	Velocity.Z = 210;
	if ( DodgeMove == DODGE_Left )
		PlayAnim('LeftDodge', 1.35, 0.06);
	else if ( DodgeMove == DODGE_Right )
		PlayAnim('RightDodge', 1.35, 0.06);
	else if ( DodgeMove == DODGE_Forward )
		PlayAnim('Lunge', 1.2, 0.06);
	else
		PlayDuck();
}

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayAnim('Turn', 0.3, 0.3);
}

function TweenToWalking(float tweentime)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		TweenAnim('Walk', tweentime);
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
		TweenAnim('WalkFire', tweentime);
	else
		TweenAnim('Walk', tweentime);
}

function TweenToRunning(float tweentime)
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (bIsWalking)
		TweenToWalking(0.1);
	else if (Weapon == None)
		PlayAnim('Jog', 1, tweentime);
	else if ( Weapon.bPointing )
		PlayAnim('JogFire', 1, tweentime);
	else
		PlayAnim('Jog', 1, tweentime);
}

function PlayWalking()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Walk',1.1);
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
		LoopAnim('WalkFire',1.1);
	else
		LoopAnim('Walk',1.1);
}

function PlayRunning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Jog',1.1);
	else if ( Weapon.bPointing )
		LoopAnim('JogFire',1.1);
	else
		LoopAnim('Jog',1.1);
}

function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	PlayAnim('Getup', 0.7, 0.1);
}

function PlayFeignDeath()
{
	BaseEyeHeight = 0;
	PlayAnim('Death2',0.7);
}

function PlayDying(name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;

	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();

	if ( FRand() < 0.15 )
	{
		PlayAnim('Death',0.7,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.7) )
	{
		PlayAnim('Death2', 0.7, 0.1);
		return;
	}

	// check for head hit
	if ( (DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight) )
	{
		DamageType = 'Decapitated';
		PlayAnim('Death', 0.7, 0.1);
		return;
	}


	if ( FRand() < 0.15)
	{
		PlayAnim('Death3', 0.7, 0.1);
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	X.Z = 0;
	HitVec = Normal(HitLoc - Location);
	HitVec2D= HitVec;
	HitVec2D.Z = 0;
	dotp = HitVec2D dot X;

	if (Abs(dotp) > 0.71) //then hit in front or back
		PlayAnim('Death3', 0.7, 0.1);
	else
	{
		dotp = HitVec dot Y;
		if (dotp > 0.0)
			PlayAnim('Death', 0.7, 0.1);
		else
			PlayAnim('Death4', 0.7, 0.1);
	}
}

//FIXME - add death first frames as alternate takehit anims!!!

function PlayGutHit(float tweentime)
{
	if ( AnimSequence == 'GutHit' )
	{
		if (FRand() < 0.5)
			TweenAnim('LeftHit', tweentime);
		else
			TweenAnim('RightHit', tweentime);
	}
	else
		TweenAnim('GutHit', tweentime);
}

function PlayHeadHit(float tweentime)
{
	if ( AnimSequence == 'HeadHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('HeadHit', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( AnimSequence == 'LeftHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('LeftHit', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( AnimSequence == 'RightHit' )
		TweenAnim('GutHit', tweentime);
	else
		TweenAnim('RightHit', tweentime);
}

function PlayLanded(float impactVel)
{
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( Role == ROLE_Authority )
	{
		if ( impactVel > 0.17 )
			PlaySound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
		if( Level.FootprintManager!=None )
			Level.FootprintManager.Static.PlayLandingNoise(Self,1,impactVel);
		else if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
			PlaySound(Land, SLOT_Interact, FClamp(4.5 * impactVel,0.5,6), false, 1000, 1.0);
	}

	if ( (GetAnimGroup(AnimSequence) == 'Dodge') && IsAnimating() )
		return;
	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') )
		TweenAnim('Land', 0.12);
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			AnimEnd();
		else
			TweenAnim('Land', 0.12);
	}
}

function PlayInAir()
{
	BaseEyeHeight =  Default.BaseEyeHeight;
	TweenAnim('InAir', 0.4);
}

function PlayDuck()
{
	BaseEyeHeight = 0;
	TweenAnim('Duck', 0.25);
}

function PlayCrawling()
{
	BaseEyeHeight = 0;
	LoopAnim('DuckWalk');
}

function TweenToWaiting(float tweentime)
{
	if ( IsInState('PlayerSwimming') || Physics==PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		TweenAnim('Swim', tweentime);
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		TweenAnim('Firing', tweentime);
	}
}

function PlayWaiting()
{
	local name newAnim;

	if ( IsInState('PlayerSwimming') || (Physics==PHYS_Swimming) )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		LoopAnim('Swim');
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( (Weapon != None) && Weapon.bPointing )
			TweenAnim('Firing', 0.3);
		else
		{
			if ( FRand() < 0.2 )
				newAnim = 'Breath';
			else
				newAnim = 'Breath2';

			if ( AnimSequence == newAnim )
				LoopAnim(newAnim, 0.3 + 0.7 * FRand());
			else
				PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);
		}
	}
}

function PlayFiring()
{
	// switch animation sequence mid-stream if needed
	if (AnimSequence == 'Jog')
		AnimSequence = 'JogFire';
	else if (AnimSequence == 'Walk')
		AnimSequence = 'WalkFire';
	else if ( AnimSequence == 'InAir' )
		TweenAnim('JogFire', 0.03);
	else if ( (GetAnimGroup(AnimSequence) != 'Attack')
			  && (GetAnimGroup(AnimSequence) != 'MovingAttack')
			  && (GetAnimGroup(AnimSequence) != 'Dodge')
			  && (AnimSequence != 'Swim') )
		TweenAnim('Firing', 0.02);
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
}

function PlaySwimming()
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	LoopAnim('Swim');
}

function TweenToSwimming(float tweentime)
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	TweenAnim('Swim',tweentime);
}

function SwimAnimUpdate(bool bNotForward)
{
	if ( !bAnimTransition && (GetAnimGroup(AnimSequence) != 'Gesture') && (AnimSequence != 'Swim') )
		TweenToSwimming(0.1);
}

defaultproperties
{
	Footstep1=Sound'UnrealShare.Cow.walkC'
	Footstep2=Sound'UnrealShare.Cow.walkC'
	Footstep3=Sound'UnrealShare.Cow.walkC'
	UWHit1=Sound'UnrealShare.Male.MUWHit1'
	UWHit2=Sound'UnrealShare.Male.MUWHit2'
	Die=Sound'SKPDeath1'
	Die2=Sound'SKPDeath2'
	Die3=Sound'SKPDeath3'
	Die4=Sound'SKPDeath3'
	HitSound1=Sound'SKPInjur1'
	HitSound2=Sound'SKPInjur2'
	HitSound3=Sound'SKPInjur3'
	HitSound4=Sound'SKPInjur4'
	GaspSound=Sound'SKPGasp1'
	JumpSound=Sound'SKPJump1'
	Drown=Sound'SKPDrown1'
	breathagain=Sound'SKPGasp1'
	LandGrunt=Sound'Land1SK'
	CarcassType=Class'TrooperCarcass'
	bSinglePlayer=False
	JumpZ=360.00
	BaseEyeHeight=24.75
	EyeHeight=24.75
	Health=130
	MenuName="Skaarj"
	Skin=Texture'sktrooper1'
	Mesh=LodMesh'sktrooper'
	CollisionRadius=32.00
	CollisionHeight=42.00
	Mass=120.00
	Buoyancy=118.80
}