//=============================================================================
// Octagon.
//=============================================================================
class Octagon expands Effects;

#exec AUDIO IMPORT FILE="SOUNDS\MARINE\BEAMIN.WAV" NAME="BeamIn" GROUP="Beam"

simulated function PostBeginPlay()
{
	Fatness = 0;
	Disable( 'Tick' );
	SetTimer( 3.0, false );
}
simulated event Landed( vector HitNormal )
{
	AmbientSound = sound'BeamIn';
	SoundVolume = 1;
	SoundRadius = 128;
	Mesh = mesh'Octagon';
	Enable( 'Tick' );
}
simulated function Tick( float DeltaTime )
{
	if( SoundVolume <= 128 )
		SoundVolume += 2;
	
	if( Fatness < 220 && mesh != none )
		Fatness += 1;
}
simulated function Timer()
{
	if( Level.NetMode==NM_DedicatedServer )
	{
		Destroy();
		Return;
	}
	SoundVolume = 128;
	GotoState( 'FadingOut' );
}
simulated state FadingOut
{
	simulated function BeginState()
	{
	}
	
	simulated function Tick( float DeltaTime )
	{
		if( Fatness > 0.0 )
		{
			Fatness -= 1;
			if( DrawScale > 1 )
				DrawScale -= 0.01;
		}
		else
		{
			if( ScaleGlow > 0.01 )
			{
				if( SoundVolume > 15 )
					SoundVolume -= 1;
				bUnlit = false;
				ScaleGlow -= 0.01;
			}
			else Destroy();
		}
	}
}

defaultproperties
{
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=FireTexture'UPak.BeamEffect.beam3'
     Skin=FireTexture'UPak.BeamEffect.beam3'
     bUnlit=True
     CollisionRadius=22.000000
     CollisionHeight=1.000000
     bCollideWorld=True
}
