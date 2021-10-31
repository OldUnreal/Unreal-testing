//by Raven
class SimulatorAtmospheric extends UIParticleEmitter;

var() bool bIsOn;                     // replaces bOn from ParticleEmitter in new states

replication
{
	reliable if (Role == ROLE_Authority)
		bIsOn, SetOn;
}
//=============================================================================
// Set's bOn on or off. cleintside function
//=============================================================================
simulated function SetOn(bool btun)
{
	bIsOn=btun;
}

auto simulated state() Simulation
{
Begin:
//nothing here :)
AfterBegin:
	if (!bIsOn) GoTo('NearEnd');
	InStateStuff();
NearEnd:
	sleep(trIntervall);
	GoTo('AfterBegin');
}

defaultproperties
{
	InitialState=Simulation
}