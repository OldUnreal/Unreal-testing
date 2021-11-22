//=============================================================================
// TazerExplosion.
//=============================================================================
class TazerExplosion extends Effects
	transient;

#exec MESH IMPORT MESH=TazerExpl ANIVFILE=Models\tex_a.3d DATAFILE=Models\tex_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TazerExpl X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=TazerExpl SEQ=All       STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=TazerExpl SEQ=Explosion STARTFRAME=0   NUMFRAMES=6
#exec OBJ LOAD FILE=Textures\fireeffect3.utx PACKAGE=UnrealShare.Effect3
#exec MESHMAP SCALE MESHMAP=TazerExpl X=.4 Y=0.4 Z=0.8 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=TazerExpl NUM=1 TEXTURE=UnrealShare.Effect3.FireEffect3a

var rotator NormUp;
var() float Damage;
var() float radius;
var() float MomentumTransfer;

simulated function AnimEnd()
{
	Destroy();
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explosion', 1 );
		PlaySound (EffectSound1);
	}
	MakeNoise(1.0);
}

defaultproperties
{
	Damage=+00040.000000
	Radius=+00120.000000
	MomentumTransfer=+01400.000000
	EffectSound1=UnrealShare.Explode1
	DrawType=DT_Mesh
	Mesh=UnrealShare.TazerExpl
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=+3.0
}
