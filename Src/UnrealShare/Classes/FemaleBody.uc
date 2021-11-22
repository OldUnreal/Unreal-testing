//=============================================================================
// FemaleBody.
//=============================================================================
class FemaleBody extends HumanCarcass;

#exec MESH IMPORT MESH=Fem1Body ANIVFILE=Models\F1Dead_a.3d DATAFILE=Models\Female_d.3d ZEROTEX=1
#exec MESH ORIGIN MESH=Fem1Body X=-30 Y=400 Z=20 YAW=64 ROLL=-64

#exec MESH SEQUENCE MESH=Fem1Body SEQ=All     STARTFRAME=0  NUMFRAMES=39
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Slump1  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Slump2  STARTFRAME=1  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Hang1   STARTFRAME=2  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Hang2   STARTFRAME=3  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Drape1  STARTFRAME=4  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Drape2  STARTFRAME=5  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Twist1  STARTFRAME=6  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Fold1   STARTFRAME=7  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Twist2  STARTFRAME=8  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Half1   STARTFRAME=9  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Hole1   STARTFRAME=10  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Drape3  STARTFRAME=11  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead2   STARTFRAME=12  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead3   STARTFRAME=13  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead4   STARTFRAME=14  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead5   STARTFRAME=15  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead6   STARTFRAME=16  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead7   STARTFRAME=17  NUMFRAMES=1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead1   STARTFRAME=18  NUMFRAMES=1	GROUP=Dead1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead1A  STARTFRAME=19  NUMFRAMES=10	GROUP=Dead1
#exec MESH SEQUENCE MESH=Fem1Body SEQ=Dead1B  STARTFRAME=29  NUMFRAMES=10	GROUP=Dead1

#exec MESHMAP SCALE MESHMAP=Fem1Body X=0.056 Y=0.056 Z=0.112
#exec TEXTURE IMPORT NAME=Gina FILE=Models\Gina.pcx GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=Fem1Body NUM=0 TEXTURE=Gina

#exec AUDIO IMPORT FILE="Sounds\Female\convulse.wav" NAME="ConvulseFem" GROUP="Female"

var bool bFullyDead;

function Trigger( actor Other, pawn EventInstigator )
{
	if ( bFullyDead )
		return;
	if ( GetAnimGroup(AnimSequence) != 'Dead1' )
		bFullyDead = true;
	else if ( !IsAnimating() )
	{
		if ( FRand() < 0.5 )
			PlayAnim('Dead1A');
		else
			PlayAnim('Dead1B');
		bFullyDead = (FRand() < 0.5);
	}

}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation,
					 Vector Momentum, name DamageType)
{
	if ( !bFullyDead )
	{
		if ( GetAnimGroup(AnimSequence) != 'Dead1' )
			bFullyDead = true;
		else if ( !IsAnimating() )
		{
			if ( FRand() < 0.5 )
				PlayAnim('Dead1A');
			else
				PlayAnim('Dead1B');
			bFullyDead = (FRand() < 0.5);
		}
	}

	Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}

function Convulse()
{
	PlaySound(sound'ConvulseFem',SLOT_Interact);
}

defaultproperties
{
	MasterReplacement=class'FemaleMasterChunk'
			Mesh=Mesh'UnrealShare.Fem1Body'
			Mass=100.000000
			LifeSpan=0.000000
			AnimSequence=Slump1
			AnimFrame=0.000000
			Physics=PHYS_None
			}
