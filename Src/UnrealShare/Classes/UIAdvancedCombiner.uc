class UIAdvancedCombiner extends UIParticleSystem;

enum ERotationType
{
	ROT_Default,                                        // rotation will not be changed
	ROT_Spawner,                                        // emitter will have EmitterMultiSpawner rotation
	ROT_Custom                                          // custom rotation (EmittterRotation)
};
struct SMultiS
{
	var() class<UIParticleEmitter> ParticleEmitter;   // spawned emitter
	var() vector EmitterOffset;                       // emitter position relative to EmitterMultiSpawner location
	var() rotator EmittterRotationOffset;             // emitters rotation
	var() bool bEmitterFollowRotation;                // emitter follows combiners rotation
	var() bool bTrailerEmitter;                       // emitter follows combiners location (should be used in NoRotation state)
	var() bool bKeepStill;                            // no rotation
	var() ERotationType RoataionType;                 // type of emitter rotation (should be used in NoRotation state)
};
struct SProb
{
	var() bool bUseProbability;
	var() float SpawnProbability;
};
var() SProb Probability[50];
var() SMultiS EmitterConfig[50];                       // emitter configuration
var() int NumEmitters;                                 // number of emitters (can not be 0 or higher then 50)
var() bool bDestroy;                                   // should EmitterMultiSpawner be destroyed
var() bool bDestroyUnderWater;
var() float TickTime;                                  // update tim
var() actor AttachTo;                                  // attach actor
var() bool bOn;                                        // is on
var() bool bNoticeEmitter;                             // should emitters be noticed when combiners is destroyed
var UIParticleEmitter PEmitter[50];
var rotator DefaultRotation;

replication
{
//      reliable if( Role==ROLE_Authority ) CalcNewVector,CalculateRelativeLocation,RotateEmitter,BeginRotate,EndRotate;
	reliable if ( Role==ROLE_Authority ) bOn;
}

function BeginPlay()
{
	if (NumEmitters <= 0 || NumEmitters > 50)
		Destroy();
}

simulated function vector CalcNewVector(vector X, vector Y, vector Z, vector NewOffset)
{
	return NewOffset.X * X + NewOffset.Y * Y + NewOffset.Z * Z;    //uses for calculate fire place and bullet/projectile direction
}
simulated function vector CalculateRelativeLocation(vector NewOffset)
{
	local vector X,Y,Z;
	GetAxes(Rotation,X,Y,Z);
	return Location+CalcNewVector(X,Y,Z,NewOffset);
}

simulated function BeginRotate()
{
	local int i;

	for (i=0; i<NumEmitters; i++)
	{
		if (EmitterConfig[i].ParticleEmitter != none)
		{
			if (Probability[i].bUseProbability && FRand() > Probability[i].SpawnProbability) return;
			PEmitter[i]=Spawn(EmitterConfig[i].ParticleEmitter,self,'',Location+EmitterConfig[i].EmitterOffset,Rotation+EmitterConfig[i].EmittterRotationOffset);
			if (EmitterConfig[i].bTrailerEmitter)
			{
				PEmitter[i].SetBase(self);
				PEmitter[i].SetPhysics(PHYS_Trailer);
			}
			if (InitialState == 'NoRotation')
			{
				if (EmitterConfig[i].RoataionType == ROT_Custom) PEmitter[i].SetRotation(EmitterConfig[i].EmittterRotationOffset);
				else if (EmitterConfig[i].RoataionType == ROT_Spawner) PEmitter[i].SetRotation(Rotation+EmitterConfig[i].EmittterRotationOffset);
			}
		}
	}
	if (bDestroy) Destroy();
}

simulated function EndRotate()
{
	local int i;

	for (i=0; i<NumEmitters; i++)
	{
		if (PEmitter[i] != none)
		{
			PEmitter[i].EmitterDestroy();
			PEmitter[i]=none;
		}
	}
}

simulated function RotateEmitter()
{
	local int i;
	for (i=0; i<NumEmitters; i++)
	{
		if (PEmitter[i] != none && !EmitterConfig[i].bKeepStill)
		{
			if ( EmitterConfig[i].bEmitterFollowRotation ) PEmitter[i].SetRotation(Rotation+EmitterConfig[i].EmittterRotationOffset);
			PEmitter[i].SetLocation(CalculateRelativeLocation(EmitterConfig[i].EmitterOffset));
		}
	}
	if (AttachTo != none)
	{
		SetRotation(AttachTo.Rotation);
		SetLocation(AttachTo.Location);
	}
}

simulated state() NoRotation
{
Begin:
	BeginRotate();
}

simulated State() NormalRotation
{
Begin:
	if (TickTime <= 0) TickTime=0.1;
	BeginRotate();
Loop:
	RotateEmitter();
	Sleep(TickTime);
	GoTo('Loop');
}

//=============================================================================
// Toggle when triggered.
//=============================================================================
simulated state() TriggerToggle
{
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		if (bOn)
		{
			EndRotate();
			bOn=false;
		}
		else
		{
			SetRotation(DefaultRotation);
			BeginRotate();
			bOn=true;
		}
	}
Begin:
	DefaultRotation=Rotation;
//nothing here :)
AfterBegin:
	if (!bOn) GoTo('NearEnd');
	RotateEmitter();
NearEnd:
	sleep(TickTime);
	GoTo('AfterBegin');
}
//=============================================================================
// tunrs off when triggered.
//=============================================================================
simulated state() TriggerTurnsOff
{
	simulated function BeginState()
	{
		BeginRotate();
		bOn=true;
	}
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		bOn=false;
		EndRotate();
		Destroy();
		Disable('Trigger');
	}
Begin:
	if (!bOn) GoTo('NearEnd');
	RotateEmitter();
NearEnd:
	sleep(TickTime);
	GoTo('Begin');
}
//=============================================================================
// turns on when triggered.
//=============================================================================
simulated state() TriggerTurnsOn
{
	simulated function BeginState()
	{
		DefaultRotation=Rotation;
		EndRotate();
		bOn=false;
	}
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		SetRotation(DefaultRotation);
		BeginRotate();
		bOn=true;
		Disable('Trigger');
	}
Begin:
	if (!bOn) GoTo('NearEnd');
	RotateEmitter();
NearEnd:
	sleep(TickTime);
	GoTo('Begin');
}
//=============================================================================
// Start when triggered, Stop when get untriggered.
//=============================================================================
simulated state() TriggerControl
{
	simulated function BeginState()
	{
		EndRotate();
		bOn=false;
	}
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		BeginRotate();
		bOn=true;
	}
	simulated function UnTrigger( actor Other, pawn EventInstigator )
	{
		EndRotate();
		bOn=false;
	}
Begin:
//nothing here :)
AfterBegin:
	if (!bOn) GoTo('NearEnd');
	RotateEmitter();
NearEnd:
	sleep(TickTime);
	GoTo('AfterBegin');
}

function Destroyed()
{
	local int i;
	if (!bNoticeEmitter)
	{
		Super.Destroyed();
		return;
	}
	for (i=0; i<50; i++)
	{
		if (PEmitter[i] != none)
		{
			PEmitter[i].EmitterDestroy();
		}
	}
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	if (!NewZone.bWaterZone) Return;
	if (bDestroyUnderWater) Destroy();
}

defaultproperties
{
	Texture=Texture'UnrealShare.Icons.ParticleCombiner'
	TickTime=0.02
	Physics=PHYS_Rotating
	bHidden=true
	InitialState=NormalRotation
	bNoDelete=true
	bNoticeEmitter=true
}