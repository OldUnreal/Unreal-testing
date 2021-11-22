//=============================================================================
// MaleOneBot.
//=============================================================================
class MaleOneBot extends MaleBot;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Male\metal01.wav" NAME="metwalk1" GROUP="Male"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Male\metal02.wav" NAME="metwalk2" GROUP="Male"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Male\metal03.wav" NAME="metwalk3" GROUP="Male"

function ForceMeshToExist()
{
	Spawn(class'MaleOne');
}

function BeginPlay()
{
	Super.BeginPlay();
}

simulated function PlayMetalStep()
{
	local sound step;
	local float decision;

	if ( Level.NetMode==NM_DedicatedServer )
		Return;

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			step = sound'MetWalk1';
		else if (decision < 0.67 )
			step = sound'MetWalk2';
		else
			step = sound'MetWalk3';
	}
	if( step==None )
		return;
	if ( bIsWalking )
		PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else PlaySound(step, SLOT_Interact, 1, false, 1000.0, 1.0);
}

defaultproperties
{
	Mesh=Male1
	Skin=Texture'UnrealI.Kurgan'
	CarcassType=MaleOneCarcass
}
