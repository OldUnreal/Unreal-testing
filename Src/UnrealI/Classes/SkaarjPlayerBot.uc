//=============================================================================
// SkaarjPlayerBot.
//=============================================================================
class SkaarjPlayerBot extends Bots;

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

function PlayDodge(bool bDuckLeft)
{
	bCanDuck = false;
	Velocity.Z = 200;
	if ( bDuckLeft )
		PlayAnim('LeftDodge', 1.35, 0.06);
	else
		PlayAnim('RightDodge', 1.35, 0.06);
}

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayAnim('Turn', 0.3, 0.3);
}

function TweenToWalking(float tweentime)
{
	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			TweenToSwimming(tweentime);
		else
			TweenToWaiting(tweentime);
	}

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
	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			TweenToSwimming(tweentime);
		else
			TweenToWaiting(tweentime);
	}

	BaseEyeHeight = Default.BaseEyeHeight;
	if (bIsWalking)
		TweenToWalking(0.1);
	else if ( (Weapon != None) && Weapon.bPointing )
		TweenAnim('JogFire', tweentime);
	else
		TweenAnim('Jog', tweentime);
}

function PlayWalking()
{
	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			PlaySwimming();
		else
			PlayWaiting();
		return;
	}

	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Walk');
	else if ( Weapon.bPointing || (CarriedDecoration != None) )
		LoopAnim('WalkFire');
	else
		LoopAnim('Walk');
}

function PlayRunning()
{
	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			PlaySwimming();
		else
			PlayWaiting();
		return;
	}

	BaseEyeHeight = Default.BaseEyeHeight;
	if (Weapon == None)
		LoopAnim('Jog');
	else if ( Weapon.bPointing )
		LoopAnim('JogFire');
	else
		LoopAnim('Jog');
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
	if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight))
			&& !Level.Game.bVeryLowGore )
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
	if ( Physics==PHYS_Swimming )
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

	if ( Physics==PHYS_Swimming )
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

function PlayChallenge()
{
	local float decision;

	decision = FRand();
	if ( decision < 0.6 )
		TweenToWaiting(0.1);
	else
		PlayAnim('Button1');
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

state FallingState
{
	ignores Bump, Hitwall, HearNoise, WarnTarget;

	function Landed(vector HitNormal)
	{
		local float landVol;

		if ( GetAnimGroup(AnimSequence) == 'Dodge' )
		{
			if (Velocity.Z <= -1100)
			{
				if ( (Velocity.Z < -2000) && (ReducedDamageType != 'All') )
				{
					health = -1000; //make sure gibs
					Died(None, 'fell', Location);
				}
				else if ( Role == ROLE_Authority )
					TakeDamage(-0.15 * (Velocity.Z + 1050), None, Location, vect(0,0,0), 'fell');
			}
			landVol = Velocity.Z/JumpZ;
			landVol = 0.008 * Mass * landVol * landVol;
			if ( !FootRegion.Zone.bWaterZone )
				PlaySound(Land, SLOT_Interact, FMin(20, landVol));
			GotoState('FallingState', 'FinishDodge');
		}
		else
			Super.Landed(HitNormal);
	}

FinishDodge:
	FinishAnim();
	bCanDuck = true;
	Goto('Done');
}

defaultproperties
{
	CarcassType=Class'UnrealI.TrooperCarcass'
	drown=Sound'UnrealI.Skaarj.SKPDrown1'
	breathagain=Sound'UnrealI.Skaarj.SKPGasp1'
	Footstep1=Sound'UnrealShare.Cow.walkC'
	Footstep2=Sound'UnrealShare.Cow.walkC'
	Footstep3=Sound'UnrealShare.Cow.walkC'
	HitSound3=Sound'UnrealI.Skaarj.SKPInjur3'
	HitSound4=Sound'UnrealI.Skaarj.SKPInjur4'
	Die2=Sound'UnrealI.Skaarj.SKPDeath2'
	Die3=Sound'UnrealI.Skaarj.SKPDeath3'
	Die4=Sound'UnrealI.Skaarj.SKPDeath3'
	GaspSound=Sound'UnrealI.Skaarj.SKPGasp1'
	UWHit1=Sound'UnrealShare.Male.MUWHit1'
	UWHit2=Sound'UnrealShare.Male.MUWHit2'
	LandGrunt=Sound'UnrealI.Skaarj.Land1SK'
	JumpSound=Sound'UnrealI.Skaarj.SKPJump1'
	JumpZ=360.000000
	BaseEyeHeight=24.750000
	EyeHeight=24.750000
	Health=120
	HitSound1=Sound'UnrealI.Skaarj.SKPInjur1'
	HitSound2=Sound'UnrealI.Skaarj.SKPInjur2'
	Die=Sound'UnrealI.Skaarj.SKPDeath1'
	Skin=Texture'UnrealI.Skins.sktrooper1'
	Mesh=LodMesh'UnrealI.sktrooper'
	CollisionRadius=32.000000
	CollisionHeight=42.000000
	Mass=120.000000
	Buoyancy=118.800003
}
