//=============================================================================
// TriggerLight.
// A lightsource which can be triggered on or off.
//=============================================================================
class TriggerLight extends Light;

//-----------------------------------------------------------------------------
// Variables.

var() float ChangeTime;        // Time light takes to change from on to off.
var() bool  bInitiallyOn;      // Whether it's initially on.
var() bool  bDelayFullOn;      // Delay then go full-on.
var() float RemainOnTime;      // How long the TriggerPound effect lasts

var   float InitialBrightness; // Initial brightness.
var   float Alpha, Direction;
var   actor SavedTrigger;
var   float poundTime;
var   bool bStopTick;
var   bool bInitial;

//-----------------------------------------------------------------------------
// Engine functions.

// Called at start of gameplay.
simulated function BeginPlay()
{
	// Remember initial light type and set new one.
	InitialBrightness = LightBrightness;
	if ( bInitiallyOn )
	{
		Alpha     = 1.0;
		Direction = 1.0;
	}
	else
	{
		Alpha     = 0.0;
		Direction = -1.0;
	}
	DrawType = DT_None;
}

// Called whenever time passes.
function Tick( float DeltaTime )
{
	if (!bStopTick)
	{
		Alpha += Direction * DeltaTime / ChangeTime;
		if ( Alpha > 1.0 )
		{
			Alpha = 1.0;
			bStopTick=True;
			if ( SavedTrigger != None )
				SavedTrigger.EndEvent();
		}
		else if ( Alpha < 0.0 )
		{
			Alpha = 0.0;
			bStopTick=True;
			if ( SavedTrigger != None )
				SavedTrigger.EndEvent();
		}
		if ( !bDelayFullOn )
			LightBrightness = Alpha * InitialBrightness;
		else if ( (Direction>0 && Alpha!=1) || Alpha==0 )
			LightBrightness = 0;
		else
			LightBrightness = InitialBrightness;
		if ( !bInitial)
		{
			bStopTick=True;
			bInitial=True;
		}
		bForceNetUpdate = true;
	}
}

//-----------------------------------------------------------------------------
// Public states.

// Trigger turns the light on.
state() TriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger!=None )
			SavedTrigger.BeginEvent();
		Direction = 1.0;
		bStopTick=False;
	}
}

// Trigger turns the light off.
state() TriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger!=None )
			SavedTrigger.BeginEvent();
		Direction = -1.0;
		bStopTick=False;
	}
}

// Trigger toggles the light.
state() TriggerToggle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger!=None )
			SavedTrigger.BeginEvent();
		Direction *= -1;
		bStopTick=False;
	}
}

// Trigger controls the light.
state() TriggerControl
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger!=None )
			SavedTrigger.BeginEvent();
		if ( bInitiallyOn ) Direction = -1.0;
		else               Direction = 1.0;
		bStopTick=False;
	}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger!=None )
			SavedTrigger.BeginEvent();
		if ( bInitiallyOn ) Direction = 1.0;
		else               Direction = -1.0;
		bStopTick=False;
	}
}

state() TriggerPound
{
	function Timer ()
	{
		if (poundTime >= RemainOnTime)
			Disable ('Timer');
		poundTime += ChangeTime;
		Direction *= -1;
		SetTimer (ChangeTime, false);
	}
	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( SavedTrigger!=None )
			SavedTrigger.EndEvent();
		SavedTrigger = Other;
		if ( SavedTrigger!=None )
			SavedTrigger.BeginEvent();
		Direction = 1;
		poundTime = ChangeTime;			// how much time will pass till reversal
		SetTimer (ChangeTime, false);		// wake up when it's time to reverse
		Enable   ('Timer');
		bStopTick=False;
	}
	function Reset()
	{
		SetTimer(0,false);
		Enable('Timer');
		Global.Reset();
	}
}

// Reset the light
function Reset()
{
	LightBrightness = InitialBrightness;
	if ( bInitiallyOn )
	{
		Alpha     = 1.0;
		Direction = 1.0;
	}
	else
	{
		Alpha     = 0.0;
		Direction = -1.0;
	}
	bForceNetUpdate = true;
}

defaultproperties
{
	bStatic=False
	bHidden=False
	bMovable=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=2
}