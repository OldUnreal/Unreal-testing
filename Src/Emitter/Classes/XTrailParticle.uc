// Trail Emitter particle, Do not spawn this actor into level!
Class XTrailParticle extends Actor
	Native
	Transient;

function PreBeginPlay()
{
	Destroy();
}

defaultproperties
{
	DrawType=DT_Mesh
	Style=STY_Translucent
	bStatic=true
	Mesh=Mesh'WoodenBoxM'
}