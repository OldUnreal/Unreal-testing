//=============================================================================
// SpaceMarineCarcass.
//=============================================================================
class SpaceMarineCarcass expands CreatureCarcass;

function ForceMeshToExist()
{
	//never called
	Spawn(class 'SpaceMarine');
	InitFor( Self );
}

function Initfor(actor Other)
{
	local int i;

	bReducedHeight = false;
	PrePivot = vect(0,0,0);
	for ( i=0; i<4; i++ )
		Multiskins[i] = Pawn(Other).MultiSkins[i];	
	Super.InitFor(Other);
}

defaultproperties
{
     bodyparts(1)=LodMesh'UPak.SMGib1'
     bodyparts(2)=LodMesh'UPak.SMGib2'
     bodyparts(3)=LodMesh'UPak.SMGib3'
     bodyparts(4)=LodMesh'UPak.SMGib4'
     bodyparts(5)=None
     flies=0
     AnimSequence=Dead2
     Mesh=LodMesh'UPak.Marine'
}
