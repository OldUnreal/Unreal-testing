//=============================================================================
// starterbolt.
//=============================================================================
class UIStartBeam extends UIBaseBeam;

simulated function Spawned()
{
	if (Owner != none && UIBeamEmitter(Owner) != none)
	{
		MyEmitter=UIBeamEmitter(Owner);
		ForceSettings(MyEmitter);
		CurrentTarget=MyEmitter.BeamTarget;
	}
}

auto simulated  state ContinousUpdates
{
	simulated function ContinueUpdate()
	{
		local vector X,Y,Z;

		if (MyEmitter != none)
		{
			GetAxes(MyEmitter.Rotation,X,Y,Z);
			SetLocation(MyEmitter.Location);
			CheckBeam(ReturnOrientation(MyEmitter), MyEmitter.BeamUpdateTime);
		}
	}
Begin:
	if (MyEmitter != none)
	{
		ContinueUpdate();
		Sleep(MyEmitter.BeamUpdateTime);
		GoTo('Begin');
	}
	else
	{
		sleep(0.25);
		GoTo('Begin');
	}

}

simulated state Idle
{
	simulated function BeginState()
	{
		bHidden=true;
		if (ChildBeam != none) ChildBeam.Destroy();
		if (ChildRoot != none) ChildRoot.Destroy();
	}

	simulated function EndState()
	{
		bHidden=false;
	}
}
defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
}
