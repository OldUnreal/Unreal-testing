//=============================================================================
// Spawnpoint.
//Used by Creature Factories for spawning monsters
//=============================================================================
class SpawnPoint extends NavigationPoint;

#exec Texture Import File=Textures\SpwnAI.pcx Name=S_SpawnP Mips=Off Flags=2

var ThingFactory factory;

function bool Create()
{
	local Pawn newcreature;
	local CreatureFactory pawnFactory;
	local Actor temp;
	local rotator newRot;

	if ( !factory.prototype || (factory.bCovert && PlayerCanSeeMe()) ) //make sure no player can see this
		return false;

	if ( factory.prototype.Default.bIsProjectile )
		newRot = Rotation;
	else newRot.Yaw = Rotation.Yaw;
	
	temp = Spawn(factory.prototype,,factory.itemtag,,newRot);
	if ( !temp )
		return false;
	temp.Event = factory.Tag;

	TriggerEvent(Event,Self,Instigator);

	if ( factory.bFalling )
		temp.SetPhysics(PHYS_Falling);
	if ( !temp.bIsPawn )
		return true;

	pawnFactory = CreatureFactory(factory);
	if ( !pawnFactory )
	{
		Log("Error - use creature factory to spawn pawns at "$Self$" with "$factory);
		return true;
	}
	newcreature = Pawn(temp);
	if ( ScriptedPawn(newcreature) )
	{
		ScriptedPawn(newcreature).Orders = pawnFactory.Orders;
		ScriptedPawn(newcreature).OrderTag = pawnFactory.OrderTag;
		ScriptedPawn(newcreature).SetEnemy(pawnFactory.Enemy);
		ScriptedPawn(newcreature).Alarmtag = pawnFactory.AlarmTag;
	}
	else
		newcreature.Enemy = pawnFactory.Enemy;
	if ( newcreature.Enemy )
		newcreature.lastseenpos = newcreature.Enemy.Location;
	newcreature.SetMovementPhysics();
	if ( newcreature.Physics == PHYS_Walking)
		newcreature.SetPhysics(PHYS_Falling);
	return true;
}

defaultproperties
{
	bDirectional=True
	SoundVolume=128
	Texture=S_SpawnP
}
