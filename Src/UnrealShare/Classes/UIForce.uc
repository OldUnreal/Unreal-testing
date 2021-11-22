//================================================================
// class: Force
// file: Force.uc
// author: Raven
// www: http://turniej.unreal.pl/rp
// description:
// adds force to particles
//================================================================
/*
   usage:
      if bOn is true this actor will change velocity of all
      particles that will touch it.

      Force has 4 states:
       * TriggerToggle - toggle when triggered.
       * TriggerTurnsOff - tunrs off when triggered.
       * TriggerTurnsOn - turns on when triggered.
       * TriggerControl - turns on when triggered, tunrs off when get untriggered.
      And 4 variables:
       * ParticleSpeed (float) - new particle speed
       * ParticleSpeedVariance (float) - new particle speed variance
       * bOn (bool) - is active or not
       * ForceType (enum) - how change particle velocity
          - FORCE_Addictive - new force will be add to particle velocity
          - FORCE_Multiply - new force will multiply particle velocity
          - FORCE_Replace - new force will replace particle velocity

*/
class UIForce extends UIParticleSystem;

var() float ParticleSpeed;               //new particle speed
var() float ParticleSpeedVariance;       //new particle speed variance
var() bool bOn;                          //is active or not
var() enum EForceType
{
	FORCE_Addictive,                      //new force will be add to particle velocity
	FORCE_Multiply,                       //new force will multiply particle velocity
	FORCE_Replace                         //new force will replace particle velocity
} ForceType;                             //how change particle velocity
var() float SprayFactor;                 //spray
var() float SprayFactorVariance;         //spray vairance
var() bool bRandomizeRotation;           //uses random spawn rotation
var() bool bRandPitch;                   //random pitch
var() bool bRandYaw;                     //random yaw
var() bool bRandRoll;                    //randomed roll
var() rotator MinRotation;               //min rotation
var() rotator MaxRotation;               //max rotation
var() bool bForceRndRot;                 //forces RotRand() function

var vector NewLocal;
var rotator RndRot,RndRot2;

replication
{
	// Variables the server should send to the client.
	unreliable if ( Role==ROLE_Authority )
		bOn,NewLocal,RndRot,RndRot2;
	unreliable if ( Role==ROLE_Authority )
		AddForce;
}

simulated function AddForce(UIBasicParticle BasicParticle)
{

	if (BasicParticle == none) return;
	if (bRandomizeRotation)
	{
		RndRot=Rotation;
		if (!bForceRndRot)
		{
			if (bRandPitch) RndRot.Pitch=RandRange(MinRotation.Pitch, MaxRotation.Pitch);
			if (bRandYaw) RndRot.Yaw=RandRange(MinRotation.Yaw, MaxRotation.Yaw);
			if (bRandRoll) RndRot.Roll=RandRange(MinRotation.Roll, MaxRotation.Roll);

		}
		else
		{
			RndRot2=RotRand();
			if (bRandPitch) RndRot.Pitch=RndRot2.Pitch;
			if (bRandYaw) RndRot.Yaw=RndRot2.Yaw;
			if (bRandRoll) RndRot.Roll=RndRot2.Roll;
		}
		NewLocal=(ParticleSpeed + Jiiter(ParticleSpeedVariance))*vector(RndRot);
	}
	else
	{
		NewLocal=(ParticleSpeed + Jiiter(ParticleSpeedVariance))*vector(Rotation);
	}
	if (SprayFactor > 0.0)
	{
		NewLocal.x=NewLocal.x*(SprayFactor + Jiiter(SprayFactorVariance));
		NewLocal.y=NewLocal.y*(SprayFactor + Jiiter(SprayFactorVariance));
		NewLocal.z=NewLocal.z*(SprayFactor + Jiiter(SprayFactorVariance));
	}
	if (Forcetype == FORCE_Addictive)
	{
		BasicParticle.Velocity+=NewLocal;
	}
	else if (Forcetype == FORCE_Multiply)
	{
		BasicParticle.Velocity*=NewLocal;
	}
	else if (Forcetype == FORCE_Replace)
	{
		BasicParticle.Velocity=NewLocal;
	}
//    log("BasicParticle touched, "$BasicParticle$".Velocity="$BasicParticle.Velocity,'FORCE');
}

simulated function Touch(Actor Other)
{
//     log("Touched Other"$Other,'FORCE');
	if (UIBasicParticle(Other) != none && bOn) AddForce(UIBasicParticle(Other));
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
			bOn=false;
		}
		else
		{
			bOn=true;
		}
	}
}
//=============================================================================
// tunrs off when triggered.
//=============================================================================
simulated state() TriggerTurnsOff
{
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		bOn=false;
		Destroy();
	}
Bagin:
	bOn=true;
}
//=============================================================================
// turns on when triggered.
//=============================================================================
simulated state() TriggerTurnsOn
{
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		bOn=true;
	}
Bagin:
	bOn=false;
}
//=============================================================================
// Start when triggered, Stop when get untriggered.
//=============================================================================
simulated state() TriggerControl
{
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		bOn=true;
	}
	simulated function UnTrigger( actor Other, pawn EventInstigator )
	{
		bOn=false;
	}
Bagin:
	bOn=false;
}

defaultproperties
{
	bDirectional=true
	Texture=Texture'UnrealShare.Icons.ParticleForce'
	DrawScale=0.5
	bCollideActors=true
	bHidden=true
	bRandPitch=True
	bRandYaw=True
	bRandRoll=True
	MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536)
	bStasis=True
	RemoteRole=ROLE_SimulatedProxy
	bNoDelete=true
}
