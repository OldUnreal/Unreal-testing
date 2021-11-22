//=============================================================================
// ParentBlob.
//=============================================================================
class ParentBlob extends FlockMasterPawn;

var bool bEnemyVisible;
var int numBlobs;
var	Bloblet blobs[16];
var localized string BlobKillMessage, FemBlobKillMessage;

function setMovementPhysics()
{
	SetPhysics(PHYS_Spider);
}

function string KillMessage(name damageType, pawn Other)
{
	if (Other.bIsFemale && Len(FemBlobKillMessage) > 0)
		return FemBlobKillMessage;
	return BlobKillMessage;
}

function Shrink(Bloblet b)
{
	local int i,j;

	for (i=0; i<numBlobs; i++ )
		if ( blobs[i] == b )
			break;
	numBlobs--;
	for (j=i; j<numBlobs; j++ )
		blobs[j] = blobs[j+1];
	if (numBlobs == 0)
		Destroy();
	else
		SetRadius();
}

function SetRadius()
{
	local int i;
	local float size;

	size = 24 + 1.5 * numBlobs;
	for (i=0; i<numBlobs; i++)
		blobs[i].Orientation = size * vector(rotang(0,360,0) * i/numBlobs);
}

function PreSetMovement()
{
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.6;
}


function BaseChange()
{
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	local int i;

	if (Other == Enemy)
	{
		for (i=0; i<numBlobs; i++ )
			blobs[i].GotoState('asleep');
		GotoState('stasis');
	}
}

auto state stasis
{
	ignores EncroachedBy, EnemyNotVisible;

	function SeePlayer(Actor SeenPlayer)
	{
		local Bloblet b;
		local int i;

		if ( numBlobs == 0)
		{
			foreach AllActors(class'Bloblet',b,Tag,,false)
			{
				if( b.Health>0 )
				{
					blobs[numBlobs] = b;
					b.ParentBlob = self;
					b.GotoState('Active');
					
					if( ++numBlobs==ArrayCount(blobs) )
						break;
				}
			}
			if ( numBlobs == 0)
			{
				Destroy();
				return;
			}
			SetRadius();
		}
		else
		{
			for (i=0; i<numBlobs; i++ )
				blobs[i].GotoState('Active');
		}
		enemy = Pawn(SeenPlayer);
		bEnemyVisible = true;
		Gotostate('Attacking');
	}

Begin:
	SetPhysics(PHYS_None);
}

state Attacking
{
	function Timer()
	{
		local int i;

		Enemy = None;
		for (i=0; i<numBlobs; i++ )
			blobs[i].GotoState('asleep');
		GotoState('Stasis');
	}

	function Tick(float DeltaTime)
	{
		local int i;

		for (i=0; i<numBlobs; i++ )
			if ( blobs[i].MoveTarget == None )
				blobs[i].Destination = Location + blobs[i].Orientation;
	}

	function SeePlayer(Actor SeenPlayer)
	{
		Disable('SeePlayer');
		Enable('EnemyNotVisible');
		bEnemyVisible = true;
		if ( enemy!=SeenPlayer )
		{
			if ( !LineOfSightTo(enemy) || VSize(enemy.Location-Location)>VSize(SeenPlayer.Location-Location) )
				enemy = Pawn(SeenPlayer);
		}
		SetTimer(0, false);
	}

	function EnemyNotVisible()
	{
		Disable('EnemyNotVisible');
		Enable('SeePlayer');
		bEnemyVisible = false;
		SetTimer(35, false);
	}

Begin:
	SetPhysics(PHYS_Spider);

Chase:
	if (bEnemyVisible)
		MoveToward(Enemy);
	else
		MoveTo(LastSeenPos);

	Sleep(0.1);
	Goto('Chase');
}

defaultproperties
{
	BlobKillMessage="was corroded by a Blob"
	GroundSpeed=150.000000
	WaterSpeed=150.000000
	AccelRate=800.000000
	JumpZ=-1.000000
	MaxStepHeight=50.000000
	SightRadius=1000.000000
	PeripheralVision=-5.000000
	HearingThreshold=50.000000
	Intelligence=BRAINS_NONE
	bHidden=True
	Tag=blob1
}
