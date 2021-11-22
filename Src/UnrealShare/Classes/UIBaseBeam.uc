//=============================================================================
// basic beam.
//=============================================================================
class UIBaseBeam extends UIBeamIncludes;

var UIBaseBeam ChildBeam;
var int Position;
var UIBeamEmitter MyEmitter;
var Actor DamagedActor;
var Actor WallEffect;

var bool bUpdated;
var vector BackupHit;
var bool bLocationEnd;
var actor CurrentTarget;
var UIBaseBeam ChildRoot;
var bool bCreateRoot;
var actor ChildBeamTarget;
var actor SecondBeamTarget;
var bool bIsChild;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority ) bUpdated,bIsChild;
}

simulated function Spawned()
{
	if (UIBaseBeam(Owner) != none/*Owner.Owner != none && CHBeamEmitter(Owner.Owner) != none*/)
	{
		bIsChild=UIBaseBeam(Owner).bIsChild;
		MyEmitter=UIBaseBeam(Owner).MyEmitter;
		ForceSettings(MyEmitter);
		CurrentTarget=UIBaseBeam(Owner).CurrentTarget;
	}
}

simulated function CreateRoot(vector X)
{
	if (ChildRoot == none)
	{
		ChildRoot = Spawn(class'UIBaseBeam',self,'root', Location + MyEmitter.ReturnNormalScale * X);
		ChildRoot.bIsChild=true;
		ChildRoot.Position = 1;
		ChildRoot.CurrentTarget=ChildBeamTarget;
		ChildRoot.UpdateChild();
	}
}

simulated function UpdateChild()
{
	bIsChild=true;
	if (ChildBeam != none) ChildBeam.bIsChild=true;
}

simulated function CheckBeam(vector X, float DeltaTime)
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	if ( MyEmitter != none)
	{
		if (MyEmitter.bUseHitLocation)
		{
			HitActor = Trace(HitLocation, HitNormal, Location + MyEmitter.ReturnNormalScale * X, Location, true);
			if ( (HitActor != None) && (HitActor != Instigator) && (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers)) && ((Pawn(HitActor) == None) || Pawn(HitActor).AdjustHitLocation(HitLocation, Velocity)) )
			{
				if ( Level.Netmode != NM_Client )
				{
					if (MyEmitter.bDamageActors)
					{
						if ( DamagedActor == None)
						{
							HitActor.TakeDamage(MyEmitter.BeamDamage, instigator, HitLocation, (MyEmitter.BeamMomentumTransfer * X), MyEmitter.BeamDamageType);
						}
						else
						{
							DamagedActor.TakeDamage(MyEmitter.BeamDamage, instigator, HitLocation, (MyEmitter.BeamMomentumTransfer * X), MyEmitter.BeamDamageType);
						}
					}
				}
				if (MyEmitter.WallHitEffect != none)
				{
					if ( HitActor.bIsPawn && Pawn(HitActor).bIsPlayer )
					{
						if ( WallEffect != None )
							WallEffect.Destroy();
					}
					else if ( (WallEffect == None) || WallEffect.bDeleteMe )
						WallEffect = Spawn(MyEmitter.WallHitEffect,,, HitLocation - 5 * X);
					else
						WallEffect.SetLocation(HitLocation - 5 * X);

					if ( (WallEffect != None) && (Level.NetMode != NM_DedicatedServer) && (MyEmitter.WallHitDecal != none))
						Spawn(MyEmitter.WallHitDecal,,,HitLocation,rotator(HitNormal));
				}
				if (MyEmitter.bStopOnCollision)
				{
					if ( ChildBeam != None )
					{
						ChildBeam.Destroy();
						ChildBeam = None;
					}

					return;
				}
			}
			else if ( (Level.Netmode != NM_Client) && (DamagedActor != None) )
			{
				DamagedActor = None;
			}
		}

		if ( Position > MyEmitter.RealNumSegments || (MyEmitter.bForceTargetClip && abs(vsize(Location-CurrentTarget.Location)) <= MyEmitter.BeamTargetClipDistance && CurrentTarget != none))
			bLocationEnd=true;
		if (!bLocationEnd)
		{
			if ( ChildBeam == None )
			{
				ChildBeam = Spawn(class'UIBaseBeam',self,'', Location + MyEmitter.ReturnNormalScale * X);
				ChildBeam.Position = Position + 1;
			}
			else
				ChildBeam.UpdateBeam(self, X, DeltaTime);

		}
		if (bCreateRoot && ChildRoot == none)
		{
			CreateRoot(X);
			bCreateRoot=false;
		}

		if (ChildRoot != none)
			ChildRoot.UpdateBeam(self, X, DeltaTime);
	}
}

simulated function UpdateBeam(UIBaseBeam ParentBeam, vector Dir, float DeltaTime)
{
	local vector HitLocation;

	if ( MyEmitter != none)
	{
		SetLocation(ParentBeam.Location + MyEmitter.ReturnNormalScale * Dir);
		if (!bUpdated)
		{
			HitLocation=RandomizeGiven(Dir,MyEmitter.BeamSprayFactor,0.5);
			if (CurrentTarget != none) HitLocation+=ModifyPath(CurrentTarget, Location, MyEmitter.BeamTargetSpray);
			HitLocation=Normal(HitLocation);
		}
		else
		{
			HitLocation=BackupHit;
		}
		if (MyEmitter.bKeepShape && !bUpdated)
		{
			BackupHit=HitLocation;
			bUpdated=true;
		}
		SetRotation(rotator(HitLocation));
		CheckBeam(HitLocation, DeltaTime);
	}
}

simulated function Destroyed()
{
	if (ChildBeam != none) ChildBeam.Destroy();
	if (WallEffect != None) WallEffect.Destroy();
	if (ChildRoot != none) ChildRoot.Destroy();
}

defaultproperties
{
	bNetTemporary=False
	Physics=PHYS_None
	RemoteRole=ROLE_None
	bCollideActors=True
	bCollideWorld=False
	DrawType=DT_Mesh
}
