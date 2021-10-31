//=============================================================================
// RespawningHealth.
//=============================================================================
class RespawningHealth expands UPakHealth;

function Bump( actor Other ) {}

function BaseChange() { }

defaultproperties
{
     bRespawnInSP=True
     Mesh=LodMesh'UnrealShare.SuperHealthMesh'
}
