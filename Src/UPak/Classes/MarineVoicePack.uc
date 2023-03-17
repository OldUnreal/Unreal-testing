// Moved all talking from CrashSiteGame to here
Class MarineVoicePack extends Info;

#exec OBJ LOAD FILE=Marine.uax

var() config bool bNoTalking,bCanTalkBS;
var() sound MaleKillSounds[7],FemaleKillSounds[6],MaleHelpReq[9],FemaleHelpReq[8],MaleAcquireTalk[12],FemaleAcquireTalk[9],MaleCharge[18],FemaleCharge[16];
var SpaceMarine Talker, LastTalker;
var bool bKillPhrase, bHelpPhrase, bAcquirePhrase, bChargePhrase;

function RequestBackup( SpaceMarine Other )
{
	if( Other==LastTalker || bNoTalking )
		Return;
	Talker = Other;
	bHelpPhrase = true;
	SetTimer( 0.1, false );
}
function TalkVictory( SpaceMarine Other )
{
	Talker = Other;
	bKillPhrase = true;
	SetTimer( 1.0 + FRand(), false );
}
function Timer()
{
	if( bKillPhrase && Talker != None )
	{
		Talker.PlayVictoryDance();
		InitSound();
	}
	else InitSound();
}

function InitSound()
{
	local int RandNum;

	if( bKillPhrase && Talker != None )
	{
		if( !Talker.bFemale )
		{
			RandNum = Rand( ArrayCount(MaleKillSounds) );
			Talker.PlaySound( MaleKillSounds[RandNum], SLOT_Talk,, false );
		}
		else
		{
			RandNum = Rand( ArrayCount(FemaleKillSounds) );
			Talker.PlaySound( FemaleKillSounds[RandNum], SLOT_Talk,, false );
		}
		bKillPhrase = false;
	}

	else if( bHelpPhrase )
	{
		if( !Talker.bIsFemale )
		{
			RandNum = Rand( ArrayCount(MaleHelpReq) );
			Talker.PlaySound( MaleHelpReq[RandNum], SLOT_Talk,, false );
		}
		else
		{
			RandNum = Rand( ArrayCount(FemaleHelpReq) );
			Talker.PlaySound( FemaleHelpReq[RandNum], SLOT_Talk,, false );
		}
		LastTalker = Talker;
		bHelpPhrase = false;
	}
	else if( bAcquirePhrase )
	{
		if( !Talker.bIsFemale )
		{
			if( bCanTalkBS )
				RandNum = Rand( ArrayCount(MaleAcquireTalk) );
			else RandNum = Rand( ArrayCount(MaleAcquireTalk)-4 );
			Talker.PlaySound( MaleAcquireTalk[RandNum], SLOT_Talk,, false );
		}
		else
		{
			if( bCanTalkBS )
				RandNum = Rand( ArrayCount(FemaleAcquireTalk) );
			else RandNum = Rand( ArrayCount(FemaleAcquireTalk)-4 );
			Talker.PlaySound( FemaleAcquireTalk[RandNum], SLOT_Talk,, false );
		}
		LastTalker = Talker;
		bAcquirePhrase = false;
	}
	else if( bChargePhrase )
	{
		if( !Talker.bIsFemale )
		{
			if( bCanTalkBS )
				RandNum = Rand( ArrayCount(MaleCharge) );
			else RandNum = Rand( ArrayCount(MaleCharge)-5 );
			Talker.PlaySound( MaleCharge[RandNum], SLOT_Talk,, false );
		}
		else
		{
			if( bCanTalkBS )
				RandNum = Rand( ArrayCount(FemaleCharge) );
			else RandNum = Rand( ArrayCount(FemaleCharge)-5 );
			Talker.PlaySound( FemaleCharge[RandNum], SLOT_Talk,, false );
		}
		LastTalker = Talker;
		bChargePhrase = false;
	}
}

defaultproperties
{
     bCanTalkBS=True
     MaleKillSounds(0)=Sound'Marine.Ms110'
     MaleKillSounds(1)=Sound'Marine.Ms115'
     MaleKillSounds(2)=Sound'Marine.Ms116'
     MaleKillSounds(3)=Sound'Marine.Ms210b'
     MaleKillSounds(4)=Sound'Marine.Ms210a'
     MaleKillSounds(5)=Sound'Marine.Ms215b'
     MaleKillSounds(6)=Sound'Marine.Ms215a'
     FemaleKillSounds(0)=Sound'Marine.Ms315b'
     FemaleKillSounds(1)=Sound'Marine.Ms310b'
     FemaleKillSounds(2)=Sound'Marine.Ms316a'
     FemaleKillSounds(3)=Sound'Marine.Ms316b'
     FemaleKillSounds(4)=Sound'Marine.Ms315a'
     FemaleKillSounds(5)=Sound'Marine.Ms310a'
     MaleHelpReq(0)=Sound'Marine.Ms214a'
     MaleHelpReq(1)=Sound'Marine.Ms214b'
     MaleHelpReq(2)=Sound'Marine.Ms209a'
     MaleHelpReq(3)=Sound'Marine.Ms209b'
     MaleHelpReq(4)=Sound'Marine.Ms204a'
     MaleHelpReq(5)=Sound'Marine.Ms204b'
     MaleHelpReq(6)=Sound'Marine.Ms104'
     MaleHelpReq(7)=Sound'Marine.Ms109'
     MaleHelpReq(8)=Sound'Marine.Ms114'
     FemaleHelpReq(0)=Sound'Marine.Ms304a'
     FemaleHelpReq(1)=Sound'Marine.Ms304b'
     FemaleHelpReq(2)=Sound'Marine.Ms309a'
     FemaleHelpReq(3)=Sound'Marine.Ms309b'
     FemaleHelpReq(4)=Sound'Marine.Ms313a'
     FemaleHelpReq(5)=Sound'Marine.Ms313b'
     FemaleHelpReq(6)=Sound'Marine.Ms314a'
     FemaleHelpReq(7)=Sound'Marine.Ms314b'
     MaleAcquireTalk(0)=Sound'Marine.Ms105'
     MaleAcquireTalk(1)=Sound'Marine.Ms106'
     MaleAcquireTalk(2)=Sound'Marine.Ms107'
     MaleAcquireTalk(3)=Sound'Marine.Ms108'
     MaleAcquireTalk(4)=Sound'Marine.Ms206a'
     MaleAcquireTalk(5)=Sound'Marine.Ms206b'
     MaleAcquireTalk(6)=Sound'Marine.Ms205b'
     MaleAcquireTalk(7)=Sound'Marine.Ms205a'
     MaleAcquireTalk(8)=Sound'Marine.Ms202a'
     MaleAcquireTalk(9)=Sound'Marine.Ms202b'
     MaleAcquireTalk(10)=Sound'Marine.Ms201a'
     MaleAcquireTalk(11)=Sound'Marine.Ms203b'
     FemaleAcquireTalk(0)=Sound'Marine.Ms306a'
     FemaleAcquireTalk(1)=Sound'Marine.Ms306b'
     FemaleAcquireTalk(2)=Sound'Marine.Ms308a'
     FemaleAcquireTalk(3)=Sound'Marine.Ms305a'
     FemaleAcquireTalk(4)=Sound'Marine.Ms305b'
     FemaleAcquireTalk(5)=Sound'Marine.Ms303a'
     FemaleAcquireTalk(6)=Sound'Marine.Ms302a'
     FemaleAcquireTalk(7)=Sound'Marine.Ms302b'
     FemaleAcquireTalk(8)=Sound'Marine.Ms301b'
     MaleCharge(0)=Sound'Marine.Ms107'
     MaleCharge(1)=Sound'Marine.Ms108'
     MaleCharge(2)=Sound'Marine.Ms111'
     MaleCharge(3)=Sound'Marine.Ms112'
     MaleCharge(4)=Sound'Marine.Ms113'
     MaleCharge(5)=Sound'Marine.Ms207a'
     MaleCharge(6)=Sound'Marine.Ms208a'
     MaleCharge(7)=Sound'Marine.Ms211a'
     MaleCharge(8)=Sound'Marine.Ms211b'
     MaleCharge(9)=Sound'Marine.Ms212a'
     MaleCharge(10)=Sound'Marine.Ms212b'
     MaleCharge(11)=Sound'Marine.Ms213a'
     MaleCharge(12)=Sound'Marine.Ms213b'
     MaleCharge(13)=Sound'Marine.Ms101a'
     MaleCharge(14)=Sound'Marine.Ms101b'
     MaleCharge(15)=Sound'Marine.Ms103a'
     MaleCharge(16)=Sound'Marine.Ms202a'
     MaleCharge(17)=Sound'Marine.Ms202b'
     FemaleCharge(0)=Sound'Marine.Ms313a'
     FemaleCharge(1)=Sound'Marine.Ms313b'
     FemaleCharge(2)=Sound'Marine.Ms312a'
     FemaleCharge(3)=Sound'Marine.Ms312b'
     FemaleCharge(4)=Sound'Marine.Ms311a'
     FemaleCharge(5)=Sound'Marine.Ms311b'
     FemaleCharge(6)=Sound'Marine.Ms310a'
     FemaleCharge(7)=Sound'Marine.Ms310b'
     FemaleCharge(8)=Sound'Marine.Ms308a'
     FemaleCharge(9)=Sound'Marine.Ms307a'
     FemaleCharge(10)=Sound'Marine.Ms307b'
     FemaleCharge(11)=Sound'Marine.Ms301a'
     FemaleCharge(12)=Sound'Marine.Ms302a'
     FemaleCharge(13)=Sound'Marine.Ms302b'
     FemaleCharge(14)=Sound'Marine.Ms303a'
     FemaleCharge(15)=Sound'Marine.Ms303b'
}
