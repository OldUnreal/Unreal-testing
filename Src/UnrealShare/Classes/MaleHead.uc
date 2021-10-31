//=============================================================================
// MaleHead.
//=============================================================================
class MaleHead extends PlayerChunks;

#exec MESH IMPORT MESH=Male1Head ANIVFILE=Models\g_m1h_a.3d DATAFILE=Models\g_m1h_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Male1Head X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=Male1Head SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=Male1Head SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jm1h  FILE=Models\g_m1h.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=Male1Head X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=Male1Head NUM=1 TEXTURE=Jm1h

simulated function Initfor(actor Other)
{
	Super.InitFor(Other);
	RotationRate = RotationRate/3;
}

simulated function Landed(vector HitNormal)
{
	local BloodSpurt b;

	if ( trail != None )
	{
		if ( Level.bHighDetailMode )
			bUnlit = false;
		trail.Destroy();
		trail = None;
	}
	if ( Level.NetMode != NM_DedicatedServer )
	{
		b = Spawn(class 'Bloodspurt',,,,rotang(90,0,0));
		if ( bGreenBlood )
			b.GreenBlood();
		b.RemoteRole = ROLE_None;
	}
	SetPhysics(PHYS_None);
	SetCollision(true, false, false);
}

defaultproperties
{
	Mesh=UnrealShare.Male1Head
	Class=UnrealShare.MaleHead
}
