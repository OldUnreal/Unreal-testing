//=============================================================================
// SpaceMarine.
//=============================================================================
class SpaceMarine expands MaleBot;

#exec obj load file="UPakModels.u" Package="UPak"
#exec obj load file="Textures\UPakCloak.utx" Package="UPak"

#exec MESHMAP SETTEXTURE MESHMAP=marine NUM=1 TEXTURE=JMarine7
#exec MESHMAP SETTEXTURE MESHMAP=marine NUM=2 TEXTURE=JMarine8

#exec AUDIO IMPORT FILE="Sounds\Marine\UStatic.wav" NAME="UStatic" GROUP="Marines"

var weapon myWeapon;
var UPakShieldEffect BeamEffect;
var bool bFemale;

struct MarineSound
{
	var() float Duration;
	var() name UsedInState;
	var() Sound SoundName;
	var byte bPlayed;
	var SpaceMarine LastSaidBy;
}; 

var() MarineSound VoiceList[20];

var Pawn SaluteTarget;
var Pawn CommunicateTarget, MsgReceivedFrom;
var int Counting;
var bool bWarnedFriends;
var bool bTransmissionDead;
var bool bCommunicateTargetInRange;
var bool bCommunicating;
var float IncomingMessageLength;

var bool bHuntingTransmitted;

var MarineVoiceController PhraseDirector;

var MarineWaveInfo MarineBeamController;
var bool bBeamingIn;
var class< Weapon > StartWeapon;
var MarineVoicePack MyVoicePack;

function PostBeginPlay()
{
	Class'PathNodeIterator'.Static.CheckUPak();
	
	if( !Level.Game.bDeathMatch || MarineWaveInfo(Owner)!=none )
	{
		if( PlayerReplicationInfo!=None )
		{
			PlayerReplicationInfo.Destroy();
			PlayerReplicationInfo = None;
		}
		AttitudeToPlayer = ATTITUDE_Hate;
		bIsPlayer = False;
		CombatStyle = 1;
	}
	if( !Level.Game.bDeathMatch && FRand() < 0.15 )
		SetFemaleGender();
	
	if( MarineWaveInfo( Owner ) != none )
	{
		MarineBeamController = MarineWaveInfo( Owner );		
		StartWeapon = MarineBeamController.MarineWeapons[ MarineBeamController.CurrentMarine ];
	}
	else StartWeapon = class'CARifle';
	ForEach AllActors(Class'MarineVoicePack',MyVoicePack)
		Break;
	if( MyVoicePack==None )
		MyVoicePack = Spawn(Class'MarineVoicePack');
	Super.PostBeginPlay();
}

function SetFemaleGender()
{
	drown=Sound'UnrealShare.Female.mdrown2fem';
	breathagain=Sound'UnrealShare.Female.hgasp3fem';
	HitSound3=Sound'UnrealShare.Female.linjur3fem';
	HitSound4=Sound'UnrealShare.Female.hinjur4fem';
	Die2=Sound'UnrealShare.Female.death3cfem';
	Die3=Sound'UnrealShare.Female.death2afem';
	Die4=Sound'UnrealShare.Female.death4cfem';
	GaspSound=Sound'UnrealShare.Female.lgasp1fem';
	UWHit1=Sound'UnrealShare.Female.FUWHit1';
	UWHit2=Sound'UnrealShare.Male.MUWHit2';
	LandGrunt=Sound'UnrealShare.Female.lland1fem';
	JumpSound=Sound'UnrealShare.Female.jump1fem';
	HitSound1=Sound'UnrealShare.Female.linjur1fem';
	HitSound2=Sound'UnrealShare.Female.linjur2fem';
	Die=Sound'UnrealShare.Female.death1dfem';
	bFemale = true;
	bIsFemale = true;
	if (PlayerReplicationInfo != none)
		PlayerReplicationInfo.bIsFemale = true;
}

function PlayTurning()
{
	BaseEyeHeight = Default.BaseEyeHeight;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		PlayAnim('TurnLG', 0.3, 0.3);
	else
		PlayAnim('TurnLG', 0.3, 0.3);
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
	else if ( Weapon.bPointing ) 
	{
		if (Weapon.Mass < 20)
			TweenAnim('WalkSMFR', tweentime);
		else
			TweenAnim('WalkLGFR', tweentime);
	}
	else
	{
		if (Weapon.Mass < 20)
			TweenAnim('WalkSM', tweentime);
		else
			TweenAnim('WalkLG', tweentime);
	} 
}

function TweenToRunning(float tweentime)
{
	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			TweenToSwimming(tweentime);
		else TweenToWaiting(tweentime);
		return;
	}
	BaseEyeHeight = Default.BaseEyeHeight;

	if (Weapon == None)
		TweenAnim('RunLG', tweentime);
	else if ( Weapon.bPointing ) 
	{
		if (Weapon.Mass < 20)
			TweenAnim('RunLGFR', tweentime);
		else
			TweenAnim('RunLGFR', tweentime);
	}
	else
	{
		if (Weapon.Mass < 20)
			TweenAnim('RunLG', tweentime);
		else
			TweenAnim('RunLG', tweentime);
	} 
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
	else if ( Weapon.bPointing ) 
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSMFR');
		else
			LoopAnim('WalkLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('WalkSM');
		else
			LoopAnim('WalkLG');
	}
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
		LoopAnim('RunLG');
	else if ( Weapon.bPointing ) 
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunLGFR');
		else
			LoopAnim('RunLGFR');
	}
	else
	{
		if (Weapon.Mass < 20)
			LoopAnim('RunLG');
		else
			LoopAnim('RunLG');
	}
}

function PlayRising()
{
	BaseEyeHeight = 0.4 * Default.BaseEyeHeight;
	TweenAnim('DuckWlkS', 0.7);
}

function PlayFeignDeath()
{
	local float decision;

	BaseEyeHeight = 0;
	if ( decision < 0.33 )
		TweenAnim('DeathEnd', 0.5);
	else if ( decision < 0.67 )
		TweenAnim('DeathEnd2', 0.5);
	else 
		TweenAnim('DeathEnd2', 0.5);
}

function PlayDying(name DamageType, vector HitLoc)
{
	local vector X,Y,Z, HitVec, HitVec2D;
	local float dotp;
	local carcass carc;

	BaseEyeHeight = Default.BaseEyeHeight;
	PlayDyingSound();
			
	if ( FRand() < 0.15 )
	{
		PlayAnim('Dead3',0.7,0.1);
		return;
	}

	// check for big hit
	if ( (Velocity.Z > 250) && (FRand() < 0.7) )
	{
		PlayAnim('Dead2', 0.7, 0.1);
		return;
	}

	// check for head hit
	if ( ((DamageType == 'Decapitated') || (HitLoc.Z - Location.Z > 0.6 * CollisionHeight))
		 && !Level.Game.bVeryLowGore )
	{
		DamageType = 'Decapitated';
		if ( Level.NetMode != NM_Client )
		{
			if (bFemale)
				carc = Spawn(class 'FemaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
			else
				carc = Spawn(class 'MaleHead',,, Location + CollisionHeight * vect(0,0,0.8), Rotation + rot(3000,0,16384) );
			if (carc != None)
			{
				carc.Initfor(self);
				carc.Velocity = Velocity + VSize(Velocity) * VRand();
				carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
			}
		}
		PlayAnim('Dead3', 0.7, 0.1);
		return;
	}

	
	if ( FRand() < 0.15)
	{
		PlayAnim('Dead2', 0.7, 0.1);
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
		if ( (dotp > 0.0) && !Level.Game.bVeryLowGore )
		{
			PlayAnim('Dead2', 0.7, 0.1);
			carc = Spawn(class 'Arm1');
			if (carc != None)
			{
				carc.Initfor(self);
				carc.Velocity = Velocity + VSize(Velocity) * VRand();
				carc.Velocity.Z = FMax(carc.Velocity.Z, Velocity.Z);
			}
		}
		else
			PlayAnim('Dead3', 0.7, 0.1);
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
		TweenAnim('Dead2', tweentime);
}

function PlayLeftHit(float tweentime)
{
	if ( (AnimSequence == 'LeftHit') || (AnimSequence == 'Dead3') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('LeftHit', tweentime);
	else 
		TweenAnim('Dead3', tweentime);
}

function PlayRightHit(float tweentime)
{
	if ( (AnimSequence == 'RightHit') || (AnimSequence == 'Dead2') )
		TweenAnim('GutHit', tweentime);
	else if ( FRand() < 0.6 )
		TweenAnim('RightHit', tweentime);
	else
		TweenAnim('Dead3', tweentime);
}	
	
function PlayLanded(float impactVel)
{	
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		PlaySound(LandGrunt, SLOT_Talk, FMin(4, 5 * impactVel),false,1600,FRand()*0.4+0.8);
	if ( !FootRegion.Zone.bWaterZone && (impactVel > 0.01) )
		PlaySound(Land, SLOT_Interact, FClamp(4 * impactVel,0.2,4.5), false,1600, 1.0);

	if ( (impactVel > 0.06) || (GetAnimGroup(AnimSequence) == 'Jumping') )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('LandLGFr', 0.12);
		else
			TweenAnim('LandLGFR', 0.12);
	}
	else if ( !IsAnimating() )
	{
		if ( GetAnimGroup(AnimSequence) == 'TakeHit' )
			AnimEnd();
		else 
		{
			if ( (Weapon == None) || (Weapon.Mass < 20) )
				TweenAnim('LandLGFr', 0.12);
			else
				TweenAnim('LandLGFR', 0.12);
		}
	}
}
	
function PlayInAir()
{
	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpLgl', 0.8);
	else
		TweenAnim('JumpLgl', 0.8); 
}

function PlayDuck()
{
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('LandLgFr', 0.25);
	else
		TweenAnim('LandLgFr', 0.25);
}

function PlayCrawling()
{
	//log("Play duck");
	BaseEyeHeight = 0;
	if ( (Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('DuckWlkS');
	else
		LoopAnim('DuckWlkL');
}

function TweenToWaiting(float tweentime)
{
	if ( Physics == PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('TreadSM', tweentime);
		else
			TweenAnim('TreadLG', tweentime);
	}
	else
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( Enemy != None )
			ViewRotation = Rotator(Enemy.Location - Location);
		else
			ViewRotation.Pitch = 0;
		ViewRotation.Pitch = ViewRotation.Pitch & 65535;
		If ( (ViewRotation.Pitch > RotationRate.Pitch) 
			&& (ViewRotation.Pitch < 65536 - RotationRate.Pitch) )
		{
			If (ViewRotation.Pitch < 32768) 
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimUpL', 0.3);
				else
					TweenAnim('AimUpL', 0.3);
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
					TweenAnim('AimDnL', 0.3);
				else
					TweenAnim('AimDnL', 0.3);
			}
		}
		else if ( (Weapon == None) || (Weapon.Mass < 20) )
		{
			TweenAnim('StillFirL', tweentime);
		}
		else
		{
			TweenAnim('StillFirL', tweentime);
		}
	}
}

function TweenToFighter(float tweentime)
{
	TweenToWaiting(tweentime);
}
	
function PlayChallenge()
{
	local float decision;

	decision = FRand();
	if ( decision < 0.6 )
		TweenToWaiting(0.1);
	else
		PlayAnim('TauntL');
}	
	
function PlayWaiting()
{
	local name newAnim;
	// Rate to play anim at;
	local float PlayRate;
	
	if ( Physics == PHYS_Swimming )
	{
		BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			LoopAnim('TreadSM');
		else
			LoopAnim('TreadLG');
	}
	else
	{	
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( (Weapon != None) && Weapon.bPointing )
		{
			if ( Weapon.Mass < 20 )
			{
				TweenAnim( 'WalkLgFr', 0.001 );
			}
			else
			{
				TweenAnim( 'WalkLgFr', 0.001 );
			}
		}
		else
		{
			if ( FRand() < 0.005 )
			{
			}
			else
			{
				if ( (Weapon == None) || (Weapon.Mass < 20) )
				{
					if ( Health > 50 )
					{
						newAnim = 'Breath1L';
						PlayRate = 0.05;
					}
					else
						newAnim = 'Breath2L';
				}
				else
				{
					if ( Health > 50 )
						newAnim = 'Breath1L';
					else
						newAnim = 'Breath2L';
				}
								

				if ( AnimSequence == newAnim )
				{
					if ( PlayRate != 0 )
					{
						LoopAnim( newAnim, PlayRate );
					}
					else
					{
						LoopAnim(newAnim, 0.3 + 0.7 * FRand());
					}
				}
				else
				{
				
					if ( PlayRate != 0 )
					{
						PlayAnim( newAnim, PlayRate, 0.25 );
					}
					else
					{
						PlayAnim(newAnim, 0.3 + 0.7 * FRand(), 0.25);

					}
				}
			}
		}
	}
}	
	
function PlayFiring()
{
	// switch animation sequence mid-stream if needed
	if (AnimSequence == 'RunLG')
		AnimSequence = 'RunLGFR';
	else if (AnimSequence == 'RunLG')
		AnimSequence = 'RunLGFR';
	else if (AnimSequence == 'WalkLG')
		AnimSequence = 'WalkLGFR';
	else if (AnimSequence == 'WalkSM')
		AnimSequence = 'WalkSMFR';
	else if ( AnimSequence == 'JumpSMFR' )
		TweenAnim('JumpSMFR', 0.03);
	else if ( AnimSequence == 'JumpLGFR' )
		TweenAnim('JumpLGFR', 0.03);
	else if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') 
		&& (AnimSequence != 'TreadLG') && (AnimSequence != 'TreadSM') )
	{
		if ( Weapon.Mass < 20 )
			TweenAnim('StillFrRP', 0.02);
		else
			TweenAnim('StillFirL', 0.03 );
	}
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	if ( (Weapon == None) || (Weapon.Mass < 20) )
	{
		if ( (NewWeapon != None) && (NewWeapon.Mass > 20) )
		{
			if ( (AnimSequence == 'RunLG') || (AnimSequence == 'RunLGFR') )
				AnimSequence = 'RunLG';
			else if ( (AnimSequence == 'WalkSM') || (AnimSequence == 'WalkSMFR') )
				AnimSequence = 'WalkLG';	
		 	else if ( AnimSequence == 'JumpSMFR' )
		 		AnimSequence = 'JumpLGFR';
			else if ( AnimSequence == 'DuckWlkL' )
				AnimSequence = 'DuckWlkS';
		 	else if ( AnimSequence == 'StillFrRP' )
		 		AnimSequence = 'StillFRRP';
			else if ( AnimSequence == 'AimDnSm' )
				AnimSequence = 'AimDnLg';
			else if ( AnimSequence == 'AimUpSm' )
				AnimSequence = 'AimUpLg';
		 }	
	}
	else if ( (NewWeapon == None) || (NewWeapon.Mass < 20) )
	{		
		if ( (AnimSequence == 'RunLG') || (AnimSequence == 'RunLGFR') )
			AnimSequence = 'RunLG';
		else if ( (AnimSequence == 'WalkLG') || (AnimSequence == 'WalkLGFR') )
			AnimSequence = 'WalkSM';
	 	else if ( AnimSequence == 'JumpLGFR' )
	 		AnimSequence = 'JumpSMFR';
		else if ( AnimSequence == 'DuckWlkS' )
			AnimSequence = 'DuckWlkL';
	 	else if (AnimSequence == 'StillFRRP')
	 		AnimSequence = 'StillFrRP';
		else if ( AnimSequence == 'AimDnLg' )
			AnimSequence = 'AimDnSm';
		else if ( AnimSequence == 'AimUpLg' )
			AnimSequence = 'AimUpSm';
	}
}

function PlaySwimming()
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		LoopAnim('SwimSM');
	else
		LoopAnim('SwimLG');
}

function TweenToSwimming(float tweentime)
{
	BaseEyeHeight = 0.7 * Default.BaseEyeHeight;
	if ((Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('SwimSM',tweentime);
	else
		TweenAnim('SwimLG',tweentime);
}

////////////////////////////////////////////////////////////////////////////////
// Non Animation stuff
////////////////////////////////////////////////////////////////////////////////

function eAttitude AttitudeTo(Pawn Other)
{
	if ( Level.Game.bTeamGame && (PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		return ATTITUDE_Friendly; //teammate
	else if ( Other.IsA( 'SpaceMarine' ) )
		return ATTITUDE_Friendly;
	return ATTITUDE_Hate;
}

function damageAttitudeTo( pawn Other )
{
	Super.damageAttitudeTo(Other);
	if( Other==Enemy && MyVoicePack!=None )
		MyVoicePack.RequestBackup(Self);
}
function Killed(pawn Killer, pawn Other, name damageType)
{
	if( Other==Enemy && Enemy!=None && MyVoicePack!=None )
		MyVoicePack.TalkVictory(Self);
	Super.Killed(Killer,Other,damageType);
}
state Acquisition
{
	function BeginState()
	{
		if( MyVoicePack!=None && MyVoicePack.LastTalker!=self )
		{
			MyVoicePack.Talker = self;
			MyVoicePack.SetTimer( 0.1, false );
			MyVoicePack.bAcquirePhrase = true;
		}
		Super.BeginState();
	}
}


state WarnFriends expands Acquisition
{
	ignores SeePlayer;
	
	function BeginState()
	{
		bCommunicating = True;
	}
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		LastSeenPos = Enemy.Location;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
		{
			if( !bTransmissionDead )
			{
				PlaySound( sound'hiss1pp', SLOT_Talk, 200, True, 256 );
				bTransmissionDead = True;
			}
			
			return;
		}
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
	}

	function MessagePlayers()
	{
		local PlayerPawn P;
		
		foreach allactors( class'PlayerPawn', P )
		{
			P.ClientMessage( self$": I've found a target!" );
		}
	}

Begin:
	
/*	if( PhraseDirector.InitiatePlay( Self ) )
	{
		FinishAnim();
		Velocity *= 0;
		Acceleration *= 0;
		if( !bCommunicateTargetInRange )
		{
			PlayAnim( 'TalkREM', 0.25 );
		}
		else
		{
			TurnToward( CommunicateTarget );
			PlayAnim( 'WaveL', 0.25 );
		}
		Sleep( 0.15 );
		PlaySound( PhraseDirector.GetCurrentSoundName(), SLOT_Talk,, False );
		Sleep( PhraseDirector.GetCurrentSoundDuration() - 1 );
		MessagePlayers();
		PhraseDirector.Finished();
		bCommunicating = False;
		GotoState( 'Attacking' );
	}*/
	FinishAnim();
	PhraseDirector.Marine = Self;
	PhraseDirector.GotoState( 'BroadcastingSound' );
	Velocity *= 0;
	Acceleration *= 0;
	bCommunicating = True;
	if( !PhraseDirector.bReceiverInRange )
	{
		PlayAnim( 'TalkREM', 0.25 );
	}
	else
	{
		TurnToward( PhraseDirector.Receiver );
		PlayAnim( 'WaveL', 0.25 );
	}
	Sleep( 0.15 );
	PhraseDirector.Broadcast();
	FinishAnim();
	Sleep( PhraseDirector.GetCurrentSoundDuration() - 1 );
	bCommunicating = False;
	GotoState( 'Attacking' );

		
/*Begin:
	if ( FindCommunicateTarget() != None && !bWarnedFriends && !bTransmissionDead )
	{
		FinishAnim();
		Velocity *= 0;
		Acceleration *= 0;
		if( !bCommunicateTargetInRange )
		{
			PlayAnim( 'TalkREM', 0.25 );
		}
		else
		{
			TurnToward( CommunicateTarget );
			PlayAnim( 'WaveL', 0.25 );
		}
		Sleep( 0.15 );
		PlaySound( GetPhrase().SoundName, SLOT_Talk,, False );
		MessagePlayers();		

		if( !bCommunicateTargetInRange )
		{
			SpaceMarine( CommunicateTarget ).PlaySound( GetPhrase().SoundName, SLOT_Misc, 200, False, 256 );		
			SpaceMarine( CommunicateTarget ).MsgReceivedFrom = Self;
			SpaceMarine( CommunicateTarget ).bWarnedFriends = True;
		}
		SpaceMarine( CommunicateTarget ).Enemy = Enemy;
		SpaceMarine( CommunicateTarget ).IncomingMessageLength = 3.5;
		SpaceMarine( CommunicateTarget ).GotoState( 'AcknowledgeWarning' );
		FinishAnim();
		bWarnedFriends = True;
		CommunicateTarget = None;
	}
	bCommunicating = False;
	Gotostate('Attacking' );*/			
}


state AcknowledgeWarning expands Acquisition
{
	ignores SeePlayer;
	
	function BeginState()
	{
		bCommunicating = True;
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		LastSeenPos = Enemy.Location;
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 && !bTransmissionDead )
		{
			PlaySound( sound'hiss1pp', SLOT_Talk, 200, True, 256 );
			bTransmissionDead = True;
			return;
		}
		if (NextState == 'TakeHit')
		{
			NextState = 'Attacking'; 
			NextLabel = 'Begin';
			GotoState('TakeHit'); 
		}
		else
			GotoState('Attacking');
	}

	function MessagePlayers()
	{
		local PlayerPawn P;
		
		foreach allactors( class'PlayerPawn', P )
		{
			P.ClientMessage( self$": Target data received." );
		}
	}

	// each sound should have an estimated length associated with it, to insure sleep durations are accurate enough.
	
	// acknowledge delay set by communicator based on message length, passed to receiver who sleeps(?) for that duration.
	
Begin:

	if ( MsgReceivedFrom != None && !bTransmissionDead )
	{
		FinishAnim();
		if( IncomingMessageLength > 0 )
		{
			Sleep( IncomingMessageLength );
		}
		Velocity *= 0;
		Acceleration *= 0;
		PlayAnim( 'TalkREM', 0.25 );
		MessagePlayers();
		PlaySound( GetPhrase().SoundName, SLOT_Talk,, False );
		SpaceMarine( MsgReceivedFrom ).PlaySound( GetPhrase().SoundName, SLOT_Misc, 200, False, 256 );		
		FinishAnim();
		bWarnedFriends = True;
		CommunicateTarget = None;
		Sleep( 1.4 );
	}
	bCommunicating = False;
	GotoState( 'Attacking' );
}
		
function Pawn FindCommunicateTarget()
{
	local SpaceMarine Marine;
	local Actor HitActor;
	local vector HitNormal, HitLocation;
		
	foreach allactors( class'SpaceMarine', Marine )
	{
		if( Marine != Self && !Marine.bCommunicating )
		{
			CommunicateTarget = Marine;
		}
	} 
	if( CommunicateTarget != None )
	{
		HitActor = Trace( HitLocation, HitNormal, CommunicateTarget.Location, Location, True );
		if ( HitActor == Self || HitActor == CommunicateTarget )
		{
			bCommunicateTargetInRange = True;
		}
		else
		{
			bCommunicateTargetInRange = False;
		}
	}
	return CommunicateTarget;
}

function Pawn GetCommunicateTarget()
{
	return CommunicateTarget;
}


function PlayDyingSound()
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,2.0,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,2.0,,,Frand()*0.2+0.9);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)
		PlaySound(Die, SLOT_Talk,2.0);
	else if (rnd < 0.5)
		PlaySound(Die2, SLOT_Talk,2.0);
	else if (rnd < 0.75)
		PlaySound(Die3, SLOT_Talk,2.0);
	else 
		PlaySound(Die4, SLOT_Talk,2.0);

	if( bTransmissionDead && ( MsgReceivedFrom != None || CommunicateTarget != None ) )
	{
		if( MsgReceivedFrom != None )
		{
			MsgReceivedFrom.PlaySound( Die, SLOT_Talk, 2.0 );
		}
		else
		{
			CommunicateTarget.PlaySound( Die, SLOT_Talk, 2.0 );
		}
	}
}



//====================================================================================================
// Hunting State Overrides
//====================================================================================================

state Hunting
{
ignores EnemyNotVisible; 

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{
		bCanJump = ( (MoveTarget != None) || PointReachable(Destination) );
	}

	function Bump(actor Other)
	{
		if (Pawn(Other) != None)
		{
			if (Enemy == Other)
				bReadyToAttack = True; //can melee right away
			SetEnemy(Pawn(Other));
			LastSeenPos = Enemy.Location;
		}
		setTimer(2.0, false);
		Disable('Bump');
	}
	
    function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
		GotoState('Wandering', 'Moving');
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		bFrustrated = true;
		if (NextState == 'TakeHit')
		{
			if (AttitudeTo(Enemy) == ATTITUDE_Fear)
			{
				NextState = 'Retreating';
				NextLabel = 'Begin';
			}
			else
			{
				NextState = 'Hunting';
				NextLabel = 'AfterFall';
			}
			GotoState('TakeHit'); 
		}
	}

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy(NoiseMaker.instigator) )
			LastSeenPos = Enemy.Location; 
	}

	function SetFall()
	{
		NextState = 'Hunting'; 
		NextLabel = 'AfterFall';
		NextAnim = AnimSequence;
		GotoState('FallingState'); 
	}

	function bool SetEnemy(Pawn NewEnemy)
	{
		local float rnd;

		if (Global.SetEnemy(NewEnemy))
		{
			rnd = FRand();
			bReadyToAttack = true;
			DesiredRotation = Rotator(Enemy.Location - Location);
			if ( CombatStyle > FRand() )
				GotoState('Charging'); 
			else
				GotoState('Attacking');
			return true;
		}
		return false;
	} 

	function AnimEnd()
	{
		PlayRunning();
		bFire = 0;
		bAltFire = 0;
		bReadyToAttack = true;
		Disable('AnimEnd');
	}
	
	function Timer()
	{
		bReadyToAttack = true;
		Enable('Bump');
		SetTimer(1.0, false);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		if ( Wall.IsA('Mover') && Mover(Wall).HandleDoor(self) )
		{
			if ( SpecialPause > 0 )
				Acceleration = vect(0,0,0);
			GotoState('Hunting', 'SpecialNavig');
			return;
		}
		Focus = Destination;
		if (PickWallAdjust())
			GotoState('Hunting', 'AdjustFromWall');
		else
			MoveTimer = -1.0;
	}

	function PickDestination()
	{
		local actor HitActor;
		local vector HitNormal, HitLocation, nextSpot, ViewSpot;
		local float posZ, elapsed;
		local bool bCanSeeLastSeen;
	
		// If no enemy, or I should see him but don't, then give up		
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			WhatToDoNext('','');
			return;
		}
	
		bAvoidLedges = false;
		elapsed = Level.TimeSeconds - HuntStartTime;
		if ( elapsed > 30 )
		{
				WhatToDoNext('','');
				return;
		}

		if ( JumpZ > 0 )
			bCanJump = true;
		
		if ( ActorReachable(Enemy) )
		{
			if ( (numHuntPaths < 8 + Skill) || (elapsed < 15)
				|| ((Normal(Enemy.Location - Location) Dot vector(Rotation)) > -0.5) )
			{
				Destination = Enemy.Location;
				MoveTarget = None;
				numHuntPaths++;
			}
			else
				WhatToDoNext('','');
			return;
		}
		numHuntPaths++;

		ViewSpot = Location + EyeHeight * vect(0,0,1);
		bCanSeeLastSeen = false;
		HitActor = Trace(HitLocation, HitNormal, LastSeenPos, ViewSpot, false);
		bCanSeeLastSeen = (HitActor == None);
		if ( bCanSeeLastSeen )
		{
			HitActor = Trace(HitLocation, HitNormal, LastSeenPos, Enemy.Location, false);
			bHunting = (HitActor != None);
		}
		else
			bHunting = true;

		if ( FindBestPathToward(Enemy) )
			return;
		MoveTarget = None;
		if ( bFromWall )
		{
			bFromWall = false;
			if ( !PickWallAdjust() )
			{
				if ( CanStakeOut() )
					GotoState('StakeOut');
				else
					WhatToDoNext('', '');
			}
			return;
		}
		
		if ( NumHuntPaths > 60 )
		{
			WhatToDoNext('', '');
			return;
		}

		if ( LastSeeingPos != vect(1000000,0,0) )
		{
			Destination = LastSeeingPos;
			LastSeeingPos = vect(1000000,0,0);		
			HitActor = Trace(HitLocation, HitNormal, Enemy.Location, ViewSpot, false);
			if ( HitActor == None )
			{
				If (VSize(Location - Destination) < 20)
				{
					HitActor = Trace(HitLocation, HitNormal, Enemy.Location, ViewSpot, false);
					if (HitActor == None)
					{
						SetEnemy(Enemy);
						return;
					}
				}
				return;
			}
		}

		bAvoidLedges = (CollisionRadius > 42);
		posZ = LastSeenPos.Z + CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Location - Enemy.OldLocation) * CollisionRadius;
		nextSpot.Z = posZ;
		HitActor = Trace(HitLocation, HitNormal, nextSpot , ViewSpot, false);
		if ( HitActor == None )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
			Destination = LastSeenPos;
		else
		{
			Destination = LastSeenPos;
			HitActor = Trace(HitLocation, HitNormal, LastSeenPos , ViewSpot, false);
			if ( HitActor != None )
			{
				// check if could adjust and see it
				if ( PickWallAdjust() || FindViewSpot() )
					GotoState('Hunting', 'AdjustFromWall');
				else if ( VSize(Enemy.Location - Location) < 1200 )
					GotoState('StakeOut');
				else
				{
					WhatToDoNext('Waiting', 'TurnFromWall');
					return;
				}
			}
		}
		LastSeenPos = Enemy.Location;				
	}	

	function bool FindViewSpot()
	{
		local vector X,Y,Z, HitLocation, HitNormal;
		local actor HitActor;
		local bool bAlwaysTry;
		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;
		
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location + 2 * Y * CollisionRadius, false);
		if ( HitActor == None )
		{
			Destination = Location + 2.5 * Y * CollisionRadius;
			return true;
		}

		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Location - 2 * Y * CollisionRadius, false);
		if ( HitActor == None )
		{
			Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Location - 2.5 * Y * CollisionRadius;
			else
				Destination = Location - 2.5 * Y * CollisionRadius;
			return true;
		}

		return false;
	}

	function BeginState()
	{
		if ( health <= 0 )
			log(self$" hunting while dead");
		SpecialGoal = None;
		SpecialPause = 0.0;
		bFromWall = false;
		SetAlertness(0.5);
		// Changed
//		if( !bHuntingTransmitted )
//		{
//			GotoState( 'TransmitHuntingMessage' );
//		}
	}

	function EndState()
	{
		bAvoidLedges = false;
		bHunting = false;
		if ( JumpZ > 0 )
			bCanJump = true;
	}

AdjustFromWall:
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	if ( MoveTarget != None )
		Goto('SpecialNavig');
	else
		Goto('Follow');

Begin:
	numHuntPaths = 0;
	HuntStartTime = Level.TimeSeconds;
AfterFall:
	TweenToRunning(0.15);
	bFromWall = false;

Follow:
	WaitForLanding();
	if ( CanSee(Enemy) )
		SetEnemy(Enemy);
	PickDestination();
SpecialNavig:
	if ( SpecialPause > 0.0 )
	{
		Disable('AnimEnd');
		Acceleration = vect(0,0,0);
		PlayChallenge();
		Sleep(SpecialPause);
		SpecialPause = 0.0;
		Enable('AnimEnd');
		Goto('AfterFall');
	}
	if (MoveTarget == None)
		MoveTo(Destination);
	else
		MoveToward(MoveTarget); 

	Goto('Follow');
}

//====================================================================================================
// Hunting State Expansion
//====================================================================================================

state TransmitHuntingMessage expands Hunting
{
	function BeginState()
	{
//		log( Self$" transmitting Hunting message." );
	}
	
	function MessagePlayers()
	{
		local PlayerPawn P;
		
		foreach allactors( class'PlayerPawn', P )
		{
			P.ClientMessage( self$": I'm hunting!" );
		}
	}
	
Begin:
	if ( FindCommunicateTarget() != None && !bTransmissionDead )
	{
		FinishAnim();
		Velocity *= 0;
		Acceleration *= 0;
		if( !bCommunicateTargetInRange )
		{
			PlayAnim( 'TalkREM', 0.25 );
		}
		else
		{
			TurnToward( CommunicateTarget );
			PlayAnim( 'WaveL', 0.25 );
		}
		Sleep( 0.15 );
//		log( "Playing Hunting Notification to "$CommunicateTarget );
		PlaySound( GetPhrase().SoundName, SLOT_Talk,, False );

		MessagePlayers();
		
		if( !bCommunicateTargetInRange )
		{
			SpaceMarine( CommunicateTarget ).PlaySound( GetPhrase().SoundName, SLOT_Misc, 200, False, 256 );
			SpaceMarine( CommunicateTarget ).MsgReceivedFrom = Self;
			SpaceMarine( CommunicateTarget ).bWarnedFriends = True;
		}
		FinishAnim();
		CommunicateTarget = None;
	}
	bCommunicating = False;
	bHuntingTransmitted = True;
	Gotostate('Hunting' );			
}
		

function MarineSound GetPhrase()
{
	local int VoiceIncrementer;
	local MarineSound Match;
	
	for( VoiceIncrementer = 0; VoiceIncrementer <= 19; VoiceIncrementer++ )
	{
		if( VoiceList[ VoiceIncrementer ].SoundName != None )
		{
			if( VoiceList[ VoiceIncrementer ].bPlayed == 0 )
			{
				if( VoiceList[ VoiceIncrementer ].UsedInState == GetStateName() && VoiceList[ VoiceIncrementer ].LastSaidBy != Self )
				{
					Match = VoiceList[ VoiceIncrementer ];
					Match.LastSaidby = Self;
					break;
				}
			}
		}
	}
	
	return Match;
}

function bool MultipleMarineCheck()
{
	local SpaceMarine Marine;
	foreach allactors( class'SpaceMarine', Marine )
	{
		if( Marine.Health > 0 && Marine != self )
		{
			return true;
		}
	}
	
	return false;
}

		

state ReceiveIncomingMessage expands Acquisition
{

	function BeginState()
	{
//		log( "ReceiveIncomingMessage state entered by "$Self$" at: "$Level.TimeSeconds );
	}
	
	function EndState()
	{
//		log( "ReceiveIncomingMessage state exited by "$Self$" at: "$Level.TimeSeconds );
	}

Receiving:
	if( PhraseDirector.Marine.Enemy != Enemy )
	{
		Enemy = PhraseDirector.Marine.Enemy;
	}	
	
	While( SpaceMarine( PhraseDirector.Marine ).bCommunicating )	
	{
		Sleep( 0.1 );
	}			
	
	bCommunicating = True;

	PhraseDirector.Marine = Self;
	PhraseDirector.GotoState( 'BroadcastingSound' );
	if( !PhraseDirector.bReceiverInRange )
	{
		PlayAnim( 'TalkREM', 0.25 );
	}
	else
	{
		TurnToward( PhraseDirector.Receiver );
		PlayAnim( 'WaveL', 0.25 );
	}
	Sleep( 0.15 );	
	PhraseDirector.Broadcast();
	Sleep( PhraseDirector.GetCurrentSoundDuration() - 1 );
	bCommunicating = False;
	GotoState( 'Hunting' );
}


// make sure the marine starts with the right weapon
auto state StartUp
{
	ignores bump, takedamage, WarnTarget;
	
	function BeginState()
	{
		
		if( bBeamingIn )
		{
			Style = STY_Translucent;
			bMeshEnviroMap = True;
			Texture = Texture'CloakTexture';
			ScaleGlow = 0.01;
			Fatness = 250;
		}
		
		SetMovementPhysics(); 
		if ( Physics == PHYS_Walking )
		{
			SetPhysics( PHYS_Falling );
		}
		if( StartWeapon == none )
		{
			StartWeapon = class'CARifle';
		}
		
		if ( StartWeapon != None )
		{
			myWeapon = Spawn( StartWeapon );
			myWeapon.PickupSound = none;
			myWeapon.SelectSound = none;
			myWeapon.CockingSound = none;
			if ( myWeapon != None )
			{
				myWeapon.ReSpawnTime = 0.0;
			}
		}
	}

Begin:
	if( !bIsPlayer )
	{
		bIsPlayer = True;
		myWeapon.Touch( self );
		bIsPlayer = False;
	}
	else myWeapon.Touch( self );
	myWeapon.PickupSound = myWeapon.Default.PickupSound;
	myWeapon.SelectSound = myWeapon.Default.SelectSound;
	myWeapon.CockingSound = myWeapon.Default.CockingSound;

	if (bIsFemale && !bFemale)
		SetFemaleGender();

	if( MarineBeamController != none )
	{
		bHidden = true;
		Land = none;
		LandGrunt = none;
		Spawn( class'Octagon',,, Location );
		Sleep( 2.0 );
		GotoState( 'BeamingIn' );
	}
	else
	{
		Mesh = default.Mesh;
		Style = STY_Normal;
		bMeshEnviroMap = False;
		Texture = Default.Texture;
		Skin = Default.Skin;
		ScaleGlow = Default.ScaleGlow;
		Fatness = Default.Fatness;
		if( Weapon != none )
		{
			Weapon.Style = STY_Normal;
			Weapon.bMeshEnviroMap = false;
			Weapon.Texture = Weapon.Default.Texture;
			Weapon.Scaleglow = Weapon.Default.ScaleGlow;
			Weapon.Fatness = Weapon.Default.Fatness;
		}

		WhatToDoNext('','');
	}
}
event Touch( Actor Other )
{
	if( Inventory(Other)!=None && !bIsPlayer )
	{
		bIsPlayer = True;
		Other.Touch(self);
		bIsPlayer = False;
	}
	Super.Touch(Other);
}
function HidePlayer()
{
	if( !bIsPlayer )
		Destroy();
	else Super.HidePlayer();
}
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, Died, Bump, Trigger, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, SetFall, PainTimer;

	function ReStartPlayer()
	{
		if( bHidden && Level.Game.RestartPlayer(self) )
		{
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			ViewRotation = Rotation;
			ReSetSkill();
			SetPhysics(PHYS_Falling);
			GotoState('Roaming');
		}
		else
			GotoState('Dying', 'TryAgain');
	}
	
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, name damageType)
	{
		if ( !bHidden )
			Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
	}
	
	function BeginState()
	{
		if( Weapon != none )
			Weapon.Destroy();
		SetTimer(0, false);
		Enemy = None;
		AmbushSpot = None;
		bFire = 0;
		bAltFire = 0;
		if( Weapon != none )
			Weapon.AmmoType.AmmoAmount = Weapon.Default.AmmoType.AmmoAmount - Rand( 4 );
		if( MarineBeamController != none )
			MarineBeamController.SubtractMarine( Self );
		bHidden = true;
		SpawnCarcass();
		if( !Level.Game.IsA( 'MarineMatch' ) )
			Destroy();
	}

	function EndState()
	{
		if ( Health <= 0 )
			log(self$" health still <0");
}

/*Begin:
	Sleep(0.2);
	if ( !bHidden )
	{
		SpawnCarcass();
		HidePlayer();
	}
TryAgain:
	Sleep(0.25 + DeathMatchGame(Level.Game).NumBots * FRand());
	ReStartPlayer();
	Goto('TryAgain');
WaitingForStart:
	bHidden = true;*/
}


// Beaming in effect is a placeholder

state BeamingIn
{
	ignores TakeDamage, Bump, SeePlayer, WarnTarget;
	
	function BeginState()
	{
		Mass = 20000;
		Fatness = 5;
		Land = default.Land;
		LandGrunt = default.LandGrunt;
		bHidden = false;		
		LoopAnim( 'Breath2l', 0.3 );
//		Style = STY_Translucent;
//		bMeshEnviroMap = True;
//		Texture = Texture'CloakTexture';
//		Skin = Texture'CloakTexture';
//		ScaleGlow = 0.01;
//		Fatness = 250;
		Style = STY_Translucent;
		ScaleGlow = 0.0;
		PlaySound( sound'CloakOff' );	
		BeamEffect = Spawn( class'UPakShieldEffect', Self,, Location, Rotation );
		BeamEffect.Mesh = Mesh;	
		BeamEffect.DrawScale = DrawScale;	
//		if( Weapon != none )
//		{
//			UPSE = Spawn( class'UPakShieldEffect', Weapon,, Weapon.Location, Weapon.Rotation );
//		}
		if( Weapon != none )
		{
			Weapon.Style = STY_Translucent;
			Weapon.bMeshEnviroMap = true;
			Weapon.Texture = Texture'upak.beamtexture';
			Weapon.ScaleGlow = 0.01;
			Weapon.Fatness = 250;
		}
		
		SetTimer( 3.5, False );
	}
	
	function Tick( float DeltaTime )
	{
//		if( ScaleGlow < 1.5 )
//		{
//			ScaleGlow += 0.01;
			if( Weapon != none && Weapon.ScaleGlow < 1.5 )
			{
				Weapon.ScaleGlow += 0.001;
			}
			else
			{
				Weapon.Style = STY_Normal;
				Weapon.bMeshEnviroMap = false;
				Weapon.ScaleGlow = Weapon.Default.ScaleGlow;
				Weapon.Texture = Weapon.Default.Texture;
				Weapon.Fatness = Weapon.Default.Fatness;
			}
			
	if( bHidden )
		{
			bHidden = false;
			Weapon.bHidden = false;
		}
		
		else
		
		if( FRand() < 0.2 && !bHidden )
		{
			bHidden = true;
			Weapon.bHidden = true;
		}
		

//			if( Fatness > Default.Fatness )
//	{
//		Fatness -= 10;
				if( Weapon != none && Weapon.Fatness > Weapon.Default.Fatness )
				{
					Weapon.Fatness -= 10;
				}
//	}
//}
		if( Fatness < 128 )
		{
			Fatness++;
		}
		
	}
	
	function Timer()
	{
		BeamEffect.GotoState( 'OwnerFadeIn' );
//		bHidden = false;
//		Disable( 'Tick' );
//		Style = STY_Normal;
		bHidden = false;
		bMeshEnviroMap = False;
//		Texture = Default.Texture;
//		Skin = Default.Skin;
//		ScaleGlow = Default.ScaleGlow;
//		Fatness = Default.Fatness;
//		if( Weapon != none )
//		{
//			Weapon.Style = STY_Normal;
//			Weapon.bMeshEnviroMap = false;
//			Weapon.Texture = Weapon.Default.Texture;
//			Weapon.Scaleglow = Weapon.Default.ScaleGlow;
//			Weapon.Fatness = Weapon.Default.Fatness;
//		}
	}

Begin:
	if( Enemy != none )
	{
		TurnToward( Enemy );
	}
	
	else
	{
		TurnToward( MarineBeamController.GetPlayerPawn() );
//		Enemy = MarineBeamController.GetPlayerPawn();
	}
	
	sleep( 5.5 );
	bHidden = false;
	Style=STY_Normal;
	Weapon.Texture = Weapon.Default.Texture;
	Weapon.ScaleGlow = Weapon.Default.ScaleGlow;
	Mass = Default.Mass;
	Weapon.Fatness = Weapon.Default.Fatness;
	Weapon.bMeshEnviroMap = false;
	Weapon.Style=STY_Normal;
//	BeamEffect.Fatness = 129;
	BeamEffect.LifeSpan = 1;
	BeamEffect.Texture = texture'upak.Beam2';
	Enemy = MarineBeamController.GetPlayerPawn();
	Target = MarineBeamController.GetPlayerPawn();
	Fatness = Default.Fatness;
	GotoState( 'Hunting' );
//	WhatToDoNext( '', '' );
}

		
function FireWeapon()
{
	local bool bUseAltMode;

	if( Weapon != none )
	{
		Weapon.AmmoType.AmmoAmount = 999;
	}
	
	if ( (Enemy == None) && bShootSpecial )
	{
		//fake use dispersion pistol
		Spawn(class'DispersionAmmo',,, Location,Rotator(Target.Location - Location));
		return;
	}

	bUseAltMode = SwitchToBestWeapon();

	if( Weapon!=None )
	{
		if ( (Weapon.AmmoType != None) && (Weapon.AmmoType.AmmoAmount <= 0) )
		{
			bReadyToAttack = true;
			return;
		}

 		if ( !bFiringPaused && !bShootSpecial && (Enemy != None) )
 			Target = Enemy;
		ViewRotation = Rotation;
		if ( bUseAltMode )
		{
			bFire = 0;
			bAltFire = 1;
			Weapon.AltFire(1.0);
		}
		else
		{
			bFire = 1;
			bAltFire = 0;
			Weapon.Fire(1.0);
		}
		PlayFiring();
	}
	bShootSpecial = false;
}


function Died(pawn Killer, name damageType, vector HitLocation)
{
	if( MarineBeamController != none )
	{
		MarineBeamController.SubtractMarine( Self );
		MarineBeamController = None;
	}
	if( Weapon != none && Weapon.AmmoType != none )
		Weapon.AmmoType.AmmoAmount =
			Max(int(Weapon.PickupAmmoCount > 0 || Weapon.AmmoType.Default.AmmoAmount > 0),
				Weapon.AmmoType.Default.AmmoAmount - Rand(3));
	Super.Died(Killer,damageType,HitLocation);
} 


state Charging
{
	function BeginState()
	{
		if( MarinesTalk() && FRand() < 0.3 && Health > 50 )
		{		
			MyVoicePack.Talker = self;
			MyVoicePack.SetTimer( 0.1, false );
			MyVoicePack.bChargePhrase = true;
		}
		Super.BeginState();
	}
}



function bool MarinesTalk()
{
	if( MyVoicePack!=None && MyVoicePack.LastTalker!=self )
		return true;
	else return false;
}


function PlayVictoryDance()
{
	if( MyVoicePack!=None )
	{
		GotoState( 'Victory' );
	}
}

state Victory
{
	Begin:
	
	FinishAnim();
	Acceleration = vect( 0, 0, 0 );
	Velocity = vect( 0, 0, 0 );
	PlayAnim( 'TalkREM', 0.3 );
	FinishAnim();
	if( FRand() < 0.5 )
	{
		PlayAnim( 'TauntL', 3.3 );
		FinishAnim();
	}
	GotoState( 'Roaming' );
}

	
state TacticalMove
{
ignores SeePlayer, HearNoise;

	function SetFall()
	{
		Acceleration = vect(0,0,0);
		Destination = Location;
		NextState = 'Attacking'; 
		NextLabel = 'Begin';
		NextAnim = 'Breath1l';
		GotoState('FallingState');
	}

	function WarnTarget(Pawn shooter, float projSpeed, vector FireDir)
	{	
		if ( bCanFire && (FRand() < 0.4) ) 
			return;

		Super.WarnTarget(shooter, projSpeed, FireDir);
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
		if ( health <= 0 )
			return;
		if ( NextState == 'TakeHit' )
		{
			NextState = 'TacticalMove'; 
			NextLabel = 'TakeHit';
			GotoState('TakeHit'); 
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Focus = Destination;
		//if (PickWallAdjust())
		//	GotoState('TacticalMove', 'AdjustFromWall');
		if ( bChangeDir || (FRand() < 0.5) 
			|| (((Enemy.Location - Location) Dot HitNormal) < 0) )
		{
			DesiredRotation = Rotator(Enemy.Location - location);
			GiveUpTactical(false);
		}
		else
		{
			bChangeDir = true;
			Destination = Location - HitNormal * FRand() * 500;
		}
	}

	function FearThisSpot(Actor aSpot)
	{
		Destination = Location + 120 * Normal(Location - aSpot.Location); 
	}

	function AnimEnd() 
	{
		PlayCombatMove();
	}

	function Timer()
	{
		bReadyToAttack = True;
		Enable('Bump');
		Target = Enemy;
		if (VSize(Enemy.Location - Location) 
				<= (MeleeRange + Enemy.CollisionRadius + CollisionRadius))
			GotoState('RangedAttack');		 
		else if ( FRand() > 0.5 + 0.17 * skill ) 
			GotoState('RangedAttack');
	}

	function EnemyNotVisible()
	{
		if ( !bGathering && (aggressiveness > relativestrength(enemy)) )
		{
			if (ValidRecovery())
				GotoState('TacticalMove','RecoverEnemy');
			else
				GotoState('Attacking');
		}
		Disable('EnemyNotVisible');
	}

	function bool ValidRecovery()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal;
		
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, LastSeeingPos, false);
		return (HitActor == None);
	}
		
	function GiveUpTactical(bool bNoCharge)
	{	
		if ( !bNoCharge && (2 * CombatStyle > (3 - Skill) * FRand()) )
			GotoState('Charging');
		else if ( bReadyToAttack && (skill > 3 * FRand() - 1) )
			GotoState('RangedAttack');
		else
			GotoState('RangedAttack', 'Challenge'); 
	}		

	function bool TryToward(inventory Inv, float Weight)
	{
		local bool success; 
		local vector pickdir, collSpec, minDest, HitLocation, HitNormal;
		local Actor HitActor;

		if ( (Weight < 0.0008) && ((Weight < 0.0008 - 0.0002 * skill) 
				|| !Enemy.LineOfSightTo(Inv)) )
			return false;

		pickdir = Inv.Location - Location;
		if ( Physics == PHYS_Walking )
			pickDir.Z = 0;
		pickDir = Normal(PickDir);

		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + FMin(160.0, 3*CollisionRadius) * pickDir;
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if ( success )
			{
				Destination = Inv.Location;
				bGathering = true;
				if ( 2.7 * FRand() < skill )
					GotoState('TacticalMove','DoStrafeMove');
				else
					GotoState('TacticalMove','DoDirectMove');
				return true;
			}
		}

		return false;
	}

	function PainTimer()
	{
		if ( (FootRegion.Zone.bPainZone) && (FootRegion.Zone.DamagePerSec > 0)
			&& (FootRegion.Zone.DamageType != ReducedDamageType) )
			GotoState('Retreating');
		Super.PainTimer();
	}


/* PickDestination()
Choose a destination for the tactical move, based on aggressiveness and the tactical
situation. Make sure destination is reachable
*/
	function PickDestination(bool bNoCharge)
	{
		local inventory Inv, BestInv, SecondInv;
		local float Bestweight, NewWeight, MaxDist, SecondWeight;

		// possibly pick nearby inventory
		// higher skill bots will always strafe, lower skill
		// both do this less, and strafe less

		if ( !bReadyToAttack && (TimerRate == 0.0) )
			SetTimer(0.7, false);
		if ( Level.TimeSeconds - LastInvFind < 2.5 - 0.5 * skill )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		LastInvFind = Level.TimeSeconds;
		bGathering = false;
		BestWeight = 0;
		MaxDist = 600 + 70 * skill;
		foreach visiblecollidingactors(class'Inventory', Inv, MaxDist)
			if ( (Inv.IsInState('PickUp')) && (Inv.MaxDesireability/200 > BestWeight)
				&& (Inv.Location.Z < Location.Z + MaxStepHeight + CollisionHeight)
				&& (Inv.Location.Z > FMin(Location.Z, Enemy.Location.Z) - CollisionHeight) )
			{
				NewWeight = inv.BotDesireability(self)/VSize(Inv.Location - Location);
				if ( NewWeight > BestWeight )
				{
					SecondWeight = BestWeight;
					BestWeight = NewWeight;
					SecondInv = BestInv;
					BestInv = Inv;
				}
			}

		if ( BestInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(BestInv, BestWeight) )
			return;

		if ( SecondInv == None )
		{
			PickRegDestination(bNoCharge);
			return;
		}

		if ( TryToward(SecondInv, SecondWeight) )
			return;

		PickRegDestination(bNoCharge);
	}

	function PickRegDestination(bool bNoCharge)
	{
		local vector pickdir, enemydir, enemyPart, Y, minDest;
		local actor HitActor;
		local vector HitLocation, HitNormal, collSpec;
		local float Aggression, enemydist, minDist, strafeSize, optDist;
		local bool success, bNoReach;
	
		bChangeDir = false;
		if (Region.Zone.bWaterZone && !bCanSwim && bCanFly)
		{
			Destination = Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}
		if ( Enemy.Region.Zone.bWaterZone )
			bNoCharge = bNoCharge || !bCanSwim;
		else 
			bNoCharge = bNoCharge || (!bCanFly && !bCanWalk);
		
		success = false;
		enemyDist = VSize(Location - Enemy.Location);
		Aggression = 2 * (CombatStyle + FRand()) - 1.1;
		if ( Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear) && (CombatStyle > 0) )
			Aggression = Aggression - 2 - 2 * CombatStyle;
		if ( Weapon != None )
			Aggression += 2 * Weapon.SuggestAttackStyle();
		if ( Enemy.Weapon != None )
			Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();

		if ( enemyDist > 1000 )
			Aggression += 1;
		if ( !bNoCharge )
			bNoCharge = ( Aggression < FRand() );

		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
		{
			if (Location.Z > Enemy.Location.Z + 140) //tactical height advantage
				Aggression = FMax(0.0, Aggression - 1.0 + CombatStyle);
			else if (Location.Z < Enemy.Location.Z - CollisionHeight) // below enemy
			{
				if ( !bNoCharge && (Aggression > 0) && (FRand() < 0.6) )
				{
					GotoState('Charging');
					return;
				}
				else if ( (enemyDist < 1.1 * (Enemy.Location.Z - Location.Z)) 
						&& !actorReachable(Enemy) ) 
				{
					bNoReach = true;
					aggression = -1.5 * FRand();
				}
			}
		}
	
		if (!bNoCharge && (Aggression > 2 * FRand()))
		{
			if ( bNoReach && (Physics != PHYS_Falling) )
			{
				TweenToRunning(0.15);
				GotoState('Charging', 'NoReach');
			}
			else
				GotoState('Charging');
			return;
		}

		if (enemyDist > FMax(VSize(OldLocation - Enemy.OldLocation), 240))
			Aggression += 0.4 * FRand();
			 
		enemydir = (Enemy.Location - Location)/enemyDist;
		minDist = FMin(160.0, 3*CollisionRadius);
		optDist = 80 + FMin(EnemyDist, 250 * (FRand() + FRand()));  
		Y = (enemydir Cross vect(0,0,1));
		if ( Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else 
			enemydir.Z = FMax(0,enemydir.Z);
			
		strafeSize = FMax(-0.7, FMin(0.85, (2 * Aggression * FRand() - 0.3)));
		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		collSpec.X = CollisionRadius;
		collSpec.Y = CollisionRadius;
		collSpec.Z = FMax(6, CollisionHeight - 18);
		
		minDest = Location + minDist * (pickdir + enemyPart);
		HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
		if (HitActor == None)
		{
			success = (Physics != PHYS_Walking);
			if ( !success )
			{
				collSpec.X = FMin(14, 0.5 * CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
				success = (HitActor != None);
			}
			if (success)
				Destination = minDest + (pickdir + enemyPart) * optDist;
		}
	
		if ( !success )
		{					
			collSpec.X = CollisionRadius;
			collSpec.Y = CollisionRadius;
			minDest = Location + minDist * (enemyPart - pickdir); 
			HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
			if (HitActor == None)
			{
				success = (Physics != PHYS_Walking);
				if ( !success )
				{
					collSpec.X = FMin(14, 0.5 * CollisionRadius);
					collSpec.Y = collSpec.X;
					HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
					success = (HitActor != None);
				}
				if (success)
					Destination = minDest + (enemyPart - pickdir) * optDist;
			}
			else 
			{
				if ( (CombatStyle <= 0) || (Enemy.bIsPlayer && (AttitudeTo(Enemy) == ATTITUDE_Fear)) )
					enemypart = vect(0,0,0);
				else if ( (enemydir Dot enemyPart) < 0 )
					enemyPart = -1 * enemyPart;
				pickDir = Normal(enemyPart - pickdir + HitNormal);
				minDest = Location + minDist * pickDir;
				collSpec.X = CollisionRadius;
				collSpec.Y = CollisionRadius;
				HitActor = Trace(HitLocation, HitNormal, minDest, Location, false, collSpec);
				if (HitActor == None)
				{
					success = (Physics != PHYS_Walking);
					if ( !success )
					{
						collSpec.X = FMin(14, 0.5 * CollisionRadius);
						collSpec.Y = collSpec.X;
						HitActor = Trace(HitLocation, HitNormal, minDest - (18 + MaxStepHeight) * vect(0,0,1), minDest, false, collSpec);
						success = (HitActor != None);
					}
					if (success)
						Destination = minDest + pickDir * optDist;
				}
			}	
		}
					
		if ( !success )
			GiveUpTactical(bNoCharge);
		else 
		{
			pickDir = (Destination - Location);
			enemyDist = VSize(pickDir);
			if ( enemyDist > minDist + 2 * CollisionRadius )
			{
				pickDir = pickDir/enemyDist;
				HitActor = Trace(HitLocation, HitNormal, Destination + 2 * CollisionRadius * pickdir, Location, false);
				if ( (HitActor != None) && ((HitNormal Dot pickDir) < -0.6) )
					Destination = HitLocation - 2 * CollisionRadius * pickdir;
			}
		}
	}

	function BeginState()
	{
		if( MarinesTalk() && FRand() < 0.3 && Health > 50 )
		{		
			MyVoicePack.Talker = self;
			MyVoicePack.SetTimer( 0.1, false );
			MyVoicePack.bChargePhrase = true;
		}
		MinHitWall += 0.15;
		bAvoidLedges = ( !bCanJump && (CollisionRadius > 40) );
		bCanJump = false;
		bCanFire = false;
	}
	
	function EndState()
	{
		bAvoidLedges = false;
		MinHitWall -= 0.15;
		if (JumpZ > 0)
			bCanJump = true;
	}

//FIXME - what if bReadyToAttack at start
TacticalTick:
	Sleep(0.02);	
Begin:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(false);

DoMove:
	if ( !bCanStrafe )
	{ 
DoDirectMove:
		Enable('AnimEnd');
		if ( GetAnimGroup(AnimSequence) == 'MovingAttack' )
		{
			AnimSequence = '';
			TweenToRunning(0.12);
		}
		HaltFiring();
		MoveTo(Destination);
	}
	else
	{
DoStrafeMove:
		Enable('AnimEnd');
		bCanFire = true;
		StrafeFacing(Destination, Enemy);	
	}

	if ( (Enemy != None) && !LineOfSightTo(Enemy) && ValidRecovery() )
		Goto('RecoverEnemy');
	else
	{
		bReadyToAttack = true;
		GotoState('Attacking');
	}
	
NoCharge:
	TweenToRunning(0.15);
	Enable('AnimEnd');
	if (Physics == PHYS_Falling)
	{
		DesiredRotation = Rotator(Enemy.Location - Location);
		Focus = Enemy.Location;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination(true);
	Goto('DoMove');
	
AdjustFromWall:
	Enable('AnimEnd');
	StrafeTo(Destination, Focus); 
	Destination = Focus; 
	Goto('DoMove');

TakeHit:
	TweenToRunning(0.12);
	Goto('DoMove');

RecoverEnemy:
	Enable('AnimEnd');
	bReadyToAttack = true;
	HidingSpot = Location;
	bCanFire = false;
	Destination = LastSeeingPos + 3 * CollisionRadius * Normal(LastSeeingPos - Location);
	if ( bCanStrafe || (VSize(LastSeeingPos - Location) < 3 * CollisionRadius) )
		StrafeFacing(Destination, Enemy);
	else
		MoveTo(Destination);
	if ( Weapon == None ) 
		Acceleration = vect(0,0,0);
	if ( NeedToTurn(Enemy.Location) )
	{
		PlayTurning();
		TurnToward(Enemy);
	}
	if ( CanFireAtEnemy() )
	{
		Disable('AnimEnd');
		DesiredRotation = Rotator(Enemy.Location - Location);
		if ( Weapon == None ) 
		{
			PlayRangedAttack();
			FinishAnim();
			TweenToRunning(0.1);
			bReadyToAttack = false;
			SetTimer(TimeBetweenAttacks, false);
		}
		else
		{
			FireWeapon();
			if ( Weapon.bSplashDamage )
			{
				bFire = 0;
				bAltFire = 0;
				Acceleration = vect(0,0,0);
				Sleep(0.1);
			}
		}

		if ( (FRand() + 0.1 > CombatStyle) )
		{
			Enable('EnemyNotVisible');
			Enable('AnimEnd');
			Destination = HidingSpot + 4 * CollisionRadius * Normal(HidingSpot - Location);
			Goto('DoMove');
		}
	}

	GotoState('Attacking');
}

function Destroyed()
{
	if( MarineBeamController != none )
	{
		MarineBeamController.SubtractMarine( Self );
		MarineBeamController = None;
	}
	Super.Destroyed();
}

defaultproperties
{
				VoiceList(0)=(duration=3.500000,UsedInState="WarnFriends")
				VoiceList(1)=(duration=2.500000,UsedInState="TransmitHuntingMessage")
				VoiceList(2)=(duration=2.500000,UsedInState="AcknowledgeWarning")
				CarcassType=Class'UPak.SpaceMarineCarcass'
				RefireRate=0.700000
				bIsWuss=True
				bLeadTarget=False
				GroundSpeed=300.000000
				AccelRate=1500.000000
				JumpZ=300.000000
				SightRadius=1000.000000
				Health=80
				AttitudeToPlayer=ATTITUDE_Ignore
				AnimSequence="Breath1L"
				Mesh=LodMesh'UPak.marine'
				MultiSkins(1)=Texture'UPak.Skins.JMarine7'
				MultiSkins(2)=Texture'UPak.Skins.JMarine8'
				CollisionRadius=20.500000
				CollisionHeight=41.000000
				Mass=125.000000
}