//=============================================================================
// RazorBladeAlt.
//=============================================================================
class RazorBladeAlt extends RazorBlade;

var vector GuidedVelocity;
var rotator OldGuiderRotation, GuidedRotation;

replication
{
	// Things the server should send to the client.
	unreliable if ( Role==ROLE_Authority )
		GuidedVelocity;
}

simulated function SetRoll(vector NewVelocity)
{
	local rotator newRot;
	newRot = rotator(NewVelocity);
	newRot.Roll += 12768;
	SetRotation(newRot);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	GuidedRotation = Rotation;
	OldGuiderRotation = Rotation;
}

auto state Flying
{
	simulated function Tick(float DeltaTime)
	{
		local int DeltaYaw, DeltaPitch;
		local int YawDiff;

		if ( Level.NetMode == NM_Client )
			Velocity = GuidedVelocity;
		else
		{
			if ( instigator == None || (instigator.Health <= 0) || instigator.IsA('Bot') )
			{
				Disable('Tick');
				return;
			}
			else
			{
				DeltaYaw = (instigator.ViewRotation.Yaw & 65535) - (OldGuiderRotation.Yaw & 65535);
				DeltaPitch = (instigator.ViewRotation.Pitch & 65535) - (OldGuiderRotation.Pitch & 65535);
				if ( DeltaPitch < -32768 )
					DeltaPitch += 65536;
				else if ( DeltaPitch > 32768 )
					DeltaPitch -= 65536;
				if ( DeltaYaw < -32768 )
					DeltaYaw += 65536;
				else if ( DeltaYaw > 32768 )
					DeltaYaw -= 65536;

				YawDiff = (Rotation.Yaw & 65535) - (GuidedRotation.Yaw & 65535) - DeltaYaw;
				if ( DeltaYaw < 0 )
				{
					if ( ((YawDiff > 0) && (YawDiff < 16384)) || (YawDiff < -49152) )
						GuidedRotation.Yaw += DeltaYaw;
				}
				else if ( ((YawDiff < 0) && (YawDiff > -16384)) || (YawDiff > 49152) )
					GuidedRotation.Yaw += DeltaYaw;

				GuidedRotation.Pitch += DeltaPitch;

				Velocity += Vector(GuidedRotation) * 2000 * DeltaTime;
				speed = VSize(Velocity);
				Velocity = Velocity * FClamp(speed,400,750)/speed;
				GuidedVelocity = Velocity;
				OldGuiderRotation = instigator.ViewRotation;
			}
		}
		SetRotation(Rotator(Velocity) + rotang(0,0,70));
	}

	simulated function BeginState()
	{
		local rotator newRot;

		Super.BeginState();
		if ( Role == ROLE_Authority )
		{
			newRot = instigator.ViewRotation;
			newRot.Roll += 12768;
			SetRotation(newRot);
		}
	}
}

defaultproperties
{
	bNetTemporary=false
	MyDamageType="Decapitated"
}
