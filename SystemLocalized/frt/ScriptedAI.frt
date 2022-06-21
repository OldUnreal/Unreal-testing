[SVariableBase]
MenuName=Variables

[VAR_OBJECT_BASE]
MenuName=Object ref

[VAR_OBJECTARRAY_BASE]
MenuName=Object array

[VAR_Vector]
MenuName="Vector"
Description="Vector variable"

[VAR_STRUCT_BASE]
MenuName=Struct members

[LOGICBASE]
MenuName=Logic

[ACTIONSBASE]
MenuName=Actions

[ACTORBASE]
MenuName=Actor

[ACTOR_Overlay]
MenuName="Mesh Overlay"
Description="Add a temporary mesh overlay to an actor"

[HUD_DrawIcon]
MenuName="Draw Icon"
Description="Draw an icon on HUD."

[HUDElementBase]
MenuName=HUD

[HUD_DrawText]
MenuName="Draw Text"
Description="Draw a message on HUD."

[TEXT_ShowMessage]
MenuName="Show Message"
Description="Show a client message on screen.|If no receiver is specified, everyone will receive the message."

[TEXTBASE]
MenuName=Text Op

[VAR_ActorList]
MenuName="Actor List"
Description="Dynamic actorlist reference variable"

[VARIABLEBASE]
MenuName=Variables

[VAR_ObjectList]
MenuName="Object List"
Description="Object list reference variable|WARNING: Don't use this to reference dynamic destroyable actors or game could crash!"

[LEVELSBASE]
MenuName=Level

[VAR_Actor]
MenuName="Actor"
Description="Dynamic actor reference variable"

[VAR_Float]
MenuName="Float"
Description="Floating point variable"

[VAR_Int]
MenuName="Int"
Description="32-bit integer variable"

[LEVEL_Network]
MenuName="Network to Client"
Description="Transmit data from server to client.|All inputs you set will also output on client side and fire output event client side everytime you fire input serverside.|If no receiver is specified, the networked event will be broadcasted to all clients."

[LEVEL_RadialActors]
MenuName="Radius Actors"
Description="Grab all actors within a point in level.|Position input can be an actor or a vector."

[MATH_Int]
MenuName="Int op"
Description="Do a math operation with integers"

[MATHBASE]
MenuName=Math

[EVENTBASE]
MenuName=Events

[VAR_String]
MenuName="String"
Description="Text line variable"

[MOVER_MoveToKey]
MenuName="Move to key"
Description="Move a mover to a keyframe (output waits til the mover is finished)."

[MOVERBASE]
MenuName=Mover

[PAWN_SetHealth]
MenuName="Give Health"
Description="Give or remove health from pawn."

[PAWNBASE]
MenuName=Pawn

[EVENT_Triggered]
MenuName="Triggered"
Description="Triggered by a regular in level event.|Tag can be changed by firing Set Tag event and binding NewTag value."

[ACTOR_ChangeScale]
MenuName="Change scale"
Description="Resize an actor with optional blend time."

[VAR_Name]
MenuName="Name"
Description="Name variable"

[ACTOR_Destroy]
MenuName="Destroy Actor"
Description="Instantly destroy an actor"

[MATH_Float]
MenuName="Float op"
Description="Do a math operation with floating point"

[VAR_Bool]
MenuName="Boolean"
Description="Boolean variable"

[LATENT_MoveToActor]
MenuName="AI Move to actor"
Description="Make a ScriptedPawn/PlayerPawn move to a goal actor.|Output is fired when a pawn has reached or not the goal actor, with Reached output set to just finished pawn."

[LATENTBASE]
MenuName=Latent

[ACTOR_PlaySound]
MenuName="Play Sound"
Description="Play sound effect.|Sound source can be an actor or a vector. If actor array, it will play the sound on all actors in that array."

[VAR_Rotator]
MenuName="Rotator"
Description="Rotator variable"

[LEVEL_SpawnActor]
MenuName="Spawn Actor"
Description="Spawn a new actor.|If you input Position as actor variable, it will use that actor rotation. Otherwise you can input vector and rotation."

[LEVEL_AllPawns]
MenuName="All Pawns"
Description="Grab all pawns from level"

[PAWN_GiveItem]
MenuName="Give Item"
Description="Give an inventory item to a player"

[LOGIC_ArrayAdd]
MenuName="Array Add"
Description="Add an unique item to array.|Fires event Found or Not Found depending on the result."

[VAR_RandInt]
MenuName="Random Int"
Description="Random integer variable"

[TEXT_AddText]
MenuName="Append Text"
Description="Add text to the end of current textline"

[VAR_Object]
MenuName="Object"
Description="Object reference variable|WARNING: Don't use this to reference dynamic destroyable actors or game could crash!"

[LEVEL_PlayMusic]
MenuName="Play Music"
Description="Change currently played music.|If no player specified, everyone will change music."

[VAR_RandFloat]
MenuName="Random Float"
Description="Random float variable"

[LATENT_Timer]
MenuName="Timer"
Description="Wait for specific time"

[ACTOR_SetHidden]
MenuName="Set Hidden"
Description="Toggle actor hidden"

[VAR_LocalPlayer]
MenuName="Local Player"
Description="Local player variable function"

[EVENT_PawnDied]
MenuName="Pawn Died"
Description="Triggered when a pawn dies."

[EVENT_PawnHurt]
MenuName="Pawn Hurt"
Description="Triggered when a pawn takes damage."

[EVENT_PawnPrevDeath]
MenuName="Prevent Death"
Description="Prevent a pawn from dying.|NOTE: Output link is fired, AFTER that it checks Input flag if true, then prevents pawn from dying."

[OBJECTBASE]
MenuName=Object

[EVENT_PlayerSpawn]
MenuName="Player spawned"
Description="Triggered when a player spawns."

[PAWN_Kill]
MenuName="Kill Pawn"
Description="Instantly kill a pawn"

[LOGIC_ListIterator]
MenuName="ObjList Iterator"
Description="Iterate through object list"

[LEVEL_SendEvent]
MenuName="Trigger Event"
Description="Send a regular event to all actors in level"

[LOGIC_ArrayRemove]
MenuName="Array Remove"
Description="Remove a single item from array and return size.|Empty event is fired once final array entry has been removed."

[TEXT_Replace]
MenuName="Replace Text"
Description="Replace a part of text with text"

[LOGIC_Dispatch]
MenuName="Dispatcher"
Description="Split a call into multiple branches"

[ACTOR_TakeDamage]
MenuName="Take Damage"
Description="Make an actor take damage"

[ACTOR_SetPhysics]
MenuName="Set Physics"
Description="Change actor movement physics"

[ACTOR_SetCollision]
MenuName="Set Collision"
Description="Change actor collision state"

[ACTOR_PlayAnim]
MenuName="Play Anim"
Description="Play an animation on actors.|Note: Pawn code may override the animation!"

[LOGIC_CompareFloat]
MenuName="Compare Float"
Description="Compare 2 floating points"

[PAWN_DeleteItem]
MenuName="Delete Item"
Description="Find and delete an inventory item from a player"

[LOGIC_CompareInt]
MenuName="Compare Int"
Description="Compare 2 integers"

[VARIABLE_ToVector]
MenuName="To Vector"
Description="Construct a vector from individual components"

[VARIABLE_ToRotator]
MenuName="To Rotator"
Description="Construct a rotator from individual components"

[LOGIC_Gate]
MenuName="Logic Gate"
Description="A logic gate"

[VARIABLE_FromVector]
MenuName="From Vector"
Description="Grab each vector component"

[PAWN_FindItem]
MenuName="Find Item"
Description="Find an inventory item from a player"

[VARIABLE_FromRotator]
MenuName="From Rotator"
Description="Grab each rotator component"

[LOGIC_CompareObject]
MenuName="Compare Object"
Description="Compare 2 objects"

[LOGIC_CompareText]
MenuName="Compare Text"
Description="Compare 2 string text lines"

[ACTOR_GetName]
MenuName="Get Name"
Description="Grab the actor name"

[LOGIC_GetArraySize]
MenuName="Get Array Size"
Description="Check the size of an object array"

[OBJECT_SetProperty]
MenuName="Set Property"
Description="Change Object property value"

[OBJECT_ChangeState]
MenuName="Change State"
Description="Change actor script state"

[LEVEL_AllActors]
MenuName="All Actors"
Description="Grab all actors from level"

[OBJECT_GetProperty]
MenuName="Get Property"
Description="Grab Object property value"

[VARIABLE_SetBool]
MenuName="Set Bool"
Description="Set boolean value"

[LEVEL_ResetLevel]
MenuName="Reset level"
Description="Soft reset the level."

[VARIABLE_SetFloat]
MenuName="Set Float"
Description="Set float value"

[LOGIC_ArrayEmpty]
MenuName="Array Empty"
Description="Simply blank out an array."

[VARIABLE_SetInt]
MenuName="Set Int"
Description="Set integer value"

[VARIABLE_SetString]
MenuName="Set Text"
Description="Set string value"

[EVENT_BeginPlay]
MenuName="Begin Play"
Description="Fires an event on start of map.|Reset event is fired instead when level was soft resetted."

[LOGIC_CompareBool]
MenuName="Compare Bool"
Description="Compare a boolean"

[LOGIC_ServerType]
MenuName="Server Type"
Description="Check in which enviroment this action is executed on"

[ACTOR_SetPosition]
MenuName="Set Location"
Description="Change Actor location and/or rotation"

[ACTOR_GetPosition]
MenuName="Get Location"
Description="Grab Actor location and rotation"

[LEVEL_NetworkToServer]
MenuName="Network to Server"
Description="Transmit data from client to server.|All inputs you set will also output on server side and fire output event server side everytime you fire input serverside.|Sender will be the local player who sent this message."

[LATENT_AIAnimation]
MenuName="AI Play Animation"
Description="Make a ScriptedPawn play an animation and wait for the animation to finish, with Animator set to the pawn that finished the animation."

[ACTOR_TraceHit]
MenuName="Trace Hit Info"
Description="Do a trace from Start to End.|Source: The actor that performed the trace (ignore hit with this).|Location/Normal: Hit location and direction.|Actor: Trace hit actor."

[ACTOR_TraceVisible]
MenuName="Trace Visible"
Description="Do a simple visibility trace from Start to End."

[ACTOR_Explosion]
MenuName="Explosion"
Description="Spawn an explosion at a point in level.|Note: Source may be a vector or actor (if a list of actors it will spawn on all of them).|Instigator is the pawn dealing the damage."

[VAR_RandString]
MenuName="Random String"
Description="Multi-text line variable"

[PAWN_LookAt]
MenuName="Look At"
Description="Make player/AI look towards a direction/actor/location."

[EVENT_BindPress]
MenuName="Bind Press"
Description="Called on CLIENT side when local user presses a keybinding.|Axis is when user presses joystick or moves mouse."

[EVENT_ActorSpawned]
MenuName="Actor spawned"
Description="Triggered when an actor spawns.|Caution: A lot of these events could effect performance|(keep them disabled when not actively in use)."

[LATENT_Dispatch]
MenuName="Dispatch Timed"
Description="Send out multiple outputs with a delay timer"

[PAWN_SetViewTarget]
MenuName="Set ViewTarget"
Description="Change player viewtarget.\nEmpty viewtarget = switch to first person view."

[LOGIC_ArrayRandom]
MenuName="Array Random"
Description="Pick a random item from a list"

[EVENT_InvPickup]
MenuName="Get Inventory"
Description="Triggered when a pawn picks up an inventory item."

[LATENT_TimerActor]
MenuName="Timer Actor"
Description="Wait for specific time for each actor"

[VARIABLE_ToggleBool]
MenuName="Toggle Bool"
Description="Toggle boolean value"

[PAWN_GodMode]
MenuName="God Mode"
Description="Give a pawn degreelessness mode"

[MATH_VectorVectorOp]
MenuName="Vector Vector op"
Description="Do a math operation with vector and vector"

[MATH_ToRotation]
MenuName="To rotation"
Description="Convert a vector into rotation (* with optional up axis)"

[LOGIC_LockGate]
MenuName="Lock Gate"
Description="To control execution flow to only once per sequence of actions.|Fire Lock to output once only until you fire Unlock."

[ACTOR_USER_GetInt]
MenuName="Get Int"

[MATH_FromRotation]
MenuName="From rotation"
Description="Get vector from rotation"

[MATH_VectorDist]
MenuName="Distance"
Description="Get distance of 2 vectors"

[ACTOR_USER_GetStr]
MenuName="Get String"

[ACTOR_USER_GetFloat]
MenuName="Get Float"

[MATH_VectorFloatOp]
MenuName="Vector Float op"
Description="Do a math operation with vector and floating point"

[ACTOR_USER_GetObj]
MenuName="Get Object"

[LOGIC_PassesFilter]
MenuName="Passes Filter"
Description="Check if a single object passes a filter test"

[EVENT_KeyPress]
MenuName="Key Press"
Description="Called on CLIENT side when local user presses a keystroke.|Axis is when user presses joystick or moves mouse."

[ACTOR_USER_SetStr]
MenuName="Set String"

[ACTOR_USER_SetObj]
MenuName="Set Object"

[ACTOR_USER_SetInt]
MenuName="Set Int"

[ACTOR_USER_SetFloat]
MenuName="Set Float"

[LOGIC_Random]
MenuName="Random gate"
Description="Fire an output at random gate"

