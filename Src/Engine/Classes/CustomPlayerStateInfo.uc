class CustomPlayerStateInfo expands Info
	abstract
	nousercreate;

var PlayerPawn PlayerOwner;

auto state Inactive
{
}

state Active
{
	event BeginState()
	{
		if (PlayerOwner != none)
		{
			Handle_BeginState();
			PlayerOwner.LastUpdateTime = -1;
		}
	}

	event EndState()
	{
		if (PlayerOwner != none)
		{
			Handle_EndState();
			PlayerOwner.LastUpdateTime = -1;
		}
	}
}

function Init()
{
	PlayerOwner = PlayerPawn(Owner);
}

event Destroyed()
{
	if (PlayerOwner != none && PlayerOwner.CustomPlayerStateInfo == self)
		PlayerOwner.CustomPlayerStateInfo = none;
}

final static function Default_PlayerTick(PlayerPawn Player, float DeltaTime)
{
	if (Player.bUpdatePosition)
		Player.ClientUpdatePosition();

	if (Player.Role < ROLE_Authority)
		Player.ReplicateMove(DeltaTime, vect(0, 0, 0), DODGE_None, rot(0, 0, 0));
	else
		Player.ProcessMove(DeltaTime, vect(0, 0, 0), DODGE_None, rot(0, 0, 0));
}

// -----------------------------------------------------------------------------
// Handle events

function Handle_AnimEnd()
{
	PlayerOwner.GlobalFunc_AnimEnd();
}

function Handle_BaseChange()
{
	PlayerOwner.GlobalFunc_BaseChange();
}

function Handle_BeginState();

function Handle_Bump(Actor A)
{
	PlayerOwner.GlobalFunc_Bump(A);
}

function Handle_EndState();

function Handle_Falling()
{
	PlayerOwner.GlobalFunc_Falling();
}

function Handle_FootZoneChange(ZoneInfo NewZone)
{
	PlayerOwner.GlobalFunc_FootZoneChange(NewZone);
}

function Handle_HeadZoneChange(ZoneInfo NewZone)
{
	PlayerOwner.GlobalFunc_HeadZoneChange(NewZone);
}

function Handle_Landed(vector HitNormal)
{
	PlayerOwner.GlobalFunc_Landed(HitNormal);
}

function Handle_PainTimer()
{
	PlayerOwner.GlobalFunc_PainTimer();
}

function Handle_PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
	PlayerOwner.GlobalFunc_PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
}

function Handle_PlayerTick(float DeltaTime)
{
	Default_PlayerTick(PlayerOwner, DeltaTime);
}

function Handle_RenderOverlays(Canvas Canvas)
{
	PlayerOwner.GlobalFunc_RenderOverlays(Canvas);
}

function Handle_Touch(Actor A)
{
	PlayerOwner.GlobalFunc_Touch(A);
}

function Handle_UnTouch(Actor A)
{
	PlayerOwner.GlobalFunc_UnTouch(A);
}

function Handle_UpdateEyeHeight(float DeltaTime)
{
	PlayerOwner.GlobalFunc_UpdateEyeHeight(DeltaTime);
}

function Handle_ZoneChange(ZoneInfo NewZone)
{
	PlayerOwner.GlobalFunc_ZoneChange(NewZone);
}

// -----------------------------------------------------------------------------
// Handle exec functions

function Handle_ActivateHint()
{
	PlayerOwner.GlobalFunc_ActivateHint();
}

function Handle_ActivateInventoryItem(class InvItem)
{
	PlayerOwner.GlobalFunc_ActivateInventoryItem(InvItem);
}

function Handle_ActivateItem()
{
	PlayerOwner.GlobalFunc_ActivateItem();
}

function Handle_ActivateTranslator()
{
	PlayerOwner.GlobalFunc_ActivateTranslator();
}

function Handle_AltFire(optional float F)
{
	PlayerOwner.GlobalFunc_AltFire(F);
}

function Handle_ChangeHud()
{
	PlayerOwner.GlobalFunc_ChangeHud();
}

function Handle_FeignDeath();

function Handle_Fire(optional float F)
{
	PlayerOwner.GlobalFunc_Fire(F);
}

function Handle_GetWeapon(class<Weapon> NewWeaponClass)
{
	PlayerOwner.GlobalFunc_GetWeapon(NewWeaponClass);
}

function Handle_Grab()
{
	PlayerOwner.GlobalFunc_Grab();
}

function Handle_Jump(optional float F)
{
	PlayerOwner.GlobalFunc_Jump(F);
}

function Handle_NextItem()
{
	PlayerOwner.GlobalFunc_NextItem();
}

function Handle_NextWeapon()
{
	PlayerOwner.GlobalFunc_NextWeapon();
}

function Handle_PrevItem()
{
	PlayerOwner.GlobalFunc_PrevItem();
}

function Handle_PrevWeapon()
{
	PlayerOwner.GlobalFunc_PrevWeapon();
}

function Handle_Suicide()
{
	PlayerOwner.GlobalFunc_Suicide();
}

function Handle_SwitchWeapon(byte F)
{
	PlayerOwner.GlobalFunc_SwitchWeapon(F);
}

function Handle_Taunt(name Sequence)
{
	PlayerOwner.GlobalFunc_Taunt(Sequence);
}

function Handle_ThrowWeapon()
{
	PlayerOwner.GlobalFunc_ThrowWeapon();
}

function Handle_Walk()
{
	PlayerOwner.GlobalFunc_Walk();
}

// -----------------------------------------------------------------------------
// Handle regular functions

function Handle_AddVelocity(vector V)
{
	PlayerOwner.GlobalFunc_AddVelocity(V);
}

function bool Handle_AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	return PlayerOwner.GlobalFunc_AdjustHitLocation(HitLocation, TraceDir);
}

function float Handle_CalcDesiredPrePivotZ()
{
	return PlayerOwner.GlobalFunc_CalcDesiredPrePivotZ();
}

function bool Handle_CanInteractWithWorld()
{
	return PlayerOwner.GlobalFunc_CanInteractWithWorld();
}

function Handle_ChangedWeapon()
{
	PlayerOwner.GlobalFunc_ChangedWeapon();
}

function class<ClientReplicationInfo> Handle_ClientReplicationInfoBase()
{
	return PlayerOwner.GlobalFunc_ClientReplicationInfoBase();
}

function name Handle_DesiredClientState()
{
	return PlayerOwner.GlobalFunc_DesiredClientState();
}

function bool Handle_DesiredCrouch()
{
	return PlayerOwner.GlobalFunc_DesiredCrouch();
}

function Handle_Died(Pawn Killer, name DamageType, vector HitLocation)
{
	PlayerOwner.GlobalFunc_Died(Killer, DamageType, HitLocation);
}

function Handle_DoJump(optional float F)
{
	PlayerOwner.GlobalFunc_DoJump(F);
}

function Handle_HandleWalking()
{
	PlayerOwner.GlobalFunc_HandleWalking();
}

function Handle_KilledBy(Pawn EventInstigator)
{
	PlayerOwner.GlobalFunc_KilledBy(EventInstigator);
}

function Handle_PlayChatting()
{
	PlayerOwner.GlobalFunc_PlayChatting();
}

function Handle_ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
{
	PlayerOwner.GlobalFunc_ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
}

function Handle_ServerTaunt(name Sequence)
{
	PlayerOwner.GlobalFunc_ServerTaunt(Sequence);
}

function Handle_StartClimbing(LadderTrigger Ladder)
{
	PlayerOwner.GlobalFunc_StartClimbing(Ladder);
}

function Handle_TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, name DamageType)
{
	PlayerOwner.GlobalFunc_TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

function Handle_UpdateRotation(float DeltaTime, float MaxPitch)
{
	PlayerOwner.GlobalFunc_UpdateRotation(DeltaTime, MaxPitch);
}

defaultproperties
{
	RemoteRole=ROLE_None
}
