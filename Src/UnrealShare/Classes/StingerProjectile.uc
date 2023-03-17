//=============================================================================
// StingerProjectile.
//=============================================================================
class StingerProjectile extends Projectile;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=TarydiumProjectile ANIVFILE=Models\aniv52.3d DATAFILE=Models\data52.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TarydiumProjectile X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=TarydiumProjectile SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Tarydium1HD FILE=Models\shells.bmp Group="HD" DETAIL=Marble
#exec TEXTURE IMPORT NAME=Tarydium1 FILE=Models\shells_old.pcx HD=Tarydium1HD
#exec MESHMAP SCALE MESHMAP=TarydiumProjectile X=0.015 Y=0.015 Z=0.03
#exec MESHMAP SETTEXTURE MESHMAP=TarydiumProjectile NUM=4 TEXTURE=Tarydium1

#exec TEXTURE IMPORT NAME=ExplosionPal3 FILE=Textures\expal2.pcx GROUP=Effects

#exec MESH IMPORT MESH=burst ANIVFILE=Models\burst_a.3d DATAFILE=Models\burst_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=burst X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=burst SEQ=All       STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=burst SEQ=Explo     STARTFRAME=0   NUMFRAMES=6
#exec TEXTURE IMPORT NAME=Jburst1 FILE=Models\burst.pcx GROUP=Skin
#exec MESHMAP SCALE MESHMAP=burst X=0.2 Y=0.2 Z=0.4 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=burst NUM=0 TEXTURE=Jburst1

#exec AUDIO IMPORT FILE="Sounds\Stinger\Ricochet.wav" NAME="Ricochet" GROUP="Stinger"
#exec AUDIO IMPORT FILE="..\UnrealI\Sounds\Razor\bladehit.wav" NAME="BladeHit" GROUP="RazorJack"

var bool bLighting;
var float DelayTime;

/////////////////////////////////////////////////////
auto state Flying
{
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		local vector hitDir;

		if (Other != instigator && StingerProjectile(Other) == none)
		{
			if ( Other.Role==ROLE_Authority )
			{
				hitDir = Normal(Velocity);
				if ( FRand() < 0.2 )
					hitDir *= 5;
				Other.TakeDamage(damage, instigator,HitLocation,(MomentumTransfer * hitDir),'shot');
			}
			Destroy();
		}
	}
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		local Texture T;

		Super.HitWall(HitNormal, Wall);
		MakeNoise(0.3);
		if( Level.NetMode==NM_DedicatedServer )
		{
			Destroy();
			return;
		}
		if (FRand()<0.3)
			PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
		else PlaySound(MiscSound, SLOT_Misc, 0.6,,,1.0);

		if ( !EffectIsRelevant(Location) )
		{
			Destroy();
			return;
		}

		T = GetHitTexture();
		RemoteRole = ROLE_None; // Tear off.
		SetPhysics(PHYS_None);
		SetCollision(false);

		if( T==None || (T.SurfaceType!=EST_Wood && T.SurfaceType!=EST_Plant && T.SurfaceType!=EST_Flesh && T.SurfaceType!=EST_Snow && T.SurfaceType!=EST_Dirt) )
		{
			Mesh = mesh'Burst';
			SetRotation(RotRand());
			Spawn(class'StingerCrack',,,Location, rotator(HitNormal));
			PlayAnim('Explo',0.9);
		}
		else if( T.SurfaceType==EST_Snow )
			Destroy(); // Snow sucks it up.
		else
		{
			LightType = LT_None;
			SetBase(Wall);
			if( Level.bDropDetail )
				LifeSpan = 1.f;
			else LifeSpan = 3.f;
		}
	}

	simulated function Timer()
	{
		local bubble1 b;		
		if (!Region.Zone.bWaterZone)
		{
			SetTimer(0,False);
			Return;
		}
		if ( EffectIsRelevant(Location) && !Level.bDropDetail )
		{
			b=spawn(class'Bubble1',,,Location+FRand()*vect(2,0,0)+FRand()*Vect(0,2,0)+FRand()*Vect(0,0,2));
			if( b!=None )
			{
				b.DrawScale= 0.1 + FRand()*0.2;
				b.buoyancy = b.mass+(FRand()*0.4+0.1);
				b.RemoteRole = ROLE_None;
			}
		}
		DelayTime+=FRand()*0.1+0.1;
		SetTimer(DelayTime,False);
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		if( NewZone.bWaterZone && Region.Zone!=None && !Region.Zone.bWaterZone )
		{
			Velocity=0.7*Velocity;
			DelayTime=0.03;
			SetTimer(DelayTime,False);
		}
	}

	simulated function BeginState()
	{
		local rotator RandRot;

		if ( Role == ROLE_Authority )
		{
			Velocity = Vector(Rotation) * speed;
			RandRot.Pitch = FRand() * 200 - 100;
			RandRot.Yaw = FRand() * 200 - 100;
			RandRot.Roll = FRand() * 200 - 100;
			Velocity = Velocity >> RandRot;
			if ( Region.zone.bWaterZone )
				Velocity=0.7*Velocity;
		}
		DelayTime=0.03;
		if ( Region.zone.bWaterZone )
			SetTimer(DelayTime,False);
	}
}

///////////////////////////////////////////////////////
simulated function Explode(vector HitLocation, vector HitNormal)
{
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
	speed=1600.000000
	Damage=14.000000
	MomentumTransfer=4000
	ImpactSound=Sound'UnrealShare.Stinger.Ricochet'
	MiscSound=Sound'UnrealShare.Razorjack.BladeHit'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=6.000000
	AnimRate=1.000000
	Mesh=Mesh'UnrealShare.TarydiumProjectile'
	AmbientGlow=215
	bUnlit=True
	bNoSmooth=False
	bMeshCurvy=False
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=80
	LightHue=152
	LightSaturation=32
	LightRadius=5
	LightPeriod=50
	bBounce=True
	Mass=2.000000
	NetPriority=6.000000
	MyDamageType="Shot"
}

