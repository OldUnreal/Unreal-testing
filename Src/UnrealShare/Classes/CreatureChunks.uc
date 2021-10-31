//=============================================================================
// CreatureChunks.
//=============================================================================
class CreatureChunks extends Carcass;

#exec MESH IMPORT MESH=CowBody1 ANIVFILE=Models\g_cow2_a.3d DATAFILE=Models\g_cow2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=CowBody1 X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=CowBody1 SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=CowBody1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JGCow1  FILE=Models\Nc_1.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=CowBody1 X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=CowBody1 NUM=1 TEXTURE=JGCow1

#exec AUDIO IMPORT FILE="Sounds\Gibs\gibP1.wav" NAME="gibP1" GROUP="Gibs"
#exec AUDIO IMPORT FILE="Sounds\Gibs\gibP3.wav" NAME="gibP3" GROUP="Gibs"
#exec AUDIO IMPORT FILE="Sounds\Gibs\gibP4.wav" NAME="gibP4" GROUP="Gibs"
#exec AUDIO IMPORT FILE="Sounds\Gibs\gibP5.wav" NAME="gibP5" GROUP="Gibs"
#exec AUDIO IMPORT FILE="Sounds\Gibs\gibP6.wav" NAME="gibP6" GROUP="Gibs"

var		Bloodtrail		trail;
var		float			TrailSize;
var		bool			bGreenBlood;
var		bool			bMasterChunk;
var		bool			bMustSpawnChunks;
var		class<CreatureCarcass>	CarcassClass;
var		name			CarcassAnim;
var		Vector			CarcLocation;
var		float			CarcHeight;

replication
{
	// Things the server should send to the client.
	unreliable if ( Role==ROLE_Authority )
		bGreenBlood, bMasterChunk, CarcassClass, CarcassAnim, CarcLocation, CarcHeight;
}

simulated function PostBeginPlay()
{
	if ( Region.Zone.bDestructive || ((Level.Game != None) && Level.Game.bLowGore) )
	{
		Destroy();
		return;
	}
	if ( bMasterChunk && (Level.NetMode == NM_Client) ) //only if client
		ClientExtraChunks(true);
	else if ( Level.NetMode == NM_Client )
		SetTimer(0.05, false);

	Super.PostBeginPlay();
}

simulated function ClientExtraChunks(bool bSpawnChunks)
{
	local CreatureChunks carc;
	local bloodpuff Blood;
	local bloodspurt b;
	local int n;

	If ( Level.NetMode == NM_DedicatedServer )
	return;

	bMustSpawnChunks = false;
	b = Spawn(class 'Bloodspurt',,,,rotang(90,0,0));
	if ( bGreenBlood )
		b.GreenBlood();
	b.RemoteRole = ROLE_None;

	if ( !bSpawnChunks || (CarcassClass == None) )
		return;

	n = 1;

	while ( (n<8) && (CarcassClass.Default.bodyparts[n] != none) )
	{
		if ( CarcassClass.Static.AllowChunk(n, CarcassAnim) )
		{
			if ( CarcLocation == vect(0,0,0) ) CarcLocation = Location;
			carc = Spawn(class 'CreatureChunks',,, CarcLocation
						 + CarcassClass.Default.ZOffset[n] * CarcHeight * vect(0,0,1));
			if (carc != None)
			{
				carc.TrailSize = CarcassClass.Default.Trails[n];
				carc.Mesh = CarcassClass.Default.bodyparts[n];
				carc.Initfor(self);
				carc.RemoteRole = ROLE_None;
			}
		}
		n++;
	}

	if ( Level.bHighDetailMode && !bGreenBlood )
	{
		Blood = spawn(class'BloodPuff',,, CarcLocation);
		Blood.drawscale = 0.2 * CollisionRadius;
		Blood.RemoteRole = ROLE_None;
	}
}

simulated function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if ( NewZone.bWaterZone )
	{
		if ( trail != None )
		{
			if ( Level.bHighDetailMode )
				bUnlit = false;
			trail.Destroy();
		}
		if ( Mass <= Buoyancy )
			SetCollisionSize(0,0);
		if ( bSplash && !Region.Zone.bWaterZone && (Abs(Velocity.Z) < 80) )
			RotationRate *= 0.6;
		else if ( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// else play a splash
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 3.0 );
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor);
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
		bSplash = true;
	}

	if ( NewZone.bDestructive || (NewZone.bPainZone  && (NewZone.DamagePerSec > 0)) )
		Destroy();
}

simulated function Destroyed()
{
	if ( trail != None )
		trail.Destroy();
	Super.Destroyed();
}

function Initfor(actor Other)
{
	local vector RandDir;

	if ( Other.IsA('Carcass') )
		PlayerOwner = Carcass(Other).PlayerOwner;
	bDecorative = false;
	DrawScale = Other.DrawScale;
	if ( DrawScale != 1.0 )
		SetCollisionSize(CollisionRadius * 0.5 * (1 + DrawScale), CollisionHeight * 0.5 * (1 + DrawScale));
	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));
	RandDir = 700 * FRand() * VRand();
	RandDir.Z = 200 * FRand() - 50;
	if ( bMasterChunk )
		SetAsMaster(Other);
	else
	{
		Velocity = (0.2 + FRand()) * (other.Velocity + RandDir);
		If (Region.Zone.bWaterZone)
		Velocity *= 0.5;
	}
	if ( TrailSize > 0 )
	{
		if ( Other != None && Other.isa('ScriptedPawn'))
			bGreenBlood = ScriptedPawn(Other).bGreenBlood;
		else if ( CreatureCarcass(Other) != None )
			bGreenBlood = CreatureCarcass(Other).bGreenBlood;
		else if ( (CreatureChunks(Other) != None) )
			bGreenBlood = CreatureChunks(Other).bGreenBlood;
	}

	if ( FRand() < 0.3 )
		Buoyancy = 1.06 * Mass; // float corpse
	else
		Buoyancy = 0.94 * Mass;

	if ( bMasterChunk ) // only if server
		ClientExtraChunks(bMustSpawnChunks);
}

function SetAsMaster(Actor Other)
{
	Velocity = Other.Velocity;
	CarcassClass = class<CreatureCarcass>(Other.Class);
	CarcassAnim = Other.AnimSequence;
	CarcLocation = Other.Location;
	CarcHeight = Other.CollisionHeight;
}

function ChunkUp(int Damage)
{
	local BloodSpurt b;

	if (bHidden)
		return;
	b = Spawn(class 'Bloodspurt',,,,rotang(90,0,0));
	if ( bGreenBlood )
		b.GreenBlood();
	if (bPlayerCarcass)
	{
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		bProjTarget = false;
		if ( Trail != None )
			Trail.Destroy();
	}
	else
		destroy();
}

simulated function Landed(vector HitNormal)
{
	local rotator finalRot;
	local BloodSpurt b;
	local Bloodsplat2 BS2;

	if ( trail != None )
	{
		if ( Level.bHighDetailMode )
			bUnlit = false;
		trail.Destroy();
		trail = None;
	}
	finalRot = Rotation;
	finalRot.Roll = 0;
	finalRot.Pitch = 0;
	setRotation(finalRot);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		b = Spawn(class 'Bloodspurt',,,,rotang(90,0,0));
		if ( bGreenBlood )
			b.GreenBlood();
		b.RemoteRole = ROLE_None;
		BS2=Spawn(class'BloodSplat2',Owner,,,Rotator(HitNormal));
		if (bGreenBlood && BS2 != none)
			BS2.Green();
	}
	SetPhysics(PHYS_None);
	SetCollision(true, false, false);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local float speed, decision;
	local BloodSpurt b;
	local Bloodsplat2 BS2;

	Velocity = 0.8 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	Velocity.Z = FMin(Velocity.Z * 0.8, 700);
	speed = VSize(Velocity);
	if ( speed < 250 )
	{
		if ( trail != None )
		{
			if ( Level.bHighDetailMode )
				bUnlit = false;
			trail.Destroy();
			trail = None;
		}
		if ( speed < 120 )
		{
			bBounce = false;
			Disable('HitWall');
		}
	}
	else if ( speed > 350 )
	{
		if ( speed > 700 )
			velocity *= 0.8;
		if (  Level.NetMode != NM_DedicatedServer )
		{
			decision = FRand();
			if ( decision < 0.2 )
				PlaySound(sound 'gibP1');
			else if ( decision < 0.4 )
				PlaySound(sound 'gibP3');
			else if ( decision < 0.6 )
				PlaySound(sound 'gibP4');
			else if ( decision < 0.8 )
				PlaySound(sound 'gibP5');
			else
				PlaySound(sound 'gibP6');
		}
	}
	if ( (trail == None) && (Level.NetMode != NM_DedicatedServer) )
	{
		b = Spawn(class 'Bloodspurt',,,,Rotator(HitNormal));
		if ( bGreenBlood )
			b.GreenBlood();
		b.RemoteRole = ROLE_None;
	}
	if (Level.Netmode != NM_DedicatedServer)
		BS2=Spawn(class'BloodSplat2',Owner,,,Rotator(HitNormal));
	if (bGreenBlood && BS2 != none)
		BS2.Green();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					 Vector momentum, name damageType)
{
	if (bStatic || bDeleteme)
		return;
	SetPhysics(PHYS_Falling);
	bBobbing = false;
	Velocity += momentum/Mass;
	CumulativeDamage += Damage;
	If ( Damage > FMin(15, Mass) || (CumulativeDamage > Mass) )
	ChunkUp(Damage);
}

simulated function Timer()
{
	if ( (Level.NetMode == NM_Client) && bMasterChunk )
		ClientExtraChunks(bMustSpawnChunks);
}


auto state Dying
{
	ignores TakeDamage;

Begin:
	if ( bDecorative )
		SetPhysics(PHYS_None);
	else if ( (TrailSize > 0) && !Region.Zone.bWaterZone )
	{
		trail = Spawn(class'BloodTrail',self);
//		trail.DrawScale = TrailSize;
		if ( bGreenBlood )
			trail.GreenBlood();
	}
	Sleep(0.35);
	SetCollision(true, false, false);
	bMasterChunk = false;
	GotoState('Dead');
}

state Dead
{
	function BeginState()
	{
		if ( bDecorative )
			lifespan = 0.0;
		else
			SetTimer(5.0, false);
	}
}

defaultproperties
{
	TrailSize=3.000000
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=20.000000
	Mesh=Mesh'UnrealShare.CowBody1'
	bCollideActors=False
	bBounce=True
	bFixedRotationDir=True
	bUnlit=True
	Mass=30.000000
	Buoyancy=27.000000
	RotationRate=(Pitch=30000,Roll=30000)
	bMustSpawnChunks=true
}
