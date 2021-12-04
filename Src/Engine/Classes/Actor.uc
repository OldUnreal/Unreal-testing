//=============================================================================
// Actor: The base class of all actors.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Actor extends Object
	abstract
		native
			NativeReplication;

// Imported data (during full rebuild).
#exec Texture Import File=Textures\S_Actor.pcx Name=S_Actor Mips=Off Flags=2

// Flags.
var(Advanced) const bool	bStatic;		// Does not move or change over time (note that this is very much optimized for network play).
var(Advanced) bool			bHidden;		// Is hidden during gameplay.
var(Advanced) const bool	bNoDelete;		// Cannot be deleted during play (note that this makes actor more optimized for network play).
var bool					bAnimFinished;	// Unlooped animation sequence has finished.
var(Display) bool			bAnimLoop;		// Whether animation is looping.
var norepnotify bool		bAnimNotify;	// Whether a notify is applied to the current sequence.
var(Advanced) bool			bAnimByOwner;	// Animation dictated by owner.
var const bool				bDeleteMe;		// About to be deleted.
var transient const bool	bAssimilated;	// Actor dynamics are assimilated in world geometry.
var transient const bool	bTicked;		// Actor has been updated.
var transient bool			bLightChanged;	// Recalculate this light's lighting now.
var bool					bDynamicLight;	// Temporarily treat this as a dynamic light.
var bool					bTimerLoop;		// Timer loops (else is one-shot).

// 227 Booleans
var bool				bNetNotify;			// Call PostNetReceive when a variable has been replicated to client.
var bool				bHandleOwnCorona;		// Internal flag.
var(Display)   bool		bRenderMultiEnviroMaps;	// Display multiple mesh environment textures at once.
var(Collision) bool		bWorldGeometry;		// If true, this actor acts with traces as part of the world geometry.
var(Collision) bool		bUseMeshCollision;	// This actor should use it's mesh zero frame as a 3D collision model.
var	bool				bEditorSelectRender;
var(Display) bool		bNoDynamicShadowCast;	// Don't cast projector/decal shadows. Does not affect BSP shadows!
var(Display) bool		bProjectorDecal;	// Decal is a projector.
var(Display) bool		bUseLitSprite;		// On DT_Sprite, make sprites lit by light sources.
var(Advanced) bool        bTickRealTime;     // Tick this actor using real time passing instead of one scaled by TimeDilation.

// Editing flags
var(Advanced) bool        bHiddenEd;     // Actor is hidden during editing.
var(Advanced) bool        bDirectional;  // Actor shows direction arrow during editing.
var const bool            bSelected;     // Selected in UnrealEd.
var const bool            bMemorized;    // Remembered in UnrealEd.
var const bool            bHighlighted;  // Highlighted in UnrealEd.
var bool                  bEdLocked;     // Locked in editor (no movement or rotation).
var(Advanced) bool        bEdShouldSnap; // Snap to grid in editor.
var transient bool        bEdSnap;       // Should snap to grid in UnrealEd.
var transient const bool  bTempEditor;   // Internal UnrealEd.

// What kind of gameplay scenarios to appear in.
var(Filter) bool          bDifficulty0;  // Appear in difficulty 0.
var(Filter) bool          bDifficulty1;  // Appear in difficulty 1.
var(Filter) bool          bDifficulty2;  // Appear in difficulty 2.
var(Filter) bool          bDifficulty3;  // Appear in difficulty 3.
var(Filter) bool          bSinglePlayer; // Appear in single player.
var(Filter) bool          bNet;          // Appear in regular network play.
var(Filter) bool          bNetSpecial;   // Appear in special network play mode.

// set to prevent re-initializing of actors spawned during level startup
var	transient bool		  bScriptInitialized;

// Other flags.
var(Advanced) bool		bCanTeleport;	// This actor can be teleported.
var(Advanced) bool		bIsSecretGoal;	// This actor counts in the "secret" total (unused).
var(Advanced) bool		bIsKillGoal;	// This actor counts in the "death" toll (unused).
var(Advanced) bool		bIsItemGoal;	// This actor counts in the "item" count (unused).
var(Advanced) bool		bCollideWhenPlacing; // This actor collides with the world when placing.
var(Advanced) bool		bTravel;		// Actor is capable of travelling among servers (not for mappers).
var(Advanced) bool		bMovable;		// Actor is able to move.
var(Advanced) bool		bHighDetail;	// Only show up on high-detail.
var(Advanced) bool		bStasis;		// In StandAlone games, turn off if not in a recently rendered zone turned and physics = PHYS_None or PHYS_Rotating.
var(Advanced) bool		bForceStasis;	// Force stasis when not recently rendered, even if physics not none or rotating.
var const     bool		bIsPawn;		// True only for pawns.
var const     bool		bIsPlayerPawn;	// True only for playerpawns.
var const     bool		bIsProjectile;	// True only for projectiles.
var const     bool		bIsStaticMesh;	// True only for static mesh actors (hint for editor when hiding static meshes).
var(Advanced) const bool	bNetTemporary;	// Tear-off simulation in network play (mainly for projectiles, not for mappers).
var(Advanced) const bool	bNetOptional;	// Actor should only be replicated if bandwidth available.
var(Networking) bool		bReplicateInstigator; // Replicate instigator to client (used by bNetTemporary projectiles).
var(Advanced) bool		bTrailerSameRotation; // If PHYS_Trailer and true, have same rotation as owner.

// Display.
var(Display)  bool      bUnlit;          // Lights don't affect actor.
var(Display)  bool      bNoSmooth;       // Don't smooth actor's texture.
var(Display)  bool      bParticles;      // Mesh is a particle system. Don't forget to set Texure->Alpha in case of an alphablend texture.
var(Display)  bool      bRandomFrame;    // Particles use a random texture from among the default texture and the multiskins textures.
var(Display)  bool      bMeshEnviroMap;  // Environment-map the mesh.
var(Display)  bool		bFilterByVolume; // Filter this sprite by its Visibility volume.
var bool				bMeshCurvy;      // Not used anymore.

// 227: Implemented.
var(Display) bool       bShadowCast;     // Casts shadows on BSP after rebuild in editor.
var bool				bCustomDrawActor; // Call DrawActor function when it's this actors turn to render self.

// Advanced.
var(Advanced) bool	bOwnerNoSee;	// Everybody but the owner can see this actor.
var(Advanced) bool	bOnlyOwnerSee;	// Only owner can see this actor.
var const     bool	bIsMover;		// Is a mover, used for faster C++ casting, DO NOT EDIT!
var(Networking) bool	bAlwaysRelevant;	// Always relevant for network.
var const	  bool	bAlwaysTick;	// Update even when paused.
var bool			bHurtEntry;		// keep HurtRadius from being reentrant
var(Advanced) bool	bGameRelevant;	// Always relevant for game (prevents filters and mutators from removing).
var bool			bCarriedItem;	// being carried, and not responsible for displaying self, so don't replicated location and rotation
var bool			bForcePhysicsUpdate; // force a physics update for simulated pawns

// 227 Network modifiers
var bool bSkipActorReplication;				// Don't replicate any actor properties.
var bool bRepAnimations;					// Should replicate animations.
var bool bRepAmbientSound;					// Should replicate ambient sound.
var bool bSimulatedPawnRep;					// Should replicate physics like simulated pawns.
var bool bRepMesh;							// Should replicate mesh and the skins.
var const bool bNetInitialRotation;			// Should initially network rotation when opening this actor channel (makes rotation valid on BeginPlay event clientside).

// Collision flags.
var(Collision) const bool bCollideActors;   // Collides with other actors.
var(Collision) bool       bCollideWorld;    // Collides with the world.
var(Collision) bool       bBlockActors;	    // Blocks other nonplayer actors.
var(Collision) bool       bBlockPlayers;    // Blocks other player actors.
var(Collision) bool       bProjTarget;      // Projectiles should potentially target this actor.
var(Collision) bool		  bPathCollision;	// This actor blocks paths during editor path defining.
var(Collision) bool		  bBlockZeroExtentTraces; // block zero extent actors/traces
var(Collision) bool		  bBlockNonZeroExtentTraces;	// block non-zero extent actors/traces
var(Collision) bool		  bBlockAISight;	// While non-blocking, should block AI sight?
var(Collision) bool		  bBlockTextureTrace; // If true, this actor only collides for texture tracing (can be used for easy walk texture meshes on ground).
var(Collision) const bool bBlockRigidBodyPhys; // Blocks rigidbody physics objects, requires bBlockActors as-well.

// Lighting.
var(Lighting) bool		bSpecialLit;	// Only affects special-lit surfaces.
var(Lighting) bool		bActorShadows;  // Light casts actor shadows.
var(Lighting) bool		bCorona;        // Light uses Skin as a corona.
var(Lighting) bool		bForcedCorona;  // 227j: Draw corona regardless of client corona enabled setting.
var(Lighting) bool		bLensFlare;     // Whether to use zone lens flare.
var(Lighting) bool		bDarkLight;		// Should be a subtractive light instead of additive.
var(NormalLighting) bool      bZoneNormalLight; // Whether NormalLightRadius is additionally zone dependent or not.

// Symmetric network flags, valid during replication only.
var const bool bNetInitial;       // Initial network update.
var const bool bNetOwner;         // Player owns this actor.
var const bool bNetRelevant;      // Actor is currently relevant. Only valid server side, only when replicating variables.
var const bool bNetSee;           // Player sees it in network play.
var const bool bNetHear;          // Player hears it in network play.
var const bool bNetFeel;          // Player collides with/feels it in network play.
var const bool bSimulatedPawn;	  // True if Pawn and simulated proxy.
var const bool bDemoRecording;	  // True we are currently demo recording
var const bool bClientDemoNetFunc;// True if we're client-side demo recording and this call originated from the remote.

// Physics options.
var(Movement) bool		bBounce;           // Actor does not change physics to PHYS_None when it hits a wall or floor.
var(Movement) bool		bFixedRotationDir; // Fixed direction of rotation (if combined with bRotateToDesired it does not rotate to nearest rotation, instead may turn around 270 degrees).
var(Movement) bool		bRotateToDesired;  // Rotate to DesiredRotation.
var           bool		bInterpolating;    // Performing interpolating.
var const bool			bJustTeleported;   // Used by engine physics - not valid for scripts.
var const bool			bNotifyPositionUpdate; // Call C++ callback when this Actor was moved.

// 227 Variables
//=============================================================================

// 227 networking variables:
var transient const bool bNetBeginPlay;		// 227j: This actor just received initial replication (set to true AFTER PostBeginPlay but to false BEFORE PostNetBeginPlay)
var transient bool		bForceNetUpdate;	// 227j: When set to TRUE will force this actor to immediately be considered for replication, instead of waiting for NetUpdateTime
var transient const bool bPendingNetUpdate; // 227j: This actor is pending net update because client was unable to receive it due to net saturation.
var transient bool		bNetDirty;			// 227j: This actor has had one of its network variable changed and needs to be replicated.
var(Networking) bool	bCrossLevelNetwork;	// if bAlwaysRelevant, this actor should replicate to across level clients.
var(Networking) bool	bOnlyOwnerRelevant;	// This actor can only be network relevant to owner actor.
var(Networking) bool	bOnlyDirtyReplication; // 227j: This actor should only be networked when its bNetDirty.
var(Networking) bool	bForceDirtyReplication; // 227j: This actor should instantly network update when its bNetDirty (even if NetUpdateTime isn't yet).
var bool				bAlwaysNetDirty;	// 227j: This actor should always be net dirty every tick (mainly for PlayerPawn).

var transient const bool bRunningPhysics;	// 227j: This actor is currently simulating a physics step (thus can't change velocity).
var transient bool		bEdSelectionLock;	// 227j: This actor can't be selected in editor.
var bool				bTraceHitBoxes;		// 227j: This actor should trace skeletal mesh hitboxes.
var bool				bTextureAnimOnce;	// 227j: DT_SpriteAnimOnce but for mesh skins.
var private bool		bSerializeMeshInst; // Internal: Should serialize mesh instance data.
var(Advanced) bool		bSpecialBrushActor;	// 227j Editor only: This actor can be deployed as a brush actor.
var(Advanced) bool		bNetInterpolatePos;	// 227j: This actor should interpolate between position on net updates.
var(Movement) bool		bHardAttach;		// Extra sticky attachment to base (for Skeletal meshes this makes them update even when not drawn).
var(Frob) bool			bIsFrobable;		//To manipulate or adjust, to tweak this actor over Frob() interface.
var(Advanced) float		RandomDelayTime;	// Changes the delay in which a new random value is applied. Currently in use for lighting effect RandomSubtlePulse and RandomPulse.
var transient float		RandomValue,LastRandomTime;	// Random value (f.e. in internal use in relation with RandomDelayTime, set with appFrand()).
var transient name		BlendAnimationSequence; // When bleding to new animation, this is the old anim sequence.

var transient	float	LastRenderedTime;	// Most recent TimeSeconds this actor was rendered.
var(Display)	color	ActorRenderColor,	// Actor lit color light scaling.
						ActorGUnlitColor,	// Actor unlit color.
						AmbientGlowColor;	// Actor unlit color.
var Primitive			CollisionOverride;	// Uses this primitive as collision model on this actor.
var pointer<FMeshInstanceBase*> MeshInstance; // Mesh render instance.
var vector				RelativeLocation;	// When this actor is being attached to bone of some other actor, use this offset to it.
var rotator				RelativeRotation;
var pointer<FLightVisibilityCache*> LightDataPtr; // Cached light data.
var pointer<FDynamicSprite*> RenderState;	// Pending render state.
var pointer<FInterpolateData*> RenderInterpolate; // Interpolation data when net updating.
var int					CollisionGroups,CollisionFlag; // 2 actors with matching groups and flags are allowed to block each other!
var(Movement) const editinline export PX_PhysicsDataBase PhysicsData; // Current rigidbody physics data associated to this actor while PHYS_RigidBody.
var pointer<FActorRBPhysicsBase*> RbPhysicsData;	// Internal physics data.

var enum ERenderPass
{
	RP_Auto,								// Let Engine handle it.
	RP_Solid,								// Fully solid
	RP_SemiSolid,							// Partially translucent
	RP_Translucent,							// Fully translucent, must draw last.
} RenderPass;								// Overridden render pass

var enum EHitBoxType
{
	HITBOX_Default,
	HITBOX_Head,
	HITBOX_Chest,
	HITBOX_Stomach,
	HITBOX_LeftArm,
	HITBOX_RightArm,
	HITBOX_LeftLeg,
	HITBOX_RightLeg,
} LastHitBox; // When tracing skeletal mesh hitboxes, which hitbox type was last hit with this actor.

var(Display)	vector				DrawScale3D;		// 3D scaling.
var transient	const				array<Projector> ProjectorList;
var pointer<BYTE*>					NetInitialProperties;
var pointer<struct FTreeActor*>		OctreeNode;
var noedsave const	array<Actor>	RealTouching;		// The actual touchlist in 227, can be accessed with TouchingActors iterator.
var pointer<TArray<AActor*>*>		RealBasedActors;	// Actual list of actors based on this actor.
var pointer<TArray<AActor*>*>		RealChildActors;	// Actual list of actors owned by this actor.
var pointer<TArray<UPXJ_BaseJoint*>*> JoinedActorsPtr;	// List of jointed actors to this.
var pointer<struct FNetworkData*>	NetworkChannels;	// Currently opened ActorChannels for this Actor.

struct export MultiTimerType
{
	var name Func;
	var float Rate,Counter;
	var Object Object;
	var any Data;
	
	cpptext
	{
		FMultiTimerType( FName F, FLOAT R, FLOAT C, UObject* Obj, FAnyProperty* A )
			: Func(F), Rate(R), Counter(C), Object(Obj), Data(A)
		{
			if( A ) A->AddRef();
		}
		~FMultiTimerType()
		{
			if( Data ) Data->Release();
		}
	}
};
var noedsave array<MultiTimerType> MultiTimers;

var map<name,any> UserData; // For modders to use to store user data with this actor.

// Priority Parameters
// Actor's current physics mode.
var(Movement) const enum EPhysics
{
	PHYS_None,
	PHYS_Walking,
	PHYS_Falling,
	PHYS_Swimming,
	PHYS_Flying,
	PHYS_Rotating,
	PHYS_Projectile,
	PHYS_Rolling,
	PHYS_Interpolating,
	PHYS_MovingBrush,
	PHYS_Spider,
	PHYS_Trailer,
	PHYS_RigidBody, // 227j: Rigidbody physics if supported by PhysicsEngine.
} Physics;

// Net variables.
enum ENetRole
{
	ROLE_None,					// No role at all.
	ROLE_DumbProxy,				// Dumb proxy of this actor.
	ROLE_SimulatedProxy,			// Locally simulated proxy of this actor.
	ROLE_AutonomousProxy,			// Locally autonomous proxy of this actor.
	ROLE_Authority,				// Authoritative control over the actor.
};
var ENetRole Role;
var(Networking) ENetRole RemoteRole; /* Networking role:
										ROLE_None - No networking on this actor.
										ROLE_DumbProxy - Full physics network replication.
										ROLE_SimulatedProxy - Only initial physics replication.
										ROLE_AutonomousProxy - Not to be used by mappers.
										ROLE_Authority - Not to be used by mappers. */

// Owner.
var noedsave norepnotify const Actor Owner;		// Owner actor.
var(Object) name		InitialState;
var(Object) name		Group;		// Editor group name.

// Execution and timer variables.
var float			TimerRate;		// Timer event, 0=no timer.
var const float		TimerCounter;	// Counts up until it reaches TimerRate.
var(Advanced) float	LifeSpan;		// How old the object lives before dying, 0=forever.

// Animation variables.
var(Display) name		AnimSequence;	// Animation sequence we're playing.
var(Display) float	AnimFrame;		// Current animation frame, 0.0 to 1.0.
var(Display) float	AnimRate;		// Animation rate in frames per second, 0=none, negative=velocity scaled.
var          float	TweenRate;		// Tween-into rate.
var const    Animation	SkelAnim;		// Override skeletal animation (use LinkSkelAnim).
var const    array<Animation> AnimSets;	// Use LinkSkelAnim to add animations here.

var(Display) float	LODBias;		// LodMesh render Level Of Detail scaling.

var(Display) editinline AnimationNotify AnimationNotify;

//-----------------------------------------------------------------------------
// Structures.

// Identifies a unique convex volume in the world.
struct PointRegion
{
	var zoneinfo Zone;       // Zone.
	var int      iLeaf;      // Bsp leaf.
	var byte     ZoneNumber; // Zone number.
};

// Mesh sockets
// Use GetSocketInfo/SetSocketInfo to modify sockets in-game.
// Use GetBoneIndex to get socket index.
// Use AttachActorToBone to attach actor to the said socket.
// Use GetBoneLocation/Rotation/Coords to get socket position.
struct export MeshSocketInfo
{
	var() int iVerts[3];	// If vertex mesh, 3 verts that build up a triangle, origin will be location, direction to iVert[0] will be forward and normal will be up direction.
	var() name BoneName;	// If skeletal mesh, name of the bone that this socket is attached to.
	var() name SocketName;	// Name of this socket.
	var() vector Offset;	// RelativeOffset of the attachment.
	var() rotator RotOffset; // RelativeRotation of the attachment.
};

//-----------------------------------------------------------------------------
// Major actor properties.

// Scriptable.
var       const LevelInfo Level;         // Level this actor is on.
var       const Level     XLevel;        // Level object.
var(Events) name		  Tag;			 // Actor's tag name.
var(Events) name          Event;         // The event this actor causes.
var Actor                 Target;        // Actor we're aiming at (other uses as well).
var Pawn                  Instigator;    // Pawn responsible for damage.
var Inventory             Inventory;     // Inventory chain.
var const norepnotify Actor Base;          // Moving brush actor we're standing on.
var const PointRegion	  Region;        // Region this actor is in.
var const name            AttachedBone;  // Skeletal mesh bone were attached to.
var(Movement)	name	  AttachTag;	 // Tag of actor this actor should be initially based on.

// Internal.
var noedsave const byte	  StandingCount; // Count of actors standing on this actor.
var noedsave const byte   MiscNumber;    // Internal use.
var noedsave const byte   LatentByte;    // Internal latent function use.
var noedsave const int    LatentInt;     // Internal latent function use.
var noedsave const float  LatentFloat;   // Internal latent function use.
var noedsave const actor  LatentActor;   // Internal latent function use.
var noedsave const actor  Touching[4];   // List of touching actors.
var const actor           Deleted;       // Next actor in just-deleted chain.

// Internal tags.
var const transient int CollisionTag, LightingTag, NetTag, OtherTag, ExtraTag, SpecialTag;

// The actor's position and rotation.
var(Movement) const norepnotify vector	Location;		// Actors initial location.
var(Movement) const norepnotify rotator	Rotation;		// Actors initial rotation.
var noedsave const vector				OldLocation;	// Actors old location one tick ago.
var noedsave const vector				ColLocation;	// Actors old location one move ago.
var(Movement) norepnotify vector		Velocity;		// Velocity.
var(Movement) norepnotify vector		Acceleration;	// Acceleration.

var(Filter) float		  OddsOfAppearing; // 0-1 - chance actor will appear in relevant game modes.

// Editor support.
var Actor				  HitActor;		// Actor to return instead of this one, if hit.

//-----------------------------------------------------------------------------
// Display properties.

// Drawing effect.
var(Display) enum EDrawType
{
	DT_None,
	DT_Sprite,
	DT_Mesh,
	DT_Brush,
	DT_RopeSprite,
	DT_VerticalSprite,
	DT_Terraform,
	DT_SpriteAnimOnce,
} DrawType;

// Style for rendering sprites, meshes.
var(Display) enum ERenderStyle
{
	STY_None,
	STY_Normal,
	STY_Masked,
	STY_Translucent,
	STY_Modulated,
	STY_AlphaBlend,
} Style;

// Other display properties.
var(Display) texture    Sprite;			 // Sprite texture if DrawType=DT_Sprite.
var(Display) texture    Texture;		 // Misc texture (i.e: environment texture).
var(Display) texture    Skin;            // Mesh skin #1.
var(Display) mesh       Mesh;            // Mesh if DrawType=DT_Mesh.
var(Display) mesh       ShadowMesh;      // If Mesh, DrawType=DT_Mesh and bShadowCast, use this mesh for casting the shadow.
var const export model  Brush;           // Brush if DrawType=DT_Brush.
var(Display) norepnotify float DrawScale;// Scaling factor, 1.0=normal size.
var(Display) norepnotify vector PrePivot;// Offset from box center for drawing.
var(Display) norepnotify float ScaleGlow;// Multiplies lighting scale.
var(Display)  float     VisibilityRadius;// Actor is drawn if viewer is within its visibility radius. Zero=infinite visibility. Negative=hidden if within radius.
var float VisibilityHeight;				 // unused since 227j.
var(Display) norepnotify byte AmbientGlow;// Ambient brightness, or 255=pulsing.
var(Display) norepnotify byte Fatness;   // Fatness in UU (mesh distortion), 128 = default.
var(Display) float		SpriteProjForward;// Distance forward to draw sprite from actual location.
var(Display) float		AmbientGlowPulseSpeed; //pulse speed for AmbientGlow.

// Multiple skin support.
var(Display) texture	MultiSkins[8]; // Mesh skins #0-7.

//-----------------------------------------------------------------------------
// Sound.

// Ambient sound.
var(Sound) norepnotify byte SoundRadius;	 // Radius of ambient sound.
var(Sound) norepnotify byte SoundVolume;	 // Volume of amient sound.
var(Sound) norepnotify byte SoundPitch;	     // Sound pitch shift, 64.0=none.
var(Sound) sound        AmbientSound;    // Ambient sound effect.

// Regular sounds.
var(Sound) float		TransientSoundVolume; // Default sound volume of this actor.
var(Sound) float		TransientSoundRadius; // Default sound radius of this actor.

// Sound slots for actors.
enum ESoundSlot
{
	SLOT_None,
	SLOT_Misc,
	SLOT_Pain,
	SLOT_Interact,
	SLOT_Ambient,
	SLOT_Talk,
	SLOT_Interface,
};

// Music transitions.
enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};

//-----------------------------------------------------------------------------
// Collision.

// Collision size.
var(Collision) norepnotify const float CollisionRadius; // Radius of collision cyllinder.
var(Collision) norepnotify const float CollisionHeight; // Half-height cyllinder.

//-----------------------------------------------------------------------------
// Lighting.

// Light modulation.
var(Lighting) enum ELightType
{
	LT_None,
	LT_Steady,
	LT_Pulse,
	LT_Blink,
	LT_Flicker,
	LT_Strobe,
	LT_BackdropLight,
	LT_SubtlePulse,
	LT_TexturePaletteOnce,
	LT_TexturePaletteLoop,
	LT_RandomPulse, //using random LightPeriod.
	LT_RandomSubtlePulse //using random LightPeriod.
} LightType;

// Spatial light effect to use.
var(Lighting) enum ELightEffect
{
	LE_None,
	LE_TorchWaver,
	LE_FireWaver,
	LE_WateryShimmer,
	LE_Searchlight,
	LE_SlowWave,
	LE_FastWave,
	LE_CloudCast,
	LE_StaticSpot,
	LE_Shock,
	LE_Disco,
	LE_Warp,
	LE_Spotlight,
	LE_NonIncidence,
	LE_Shell,
	LE_OmniBumpMap,
	LE_Interference,
	LE_Cylinder,
	LE_Rotor,
	LE_Sunlight
} LightEffect;

// Lighting info.
var(LightColor) norepnotify byte
	LightBrightness,
	LightHue,
	LightSaturation;

// Light properties.
var(Lighting) norepnotify byte
	LightRadius, // Lighting radius = 25 X (LightRadius+1).
	LightPeriod, // Lighting 'speed' of LT_Pulse, LT_Blink, LT_SubtlePulse, LT_TexturePaletteLoop and LE_Searchlight.
	LightPhase, // Lighting time offset in LT_Pulse, LT_Blink, LT_SubtlePulse, LT_TexturePaletteLoop and LE_Searchlight.
	LightCone, // Light cone in LE_Spotlight.
	VolumeBrightness,
	VolumeRadius, // Volumetric fog radius = 25 X (VolumeRadius+1).
	VolumeFog;

// Lighting.
var transient float		CoronaAlpha;	// Corona fade brightness (227g: moved from Render to Actor).

// Normal (bump)mapping (depends on lighting information)
var(NormalLighting) float NormalLightRadius; // To configure a radius in which normal mapping appears, independently from LightRadius. 0 (default) disables the effect except for LE_Sunlight.

//-----------------------------------------------------------------------------
// Physics.

// Dodge move direction.
var enum EDodgeDir
{
	DODGE_None,
	DODGE_Left,
	DODGE_Right,
	DODGE_Forward,
	DODGE_Back,
	DODGE_Active,
	DODGE_Done
} DodgeDir;

// Physics properties.
var(Movement) float       Mass;            // Mass of this actor.
var(Movement) float       Buoyancy;        // Water buoyancy (if higher than Mass, actor will float).
var(Movement) norepnotify rotator RotationRate;    // Change in rotation per second.
var(Movement) norepnotify rotator DesiredRotation; // Physics will rotate pawn to this if bRotateToDesired.
var           float       PhysAlpha;       // Interpolating position, 0.0-1.0.
var           float       PhysRate;        // Interpolation rate per second.
var	transient const Actor PendingTouch;    // Actor touched during move which wants to add an effect after the movement completes, 227j: Use SetPendingTouch.

//-----------------------------------------------------------------------------
// Animation.

// Animation control.
var          float        AnimLast;        // Last frame.
var norepnotify float     AnimMinRate;     // Minimum rate for velocity-scaled animation.
var			 float		  OldAnimRate;	   // Animation rate of previous animation (= AnimRate until animation completes).
var	norepnotify plane	  SimAnim;		   // replicated to simulated proxies.

//-----------------------------------------------------------------------------
// Networking.

// Network control.
var(Networking) float NetPriority; // Higher priorities means update it more frequently.
var(Networking) float NetUpdateFrequency; // How many times per second between net updates.
var transient float NetUpdateTime; // Next RealTimeSeconds this actor will be network updated.
var pointer<struct FActorPriority*> NetworkPtr;

//-----------------------------------------------------------------------------
// Enums.

// Travelling from server to server.
enum ETravelType
{
	TRAVEL_Absolute,	// Absolute URL.
	TRAVEL_Partial,		// Partial (carry name, reset server).
	TRAVEL_Relative,	// Relative URL.
};

// Input system states.
enum EInputAction
{
	IST_None,    // Not performing special input processing.
	IST_Press,   // Handling a keypress or button press.
	IST_Hold,    // Handling holding a key or button.
	IST_Release, // Handling a key or button release.
	IST_Axis,    // Handling analog axis movement.
};

// Input keys.
enum EInputKey
{
	/*00*/	IK_None			,IK_LeftMouse	,IK_RightMouse	,IK_Cancel		,
	/*04*/	IK_MiddleMouse	,IK_Unknown05	,IK_Unknown06	,IK_Unknown07	,
	/*08*/	IK_Backspace	,IK_Tab         ,IK_Unknown0A	,IK_Unknown0B	,
	/*0C*/	IK_Unknown0C	,IK_Enter	    ,IK_Unknown0E	,IK_Unknown0F	,
	/*10*/	IK_Shift		,IK_Ctrl	    ,IK_Alt			,IK_Pause       ,
	/*14*/	IK_CapsLock		,IK_MouseButton4,IK_MouseButton5,IK_MouseButton6,
	/*18*/	IK_MouseButton7	,IK_MouseButton8,IK_Unknown1A	,IK_Escape		,
	/*1C*/	IK_Unknown1C	,IK_Unknown1D	,IK_Unknown1E	,IK_Unknown1F	,
	/*20*/	IK_Space		,IK_PageUp      ,IK_PageDown    ,IK_End         ,
	/*24*/	IK_Home			,IK_Left        ,IK_Up          ,IK_Right       ,
	/*28*/	IK_Down			,IK_Select      ,IK_Print       ,IK_Execute     ,
	/*2C*/	IK_PrintScrn	,IK_Insert      ,IK_Delete      ,IK_Help		,
	/*30*/	IK_0			,IK_1			,IK_2			,IK_3			,
	/*34*/	IK_4			,IK_5			,IK_6			,IK_7			,
	/*38*/	IK_8			,IK_9			,IK_Unknown3A	,IK_Unknown3B	,
	/*3C*/	IK_Unknown3C	,IK_Unknown3D	,IK_Unknown3E	,IK_Unknown3F	,
	/*40*/	IK_Unknown40	,IK_A			,IK_B			,IK_C			,
	/*44*/	IK_D			,IK_E			,IK_F			,IK_G			,
	/*48*/	IK_H			,IK_I			,IK_J			,IK_K			,
	/*4C*/	IK_L			,IK_M			,IK_N			,IK_O			,
	/*50*/	IK_P			,IK_Q			,IK_R			,IK_S			,
	/*54*/	IK_T			,IK_U			,IK_V			,IK_W			,
	/*58*/	IK_X			,IK_Y			,IK_Z			,IK_Unknown5B	,
	/*5C*/	IK_Unknown5C	,IK_Unknown5D	,IK_Unknown5E	,IK_Unknown5F	,
	/*60*/	IK_NumPad0		,IK_NumPad1     ,IK_NumPad2     ,IK_NumPad3     ,
	/*64*/	IK_NumPad4		,IK_NumPad5     ,IK_NumPad6     ,IK_NumPad7     ,
	/*68*/	IK_NumPad8		,IK_NumPad9     ,IK_GreyStar    ,IK_GreyPlus    ,
	/*6C*/	IK_Separator	,IK_GreyMinus	,IK_NumPadPeriod,IK_GreySlash   ,
	/*70*/	IK_F1			,IK_F2          ,IK_F3          ,IK_F4          ,
	/*74*/	IK_F5			,IK_F6          ,IK_F7          ,IK_F8          ,
	/*78*/	IK_F9           ,IK_F10         ,IK_F11         ,IK_F12         ,
	/*7C*/	IK_F13			,IK_F14         ,IK_F15         ,IK_F16         ,
	/*80*/	IK_F17			,IK_F18         ,IK_F19         ,IK_F20         ,
	/*84*/	IK_F21			,IK_F22         ,IK_F23         ,IK_F24         ,
	/*88*/	IK_Unknown88	,IK_Unknown89	,IK_Unknown8A	,IK_Unknown8B	,
	/*8C*/	IK_Unknown8C	,IK_Unknown8D	,IK_Unknown8E	,IK_Unknown8F	,
	/*90*/	IK_NumLock		,IK_ScrollLock  ,IK_Unknown92	,IK_Unknown93	,
	/*94*/	IK_Unknown94	,IK_Unknown95	,IK_Unknown96	,IK_Unknown97	,
	/*98*/	IK_Unknown98	,IK_Unknown99	,IK_Unknown9A	,IK_Unknown9B	,
	/*9C*/	IK_Unknown9C	,IK_Unknown9D	,IK_Unknown9E	,IK_Unknown9F	,
	/*A0*/	IK_LShift		,IK_RShift      ,IK_LControl    ,IK_RControl    ,
	/*A4*/	IK_UnknownA4	,IK_UnknownA5	,IK_UnknownA6	,IK_UnknownA7	,
	/*A8*/	IK_UnknownA8	,IK_UnknownA9	,IK_UnknownAA	,IK_UnknownAB	,
	/*AC*/	IK_UnknownAC	,IK_UnknownAD	,IK_UnknownAE	,IK_UnknownAF	,
	/*B0*/	IK_UnknownB0	,IK_UnknownB1	,IK_UnknownB2	,IK_UnknownB3	,
	/*B4*/	IK_UnknownB4	,IK_UnknownB5	,IK_UnknownB6	,IK_UnknownB7	,
	/*B8*/	IK_UnknownB8	,IK_UnknownB9	,IK_Semicolon	,IK_Equals		,
	/*BC*/	IK_Comma		,IK_Minus		,IK_Period		,IK_Slash		,
	/*C0*/	IK_Tilde		,IK_UnknownC1	,IK_UnknownC2	,IK_UnknownC3	,
	/*C4*/	IK_UnknownC4	,IK_UnknownC5	,IK_UnknownC6	,IK_UnknownC7	,
	/*C8*/	IK_Joy1	        ,IK_Joy2	    ,IK_Joy3	    ,IK_Joy4	    ,
	/*CC*/	IK_Joy5	        ,IK_Joy6	    ,IK_Joy7	    ,IK_Joy8	    ,
	/*D0*/	IK_Joy9	        ,IK_Joy10	    ,IK_Joy11	    ,IK_Joy12		,
	/*D4*/	IK_Joy13		,IK_Joy14	    ,IK_Joy15	    ,IK_Joy16	    ,
	/*D8*/	IK_UnknownD8	,IK_UnknownD9	,IK_UnknownDA	,IK_LeftBracket	,
	/*DC*/	IK_Backslash	,IK_RightBracket,IK_SingleQuote	,IK_UnknownDF	,
	/*E0*/  IK_JoyX			,IK_JoyY		,IK_JoyZ		,IK_JoyR		,
	/*E4*/	IK_MouseX		,IK_MouseY		,IK_MouseZ		,IK_MouseW		,
	/*E8*/	IK_JoyU			,IK_JoyV		,IK_UnknownEA	,IK_UnknownEB	,
	/*EC*/	IK_MouseWheelUp ,IK_MouseWheelDown,IK_Unknown10E,UK_Unknown10F  ,
	/*F0*/	IK_JoyPovUp     ,IK_JoyPovDown	,IK_JoyPovLeft	,IK_JoyPovRight	,
	/*F4*/	IK_UnknownF4	,IK_UnknownF5	,IK_Attn		,IK_CrSel		,
	/*F8*/	IK_ExSel		,IK_ErEof		,IK_Play		,IK_Zoom		,
	/*FC*/	IK_NoName		,IK_PA1			,IK_OEMClear
};

var(Display) class<RenderIterator> RenderIteratorClass;	// class to instantiate as the actor's RenderInterface
var transient RenderIterator RenderInterface;		// abstract iterator initialized in the Rendering engine

//-----------------------------------------------------------------------------
// natives.

// Execute a console command in the context of the current level and game engine.
native function string ConsoleCommand( string Command );


//-----------------------------------------------------------------------------
// Network replication.

replication
{
	// Relationships.
	unreliable if ( Role==ROLE_Authority )
		Owner, Role, RemoteRole;
	unreliable if ( Role==ROLE_Authority && bNetOwner )
		bNetOwner, Inventory;
	unreliable if ( bReplicateInstigator && (Role==ROLE_Authority) && (RemoteRole>=ROLE_SimulatedProxy) )
		Instigator;

	// Ambient sound.
	unreliable if ( Role==ROLE_Authority )
		AmbientSound;
	unreliable if ( Role==ROLE_Authority && AmbientSound!=None )
		SoundRadius, SoundVolume, SoundPitch;
	unreliable if ( bDemoRecording )
		DemoPlaySound;

	// Collision.
	unreliable if ( Role==ROLE_Authority )
		bCollideActors, bCollideWorld;
	unreliable if ( Role==ROLE_Authority && bCollideActors )
		bBlockActors, bBlockPlayers;
	unreliable if ( Role==ROLE_Authority && (bCollideActors || bCollideWorld) )
		CollisionRadius, CollisionHeight;

	// Location.
	unreliable if ( Role==ROLE_Authority && !bCarriedItem && (bNetInitial || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) )
		Location;
	unreliable if ( Role==ROLE_Authority && !bCarriedItem && (DrawType==DT_Mesh || DrawType==DT_Brush) && (bNetInitial || bSimulatedPawn || RemoteRole<ROLE_SimulatedProxy) )
		Rotation;
	unreliable if ( Role==ROLE_Authority && RemoteRole==ROLE_SimulatedProxy )
		Base;

	// Velocity.
	unreliable if ( (RemoteRole==ROLE_SimulatedProxy && (bNetInitial || bSimulatedPawn)) || bIsMover )
		Velocity;

	// Physics.
	unreliable if ( RemoteRole==ROLE_SimulatedProxy && bNetInitial && !bSimulatedPawn )
		Physics, Acceleration, bBounce;
	unreliable if ( RemoteRole==ROLE_SimulatedProxy && Physics==PHYS_Rotating && bNetInitial )
		bFixedRotationDir, bRotateToDesired, RotationRate, DesiredRotation;

	// Animation.
	unreliable if ( DrawType==DT_Mesh && (RemoteRole<=ROLE_SimulatedProxy) )
		AnimSequence;
	unreliable if ( DrawType==DT_Mesh && (RemoteRole==ROLE_SimulatedProxy) )
		bAnimNotify;
	unreliable if ( DrawType==DT_Mesh && (RemoteRole<ROLE_AutonomousProxy) )
		SimAnim, AnimMinRate;

	// Rendering.
	unreliable if ( Role==ROLE_Authority )
		bHidden, bOnlyOwnerSee;
	unreliable if ( Role==ROLE_Authority )
		Texture, DrawScale, PrePivot, DrawType, AmbientGlow, Fatness, ScaleGlow, bUnlit, bNoSmooth, bShadowCast, bActorShadows, Style;
	unreliable if ( Role==ROLE_Authority && DrawType==DT_Sprite && !bHidden && (!bOnlyOwnerSee || bNetOwner) )
		Sprite;
	unreliable if ( Role==ROLE_Authority && DrawType==DT_Mesh )
		Mesh, bMeshEnviroMap, bMeshCurvy, Skin, MultiSkins;
	unreliable if ( Role==ROLE_Authority && DrawType==DT_Brush )
		Brush;

	// Lighting.
	unreliable if ( Role==ROLE_Authority )
		LightType;
	unreliable if ( Role==ROLE_Authority && LightType!=LT_None )
		LightEffect, LightBrightness, LightHue, LightSaturation,
		LightRadius, LightPeriod, LightPhase, LightCone,
		VolumeBrightness, VolumeRadius,
		bSpecialLit;

	// Messages
	reliable if( false ) // if ( Role<ROLE_Authority ) <- Never replicate.
		BroadcastMessage;
}

//=============================================================================
// Actor error handling.

// Handle an error and kill this one actor.
native(233) final function Error( coerce string S );

//=============================================================================
// General functions.

// Latent functions.
native(256) final latent function Sleep( float Seconds );

// Collision.
native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers, optional bool bNewBlockRbPhys );
native(283) final function bool SetCollisionSize( float NewRadius, float NewHeight, optional bool bCheckEncroachment ); // CheckEncroachment also updates touch. Does return 0 if CheckEncroachment fails (and only then).

// Movement.
native(266) final function bool Move( vector Delta, optional rotator NewRotation, optional bool bTest ); // use optional bTest flag to test only without actually really moving it.
native(267) final function bool SetLocation( vector NewLocation, optional rotator NewRotation );
native(299) final function bool SetRotation( rotator NewRotation );
native(3969) final function bool MoveSmooth( vector Delta );
native(3971) final function AutonomousPhysics(float DeltaSeconds);

// Relations.
native(298) final function SetBase( actor NewBase );
native(272) final function SetOwner( actor NewOwner );

/* Perform a point check in level and returns first hit actor if any. */
native(730) final function Actor PointCheck
(
	vector				Point,
	optional out vector	HitNormal,
	optional bool		bBlockingActors, // default: bBlockActors (if true check all blocking actors, not just the level/movers
	optional vector		Extent, // default: Collision size
	optional int		TraceFlags // = (bBlockingActors & TRACE_AllColliding) | TRACE_Level | TRACE_Blocking
);

// Attempt to find and adjust spot at a location.
native(731) final function bool FindSpot
(
	out vector			Point,
	optional bool		bBlockingActors, // default: bBlockActors
	optional vector		Extent // default: Collision size
);

// CollisionGroup flags:
const COLLISIONFLAG_All				= 0x00000001;
const COLLISIONFLAG_Actor			= 0x00000002;
const COLLISIONFLAG_Pawn			= 0x00000004;
const COLLISIONFLAG_PlayerPawn		= 0x00000008;
const COLLISIONFLAG_ScriptedPawn	= 0x00000010;
const COLLISIONFLAG_Projectile		= 0x00000020;
const COLLISIONFLAG_Keypoints		= 0x00000040;
const COLLISIONFLAG_Decoration		= 0x00000080;
const COLLISIONFLAG_Bots			= 0x00000100;
const COLLISIONFLAG_Effects			= 0x00000200;
const COLLISIONFLAG_Movers			= 0x00000400;
const COLLISIONFLAG_Triggers		= 0x00001000;

const COLLISIONGROUP_Everything		= 0x7FFFFFFF; // By default all actors block everything.

native(732) final function bool IsBlockedBy( Actor Other ); // Check if an Actor should block movement by another.

//=============================================================================
// Animation.

// Animation functions.
native(259) final function PlayAnim( name Sequence, optional float Rate, optional float TweenTime );
// 227j: bTweenFrame = if true, will keep looping animation with the new sequence but simply tween from old animation to new one while playing.
native(260) final function LoopAnim( name Sequence, optional float Rate, optional float TweenTime, optional float MinRate, optional bool bTweenFrame );
native(294) final function TweenAnim( name Sequence, float Time );
native(282) final function bool IsAnimating();
native(293) final function name GetAnimGroup( name Sequence );
native(261) final latent function FinishAnim();
native(263) final function bool HasAnim( name Sequence );

// Animation notifications.
event AnimEnd();

//=============================================================================
// Skeletal animation.
native final function LinkSkelAnim( Animation Anim, optional bool bAppendSet ); // If bAppendSet is True, it will add to AnimSets array, otherwise clear it and link SkelAnim.

native(1726) final function int GetBoneIndex( string BoneName ); // Get bone index of a name (-1 if not found, "Weapon" for weapon bone socket).
native(1727) final function name GetBoneName( int Index ); // Get name of a bone index

// Use bone -1 for weapon bone position!
// @ bOriginal - Original unmodified bone coordinates before any modifiers from SetBoneXXX functions are applied.
native(1728) final function Coords GetBoneCoords( int Index, optional bool bOriginal ); // Get world coords of a bone.
native(1744) final function rotator GetBoneRotation( int Index, optional bool bOriginal ); // Get bone rotation
native(1745) final function vector GetBoneLocation( int Index, optional bool bOriginal, optional out rotator Dir ); // Get bone location (faster then getting coords and rotation)

const BONESPACE_Local = 0; // Space is relative to parent bone.
const BONESPACE_Actor = 1; // Space is relative to actor orientation.
const BONESPACE_World = 2; // Space is absolute to world coordinates.

// @ Alpha (0-1) which specify how much this value should effect the modification (0 = no effect).
// @ Space, which transformation space to use, see above.
native(1729) final function bool SetBoneRotation( int Index, rotator RotModifier, optional float Alpha, optional byte Space ); // Set bone rotation (-1 Index will change mesh local rotation).
native(1730) final function bool SetBoneScale( int Index, vector New3DScale, optional float Alpha ); // Set bone size 3D.
native(1731) final function bool SetBoneRoot( int Index, optional int RootIndex ); // Change bone's root bone (attach bone to bone, 0 root = orginal bone).
native(1732) final function bool SetBonePosition( int Index, vector Offset, optional float Alpha, optional byte Space ); // Change bone location offset (offset is in mesh coords, not world coords) NOTE: -1 Index will change mesh local offset.

// Play an animation with bone index as root.
// @ Index - The root bone index for the animation.
// @ Rate (1.0) - The animation rate.
// @ TweenTime (0.0) - The "blend-in" time for the animation.
// @ bLoop (false) - Animation will loop forever.
// @ TweenOut (0.0) - When not looping, the "blend-out" time for the animation (-1 and it will freeze frame once animation completed).
// @ bGlobalPose (false) - (TODO - not yet working) Play animation at original orientation, not influenced by parent bones animation.
native(1733) final function bool SkelPlayAnim( int Index, name AnimName, optional float Rate, optional float TweenTime, optional bool bLoop, optional float TweenOut, optional bool bGlobalPose );

// Stop an animation in this bone index.
// @ bCheckFromRoot (false) - If true, check if this bone is affected by any channel towards the root.
native(1734) final function bool StopSkelAnim( int Index, optional float TweenOut, optional bool bCheckFromRoot );

// Remove all active animation channels and reset back all bone sizes and rotations (this is automatically done when mesh is switched to another skeletal mesh).
native(1735) final function ResetSkeletalMesh();

// Attach an actor to this skeletal mesh to a specific bone index.
// Set bHardAttach=true to update actors position even when host mesh isnt being rendered (only way to force mesh to sync up serverside too).
native(1737) final function AttachActorToBone( Actor Other, int Index );
native(1738) final function DeatachFromBone( Actor Other );

// Used obtain current socket info, returns True if found.
native(1777) final function bool GetSocketInfo( name SocketName, optional out MeshSocketInfo Info );
// Modifies socket info (for current mesh), but only temporarly until mapchange!
native(1778) final function SetSocketInfo( MeshSocketInfo Info );

// Find an inverse kinematics controller.
native(1764) final function IK_SolverBase GetIKSolver( class<IK_SolverBase> Class, optional name Tag );

// Remove an IK solver.
// Warning: This will also delete the object, so accessing or even leaving a memory reference to this object will crash the game.
native(1765) final function RemoveIKSolver( IK_SolverBase Solver );

// Add an IK solver.
native(1772) final function IK_SolverBase AddIKSolver( class<IK_SolverBase> Class, optional name Tag, optional IK_SolverBase Template );

// Returns true if this actor has skeletal mesh collision with hitboxes.
native final function bool HasMeshHitBoxes();

// Called when 'SkelPlayAnim' has completed.
event AnimEndOnBone( int BoneIndex );

// Notify when a new IK solver has been added or removed, great time to add or remove any references here.
// NOTE: Never keep any references after remove event has been called or game could crash.
event NotifyIKSolver( IK_SolverBase Solver, bool bDelete );

//=========================================================================
// Editor.

// Executed on editor when actor is selected and has bEditorSelectRender set on True.
event DrawEditorSelection( Canvas C );

// Called twice by editor path builder before path build.
event NotifyPathDefine( bool bPreNotify );

// Called in editor when this actor has been added to level with current mouse pointer hit information
event EdNoteAddedActor( vector HitLocation, vector HitNormal );

// Called in editor when this actor was deployed as a brush actor.
// Called on Movers and bSpecialBrushActor actors.
event EdBrushDeployed();

//=========================================================================
// Rendering.

// Debug functions, not very fast but useful for debugging stuff.
// Renders a single line on next frame.
static native(1740) final function DrawDebugLine( vector Start, vector End, vector Color, optional bool bShouldStay );

// Render a box.
static native(1741) final function DrawDebugBox( vector Start, vector End, vector Color, optional bool bShouldStay );

// Render a sphere (segments recommended: 4-16).
static native(1742) final function DrawDebugSphere( vector Point, float Radius, byte Segments, vector Color, optional bool bShouldStay );

// Remove any staying debug lines.
static native(1773) final function ClearDebugLines();

// In most cases returns Actor.Location/Rotation, but may return network interpolate position if it's in use.
native final function GetRenderPosition( optional out vector Pos, optional out rotator Dir );

//=========================================================================
// Physics.

// Physics control.
native(301) final latent function FinishInterpolation();
native(3970) final function SetPhysics( EPhysics newPhysics );

//=============================================================================
// Engine notification functions.

//
// Major notifications.
//
event Spawned();
event Destroyed();
event Expired();
event GainedChild( Actor Other );
event LostChild( Actor Other );
event Tick( float DeltaTime );
event OwnerChanged(); // 227j: Server/Client - Notify when Owner was changed (through SetOwner or owner was Destroyed).

//
// Triggers.
//
event Trigger( Actor Other, Pawn EventInstigator );
event UnTrigger( Actor Other, Pawn EventInstigator );
event BeginEvent();
event EndEvent();

//
// Physics & world interaction.
//
event Timer();
event HitWall( vector HitNormal, actor HitWall );
event Falling();
event Landed( vector HitNormal );
event ZoneChange( ZoneInfo NewZone );
event Touch( Actor Other );
event PostTouch( Actor Other ); // called for PendingTouch actor after physics completes
event UnTouch( Actor Other );
event Bump( Actor Other );
event BaseChange();
event Attach( Actor Other );
event Detach( Actor Other );
event KillCredit( Actor Other );
event Actor SpecialHandling(Pawn Other);
event bool EncroachingOn( actor Other );
event EncroachedBy( actor Other );
event bool RanInto( Actor Other ); // Return True to pass through without interacting.
event InterpolateEnd( actor Other );
event EndedRotation();
event PhysicsImpact( float Threshold, vector HitLocation, vector HitNormal, Actor Other ); // Rigidbody impact.
event PhysicsJointBreak( PXJ_BaseJoint Joint ); // Notify when a joint exceeded its withstanding force and disabled itself.

function InterpolationEnded(); // Reached end-of-path for interpolation.

simulated event FellOutOfWorld()
{
	Destroy();
}

//
// Damage and kills.
//
event KilledBy( pawn EventInstigator );
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType);

//
// Trace a line and see what it collides with first.
// Takes this actor's collision properties into account.
// Returns first hit actor, Level if hit level, or None if hit nothing.
// @ BSPTraceFlags - Ignore specific BSP surf flags:
const noexport NF_NotCsg			= 1; // Node is not a Csg splitter, i.e. is a transparent poly.
const noexport NF_ShootThrough		= 2; // Can shoot through (for projectile solid ops).
const noexport NF_NotVisBlocking	= 4; // Node does not block visibility, i.e. is an invisible collision hull.

const noexport TRACE_Pawns			= 0x01; // Check collision with pawns.
const noexport TRACE_Movers			= 0x02; // Check collision with movers.
const noexport TRACE_Level			= 0x04; // Check collision with level geometry.
const noexport TRACE_Others			= 0x10; // Check collision with all other kinds of actors.
const noexport TRACE_OnlyProjActor	= 0x20; // Check collision with other actors only if they are projectile targets
const noexport TRACE_Blocking		= 0x40; // Check collision with blocking actors only
const noexport TRACE_SingleResult	= 0x80; // Return checking after first hit with anything (may not be closest hit).
const noexport TRACE_IgnoreHidden	= 0x100; // Ignores bHidden actors.
const noexport TRACE_LightBlocking	= 0x800; // Only trace with bShadowCast actors!
const noexport TRACE_AISightBlock	= 0x1000; // Hit bBlockAISight actors.
const noexport TRACE_Volumes		= 0x2000; // Should hit volume actors.
const noexport TRACE_WalkTextures	= 0x4000; // Tracing for walk texture (collide with bBlockTextureTrace actors).

// Combinations.
const noexport TRACE_VisBlocking	= {TRACE_Level | TRACE_Movers | TRACE_Volumes};
const noexport TRACE_AllColliding	= {TRACE_VisBlocking | TRACE_Pawns | TRACE_Others};
const noexport TRACE_ProjTargets	= {TRACE_AllColliding | TRACE_OnlyProjActor};
const noexport TRACE_AIVisibility	= {TRACE_VisBlocking | TRACE_AISightBlock};
const noexport TRACE_Footsteps		= {(TRACE_AllColliding | TRACE_Blocking | TRACE_WalkTextures) & ~TRACE_Volumes};

native(277) final function Actor Trace
(
	out vector		HitLocation,
	out vector		HitNormal,
	vector			TraceEnd,
	optional vector	TraceStart, // = Location
	optional bool	bTraceActors, // = bCollideActors
	optional vector	Extent, // = vect(0,0,0)
	optional bool	bTraceBSP, // = True
	optional byte	BSPTraceFlags, // = 0
	optional int	TraceFlags // = (!bTraceActors & TRACE_OnlyProjActor) | (bTraceBSP & TRACE_VisBlocking) | TRACE_Pawns | TRACE_Others
);

// returns true if did not hit world geometry
native(548) final function bool FastTrace
(
	vector			TraceEnd,
	optional vector	TraceStart,
	optional int	TraceFlags // = TRACE_VisBlocking
);

//
// Trace against BSP world, if did hit return true and give hit information.
// Hit flags are (full 'EPolyFlags' list in UnObj.h):
const noexport PF_Invisible			= 0x00000001;	// Poly is invisible.
const noexport PF_Masked			= 0x00000002;	// Poly should be drawn masked.
const noexport PF_Translucent		= 0x00000004;	// Poly is transparent.
const noexport PF_Environment		= 0x00000010;	// Poly should be drawn environment mapped.
const noexport PF_Semisolid	  		= 0x00000020;	// Poly is semi-solid = collision solid, Csg nonsolid.
const noexport PF_Modulated			= 0x00000040;	// Modulation transparency.
const noexport PF_FakeBackdrop		= 0x00000080;	// Poly looks exactly like backdrop.
const noexport PF_AutoUPan			= 0x00000200;	// Automatically pans in U direction.
const noexport PF_AutoVPan			= 0x00000400;	// Automatically pans in V direction.
const noexport PF_NoSmooth			= 0x00000800;	// Don't smooth textures.
const noexport PF_BigWavy			= 0x00001000;	// Poly has a big wavy pattern in it.
const noexport PF_SmallWavy			= 0x00002000;	// Small wavy pattern (for water/enviro reflection).
const noexport PF_AlphaBlend 		= 0x00020000;	// This poly should be alpha blended
const noexport PF_SpecialLit		= 0x00100000;	// Only speciallit lights apply to this poly.
const noexport PF_Unlit				= 0x00400000;	// Unlit.
const noexport PF_Mirrored			= 0x08000000;	// Reflective surface.
// Useage: if( (ResultFlags & PF_Unlit)!=0 ) -> Surface is unlit

// Grab surface information and returns true if did hit geometry.
native(1736) final function bool TraceSurfHitInfo
(
	vector					Start,
	vector					End,
	optional out vector		HitLocation,
	optional out vector		HitNormal,
	optional out Texture	HitTex,
	optional out int		HitFlags,
	optional vector			Extent, // default: Collision extent
	optional out Actor		HitActor,
	optional int			TraceFlags // = TRACE_Footsteps
);

//
// Perform a single line check with this actor.
// Returns true if did hit!
//
native(1739) final function bool TraceThisActor
(
	vector				TraceEnd,
	vector				TraceStart,
	optional out vector	HitLocation,
	optional out vector	HitNormal,
	optional vector		Extent,
	optional bool		bHitBoxes // Should trace skeletal mesh hitboxes
);

//
// TraceSurfHitInfo but as an iterator to grab multiple hits.
//
native(1760) final iterator function TraceTextures
(
	Class<Actor>			BaseClass,
	out Actor				HitActor,
	Vector					TraceEnd,
	optional Vector			TraceStart, // = Location
	optional out Vector		HitLocation,
	optional out Vector		HitNormal,
	optional out Texture	HitTex,
	optional out int		HitFlags,
	optional Vector			Extent, // = vect(0,0,0)
	optional int			TraceFlags // = TRACE_AllColliding
);

//
// Obtain bounding box of this actor (if bRenderBounds get render bounding box, otherwise collision bounds).
//
native(1761) final function BoundingBox GetBoundingBox( optional bool bRenderBounds );

//
// Spawn an actor. Returns an actor of the specified class, not
// of class Actor (this is hardcoded in the compiler). Returns None
// if the actor could not be spawned (either the actor wouldn't fit in
// the specified location, or the actor list is full).
// Defaults to spawning at the spawner's location.
// @Template - Can be class, in which case it will use the default object as template, or an actor to use as template.
//
native(278) final function actor Spawn
(
	class<actor>      SpawnClass,
	optional actor	  SpawnOwner,
	optional name     SpawnTag,
	optional vector   SpawnLocation,
	optional rotator  SpawnRotation,
	optional Pawn     SpawnInstigator,
	optional Object   Template,
	optional bool     bNoCollisionFail
);

//
// Destroy this actor. Returns true if destroyed, false if indestructable.
// Destruction is latent. It occurs at the end of the tick.
//
native(279) final function bool Destroy();

//=============================================================================
// Timing.

// Causes Timer() events every NewTimerRate seconds.
// @ InFunc, new in 227i: Causes an additional timer call with specified function name.
// @ CallbackObject, new in 227j: Call the InFunc function in another object.
// @ Data: When using custom timer function, it will pass this as a parameter.
// Use 'All' to effect all timers.
native(280) final function SetTimer( float NewTimerRate, bool bLoop, optional name InFunc, optional Object CallbackObject, optional out any Data );

//=============================================================================
// Sound functions.

// Play a sound effect. 227j: Changed to return the channel ID of the sound so you can call StopSound later
native(264) final function int PlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch
);
// Stop a sound given the sound's ID
native(265) final function StopSound(int Id);

// Set the sound system volumes without waiting for a tick event
native(268) final function SetInstantSoundVolume(byte newSoundVolume);
native(269) final function SetInstantSpeechVolume(byte newSpeechVolume);
native(270) final function SetInstantMusicVolume(byte newMusicVolume);

// Stops the specified or all sound slots for an Actor. These functions are network transparent,
// but unlike PlaySound() use a reliable network replication pattern and do no distance checks.
// They share the same behaviour regarding simulated functions and invokation on network clients
// as PlaySound() does. This includes that you need to run those inside a simulated function when
// PlaySound() for that slot was called inside a simulated function (note that the server can invoke
// playback of a sound in the same channel as the client for an given actor and they will both be
// played at the same time, so sound slots are not mutually exclusive in this situation!).
// To avoid problems in netplay you should ensure that there is a slight amount of time
// between PlaySound() and StopSoundSlot()/StopAllSoundSlots() call, so both will likely be
// execute in order on the network client (note that the same argument applies to multiple
// PlaySound() calls for the same channel, so this is no new issue introduce by these functions).
// native(273) final function StopSoundSlot( ESoundSlot Slot );
// native(274) final function StopAllSoundSlots();
// native simulated event DemoStopSoundSlot( ESoundSlot Slot );
// native simulated event DemoStopAllSoundSlots();

// play a sound effect, but don't propagate to a remote owner
// (he is playing the sound clientside
native simulated final function PlayOwnedSound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch
);

native simulated event DemoPlaySound
(
	sound				Sound,
	optional ESoundSlot Slot,
	optional float		Volume,
	optional bool		bNoOverride,
	optional float		Radius,
	optional float		Pitch
);

// Get a sound duration.
native final function float GetSoundDuration( sound Sound );

//=============================================================================
// AI functions.

//
// Inform other creatures that you've made a noise
// they might hear (they are sent a HearNoise message)
// Senders of MakeNoise should have an instigator if they are not pawns.
//
native(512) final function MakeNoise( float Loudness );

//
// PlayerCanSeeMe returns true if some player has a line of sight to
// actor's location.
//
native(532) final function bool PlayerCanSeeMe();

//=============================================================================
// Regular engine functions.

// Teleportation.
event bool PreTeleport( Teleporter InTeleporter );
event PostTeleport( Teleporter OutTeleporter );

// Level state.
event NotifyLevelChange(); // Called just before map changes.
event BeginPlay();

//========================================================================
// Disk access.

// Find files.
native(539) final function string GetMapName( string NameEnding, string MapName, int Dir );
native(545) final function GetNextSkin( string Prefix, string CurrentSkin, int Dir, out string SkinName, out string SkinDesc );
native(547) final function string GetURLMap();
native final function string GetNextInt( string ClassName, int Num );
native final function GetNextIntDesc( string ClassName, int Num, out string Entry, out string Description );
// 227: Same as GetNextIntDesc, but a lot faster and has some extra features.
// @ bSingleNames - Same name entries may only outcome once.
native(313) final iterator function IntDescIterator( string ClassName, optional out string EntryName, optional out string Desc, optional bool bSingleNames );

// Iterate a list of Dynamic Link Libaries.
// @ Flags:
const LIBFLAG_AllLibs = 0;		// All libaries in System folder.
const LIBFLAG_UsedLibs = 1;		// All used libaries.
const LIBFLAG_ServerLibs = 2;	// All server required libaries (ones which client may need to connect to server).

native(400) final iterator function AllLibaries( out string LibName, byte Flags );

//=============================================================================
// Iterator functions.

// Iterator functions for dealing with sets of actors.

// AllActors() - avoid using AllActors() too often as it iterates through the whole actor list and is therefore slow.
// 227j: Pawn based classes use PawnList so its super fast, also when using 'Pawn' BaseClass and MatchTag 'Player' it will only return bIsPlayer pawns from PawnList.
// @bAllLevels: Should iterate on all sublevels too? (NOTE: defaults to BaseClass.Default.bCrossLevelNetwork or true for Pawn based classes)
native(304) final iterator function AllActors     ( class<actor> BaseClass, out actor Actor, optional name MatchTag, optional name MatchEvent, optional bool bAllLevels );
// ChildActors() returns all actors owned by this actor (really fast)
native(305) final iterator function ChildActors   ( class<actor> BaseClass, out actor Actor );
// BasedActors() returns all actors based on the current actor (really fast)
native(306) final iterator function BasedActors   ( class<actor> BaseClass, out actor Actor );
// TouchingActors() returns all actors touching the current actor (really fast)
native(307) final iterator function TouchingActors( class<actor> BaseClass, out actor Actor );
// TraceActors() return all actors along a traced line.  Reasonably fast (like any trace)
native(309) final iterator function TraceActors   ( class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent, optional int TraceFlags /* = AllColliding */ );
/*
RadiusActors() returns all actors within a give radius.  Slow like AllActors().
@ bColliding: new in 227j, use collision hash instead to grab only bCollideActors actors for extra performance gain.
*/
native(310) final iterator function RadiusActors  ( class<actor> BaseClass, out actor Actor, float Radius, optional vector Loc, optional bool bColliding );
/*
VisibleActors() returns all visible (not bHidden) actors within a radius
for which a trace from Loc (which defaults to caller's Location) to that actor's Location does not hit the world.
Slow like AllActors(). Use VisibleCollidingActors() instead if desired actor types are in the collision hash (bCollideActors is true)
*/
native(311) final iterator function VisibleActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc );
/*
VisibleCollidingActors() returns all colliding (bCollideActors==true) actors within a certain radius
for which a trace from Loc (which defaults to caller's Location) to that actor's Location does not hit the world.
Much faster than AllActors() since it uses the collision hash
*/
native(312) final iterator function VisibleCollidingActors ( class<actor> BaseClass, out actor Actor, optional float Radius, optional vector Loc, optional bool bIgnoreHidden );

//=============================================================================
// Misc 227 functions.

// An advanced 'PointReachable' which takes specific jumpZ, groundspeed and swimming ability into account and can check reachability.
native(1716) final function bool CanReachPoint( vector Start, vector End, float ColRadius, float ColHeight, float JumpZ, float XYSpeed );

// Add to package map.
// Returns False if:
// - Level gameplay has started (after first tick).
// - Package linker wasnt found (package isnt loaded).
native(1718) final function bool AddToPackagesMap( optional string PackageName );

// Check if some package is in package map.
// Returns True if file is required to enter the server.
native(1719) final function bool IsInPackageMap( optional string PackageName );

// Query actor for PendingTouch or call it instantly if possible. (Call it on the actor you want to receive PostTouch event with Other being target actor)
native final function SetPendingTouch( Actor Other );

// Send this actor to a sub-level.
native final function bool SendToLevel( LevelInfo LevelInfo, vector P, optional rotator R );

// Called by PlayerPawn when they try to 'grab' this actor.
function GrabbedBy( Pawn Other );

//
// Frob() - called to frob an object
// the subclass is responsible for implementing this
//
function Frob(Actor Frobber, Inventory frobWith)
{
}

//=============================================================================
// Mesh functions:

// Get the vertex world position from some mesh actor.
// @ iVert - the vertex number of the mesh.
native(1720) final function vector GetVertexPos( int iVert, optional bool bAnim );// bAnim is not in use and not needed anymore in 227j. Kept for compatibility to 227i mods only.

// Get number of vertexes in a mesh actor.
native(1721) final function int GetVertexCount();

// Get all the vertexes from current frame of some mesh actor (starting from iVert 0).
// @ Verts - Array of all vertices
// Very fast and efficient, it does resize array size to fit the needed size.
native(1722) final function AllFrameVerts( out array<vector> Verts );

// Get the closest vertex to a point.
// @ CheckPos - the world position of the point to check with.
// @ ResultVert - the vertex that was the closest one.
native(1723) final function int GetClosestVertex( vector CheckPos, out vector ResultVert );

// Get the closest trace line vertex.
// @ MinDot - min dot product with the line difference (0 = 90 degrees, 1 = 0 degrees)
// @ CheckPos - the world position of the point to check with.
// @ CheckDir - the trace direction of the line.
// @ ResultVert - the vertex that was the closest one.
native(1724) final function int GetBestTraceLineVertex( float MinDot, vector CheckPos, vector CheckDir, optional out vector ResultVert );

// Perform a 3D collision trace with a mesh actor, returns True if it DID hit.
native(1725) final function bool MeshTrace( vector Start, vector End, optional out vector HitNormal, optional out vector HitLocation );

//=============================================================================
// Color operators
// these operators use RGBA unlike the UT version which use RGB

native(550) static invariant final operator(20) color -     ( color A, color B );
native(551) static invariant final operator(16) color *     ( float A, color B );
native(552) static invariant final operator(20) color +     ( color A, color B );
native(553) static invariant final operator(16) color *     ( color A, float B );

//=============================================================================
// Scripted Actor functions.

// draw on canvas before flash and fog are applied (used for drawing weapons)
event RenderOverlays( canvas Canvas );

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	// Handle autodestruction if desired.
	if ( !bGameRelevant && (Level.NetMode != NM_Client) && !Level.Game.IsRelevant(Self) )
		Destroy();
}

//
// Broadcast a message to all players.
//
event BroadcastMessage( coerce string Msg, optional bool bBeep, optional name Type )
{
	local GameRules GR;
	local Pawn P;

	if (Type == '')
		Type = 'Event';

	if( Level.NetMode==NM_Client )
	{
		GetLocalPlayerPawn().ClientMessage( Msg, Type, bBeep );
		return;
	}

	if ( Level.Game.GameRules )
		for ( GR=Level.Game.GameRules; GR; GR=GR.NextRules )
			if ( GR.bNotifyMessages && !GR.AllowBroadcast(Self,Msg) )
				return;
	if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
		foreach AllActors(Class'Pawn',P,'Player')
			P.ClientMessage( Msg, Type, bBeep );
}

//
// Called immediately after gameplay begins.
//
event PostBeginPlay();

//
// Called on network clients when intial properties has been replicated.
//
event PostNetBeginPlay();

//
// Called on network clients when actor channel was closed but actor was not deleted (bNoDelete actors).
//
event ReplicationEnded();

//
// Called on network clients when a variable has been replicated (only called while bNetNotify is True).
//
event PostNetReceive();

//
// A variable with 'repnotify' keyword was replicated.
//
event OnRepNotify( name Property );

//
// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	if ( InitialState!='' )
		GotoState( InitialState );
	else
		GotoState( 'Auto' );
}

//
// Called right after load game in single player.
//
event PostLoadGame();

//
// Hurt actors within the radius.
//
native final function HurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation );

//
// Called when carried onto a new level, before AcceptInventory.
//
event TravelPreAccept();

//
// Called when carried into a new level, after AcceptInventory.
//
event TravelPostAccept();

//
// Called when a scripted texture needs rendering
//
event RenderTexture(ScriptedTexture Tex);

//
// Called by PlayerPawn when this actor becomes its ViewTarget.
//
event BecomeViewTarget();

//
// Returns the string representation of the name of an object without the package
// prefixes.
//
function String GetItemName( string FullName )
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

//
// Returns the human readable string representation of an object.
//

simulated function String GetHumanName()
{
	return string(Class.Name);
}

//
// Returns the deathmessage displayed by this class (implemented by GameInfo and Weapons)
//
static function String WriteDeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Other, optional name damagetype)
{
	if ( Killer == None )
		return Other.PlayerName$" died";
	return Killer.PlayerName$" killed "$Other.PlayerName;
}

// Set the display properties of an actor.  By setting them through this function, it allows
// the actor to modify other components (such as a Pawn's weapon) or to adjust the result
// based on other factors (such as a Pawn's other inventory wanting to affect the result)
function SetDisplayProperties(ERenderStyle NewStyle, texture NewTexture, bool bLighting, bool bEnviroMap )
{
	Style = NewStyle;
	texture = NewTexture;
	bUnlit = bLighting;
	bMeshEnviromap = bEnviromap;
}

function SetDefaultDisplayProperties()
{
	Style = Default.Style;
	texture = Default.Texture;
	bUnlit = Default.bUnlit;
	bMeshEnviromap = Default.bMeshEnviromap;
}

// Reset the Actor to inital map state.
function Reset();

// Get the Actor Triggerer
function Actor GetTriggerActor()
{
	Return Self;
}

// Trigger helper functions.
// @LevelID: Send event to specific sub-level (or 'All' for all sub-levels).
native final function TriggerEvent( name Action, optional Actor Other, optional Pawn EventInstigator, optional name LevelID );
native final function UnTriggerEvent( name Action, optional Actor Other, optional Pawn EventInstigator, optional name LevelID );

// Get the collision extent of this actor.
simulated final function vector GetExtent()
{
	return Construct<Vector>(CollisionRadius, CollisionRadius, CollisionHeight);
}

final simulated function float ScaledDefaultCollisionRadius()
{
	return default.CollisionRadius * (DrawScale / default.DrawScale);
}

final simulated function float ScaledDefaultCollisionHeight()
{
	return default.CollisionHeight * (DrawScale / default.DrawScale);
}

final simulated function vector ScaledDefaultPrePivot()
{
	return default.PrePivot * (DrawScale / default.DrawScale);
}

final static function bool IsLiveActor(Actor A)
{
	return bool(A) && !A.bDeleteMe;
}

final static function bool IsAlivePawn(Pawn Pawn)
{
	return bool(Pawn) && !Pawn.bDeleteMe && Pawn.Health > 0;
}

// Get time in seconds how long it is going to take to finish current animation.
// Returns always >0 so that SetTimer always works with it.
simulated final function float GetAnimRemainTime()
{
	return IsAnimating() ? FMax((1.f-AnimFrame)*AnimRate,0.001f) : 0.001f;
}

// Called when about to draw this actor and bCustomDrawActor is true (does not run in editor)
simulated event OnDrawActor( Canvas Canvas )
{
	Canvas.DrawActor(self);
}

// Called when this actor was sent to a new sub-level.
event OnSubLevelChange( LevelInfo PrevLevel );

// User changed shadow detail settings.
event ShadowModeChange();

defaultproperties
{
	bDifficulty0=True
	bDifficulty1=True
	bDifficulty2=True
	bDifficulty3=True
	bSinglePlayer=True
	bNet=True
	bNetSpecial=True
	OddsOfAppearing=+00001.000000
	DrawType=DT_Sprite
	Texture=S_Actor
	DrawScale=+00001.000000
	bMeshCurvy=false
	SoundRadius=32
	SoundVolume=128
	SoundPitch=64
	TransientSoundVolume=+00001.000000
	CollisionRadius=+00022.000000
	CollisionHeight=+00022.000000
	bJustTeleported=True
	Mass=+00100.000000
	Role=ROLE_Authority
	RemoteRole=ROLE_DumbProxy
	NetPriority=+00001.000000
	ScaleGlow=1.0
	Fatness=128
	Style=STY_Normal
	bMovable=True
	bHighDetail=False
	VolumeFog=0
	InitialState=None
	NetUpdateFrequency=100
	LODBias=1.0
	SpriteProjForward=32.0
	DrawScale3D=(X=1,Y=1,Z=1)
	bRepAnimations=true
	bRepAmbientSound=true
	bRepMesh=true
	RandomDelayTime=0.5
	NormalLightRadius=0.0
	bZoneNormalLight=true
	AmbientGlowPulseSpeed=0.0
	CollisionGroups=COLLISIONGROUP_Everything
	CollisionFlag=COLLISIONFLAG_Actor
	bBlockZeroExtentTraces=true
	bBlockNonZeroExtentTraces=true
}