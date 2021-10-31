//=============================================================================
// Book.
//=============================================================================
class Book extends Decoration;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=BookM ANIVFILE=Models\Book_a.3d DATAFILE=Models\Book_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BookM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=BookM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BookM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JBook1 FILE=Models\Book1.pcx GROUP=Skins DETAIL=Pock
#exec TEXTURE IMPORT NAME=JBook2 FILE=Models\Book2.pcx GROUP=Skins DETAIL=Pock
#exec TEXTURE IMPORT NAME=JBook3 FILE=Models\Book3.pcx GROUP=Skins DETAIL=Pock
#exec TEXTURE IMPORT NAME=JBook4 FILE=Models\Book4.pcx GROUP=Skins DETAIL=Pock
#exec MESHMAP SCALE MESHMAP=BookM X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=BookM NUM=0 TEXTURE=JBook1 TLOD=10

#exec AUDIO IMPORT FILE="Sounds\General\Chunkhit2.wav" NAME="Chunkhit2" GROUP="General"

var bool bFirstHit;

Auto State Animate
{
	function HitWall (vector HitNormal, actor Wall)
	{
		local float speed;
		local vector X,Y;
		local rotator R;

		if (bDeleteme)
			return;
		if (bStatic )
		{
			Velocity = vect(0,0,0);
			SetPhysics(PHYS_None);
			bBounce = False;
			return;
		}
		Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		speed = VSize(Velocity);
		if (speed>500) PlaySound(PushSound, SLOT_Misc,1.0);
		if (bFirstHit && speed<400)
		{
			bFirstHit=False;
			bRotatetoDesired=True;
			bFixedRotationDir=False;
			DesiredRotation.Pitch=0;
			DesiredRotation.Yaw=FRand()*65536;
			DesiredRotation.Roll=0;
		}
		RotationRate.Yaw = RotationRate.Yaw*0.75;
		RotationRate.Roll = RotationRate.Roll*0.75;
		RotationRate.Pitch = RotationRate.Pitch*0.75;
		If (speed < 30)
		{
			bBounce = False;
			
			if( bOrientToGround )
			{
				R.Yaw = DesiredRotation.Yaw;
				Y = Normal(HitNormal Cross vector(R));
				X = Normal(Y Cross HitNormal);
				DesiredRotation = OrthoRotation(X,Y,HitNormal);
				DesiredRotation.Yaw = R.Yaw;
			}
		}
	}

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
						 Vector momentum, name damageType)
	{
		if (bStatic || bDeleteme)
			return;
		SetPhysics(PHYS_Falling);
		bBounce = True;
		Momentum.Z = abs(Momentum.Z*4+3000);
		Velocity=Momentum*0.02;
		RotationRate.Yaw = 250000*FRand() - 125000;
		RotationRate.Pitch = 250000*FRand() - 125000;
		RotationRate.Roll = 250000*FRand() - 125000;
		DesiredRotation = RotRand();
		bRotateToDesired=False;
		bFixedRotationDir=True;
		bFirstHit=True;
	}
}

defaultproperties
{
	bPushable=True
	PushSound=Sound'UnrealShare.General.Chunkhit2'
	bStatic=False
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.BookM'
	CollisionRadius=12.000000
	CollisionHeight=4.000000
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	Mass=1.000000
	bNetInterpolatePos=true
	bOrientToGround=true
}