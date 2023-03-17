//=============================================================================
// comptablet.
//=============================================================================
class CompTablet expands Pickup;

#exec MESH IMPORT MESH=comptablet ANIVFILE=MODELS\COMPTABLET\comptablet_a.3d DATAFILE=MODELS\COMPTABLET\comptablet_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=comptablet X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=comptablet SEQ=All        STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=comptablet SEQ=COMPTABLET STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jcomptablet1 FILE=MODELS\COMPTABLET\comptablet.PCX GROUP=Skins FLAGS=2 // screen1

#exec MESHMAP NEW   MESHMAP=comptablet MESH=comptablet
#exec MESHMAP SCALE MESHMAP=comptablet X=0.15 Y=0.15 Z=0.25

#exec MESHMAP SETTEXTURE MESHMAP=comptablet NUM=1 TEXTURE=Jcomptablet1

function bool ValidTouch( actor Other )
{
	local Actor A;

	if ( Other.bIsPawn && Pawn(Other).bIsPlayer && (Pawn(Other).Health > 0) && Level.Game.PickupQuery(Pawn(Other), self) )
	{
		if ( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Other, Other.Instigator );
		if (Level.Netmode != NM_Standalone)
		{
			Lifespan = 5.0; //shitfix for InventoryData in 227
		}
		return true;
	}
	return false;
}
defaultproperties
{
     PickupMessage="You got the CompTablet."
     PickupViewMesh=LodMesh'UPak.CompTablet'
     Mesh=LodMesh'UPak.CompTablet'
}
