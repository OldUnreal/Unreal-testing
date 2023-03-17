//==================================================================================
//  UnrealBlood.
//  heavily modified into unreal 227 by []KAOS[]Casey.
//  Green blood textures provided by Dark-_|_-Night.:
//==================================================================================
Class UnrealBlood expands Effects config abstract;

var(BloodClient) globalconfig bool bEnableEnhancedBlood; //Enable this for ENHANCED blood.

var bool bGreen;
var int ticknum;
var bool bStopTick;

simulated function PostBeginPlay()
{
	if ( level.netmode != NM_DedicatedServer && !Class'UnrealBlood'.Default.bEnableEnhancedBlood )
		Destroy();
	If( Owner != none && owner.isa('scriptedpawn') && scriptedpawn(owner).default.bGreenBlood )
	Green();
}

simulated function Green()
{
	bGreen=true;
}


simulated function tick(float deltatime)
{
	if (bStopTick)
		return;

	if (ticknum > 3)
		destroy();

	if (owner == none)
		ticknum++;
	else if (owner != none && owner.isa('ScriptedPawn') && ScriptedPawn(Owner).bGreenBlood)
	{
		Green();
		bStopTick=True;
	}
	else if (owner != none && owner.isa('CreatureCarcass') && CreatureCarcass(Owner).bGreenBlood)
	{
		Green();
		bStopTick=True;
	}
	else if (Owner != none)
		bStopTick=True;
}

defaultproperties
{
	bEnableEnhancedBlood=True
	RemoteRole=ROLE_SimulatedProxy
	bGameRelevant=False
}
