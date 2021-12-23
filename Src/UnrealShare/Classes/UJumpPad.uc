// Written by .:..:
// A jump pad with bot support.
// The jumper itself (starting point).
Class UJumpPad extends UJumpPadEnd;

var() sound JumpSound;
var() vector JumpVelocityModifier;
var() float JumpZHeightModifier;
var() const bool bForceFullAccurancy; // Always jump perfectly into the Dest point, but is a little bit more CPU intensive and may variate the velocity a little bit.
var vector BackUp_Velocity,JumpVelocity;
var nowarn Pawn PendingTouch; //unused, for older version compat only.
var UJumpDest MyDest;

replication
{
	// Replace Jump velocity to client to keep them better in sync with server.
	reliable if ( Role==ROLE_Authority )
		JumpVelocity;
}

function PostBeginPlay()
{
	local byte i;
	local Actor St,En;
	local int RF,D;
	local float ZHgh;

	For( i=0; i<16; i++ )
	{
		if ( Paths[i]==-1 )
			Continue;
		describeSpec(Paths[i],St,En,RF,D);
		if ( UJumpDest(En)!=None )
		{
			MyDest = UJumpDest(En);
			if ( !bForceFullAccurancy )
			{
				ZHgh = CalcRequiredZHeight(En.Location.Z,Location.Z,Region.Zone.ZoneGravity.Z)+JumpZHeightModifier;
				JumpVelocity = SuggestFallVelocity(Location,En.Location,ZHgh,6000.f);
			}
			else JumpVelocity = MyDest.Location;
			Break;
		}
	}
	JumpVelocity+=JumpVelocityModifier;
	BackUp_Velocity = JumpVelocity;
}
function Reset()
{
	JumpVelocity = BackUp_Velocity;
}
simulated function Touch( Actor Other )
{
	if ( Other.bIsPawn && Pawn(Other).Health>0 )
		SetPendingTouch(Other);
}
simulated function PostTouch( Actor Other )
{
	local float ZH;

	if ( !Other.bDeleteMe && Other.bIsPawn )
	{
		if ( PlayerPawn(Other)==None )
		{
			Pawn(Other).PlayInAir(); // Make sure this pawn plays falling animation.
			Other.Acceleration = vect(0,0,0);
			if ( MyDest!=None )
				Pawn(Other).MoveTarget = MyDest.SpecialHandling(Pawn(Other));
		}
		// Only set the physics on server OR net owner.
		if ( Other.Role>=ROLE_AutonomousProxy && Other.Physics!=PHYS_Falling && Other.Physics!=PHYS_Flying )
			Other.SetPhysics(PHYS_Falling);
		if ( !bForceFullAccurancy )
			Other.Velocity = JumpVelocity;
		else
		{
			ZH = CalcRequiredZHeight(JumpVelocity.Z,Other.Location.Z,Region.Zone.ZoneGravity.Z)+JumpZHeightModifier;
			Other.Velocity = SuggestFallVelocity(Other.Location,JumpVelocity,ZH,6000.f)+JumpVelocityModifier;
		}
		if ( JumpSound && Level.NetMode!=NM_Client )
			MakeJumpNoise();
	}
}
function MakeJumpNoise()
{
	PlaySound(JumpSound);
}
simulated final function float CalcRequiredZHeight( float DestZ, float StartZ, float GravZ )
{
	local int LCount;

	if ( GravZ>=0 )
		GravZ = -100;
	DestZ-=StartZ;
	StartZ = 0;
	while ( DestZ>0 && LCount<8000 ) // Due to the inaccurate Unreal Engine physics code we need to do this.
	{
		StartZ+=GravZ*0.05f;
		DestZ+=StartZ*0.05f;
		LCount++;
	}
	Return Abs(StartZ);
}

// Use original behaviour.
function PathBuildingType EdPathBuildExec( NavigationPoint End, out int ForcedDistance )
{
	return Super(LiftExit).EdPathBuildExec(End,ForcedDistance);
}

// Draw trajectory.
function DrawEditorSelection( Canvas C )
{
	local color Color;
	local vector V,P,G;
	local byte i;
	local UJumpDest Dest;

	foreach AllActors(Class'UJumpDest',Dest)
		if( Dest.LiftTag==LiftTag )
			break;
	if( Dest==None )
		return;

	Color = MakeColor(255,255,0);
	V = SuggestFallVelocity(Location,Dest.Location,CalcRequiredZHeight(Dest.Location.Z,Location.Z,Region.Zone.ZoneGravity.Z),6000.f) + JumpVelocityModifier;

	G = Region.Zone.ZoneGravity*Square(0.05f);
	V*=0.05f;
	P = Location;
	for( i=0; i<200; ++i )
	{
		V+=G;
		C.Draw3DLine(Color,P,P+V);
		if( !FastTrace(P+V,P) )
			break;
		P+=V;
	}
}

defaultproperties
{
	bEditorSelectRender=True
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bSkipActorReplication=True
	bCollideActors=True
	NetPriority=7.000000
	NetUpdateFrequency=5
}
