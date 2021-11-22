//=============================================================================
// CloakGame.
//=============================================================================
class CloakMatch expands DeathMatchGame;

var() config bool bTerranWeaponsOnly;
var Pawn CloakedPawn;
var() int SuicidePenalty;
var int BotCount;
var EnemyUpdater Updater;

function PostBeginPlay()
{
	if( bTerranWeaponsOnly )
		TerranWeaponSetup(Self);
	Super.PostBeginPlay();
}

function AddDefaultInventory(Pawn Player)
{
	super.AddDefaultInventory(Player);
	if (Player == CloakedPawn)
		AddPlayerDefaultPickup(Player, class'Cloak', true);
}

function Killed(pawn killer, pawn Other, name damageType)
{
	Other.AmbientGlow = 0;
	Other.LightType = LT_None;
	Other.DamageScaling = 1.0;
	Other.bUnLit = false;

	if( ( CloakedPawn == Other ) || ( CloakedPawn == None ) )
	{
		if( (killer == None) || (killer == Other) || (killer.Health <= 0) )
		{
			if( ( killer == CloakedPawn ) && ( CloakedPawn == Other ) )
				CloakedPawn.PlayerReplicationInfo.Score -= SuicidePenalty;
			CloakedPawn = None;
		} 
		else if( killer != CloakedPawn )
		{
			Killer.PlayerReplicationInfo.Score += 4;
			DestroyCloaks();
			CloakNewPawn( killer );
		}	
	}
	if( CloakedPawn != None && Other != CloakedPawn && CloakedPawn == Killer )
		CloakedPawn.PlayerReplicationInfo.Score += 2;
	AdjustHUDs();
	Super.Killed( killer, Other, damageType );
}

function DestroyCloaks()
{
	local Cloak C;
	
	foreach allactors( class'Cloak', C )
	{
		//C.GotoState( 'Deactivated' );
		//C.Charge = 0;
		C.Destroy();
	}
	AdjustHUDs();
}

function CloakNewPawn( pawn newCloakedPawn )
{
	local Cloak CloakItem;
	
	DestroyCloaks(); //fix 2 Cloak bug
	
	CloakedPawn = newCloakedPawn;
	CloakItem = spawn( class'Cloak', newCloakedPawn,, Location, Rotation );
	CloakItem.bHeldItem = true;
	CloakItem.GiveTo( newCLoakedPawn );
	//aPickup.Activate();
	newCloakedPawn.SelectedItem = CloakItem;
	CloakItem.PickupFunction( newCloakedPawn );
	CloakItem.Activate();
	AdjustHUDS();
}

function AdjustHUDS()
{
	local PlayerPawn P;
	
	foreach allactors( class'PlayerPawn', P )
	{
		CloakMatchHUD( P.MyHUD ).Target = CloakedPawn;
	}
//	if( BotCount > 0 )
//	{
//		AdjustBotEnemy();
//	}
}


function AdjustBotEnemy()
{
}

Static function TerranWeaponSetup( Actor Other )
{
	local Inventory I;
	
	ForEach Other.AllActors(Class'Inventory',I)
	{
		if( ASMDAmmo(I)!=None )
			I.Destroy();
		else if( Sludge(I)!=None )
			I.Destroy();
		else if( StingerAmmo(I)!=None )
			I.Destroy();
		else if( WeaponPowerup(I)!=None )
			I.Destroy();
		else if( Eightball(I)!=None )
		{
			ReplaceItem(I,Class'RocketLauncher');
			I.Destroy();
		}
		else if( RocketCan(I)!=None )
		{
			ReplaceItem(I,Class'RLAmmo');
			I.Destroy();
		}
		else if( FlakBox(I)!=None )
		{
			ReplaceItem(I,Class'GLAmmo');
			I.Destroy();
		}
		else if( GESBiorifle(I)!=None )
			I.Destroy();
		else if( Rifle(I)!=None )
		{
			ReplaceItem(I,Class'CARifle');
			I.Destroy();
		}
		else if( RifleAmmo(I)!=None )
		{
			ReplaceItem(I,Class'CARifleClip');
			I.Destroy();
		}
		else if( FlakCannon(I)!=None )
		{
			ReplaceItem(I,Class'GrenadeLauncher');
			I.Destroy();
		}
		else if( Stinger(I)!=None )
		{
			ReplaceItem(I,Class'Cloak');
			I.Destroy();
		}
		else if( Razorjack(I)!=None )
			I.Destroy();
		else if( MiniGun(I)!=None )
			I.Destroy();
		else if( AutoMag(I)!=None )
			I.Destroy();
		else if( ASMD(I)!=None )
			I.Destroy();
		else if( RazorAmmo(I)!=None )
			I.Destroy();
		else if( Shells(I)!=None )
			I.Destroy();
		else if( ShellBox(I)!=None )
			I.Destroy();
	}
}
static function bool ReplaceItem( Inventory Other, Class<Inventory> NewItem )
{
	local Inventory J;

	J = Other.Spawn( NewItem,,, Other.Location, Other.Rotation);
	if( J!=None && Other.MyMarker!=None )
	{
		J.MyMarker = Other.MyMarker;
		Other.MyMarker = None;
		J.MyMarker.markedItem = J;
	}
	Return (J!=None);
}

defaultproperties
{
				bTerranWeaponsOnly=True
				SuicidePenalty=5
				GameMenuType=Class'UPak.UPakGameOptionsMenu'
				HUDType=Class'UPak.CloakMatchHUD'
				GameName="CloakMatch"
}