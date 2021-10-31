// Used for showing bot translocator/jump boots destination point.
Class TransPointDest extends LiftCenter;

var() bool bCanSingleJumpDown; // Bot can jump down without any problems.
var() bool bCanJumpUpWithBoots; // Bot can jump up with jumpboots.
var() bool bTranslocatePath; // This path can be used when having translocator.

var TransPointStart StartPoint;
var TransPointEnd EndPoint;
var bool bIsValidTransPoint;

// Cache info
var transient Pawn LastSeeker;
var transient UTranslocator LastTrans;
var transient JumpBoots LastBoots;
var transient float LastSeekingTime;

function PostBeginPlay()
{
	local byte i;
	local Actor Start,End;
	local int ReachFlg,Dist,EndSpec;
	local bool bResult;

	for ( i=0; i<ArrayCount(Paths); i++ )
	{
		if ( Paths[i]==-1 )
			continue;
		describeSpec(Paths[i],Start,End,ReachFlg,Dist);
		if ( StartPoint==None )
		{
			StartPoint = TransPointStart(End);
			if ( StartPoint!=None )
			{
				EndSpec = Paths[i];
				StartPoint.DestActor = Self;
			}
		}
		if ( EndPoint==None )
			EndPoint = TransPointEnd(End);
		bIsValidTransPoint = (StartPoint!=None && EndPoint!=None);
		if ( bIsValidTransPoint )
			break;
	}
	if ( !bCanSingleJumpDown && StartPoint!=None )
	{
		// Remove path leading down from here.
		for ( i=1; i<ArrayCount(Paths); i++ )
		{
			if ( Paths[i-1]==EndSpec )
			{
				Paths[i-1] = Paths[i];
				bResult = true;
			}
			else if ( bResult )
				Paths[i-1] = Paths[i];
		}
		if ( bResult )
			Paths[ArrayCount(Paths)-1] = -1;
		bResult = false;
		for ( i=1; i<ArrayCount(upstreamPaths); i++ )
		{
			if ( StartPoint.upstreamPaths[i-1]==EndSpec )
			{
				StartPoint.upstreamPaths[i-1] = StartPoint.upstreamPaths[i];
				bResult = true;
			}
			else if ( bResult )
				StartPoint.upstreamPaths[i-1] = StartPoint.upstreamPaths[i];
		}
		if ( bResult )
			StartPoint.upstreamPaths[ArrayCount(upstreamPaths)-1] = -1;
	}
}
final function UpdateCacheData( Pawn Other )
{
	LastSeeker = Other;
	LastSeekingTime = Level.TimeSeconds+2;
	if ( bTranslocatePath )
		LastTrans = UTranslocator(Other.FindInventoryType(Class'UTranslocator'));
	if ( bCanJumpUpWithBoots && LastTrans==None )
		LastBoots = JumpBoots(Other.FindInventoryType(Class'JumpBoots'));
	else LastBoots = None;
}
// Just before bot is getting to this point, prepare the bot by selecting boots or translocator.
function BotSuggestMovePrepare( Pawn Bot )
{
	if ( LastSeeker!=Bot || LastSeekingTime<Level.TimeSeconds )
		UpdateCacheData(Bot);

	if ( LastTrans!=None )
	{
		if ( Bot.Weapon==None )
		{
			Bot.Weapon = LastTrans;
			Bot.Weapon.BringUp();
		}
		else if ( Bot.Weapon!=LastTrans )
		{
			Bot.PendingWeapon = LastTrans;
			Bot.Weapon.PutDown();
		}
	}
	else if ( LastBoots!=None )
	{
		if ( !LastBoots.bActive )
			LastBoots.Activate();
	}
	else if ( Bot.bCanFly && Bot.Physics!=PHYS_Flying )
		Bot.SetPhysics(PHYS_Flying);
}
function Actor SpecialHandling(Pawn Other)
{
	local vector V;

	if ( !bIsValidTransPoint || Other.Physics==PHYS_Flying // Flying pawns can always get through.
			|| (bCanSingleJumpDown && VSize(Other.Location-StartPoint.Location)>VSize(Other.Location-EndPoint.Location)) ) // Is a jumpdown path.
		return Self;

	if ( LastSeeker!=Other || LastSeekingTime<Level.TimeSeconds )
		UpdateCacheData(Other);

	if ( LastTrans!=None )
	{
		Other.SpecialPause = 0.5;
		V = Location;
		V.Z+=MaxZDiffAdd;
		LastTrans.TranslocateTo(V,EndPoint.Location);
	}
	else
	{
		if ( LastBoots!=None && !LastBoots.bActive )
			LastBoots.Activate();

		// Try to make pawn jump up.
		Other.SetPhysics(PHYS_Falling);
		Other.Falling();
		Other.Destination = Location;
		Other.Focus = EndPoint.Location;
		Other.Velocity = vect(0,0,0);
		Other.Velocity.Z = Other.JumpZ;
		Other.Velocity = Other.EAdjustJump();
		if ( Other.bCountJumps && Other.Inventory!=None )
			Other.Inventory.OwnerJumped();
	}
	return Self;
}
function int SpecialCost(Pawn Seeker)
{
	if ( !bIsValidTransPoint )
		return 99999999;
	if ( Seeker.Physics==PHYS_Flying // Flying pawns can always get through.
			|| (bCanSingleJumpDown && VSize(Seeker.Location-StartPoint.Location)>VSize(Seeker.Location-EndPoint.Location)) ) // Is a jumpdown path.
		return 0;

	if ( LastSeeker!=Seeker || LastSeekingTime<Level.TimeSeconds )
		UpdateCacheData(Seeker);

	if ( LastTrans!=None || LastBoots!=None )
		return 0;
	else return 99999999;
}

defaultproperties
{
	bSpecialCost=true
	bTranslocatePath=true
}
