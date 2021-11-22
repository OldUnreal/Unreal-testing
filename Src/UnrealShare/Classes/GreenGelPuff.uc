//=============================================================================
// GreenGelPuff.
//=============================================================================
class GreenGelPuff extends GreenSmokePuff;

var int numBlobs;
var vector SurfaceNormal;

replication
{
	unreliable if ( Role==ROLE_Authority )
		numBlobs, SurfaceNormal;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.01, false);
}

simulated function Timer()
{
	Local GreenBlob GB;
	local int j;

	if ( (Level.NetMode != NM_DedicatedServer) && (numBlobs > 0) )
	{
		numBlobs = FMin(numBlobs, 10);
		for (j=0; j<numBlobs; j++)
		{
			GB = Spawn(class'GreenBlob',,,Location+SurfaceNormal*(FRand()*8-4));
			if( GB!=None )
			{
				GB.SetUp(SurfaceNormal);
				GB.RemoteRole = ROLE_None;
			}
		}
	}
}

defaultproperties
{
	numBlobs=3
}