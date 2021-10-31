/*
Allow 227 only mods add in extra playerclasses/skins for player setup.
*/
Class PlayerClassManager extends ReplicationInfo
	abstract;

var() array< Class<PlayerPawn> > AdditionalClasses;
var() array<Texture> AdditionalSkins;
var() bool bEnabled; // Whatever if this should be enabled to show more skins for players in server.

simulated function GetMeshSkins( out array<Texture> MSkins, string MeshName )
{
	local int i,j,l;

	l = Len(MeshName);
	j = AdditionalSkins.Size();
	for ( i=0; i<j; i++ )
	{
		if ( Left(string(AdditionalSkins[i].Outer.Name),l)~=MeshName )
			MSkins.Add(AdditionalSkins[i]);
	}
}

defaultproperties
{
	bAlwaysRelevant=True
	bCarriedItem=True
	RemoteRole=ROLE_SimulatedProxy
	bSkipActorReplication=true
	bEnabled=true
}