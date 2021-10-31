//================================================================
// class: BasicParticle
// file: BasicParticle.uc
// author: Raven
// www: http://turniej.unreal.pl/rp
// description:
// default particle class. it can be base for your own particle
// classes.
//================================================================
class UIBasicParticle extends UIParticleClass;

var bool NowFading;
var bool NowFadingOut;
var bool bSplash;
var bool bBobbing;
var bool WasFirstBounce;
var int AlredyBounced;
var int my_counter;
var int my_initial_lifetime;
var float StartLifeSpan;
var float my_time;
var float SpawnTime;
var EAccelType AccelerationType;

var decal Decl;
var UIParticleEmitter CallParent; //interaction with mother class
var int CurTPL;
var float ShrPrefix;
var float MTim;
var vector InitialDir;
var bool bChanged;
var actor Destn;
var Actor U1RSpawnEffect;
var vector ParticleOrign, ParticleRelMove;

simulated function SpawnDecal(vector Hitl)
{
	if (CallParent.ReturnbLimitDecals(CurTPL))
	{
		if (FRand()>0.2)
			return;
	}

	Decl=Spawn(CallParent.ReturnDecalClass(CurTPL),self,,Location, rotator(Hitl));
	if (Decl == none) return;
	Decl.Texture=CallParent.ReturnDecalTex(CurTPL);
	Decl.DrawScale=CallParent.ReturnDecalSize(CurTPL);
}

simulated simulated function PreBeginPlay()
{
	MTim=0.0;
	SetTimer(0.2, true);
}

simulated simulated function BeginPlay()
{
	if (CallParent == none && UIParticleEmitter(Owner) != none) CallParent=UIParticleEmitter(Owner);
	if (CallParent != none && CallParent.ReturnBornSound(CurTPL) != none) PartSoundPlayer(CallParent.ReturnBornSound(CurTPL));
	if (CallParent != none && CallParent.ReturnbTrailer(CurTPL))
	{
		ParticleOrign=Location-CallParent.Location;
	}
}

simulated function Spawned()
{
	Super.Spawned();
	if (Owner == none) return;
	if (CallParent == none && UIParticleEmitter(Owner) != none) CallParent=UIParticleEmitter(Owner);
}

simulated function FolloowerFunct()
{
	local vector SeekingDir;
	local float MagnitudeVel;

	if (bChanged && CallParent.ReturnDestinationType(CurTPL) == DEST_Once) return;

	if (CallParent.ReturnDestinationType(CurTPL) == DEST_Once) bChanged=true;

	if (InitialDir == vect(0,0,0)) InitialDir = Normal(Velocity);

	SeekingDir = Normal(Destn.Location - Location);
	if ( (SeekingDir Dot InitialDir) > 0 || CallParent.ReturnbForceFollow(CurTPL))
	{
		MagnitudeVel = VSize(Velocity);
		SeekingDir = Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);
		Velocity =  MagnitudeVel * SeekingDir;
	}
}

simulated function InMoveParticles()
{
	local vector i;

	if (/*CallParent.ReturnTarget(CurTPL)*/Destn != none && CallParent.ReturnDestinationType(CurTPL) != DEST_None) FolloowerFunct();
	i=velocity;
	if (CallParent.ReturnbJerkyness(CurTPL))
	{//Jerkyness by Punish3r
		i.x += (FRand() - 0.5) * CallParent.ReturnParticlesJerkyness(CurTPL);
		i.y += (FRand() - 0.5) * CallParent.ReturnParticlesJerkyness(CurTPL);
	}
	if (my_counter>1)
	{
		if (CallParent.ReturnSlowDown(CurTPL) != 0) velocity=velocity/(CallParent.ReturnSlowDown(CurTPL));
		if (CallParent.ReturnCycleSize(CurTPL) == ST_Grow || CallParent.ReturnCycleSize(CurTPL) == ST_Shrink)
		{
			if (CallParent.ReturnSizing(CurTPL) == SIZING_Infinity) DrawScale=DrawScale+CallParent.ReturnGrowth(CurTPL);
			else
			{
				if (CallParent.ReturnCycleSize(CurTPL) == ST_Grow && DrawScale < CallParent.ReturnMaxSize(CurTPL))
					DrawScale=DrawScale+CallParent.ReturnGrowth(CurTPL);
				if (CallParent.ReturnCycleSize(CurTPL) == ST_Shrink && DrawScale > CallParent.ReturnMinSize(CurTPL))
					DrawScale=DrawScale+CallParent.ReturnGrowth(CurTPL);
			}
			if (DrawScale<0.0001) destroy();
		}
		else if (CallParent.ReturnCycleSize(CurTPL) == ST_Cycle)
		{
			if (DrawScale <= CallParent.ReturnMinSize(CurTPL))
			{
				ShrPrefix=CallParent.ReturnGrow(CurTPL);
			}
			if (DrawScale >= CallParent.ReturnMaxSize(CurTPL))
			{
				ShrPrefix=CallParent.ReturnShrink(CurTPL);
			}
			DrawScale=DrawScale+ShrPrefix;
		}
		my_counter=0;
	}

	i.x=i.x*0.02;
	i.y=i.y*0.02;
	i.z=i.z*0.02;

	if (!CallParent.ReturnbTrailer(CurTPL))
	{

		if (!CallParent.ReturnMoveSmooth(CurTPL))
			Move(i);
		else
			MoveSmooth(i);
	}
	else
	{
		ParticleRelMove+=i;
		SetLocation(CallParent.Location+ParticleOrign+ParticleRelMove);
	}

	if (Mesh != none && CallParent.ReturnFaceObject(CurTPL) != FACE_None)
	{
		if (CallParent.ReturnFaceObject(CurTPL) == FACE_Velocity)
		{
			SetRotation(rotator(i));
		}
		if (CallParent.ReturnFaceObject(CurTPL) == FACE_Actor && CallParent.ReturnLookTarget(CurTPL) != none)
		{
			SetRotation(rotator(CallParent.ReturnLookTarget(CurTPL).Location-Location));
		}
	}
	my_counter++;
	if (CallParent == none) return;
	if ( CallParent.ReturnSpriteAnim(CurTPL))
	{
		if (!CallParent.ReturnSt(CurTPL))
			Texture=CallParent.ReturnAnimTex(CurTPL, ((CallParent.ReturnTexNum(CurTPL)-1)-int(((LifeSpan*100)*(CallParent.ReturnTexNum(CurTPL)-1))/(StartLifeSpan*100))));
		else
			Texture=CallParent.ReturnStAnimTex(CurTPL, ((CallParent.ReturnStTexNum(CurTPL)-1)-int(((LifeSpan*100)*(CallParent.ReturnStTexNum(CurTPL)-1))/(StartLifeSpan*100))));
	}
}

auto simulated state MoveParticles
{
Begin:
	if (Level.NetMode == NM_DedicatedServer) GoToState('Nothing');
	InMoveParticles();
	sleep(0.02);
	GoTo('Begin');
}

simulated state Nothing
{
Begin:
	if (Level.NetMode == NM_DedicatedServer)
	{
		SetTimer(0.0, false);
	}
}

simulated function AddPartAccel()
{
	if (CallParent.ReturnCanAccel(CurTPL))
	{
		if ((Velocity.Z < CallParent.ReturnTerminalAccel(CurTPL).Z)&&(Velocity.Z > - CallParent.ReturnTerminalAccel(CurTPL).Z))
			if (AccelerationType == ACC_Addictive)
				velocity.Z += CallParent.ReturnAccel(CurTPL).Z;
			else if (AccelerationType == ACC_Multiply)
				velocity.Z *= CallParent.ReturnAccel(CurTPL).Z;
		if ((Velocity.X < CallParent.ReturnTerminalAccel(CurTPL).X)&&(Velocity.X > - CallParent.ReturnTerminalAccel(CurTPL).X))
			if (AccelerationType == ACC_Addictive)
				velocity.X += CallParent.ReturnAccel(CurTPL).X;
			else if (AccelerationType == ACC_Multiply)
				velocity.X *= CallParent.ReturnAccel(CurTPL).X;

		if ((Velocity.Y < CallParent.ReturnTerminalAccel(CurTPL).Y)&&(Velocity.Y > - CallParent.ReturnTerminalAccel(CurTPL).Y))
			if (AccelerationType == ACC_Addictive)
				velocity.Y += CallParent.ReturnAccel(CurTPL).Y;
			else if (AccelerationType == ACC_Multiply)
				velocity.Y *= CallParent.ReturnAccel(CurTPL).Y;
	}
}
//tnx for bot40 (ParticleSystem_43.u) teh clue how to fade in/out particles
simulated function PartFadeIn()
{
	if (CallParent.ReturnCanFadeIn(CurTPL))
	{
		if (NowFading)
		{
			ScaleGlow=ScaleGlow+CallParent.ReturnFadeInFactor(CurTPL)/CallParent.ReturnFadeIn(CurTPL);
			if (ScaleGlow >= CallParent.ReturnFadeInFactor(CurTPL)*10)
			{
				ScaleGlow = CallParent.ReturnFadeInFactor(CurTPL)*10;
				NowFading = false;
			}
		}
	}
}
simulated function PartFadeOut()
{
	if (CallParent.ReturnCanFadeOut(CurTPL))
	{
		if (CallParent.ReturnFadeOut(CurTPL) > 0)
		{
			if ((!NowFadingOut ) && (LifeSpan - Level.TimeSeconds + SpawnTime <= CallParent.ReturnFadeOut(CurTPL) ))
				NowFadingOut = true;
			if (NowFadingOut)
				ScaleGlow = ScaleGlow - CallParent.ReturnFadeOutFactor(CurTPL)/CallParent.ReturnFadeOut(CurTPL);
		}
	}
}

function AddTimer()
{
	MTim+=0.1;
	if (MTim >= CallParent.ReturnInvDelay(CurTPL))
	{
		AddVelocityInversion();
		MTim=0;
	}
}

function AddVelocityInversion()
{


	if (CallParent.ReturnInvX(CurTPL))
	{
		Velocity.X*=-1;
	}
	if (CallParent.ReturnInvY(CurTPL))
	{
		Velocity.Y*=-1;
	}
	if (CallParent.ReturnInvZ(CurTPL))
	{
		Velocity.Z*=-1;
	}
}

simulated simulated function Timer()
{
	if (Level.NetMode == NM_DedicatedServer) return;
	if (CallParent.ReturnCanInv(CurTPL) && CallParent.ReturnCanLoopInv(CurTPL)) AddTimer();
	AddPartAccel();
	PartFadeIn();
	PartFadeOut();
	SetTimer(0.1, true);
}

singular function ZoneChange( ZoneInfo NewZone )
{
	local actor splash;


	if (Level.NetMode == NM_DedicatedServer)  return;

	if (CallParent.ReturnCanBouyance(CurTPL))
		CheckNewParticleZone(NewZone);

	if ( NewZone.bWaterZone )
	{
		if (CallParent.ReturnDestroyWhenTouchWater(CurTPL))
			Destroy();
		if ( bSplash && !Region.Zone.bWaterZone && Mass<=Buoyancy && ((Abs(Velocity.Z) < 100) || (Mass == 0)) && (FRand() < 0.05) && !PlayerCanSeeMe() )
		{
			bSplash = false;
			SetPhysics(PHYS_None);
		}
		else if ( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			if ( NewZone.EntrySound != None )
				if (CallParent.ReturnSoundWhenHitWater(CurTPL))
				{
					if (CallParent.ReturnbOverrideWaterEntrySound(CurTPL)) PlaySound(CallParent.ReturnWaterEntrySound(CurTPL), SLOT_Interact);
					else PlaySound(NewZone.EntrySound, SLOT_Interact);
				}
			if ( NewZone.EntryActor != None )
			{
				if (CallParent.ReturnSplashWhenHitWater(CurTPL))
				{
					if (CallParent.ReturnbOverrideWaterEntryEffect(CurTPL)) splash = Spawn(CallParent.ReturnWaterEntryActor(CurTPL));
					else splash = Spawn(NewZone.EntryActor);
				}
			}
		}
		bSplash = true;
	}
}

simulated function CheckNewParticleZone(ZoneInfo NewZone)
{

	if ( Region.Zone.bWaterZone && (Buoyancy > Mass) )
	{
		Velocity /= 2;
		bBobbing = true;
		if ( Buoyancy > 1.1 * Mass )
			Buoyancy = 0.95 * Buoyancy; // waterlog
		else if ( Buoyancy > 1.03 * Mass )
			Buoyancy = 0.99 * Buoyancy;
	}

	if ( NewZone.bPainZone && (NewZone.DamagePerSec > 0) )
		TakeDamage(100, None, location, vect(0,0,0), NewZone.DamageType);
}

simulated function Init()
{
	local rotator NewRot;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (!WasFirstBounce)
		{
			WasFirstBounce=true;
			AlredyBounced=CallParent.ReturnBounceNum(CurTPL);
			NewRot.Yaw = FRand()*65536;
			NewRot.Pitch = FRand()*24000;
			NewRot.Roll = 0;
			SetRotation(NewRot);
//		velocity = vector(rotation)*500;
//                settimer(0.05,true);
		}
	}
}

simulated function SetPartBounce(bool IsLanded,vector HitNormal, optional actor HitWall)
{
	local float RDND;
	Init();
	if (!CallParent.ReturnEndlessBounce(CurTPL))
	{
		if (AlredyBounced > 0)
		{
			AlredyBounced--;
		}
		else if (AlredyBounced <= 0)
		{
			return;
		}
	}
	RDND=RandRange(CallParent.ReturnParticlesBounce_Min(CurTPL),CallParent.ReturnParticlesBounce_Max(CurTPL));
	Velocity = CallParent.ReturnBounceRatio(CurTPL) * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	if (RDND > 0) Velocity *= RDND;
	if (IsLanded)
		Velocity.Z += CallParent.ReturnBounceModifier(CurTPL);
}

simulated function ParticleAddDamage(Vector HitNormal, actor Other)
{

	if (CallParent.ReturnParticleGivesDamage(CurTPL))
	{
		if (Other.IsA('PlayerPawn'))
		{
			if (CallParent.ReturnPlayerTakeDamage(CurTPL))
				Other.TakeDamage(CallParent.ReturnParticleDamage(CurTPL), Instigator, HitNormal, CallParent.ReturnMomentumTransfer(CurTPL)*Normal(Velocity), CallParent.ReturnParticleDamageType(CurTPL));

		}
		else if (Other.IsA('ScriptedPawn'))
		{
			if (CallParent.ReturnScriptedPawnTakeDamage(CurTPL))
				Other.TakeDamage(CallParent.ReturnParticleDamage(CurTPL), Instigator, HitNormal, CallParent.ReturnMomentumTransfer(CurTPL)*Normal(Velocity), CallParent.ReturnParticleDamageType(CurTPL));

		}
		else if (Other.IsA('FlockPawn'))
		{
			if (CallParent.ReturnFlockPawnTakeDamage(CurTPL))
				Other.TakeDamage(CallParent.ReturnParticleDamage(CurTPL), Instigator, HitNormal, CallParent.ReturnMomentumTransfer(CurTPL)*Normal(Velocity), CallParent.ReturnParticleDamageType(CurTPL));
		}
		else
		{
			if (CallParent.ReturnOtherActorTakeDamage(CurTPL))
				Other.TakeDamage(CallParent.ReturnParticleDamage(CurTPL), Instigator, HitNormal, CallParent.ReturnMomentumTransfer(CurTPL)*Normal(Velocity), CallParent.ReturnParticleDamageType(CurTPL));

		}
	}

}

simulated function PartSoundPlayer(sound SDGC)
{
	if (SDGC != none)
		PlaySound(SDGC,CallParent.ReturnParticleSoundSlot(CurTPL), CallParent.ReturnParticleSoundVolume(CurTPL), CallParent.ReturnParticleSoundbNoOverride(CurTPL), CallParent.ReturnParticleSoundRadius(CurTPL),CallParent.ReturnParticleSoundPitch(CurTPL));
}

simulated function HitWall(vector HitNormal, actor HitWall)
{
	PartSoundPlayer(CallParent.ReturnHittingSound(CurTPL));
	CheckForTouching(HitWall);
	if (CallParent.ReturnStopWhenTouchWall(CurTPL))
	{
		Velocity.X=0;
		Velocity.Y=0;
		Velocity.Z=0;
		SetPhysics(PHYS_Falling);
	}
	if (CallParent.ReturnStickToWall(CurTPL))
	{
		Velocity.X=0;
		Velocity.Y=0;
		Velocity.Z=0;
		SetPhysics(PHYS_None);
	}
	if (CallParent.ReturnbSpawnLandEffect(CurTPL)) Spawn(CallParent.ReturnLandEffect(CurTPL),self,,HitNormal,rotator(HitNormal));
	if (CallParent.ReturnParticleSpawnDecal(CurTPL))
		SpawnDecal(HitNormal);
	if (CallParent.ReturnStopWhenTouchWall(CurTPL) || CallParent.ReturnStickToWall(CurTPL))
		return;
	if (CallParent.ReturnDestroyWhenColideWorld(CurTPL))
		Destroy();
//   if(CallParent.ReturnCanBounce(CurTPL))
	if (bBounce)
		SetPartBounce(false, HitNormal, HitWall);
}

simulated function Bump(Actor Other)
{
	if (Other == Level)
	{
		HitWall(normal(location), other);
	}
}

simulated function CheckForTouching(actor other)
{
	if (CallParent.ReturnStickToPawn(CurTPL))
	{
		if (other.IsA('Pawn'))
		{
			Velocity.X=0;
			Velocity.Y=0;
			Velocity.Z=0;
			SetBase(Other);
			SetPhysics(PHYS_None);
		}
	}
	if (CallParent.ReturnStopWhenTouchPawn(CurTPL))
	{
		if (other.IsA('Pawn'))
		{
			Velocity.X=0;
			Velocity.Y=0;
			Velocity.Z=0;
			SetPhysics(PHYS_Falling);
		}
	}
}

simulated function Touch(actor Other)
{
	ParticleAddDamage(Velocity, Other);
	if (CallParent.ReturnDestroyWhenTouch(CurTPL))
		Destroy();
}

simulated function ProcessTouch(vector HitNormal, actor HitWall)
{
	PartSoundPlayer(CallParent.ReturnTouchingSound(CurTPL));
	CheckForTouching(HitWall);
	if (CallParent.ReturnDestroyWhenTouch(CurTPL))
		Destroy();
	if (CallParent.ReturnStickToPawn(CurTPL) || CallParent.ReturnStopWhenTouchPawn(CurTPL))
		return;
//   if(CallParent.ReturnCanBounce(CurTPL))
	if (bBounce)
		SetPartBounce(false, HitNormal, HitWall);
}

simulated function Landed( vector HitNormal )
{
	if (AmbientSound != none)
		AmbientSound=none;
	PartSoundPlayer(CallParent.ReturnLandingSound(CurTPL));
	if (CallParent.ReturnbSpawnLandEffect(CurTPL)) Spawn(CallParent.ReturnLandEffect(CurTPL),self,,Location,rotator(HitNormal));
	if (CallParent.ReturnDestroyWhenLand(CurTPL))
		Destroy();
//   if(CallParent.ReturnCanBounce(CurTPL))
	if (bBounce)
		SetPartBounce(true, HitNormal);
}

simulated function Destroyed()
{
	if (AmbientSound != none) AmbientSound=none;
	if (CallParent != none)
	{
		PartSoundPlayer(CallParent.ReturnDyingSound(CurTPL));
		if (CallParent.ReturnbSpawnEffectOnDestroy(CurTPL)) Spawn(CallParent.ReturnDestroyEffect(CurTPL),self,,Location);
	}
	if (U1RSpawnEffect != none)
	{
		if (UIParticleEmitter(U1RSpawnEffect) != none) UIParticleEmitter(U1RSpawnEffect).EmitterDestroy();
		else U1RSpawnEffect.Destroy();
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
	bStatic=false
}