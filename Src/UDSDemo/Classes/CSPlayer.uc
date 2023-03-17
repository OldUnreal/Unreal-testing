//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CSPlayer ]
//
// This is our new player class.  It holds all the additional information needed
// to handle a cut sequence.  It also has some of the specific code needed for
// the include ladder's mod.  
//
// MOD AUTHORS
//
// If you have not already begun primary coding on your mod, I suggest just 
// using this file to begin your new player class.  If your mod already has
// extensive changes to the UrealIPlayer class, the you will need to merge
// this file in.  You will also need to alter all of the other UDS classes to 
// reference your particular new player class.
//=============================================================================

class CSPlayer expands UnrealIPlayer;

// The Camera System

var bool 		bCSCameraMode;  // Are we in Camera Mode
var CS_Camera 	CSCamera;		// Where is the Camera pointed
var int 		oldhudMode;		// what is the old hud mode
var bool		bIsActing;      // Ignore movement commands
var bool		bCanEsc;		// Can the player ESC this sequence

var string CSDebug1;	
var string CSDebug2;	  // Big ass hack, but UnrealScript doesn't allow
var string CSDebug3;	  // Array's of strings (as far as I can tell
var string CSDebug4;	
var string CSDebug5;	
var string CSDebug6;	

var int			CSDebugCnt;			// Which debug line to drop shit in
var string CSLastAction;		// The name of the last action command
var bool		bCamDebug;			// Are we viewing a camera
var bool		bCSInDebug;			// Are we debugging

var CS_SpikeTape	CSMoveTarget;		// Where is the player susposed to be going.
var	CS_ShotList		CSShotList;			// What shotlist is currently in charge.

var float	CSAbortSpeed;		// When we abort, set the speed here


var vector AdjVelocity;  // How to adjust his movement.

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist, WallOutDist;

    // If a cut sequence is in progress, grab the current Location and Rotation from the camera.

 	if (bCSCameraMode) 
 	{
	    ViewActor = Self;
		CameraLocation = CSCamera.Location;
		CameraRotation = CSCamera.Rotation;
			
		return;
	}
		
	if (ViewTarget != None)
	{
		ViewActor = ViewTarget;
		CameraLocation = ViewTarget.Location;
		CameraRotation = ViewTarget.Rotation;
		if (Pawn(ViewTarget) != None)
		{
			if (PlayerPawn(ViewTarget) != None)
				CameraRotation = PlayerPawn(ViewTarget).ViewRotation;
			CameraLocation.Z += Pawn(ViewTarget).EyeHeight;
		}
		return;
	}

	// View rotation.
	ViewActor = Self;
	CameraRotation = ViewRotation;

	if(bBehindView) //up and behind
	{
	    ViewDist    = 100;
		WallOutDist = 30;
		View = vect(2,0,-1) >> CameraRotation;
		if(Trace(HitLocation, HitNormal, Location - (ViewDist+WallOutDist) * vector(CameraRotation), Location) != None)
			ViewDist = FMin((Location - HitLocation) Dot View, ViewDist);
		CameraLocation -= (ViewDist - WallOutDist) * View;
	}
	else
	{
		// First-person view.
		CameraLocation = Location;
		CameraLocation.Z += EyeHeight;
		CameraLocation += WalkBob;
	}
}

// POVGotoLocation - The original idea for this function came from Green Marine's Omni-Cam mod.  I have however
// modified it to simply take the actual camera as a parameter.  We will generation the view location/rotation from
// the camera it'self.  The benifit to this is it allows us to adjust the camera in real time.

function POVGotoLocation(CS_Camera Camera)
{

	// Set the Camera Location

    CS_AddDebug("Changing to Camera "$Camera);


	// Reset the current Camera

	if (CSCamera != None)
	{
		Camera.Target = None;
		Camera.bLockedOn = false;
		Camera.bFollowing = false;
//                Camera.bLeading = false;
		
	    
	 	Camera.SetPhysics(PHYS_None);
    
		Camera.DesiredRotation.Pitch = 0;
		Camera.DesiredRotation.Yaw = 0;
		Camera.DesiredRotation.Roll = 0;
			
		Camera.RotationRate.Pitch = 0;
		Camera.RotationRate.Yaw = 0;
		Camera.RotationRate.Roll = 0;
			
		Camera.Velocity.X =  0;
		Camera.Velocity.Y =  0;
		Camera.Velocity.Z =  0;
		
		
	}


	bCSCameraMode = true;	 // We are in camera mode
	CSCamera = Camera;		 // Set the pointer to the camera


}

// POVThirdPerson - This function switches to 3rd person view

function POVThirdPerson(bool letterboxed)
{
	// Switch POV to behind the back
  	bBehindView = true;
	// Set the custom hud

	if (myHud != None)
	{
		OldHudMode = MyHud.HudMode;  // Save this for later
		if (!LetterBoxed)
 			MyHud.HudMode=6;
 		else MyHud.HudMode=7;
	}
}
// POVFirstPerson - This function also was a part of the original Omni-Cam.  

function POVFirstPerson()
{
	bBehindView = false;
	bCSCameraMode = false;
	bCamDebug = false;
	CSCAmera = none;
    MyHud.HudMode=OldHudMode;
}

// ShowMenu must be modified so a menu cannot appear while the cut sequence is happening.

exec function ShowMenu()
{
	Fire();
}

static final function bool LevelIsIntro1( LevelInfo L )
{
	return (L.Title ~= "Intro1" || string(L.Outer.Name) ~= "Intro1");
}
static final function bool LevelIsIntro2( LevelInfo L )
{
	return (L.Title ~= "Intro2" || string(L.Outer.Name) ~= "Intro2");
}

function Freeze(bool value)
{
	bIsActing = value;
	if (value)
		GotoState('PlayerActing');
	else GotoState('PlayerWalking');
}

function ScriptedMove(vector NewVelocity)
{
	AdjVelocity = NewVelocity;
}

function ResetScriptedMove()
{
	AdjVelocity.X = 0;  
	AdjVelocity.Y = 0;
	AdjVelocity.Z = 0;
}


state PlayerActing
{
ignores SeePlayer, HearNoise, Bump;

	exec function FeignDeath()
	{
		if ( Physics == PHYS_Walking )
		{
			ServerFeignDeath();
			Acceleration = vect(0,0,0);
			GotoState('FeigningDeath');
		}
	}

	function ZoneChange( ZoneInfo NewZone )
	{
		if (NewZone.bWaterZone)
		{
			setPhysics(PHYS_Swimming);
			GotoState('PlayerSwimming');
		}
	}

	function AnimEnd()
	{
		local name MyAnimGroup;

		bAnimTransition = false;
		if (Physics == PHYS_Walking)
		{
			if (bIsCrouching)
			{
				if ( !bIsTurning && ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000) )
					PlayDuck();	
				else
					PlayCrawling();
			}
			else
			{
				MyAnimGroup = GetAnimGroup(AnimSequence);
				if ((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000)
				{
					if ( MyAnimGroup == 'Waiting' )
						PlayWaiting();
					else
					{
						bAnimTransition = true;
						TweenToWaiting(0.2);
					}
				}	
				else if (bIsWalking)
				{
					if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
					{
						TweenToWalking(0.1);
						bAnimTransition = true;
					}
					else 
						PlayWalking();
				}
				else
				{
					if ( (MyAnimGroup == 'Waiting') || (MyAnimGroup == 'Landing') || (MyAnimGroup == 'Gesture') || (MyAnimGroup == 'TakeHit')  )
					{
						bAnimTransition = true;
						TweenToRunning(0.1);
					}
					else
						PlayRunning();
				}
			}
		}
	}

	function Landed(vector HitNormal)
	{
		Global.Landed(HitNormal);
	}

	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Acceleration;
		Acceleration = NewAccel;

		if ( (Physics == PHYS_Walking) && (GetAnimGroup(AnimSequence) != 'Dodge') )
		{
			if (!bIsCrouching)
			{
				if (bDuck != 0)
				{
					bIsCrouching = true;
					PlayDuck();
				}
			}
			else if (bDuck == 0)
			{
				OldAccel = vect(0,0,0);
				bIsCrouching = false;
				if( Level.Title == " " );
			}

			if ( !bIsCrouching )
			{
				if ( (!bAnimTransition || (AnimFrame > 0)) && (GetAnimGroup(AnimSequence) != 'Landing') )
				{
					if ( Acceleration != vect(0,0,0) )
					{
						if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') || (GetAnimGroup(AnimSequence) == 'TakeHit') )
						{
							bAnimTransition = true;
							TweenToRunning(0.1);
						}
					}
			 		else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000) 
						&& (GetAnimGroup(AnimSequence) != 'Gesture') ) 
			 		{
			 			if ( GetAnimGroup(AnimSequence) == 'Waiting' )
			 			{
							if ( bIsTurning && (AnimFrame >= 0) ) 
							{
								bAnimTransition = true;
								PlayTurning();
							}
						}
			 			else if ( !bIsTurning ) 
						{
							bAnimTransition = true;
							TweenToWaiting(0.2);
						}
					}
				}
			}
			else
			{
				if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
					PlayCrawling();
			 	else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
					PlayDuck();
			}
		}
	}
			
	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z,NewAccel;
		local eDodgeDir DodgeMove;

		// Update acceleration.

		ViewRotation = Rotation;	
		GetAxes(Rotation,X,Y,Z);

		aForward = AdjVelocity.Y * 0.4;
		aStrafe  = AdjVelocity.X * 0.4;
		aLookup  = 0;
		aTurn    = 0;

		NewAccel = aForward*X + aStrafe*Y;
		NewAccel.Z = 0;

		bPressedJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, Rotation);

	}

	function BeginState()
	{
		WalkBob = vect(0,0,0);
		DodgeDir = DODGE_None;
		bIsCrouching = false;
		bIsTurning = false;
		bPressedJump = false;
		if (Physics != PHYS_Falling) SetPhysics(PHYS_Walking);
		if ( !IsAnimating() )
			PlayWaiting();
	}
	
	function EndState()
	{
		WalkBob = vect(0,0,0);
		bIsCrouching = false;
	}
}


// The player wants to fire.
exec function Fire( optional float F )
{
	local string URL;
	
	if( LevelIsIntro1(Level) )
		URL = "Intro2";
	else if( LevelIsIntro2(Level) )
		URL = "InterIntro?Game=UPak.UPakTransitionInfo";
	else URL = "UPack";
	Level.Game.SendPlayer(Self, URL);
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	Fire();
}

state LadderClimbing
{
ignores SeePlayer, HearNoise, Bump, TakeDamage;
		
	function AnimEnd()
	{
		PlayAnim('zClimb',0.7,0.2);
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = NewAccel;
		MoveSmooth(Acceleration * DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.02;
		aStrafe  *= 0.02;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.02;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	function BeginState()
	{
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_None);
		if  ( !IsAnimating() ) 
		  PlayAnim('zClimb',0.7,0.2);

	}
}


function CS_AddDebug(string msg)
{
   if (CSDebugCnt==5)
   {
   	  CSDebug1 = CSDebug2;
   	  CSDebug2 = CSDebug3;
   	  CSDebug3 = CSDebug4;
   	  CSDebug4 = CSDebug5;
      CSDebug5 = msg;
   }
   else
   {
		switch (CSDebugCnt)   
		{
			case 0 : CSDebug1 = Msg;break;
			case 1 : CSDebug2 = Msg;break;
			case 2 : CSDebug3 = Msg;break;
			case 3 : CSDebug4 = Msg;break;
			case 4 : CSDebug5 = Msg;break;
		}
   		CSDebugCnt++;
   }
   
}
     
exec function GotoCamera(name CName)
{
    local CS_Camera tc,c;
    
    //log("*****Searching for Camera "$CName);
    
    foreach AllActors(class'CS_Camera', c)
    {
    	if (C.Tag == CName)
			tc = c;
	}

	//log("****Found Camera "$TC);
	
	if (TC!= None)
	{
		bCamDebug = true;
	    POVGotoLocation(TC);
	}
}

exec function ListCameras()
{

	local CS_Camera c;
	foreach AllActors(class 'CS_Camera',c)
	{
		ClientMessage("Camera "$C.Name$" ["$C.Tag$"] at "$C.Location);
	}
}

exec function DebugCS()
{

	bCSInDebug = !bCSInDebug;

}


exec function CamMove(int x, int y, int z)
{
   local Vector L;
   
   l = CSCamera.Location;
   L.X += x;
   L.Y += Y;
   L.Z += Z;
   
   CSCamera.SetLocation(L);
}
   
exec function CamAdj(int p, int r, int y)
{
   local Rotator L;
   
   l = CSCamera.Rotation;
   L.Pitch += P;
   L.Roll  += R;
   L.Yaw   += Y;
   
   CSCamera.SetRotation(L);
}

	
exec function ResetView()
{
	POVFirstPerson();
}

state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y; 
		NewAccel.Z = 0;
		// Check for Dodge move
		if ( DodgeDir == DODGE_Active )
			DodgeMove = DODGE_Active;
		else
			DodgeMove = DODGE_None;
		if (DodgeClickTime > 0.0)
		{
			if ( DodgeDir < DODGE_Active )
			{
				OldDodge = DodgeDir;
				DodgeDir = DODGE_None;
				if (bEdgeForward && bWasForward)
					DodgeDir = DODGE_Forward;
				if (bEdgeBack && bWasBack)
					DodgeDir = DODGE_Back;
				if (bEdgeLeft && bWasLeft)
					DodgeDir = DODGE_Left;
				if (bEdgeRight && bWasRight)
					DodgeDir = DODGE_Right;
				if ( DodgeDir == DODGE_None)
					DodgeDir = OldDodge;
				else if ( DodgeDir != OldDodge )
					DodgeClickTimer = DodgeClickTime + 0.5 * DeltaTime;
				else 
					DodgeMove = DodgeDir;
			}
	
			if (DodgeDir == DODGE_Done)
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < -0.35) 
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}		
			else if ((DodgeDir != DODGE_None) && (DodgeDir != DODGE_Active))
			{
				DodgeClickTimer -= DeltaTime;			
				if (DodgeClickTimer < 0)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
		}
		
//		AnimGroupName = GetAnimGroup(AnimSequence);		
		if ( (Physics == PHYS_Walking) && (AnimGroupName != 'Dodge') )
		{
			//if walking, look up/down stairs - unless player is rotating view
			if ( !bKeyboardLook && (bLook == 0) )
			{
				if ( bLookUpStairs )
					ViewRotation.Pitch = FindStairRotation(deltaTime);
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;	
				}
			}

			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			//add bobbing when walking
			if ( !bShowMenu )
			{
				if ( Speed2D < 10 )
					BobTime += 0.2 * DeltaTime;
				else
					BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
				WalkBob = Y * 0.65 * Bob * Speed2D * sin(6.0 * BobTime);
				if ( Speed2D < 10 )
					WalkBob.Z = Bob * 30 * sin(12 * BobTime);
				else
					WalkBob.Z = Bob * Speed2D * sin(12 * BobTime);
			}
		}	
		else if ( !bShowMenu )
		{ 
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}
}

function string AdjustPlayer()
{
	switch( Class.Name )
	{
	case 'CSMaleOne':
		return "UPakMaleOne";
	case 'CSMaleTwo':
		return "UPakMaleTwo";
	case 'CSMaleThree':
		return "UPakMaleThree";
	case 'CSFemaleTwo':
		return "UPakFemaleTwo";
	default:
		return "UPakFemaleOne";
	}
}

simulated function ClientPlaySound(sound ASound, optional ESoundSlot SlotType)
{
	if ( ViewTarget != None )
		ViewTarget.PlaySound(ASound, SlotType, 2.f, true, 65536);
	else PlaySound(ASound, SlotType, 2.f, true, 65536);
}

defaultproperties
{
}
