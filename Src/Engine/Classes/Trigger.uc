//=============================================================================
// Trigger: senses things happening in its proximity and generates
// sends Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class Trigger extends Triggers
			native;

#exec Texture Import File=Textures\Trigger.pcx Name=S_Trigger Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Trigger variables.

var() enum ETriggerType
{
	TT_PlayerProximity,	// Trigger is activated by player proximity.
	TT_PawnProximity,	// Trigger is activated by any pawn's proximity
	TT_ClassProximity,	// Trigger is activated by actor of that class only
	TT_AnyProximity,    // Trigger is activated by any actor in proximity.
	TT_Shoot,		    // Trigger is activated by player shooting it.
} TriggerType; // Trigger type.

var() localized string Message; // Human readable triggering message.

var() bool bTriggerOnceOnly; // Only trigger once and then go dormant.

var() bool bInitiallyActive; // For triggers that are activated/deactivated by other triggers.
var bool BACKUP_InitActive;

var() class<actor> ClassProximityType; // Class proximity to trigger when TriggerType=TT_ClassProximity.

var() float	RepeatTriggerTime; // If > 0, repeat trigger message at this interval while still touching the actor.
var() float ReTriggerDelay; // Minimum time before trigger can be retriggered.
var	  float TriggerTime;
var() float DamageThreshold; // Minimum damage to trigger if TT_Shoot.

var() name TriggerLevelID; // 227j: Sub-Level name to send this trigger event to.

// AI vars
var	actor TriggerActor;	// actor that triggers this trigger
var actor TriggerActor2;

//=============================================================================
// AI related functions

function PostBeginPlay()
{
	BACKUP_InitActive = bInitiallyActive;
	if ( !bInitiallyActive )
		FindTriggerActor();
	if ( TriggerType == TT_Shoot )
	{
		bHidden = false;
		bProjTarget = true;
		DrawType = DT_None;
	}

	Super.PostBeginPlay();
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	if ( Tag=='' )
		Return;
	ForEach AllActors(class'Actor',A,,Tag)
	{
		if (TriggerActor == None)
			TriggerActor = A.GetTriggerActor();
		else
		{
			TriggerActor2 = A.GetTriggerActor();
			return;
		}
	}
}

function Actor SpecialHandling(Pawn Other)
{
	local Pawn P;

	if ( bTriggerOnceOnly && !bCollideActors )
		return None;

	if ( (TriggerType == TT_PlayerProximity) && !Other.bIsPlayer )
		return None;

	if ( !bInitiallyActive )
	{
		if ( TriggerActor == None )
			FindTriggerActor();
		if ( TriggerActor == None )
			return None;
		if ( (TriggerActor2 != None)
				&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
			return TriggerActor2;
		else
			return TriggerActor;
	}

	// is this a shootable trigger?
	if ( TriggerType == TT_Shoot )
	{
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return None;

		Other.Target = self;
		Other.bShootSpecial = true;
		Other.FireWeapon();
		Other.bFire = 0;
		Other.bAltFire = 0;
		return Other;
	}

	// can other trigger it right away?
	if ( IsRelevant(Other) )
	{
		foreach TouchingActors(Class'Pawn',P)
			if( P==Other )
			{
				Touch(Other);
				break;
			}
		return self;
	}

	return self;
}

// when trigger gets turned on, check its touch list

function CheckTouchList()
{
	local Actor A;

	foreach TouchingActors(Class'Actor',A)
		Touch(A);
}

//=============================================================================
// Trigger states.

// Trigger is always active.
state() NormalTrigger
{
}

// Other trigger toggles this trigger's activity.
state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = !bInitiallyActive;
		if ( bInitiallyActive )
			CheckTouchList();
	}
}

// Other trigger turns this on.
state() OtherTriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local bool bWasActive;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;
		if ( !bWasActive )
			CheckTouchList();
	}
}

// Other trigger turns this off.
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = false;
	}
}

//=============================================================================
// Trigger logic.

//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant( actor Other )
{
	if ( !bInitiallyActive )
		return false;
	switch ( TriggerType )
	{
	case TT_PlayerProximity:
		return Pawn(Other)!=None && Pawn(Other).bIsPlayer;
	case TT_PawnProximity:
		return Pawn(Other)!=None && ( Pawn(Other).Intelligence > BRAINS_None );
	case TT_ClassProximity:
		return ClassIsChildOf(Other.Class, ClassProximityType);
	case TT_AnyProximity:
		return true;
	case TT_Shoot:
		return ( (Projectile(Other) != None) && (Projectile(Other).Damage >= DamageThreshold) );
	}
}
//
// Called when something touches the trigger.
//
function Touch( actor Other )
{
	if ( bCollideActors && IsRelevant( Other ) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		TriggerEvent(Event,Other,Other.Instigator,TriggerLevelID);

		if ( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
			Pawn(Other).SpecialGoal = None;

		if ( Len(Message)>0 )
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );

		if ( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
		else if ( RepeatTriggerTime > 0 )
			SetTimer(RepeatTriggerTime, false);
	}
}

function Timer()
{
	local bool bKeepTiming;
	local Actor Other;

	foreach TouchingActors(class'Actor',Other)
		if ( IsRelevant(Other) )
		{
			bKeepTiming = true;
			Touch(Other);
		}

	if ( bKeepTiming )
		SetTimer(RepeatTriggerTime, false);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					 Vector momentum, name damageType)
{
	if ( bCollideActors && bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		// Broadcast the Trigger message to all matching actors.
		TriggerEvent(Event,instigatedBy,instigatedBy,TriggerLevelID);

		if ( Len(Message)>0 && instigatedBy.Instigator!=None )
			// Send a string message to the toucher.
			instigatedBy.Instigator.ClientMessage( Message );

		if ( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
	}
}

//
// When something untouches the trigger.
//
function UnTouch( actor Other )
{
	if ( IsRelevant( Other ) )
		UnTriggerEvent(Event,Other,Other.Instigator,TriggerLevelID); // Untrigger all matching actors.
}

// Reset trigger to it's initial state
function Reset()
{
	bInitiallyActive = BACKUP_InitActive;
	if ( bTriggerOnceOnly && !bCollideActors )
		SetCollision(True);
}

defaultproperties
{
	Texture=S_Trigger
	bInitiallyActive=True
	InitialState=NormalTrigger
}
