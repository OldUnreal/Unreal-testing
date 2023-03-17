// MapProjector - To use in maps.
Class MapProjector extends Projector;

var() bool bOnlyAttachStaticActors;
var() name IgnoreAttachActorTag; // Do not attach projector on these actors with this tag.
var() name OnlyAttachTag; // Only attach to actors with this tag!

simulated function PostBeginPlay()
{
	if( Level.NetMode==NM_DedicatedServer )
		SetCollision(false);
	else
	{
		bBuildStaticMap = (bBuildStaticMap && AttachTag=='' && RotationRate==rot(0,0,0));
		AttachPrjDecal();
		Role = ROLE_Authority;
		
		if(bOnlyAttachStaticActors) // Since we wont be actively looking for attachment, we can go dormant.
			SetCollision(false);
	}
}
simulated function Touch( Actor Other )
{
	if( bProjectActors && !Other.bHidden && ((Other.DrawType==DT_Mesh && Other.Mesh) || TerrainInfo(Other)) && (!bOnlyAttachStaticActors || Other.bStatic)
		 && (IgnoreAttachActorTag=='' || Other.Tag!=IgnoreAttachActorTag) && (OnlyAttachTag=='' || OnlyAttachTag==Other.Tag) )
		AttachActor(Other);
}
simulated function UnTouch( Actor Other )
{
	if( bProjectActors && !bOnlyAttachStaticActors )
		DeattachActor(Other);
}

function EdNoteAddedActor( vector HitLocation, vector HitNormal )
{
	SetLocation(HitLocation+HitNormal*50, rotator(-HitNormal));
}

defaultproperties
{
	bNoDelete=true
	Texture=UIProjectorIcon
	bOnlyAttachStaticActors=true
	bUseBetterActorAttach=true
	bBuildStaticMap=true
}