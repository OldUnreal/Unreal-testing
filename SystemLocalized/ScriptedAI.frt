[SVariableBase]
; EN: MenuName="Variables"
MenuName="Variables"

[VAR_OBJECT_BASE]
; EN: MenuName="Object ref"
MenuName="Réf objet"

[VAR_OBJECTARRAY_BASE]
; EN: MenuName="Object array"
MenuName="Tableau d'objets"

[VAR_Vector]
; EN: MenuName="Vector"
MenuName="Vecteur"
; EN: Description="Vector variable."
Description="Variable vectorielle."

[VAR_STRUCT_BASE]
; EN: MenuName="Struct members"
MenuName="Membres de la structure"

[LOGICBASE]
; EN: MenuName="Logic"
MenuName="Logique"

[ACTIONSBASE]
; EN: MenuName="Actions"
MenuName="Actions"

[ACTORBASE]
; EN: MenuName="Actor"
MenuName="Acteur"

[ACTOR_Overlay]
; EN: MenuName="Mesh Overlay"
MenuName="Superposition de maillage"
; EN: Description="Adds a temporary mesh overlay to an actor."
Description="Ajoute une superposition de maillage temporaire à un acteur."

[HUD_DrawIcon]
; EN: MenuName="Draw Icon"
MenuName="Icône de dessin"
; EN: Description="Draws an icon on the HUD."
Description="Dessine une icône sur le HUD."

[HUDElementBase]
; EN: MenuName="HUD"
MenuName="HUD"

[HUD_DrawText]
; EN: MenuName="Draw Text"
MenuName="Dessiner du texte"
; EN: Description="Draws a message on HUD."
Description="Dessine un message sur le HUD."

[TEXT_ShowMessage]
; EN: MenuName="Show Message"
MenuName="Voir le message"
; EN: Description="Shows a client message on screen.|If no receiver is specified, everyone will receive the message."
Description="Affiche un message client à l'écran. | Si aucun destinataire n'est spécifié, tout le monde recevra le message."

[TEXTBASE]
; EN: MenuName="Text Op"
MenuName="Texte Op"

[VAR_ActorList]
; EN: MenuName="Actor List"
MenuName="Liste des acteurs"
; EN: Description="Dynamic ActorList reference variable."
Description="Variable de référence dynamique ActorList."

[VARIABLEBASE]
; EN: MenuName="Variables"
MenuName="Variables"

[VAR_ObjectList]
; EN: MenuName="Object List"
MenuName="Liste d'objets"
; EN: Description="Object list reference variable.|WARNING: Don't use this to reference dynamic destroyable actors, or the game may crash!"
Description="Variable de référence de liste d'objets.|AVERTISSEMENT: ne l'utilisez pas pour référencer des acteurs destructibles dynamiques, sinon le jeu risque de planter!"

[LEVELSBASE]
; EN: MenuName="Level"
MenuName="Niveau"

[VAR_Actor]
; EN: MenuName="Actor"
MenuName="Acteur"
; EN: Description="Dynamic actor reference variable."
Description="Variable de référence d'acteur dynamique."

[VAR_Float]
; EN: MenuName="Float"
MenuName="Flotter"
; EN: Description="Floating point variable."
Description="Variable à virgule flottante."

[VAR_Int]
; EN: MenuName="Int"
MenuName="Int"
; EN: Description="32-bit integer variable."
Description="Variable entière de 32 bits."

[LEVEL_Network]
; EN: MenuName="Network data"
MenuName="Données réseau"
; EN: Description="Transmits data from server to client.|All inputs you set will also output on client side and fire output event client side every time you fire an input server-side.|If no receiver is specified, the networked event will be broadcast to all clients."
Description="Transmet les données du serveur au client.|Toutes les entrées que vous définissez seront également sorties côté client et déclencheront l'événement de sortie côté client chaque fois que vous déclenchez une entrée côté serveur.|Si aucun récepteur n'est spécifié, l'événement en réseau sera diffusé à tous les clients ."

[LEVEL_RadialActors]
; EN: MenuName="Radius Actors"
MenuName="Acteurs Radius"
; EN: Description="Grabs all actors within a point in level.|Position input can be an actor or a vector."
Description="Saisit tous les acteurs d'un point de niveau. | L'entrée de position peut être un acteur ou un vecteur."

[MATH_Int]
; EN: MenuName="Int op"
MenuName="Int op"
; EN: Description="Does a math operation with integers."
Description="Effectue une opération mathématique avec des nombres entiers."

[MATHBASE]
; EN: MenuName="Math"
MenuName="Math"

[EVENTBASE]
; EN: MenuName="Events"
MenuName="Événements"

[VAR_String]
; EN: MenuName="String"
MenuName="Chaîne"
; EN: Description="Text line variable."
Description="Variable de ligne de texte."

[MOVER_MoveToKey]
; EN: MenuName="Move to key"
MenuName="Déplacer vers la clé"
; EN: Description="Moves a mover to a keyframe."
Description="Déplace un déplacement vers une image clé."

[MOVERBASE]
; EN: MenuName="Mover"
MenuName="Déménageur"

[PAWN_SetHealth]
; EN: MenuName="Give Health"
MenuName="Donner de la santé"
; EN: Description="Gives or removes health from a pawn."
Description="Donne ou retire la santé d'un pion."

[PAWNBASE]
; EN: MenuName="Pawn"
MenuName="Pion"

[EVENT_Triggered]
; EN: MenuName="Triggered"
MenuName="Déclenché"
; EN: Description="Triggered by a regular in level event.|Tag can be changed by firing Set Tag event and binding NewTag value."
Description="Déclenché par un événement de niveau normal. | La balise peut être modifiée en déclenchant l'événement Set Tag et en liant la valeur NewTag."

[ACTOR_ChangeScale]
; EN: MenuName="Change scale"
MenuName="Changer d'échelle"
; EN: Description="Resizes an actor with optional blend time."
Description="Redimensionne un acteur avec un temps de fusion facultatif."

[VAR_Name]
; EN: MenuName="Name"
MenuName="Nom"
; EN: Description="Name variable."
Description="Nom de la variable."

[ACTOR_Destroy]
; EN: MenuName="Destroy Actor"
MenuName="Détruire l'acteur"
; EN: Description="Instantly destroys an actor."
Description="Détruit instantanément un acteur."

[MATH_Float]
; EN: MenuName="Float op"
MenuName="Float op"
; EN: Description="Does a math operation with floating point."
Description="Effectue une opération mathématique avec virgule flottante."

[VAR_Bool]
; EN: MenuName="Boolean"
MenuName="Booléen"
; EN: Description="Boolean variable."
Description="Variable booléenne."

[LATENT_MoveToActor]
; EN: MenuName="AI Move to actor"
MenuName="AI Passer à l'acteur"
; EN: Description="Makes a ScriptedPawn move to a goal actor.|Output is fired when a pawn has reached or not the goal actor, with Reached output set to just finished pawn."
Description="Fait passer un ScriptedPawn à un acteur de but. | La sortie est déclenchée lorsqu'un pion a atteint ou non l'acteur de but, avec la sortie Atteint définie sur le pion qui vient de terminer."

[LATENTBASE]
; EN: MenuName="Latent"
MenuName="Latent"

[ACTOR_PlaySound]
; EN: MenuName="Play Sound"
MenuName="Jouer son"
; EN: Description="Plays a sound effect.|Sound source can be an actor or a vector. If actor array, it will play the sound on all actors in that array."
Description="Lit un effet sonore. | La source sonore peut être un acteur ou un vecteur. S'il s'agit d'un tableau d'acteur, il jouera le son sur tous les acteurs de ce tableau."

[VAR_Rotator]
; EN: MenuName="Rotator"
MenuName="Rotateur"
; EN: Description="Rotator variable."
Description="Variable de rotation."

[LEVEL_SpawnActor]
; EN: MenuName="Spawn Actor"
MenuName="Acteur de spawn"
; EN: Description="Spawns a new actor.|If you input Position as actor variable, it will use that actor rotation. Otherwise you can input vector and rotation."
Description="Crée un nouvel acteur.|Si vous saisissez Position comme variable d'acteur, il utilisera cette rotation d'acteur. Sinon, vous pouvez saisir le vecteur et la rotation."

[LEVEL_AllPawns]
; EN: MenuName="All Pawns"
MenuName="Tous les pions"
; EN: Description="Grabs all pawns from level."
Description="Attrape tous les pions du niveau."

[PAWN_GiveItem]
; EN: MenuName="Give Item"
MenuName="Donner un objet"
; EN: Description="Gives an inventory item to a player."
Description="Donne un objet d'inventaire à un joueur."

[LOGIC_ArrayAdd]
; EN: MenuName="Array Add"
MenuName="Ajouter un tableau"
; EN: Description="Adds an unique item to array.|Fires event Found or Not Found depending on the result."
Description="Ajoute un élément unique au tableau. | Déclenche l'événement Trouvé ou Non Trouvé selon le résultat."

[VAR_RandInt]
; EN: MenuName="Random Int"
MenuName="Int aléatoire"
; EN: Description="Random integer variable."
Description="Variable entière aléatoire."

[TEXT_AddText]
; EN: MenuName="Append Text"
MenuName="Ajouter du texte"
; EN: Description="Adds text to the end of the current textline."
Description="Ajoute du texte à la fin de la ligne de texte actuelle."

[VAR_Object]
; EN: MenuName="Object"
MenuName="Objet"
; EN: Description="Object reference variable.|WARNING: Don't use this to reference dynamic destroyable actors, or the game may crash!"
Description="Variable de référence d'objet.|AVERTISSEMENT: ne l'utilisez pas pour référencer des acteurs destructibles dynamiques, sinon le jeu risque de planter!"

[LEVEL_PlayMusic]
; EN: MenuName="Play Music"
MenuName="Jouer de la musique"
; EN: Description="Changes currently played music.|If no player is specified, the event affects all actors."
Description="Modifie la musique en cours de lecture. | Si aucun lecteur n'est spécifié, l'événement affecte tous les acteurs."

[VAR_RandFloat]
; EN: MenuName="Random Float"
MenuName="Flotteur aléatoire"
; EN: Description="Random floating point variable."
Description="Variable à virgule flottante aléatoire."

[LATENT_Timer]
; EN: MenuName="Timer"
MenuName="Minuteur"
; EN: Description="Waits for specific time."
Description="Attend un moment précis."

[ACTOR_SetHidden]
; EN: MenuName="Set Hidden"
MenuName="Définir caché"
; EN: Description="Toggles the Hidden property for an actor."
Description="Active / désactive la propriété Masqué pour un acteur."

[VAR_LocalPlayer]
; EN: MenuName="Local Player"
MenuName="Joueur local"
; EN: Description="Local player variable function."
Description="Fonction variable du joueur local."

[EVENT_PawnDied]
; EN: MenuName="Pawn Died"
MenuName="Pion mort"
; EN: Description="Triggered when a pawn dies."
Description="Déclenché lorsqu'un pion meurt."

[EVENT_PawnHurt]
; EN: MenuName="Pawn Hurt"
MenuName="Pion blessé"
; EN: Description="Triggered when a pawn takes damage."
Description="Déclenché lorsqu'un pion subit des dégâts."

[EVENT_PawnPrevDeath]
; EN: MenuName="Prevent Death"
MenuName="Prévenir la mort"
; EN: Description="Prevents a pawn from dying.|NOTE: Output link is fired, THEN it checks the Input flag. If true, it prevents the pawn from dying."
Description="Empêche un pion de mourir. | REMARQUE: le lien de sortie est déclenché, PUIS il vérifie le drapeau d'entrée. Si c'est vrai, cela empêche le pion de mourir."

[OBJECTBASE]
; EN: MenuName="Object"
MenuName="Objet"

[EVENT_PlayerSpawn]
; EN: MenuName="Player spawned"
MenuName="Joueur engendré"
; EN: Description="Triggered when a player spawns."
Description="Déclenché lorsqu'un joueur apparaît."

[PAWN_Kill]
; EN: MenuName="Kill Pawn"
MenuName="Tuer un pion"
; EN: Description="Kills instantly a pawn."
Description="Tue instantanément un pion."

[LOGIC_ListIterator]
; EN: MenuName="ObjList Iterator"
MenuName="Itérateur ObjList"
; EN: Description="Iterates through an object list."
Description="Itère une liste d'objets."

[LEVEL_SendEvent]
; EN: MenuName="Trigger Event"
MenuName="Événement déclencheur"
; EN: Description="Sends a regular event to all actors in level."
Description="Envoie un événement régulier à tous les acteurs du niveau."

[LOGIC_ArrayRemove]
; EN: MenuName="Array Remove"
MenuName="Suppression de la baie"
; EN: Description="Remove a single item from array and return its size.|An empty event is fired once final array entry has been removed."
Description="Supprimez un seul élément du tableau et renvoyez sa taille.|Un événement vide est déclenché une fois que l'entrée finale du tableau a été supprimée."

[TEXT_Replace]
; EN: MenuName="Replace Text"
MenuName="Remplacer le texte"
; EN: Description="Replace a part of text with another text."
Description="Remplacez une partie du texte par un autre texte."

[LOGIC_Dispatch]
; EN: MenuName="Dispatcher"
MenuName="Répartiteur"
; EN: Description="Split a call into multiple branches."
Description="Divisez un appel en plusieurs branches."

[ACTOR_TakeDamage]
; EN: MenuName="Take Damage"
MenuName="Prendre des dégâts"
; EN: Description="Make an actor take damage."
Description="Faire subir des dégâts à un acteur."

[ACTOR_SetPhysics]
; EN: MenuName="Set Physics"
MenuName="Définir la physique"
; EN: Description="Changes the actor's movement physics."
Description="Modifie la physique du mouvement de l'acteur."

[ACTOR_SetCollision]
; EN: MenuName="Set Collision"
MenuName="Définir la collision"
; EN: Description="Changes the actor's collision state."
Description="Modifie l'état de collision de l'acteur."

[ACTOR_PlayAnim]
; EN: MenuName="Play Anim"
MenuName="Jouer à Anim"
; EN: Description="Play an animation on actors.|Note: Pawn code may override the animation!"
Description="Jouez une animation sur les acteurs.|Remarque: le code du pion peut remplacer l'animation!"

[LOGIC_CompareFloat]
; EN: MenuName="Compare Float"
MenuName="Comparez Float"
; EN: Description="Compare 2 floating point values."
Description="Comparez 2 valeurs à virgule flottante."

[PAWN_DeleteItem]
; EN: MenuName="Delete Item"
MenuName="Effacer l'article"
; EN: Description="Find and delete an inventory item from a player."
Description="Trouvez et supprimez un objet d'inventaire d'un joueur."

[LOGIC_CompareInt]
; EN: MenuName="Compare Int"
MenuName="Comparez Int"
; EN: Description="Compare 2 integer values."
Description="Comparez 2 valeurs entières."

[VARIABLE_ToVector]
; EN: MenuName="To Vector"
MenuName="Au vecteur"
; EN: Description="Constructs a vector from individual components."
Description="Construit un vecteur à partir de composants individuels."

[VARIABLE_ToRotator]
; EN: MenuName="To Rotator"
MenuName="Vers le rotateur"
; EN: Description="Constructs a rotator from individual components."
Description="Construit un rotateur à partir de composants individuels."

[LOGIC_Gate]
; EN: MenuName="Logic Gate"
MenuName="Porte logique"
; EN: Description="A logic gate."
Description="Une porte logique."

[VARIABLE_FromVector]
; EN: MenuName="From Vector"
MenuName="À partir du vecteur"
; EN: Description="Grab each vector component."
Description="Saisissez chaque composant vectoriel."

[PAWN_FindItem]
; EN: MenuName="Find Item"
MenuName="Trouver un article"
; EN: Description="Find an inventory item from a player."
Description="Trouvez un objet d'inventaire auprès d'un joueur."

[VARIABLE_FromRotator]
; EN: MenuName="From Rotator"
MenuName="De Rotator"
; EN: Description="Grab each rotator component."
Description="Prenez chaque composant du rotateur."

[LOGIC_CompareObject]
; EN: MenuName="Compare Object"
MenuName="Comparer un objet"
; EN: Description="Compare 2 objects."
Description="Comparez 2 objets."

[LOGIC_CompareText]
; EN: MenuName="Compare Text"
MenuName="Comparer du texte"
; EN: Description="Compare 2 string text lines."
Description="Comparez 2 lignes de texte de chaîne."

[ACTOR_GetName]
; EN: MenuName="Get Name"
MenuName="Obtenir le nom"
; EN: Description="Grab the actor name."
Description="Saisissez le nom de l'acteur."

[LOGIC_GetArraySize]
; EN: MenuName="Get Array Size"
MenuName="Obtenir la taille du tableau"
; EN: Description="Check the size of an object array."
Description="Vérifiez la taille d'un tableau d'objets."

[OBJECT_SetProperty]
; EN: MenuName="Set Property"
MenuName="Définir la propriété"
; EN: Description="Change actor property value."
Description="Changer la valeur de la propriété de l'acteur."

[OBJECT_ChangeState]
; EN: MenuName="Change State"
MenuName="Changer d'état"
; EN: Description="Change actor script state."
Description="Changer l'état du script de l'acteur."

[LEVEL_AllActors]
; EN: MenuName="All Actors"
MenuName="Tous les acteurs"
; EN: Description="Grab all actors from level."
Description="Prenez tous les acteurs du niveau."

[OBJECT_GetProperty]
; EN: MenuName="Get Property"
MenuName="Obtenir la propriété"
; EN: Description="Grab actor property value."
Description="Saisissez la valeur de la propriété de l'acteur."

[VARIABLE_SetBool]
; EN: MenuName="Set Bool"
MenuName="Définir la valeur booléenne"
; EN: Description="Set boolean value."
Description="Définissez une valeur booléenne."

[LEVEL_ResetLevel]
; EN: MenuName="Reset level"
MenuName="Réinitialiser le niveau"
; EN: Description="Soft-resets the level."
Description="Réinitialise le niveau en douceur."

[VARIABLE_SetFloat]
; EN: MenuName="Set Float"
MenuName="Définir le flotteur"
; EN: Description="Set float value."
Description="Définissez la valeur flottante."

[LOGIC_ArrayEmpty]
; EN: MenuName="Array Empty"
MenuName="Tableau vide"
; EN: Description="Simply blank out an array."
Description="Videz simplement un tableau."

[VARIABLE_SetInt]
; EN: MenuName="Set Int"
MenuName="Définir Int"
; EN: Description="Set integer value."
Description="Définissez une valeur entière."

[VARIABLE_SetString]
; EN: MenuName="Set Text"
MenuName="Définir le texte"
; EN: Description="Set string value."
Description="Définissez la valeur de la chaîne."

[EVENT_BeginPlay]
; EN: MenuName="Begin Play"
MenuName="Commencer à jouer"
; EN: Description="Fires an event on start of map.|Reset event is fired instead when level was soft-reset."
Description="Déclenche un événement au début de la carte. | L'événement de réinitialisation est déclenché à la place lorsque le niveau a été réinitialisé à chaud."

[LOGIC_CompareBool]
; EN: MenuName="Compare Bool"
MenuName="Comparer Bool"
; EN: Description="Compare a boolean value."
Description="Comparez une valeur booléenne."

[LOGIC_ServerType]
; EN: MenuName="Server Type"
MenuName="Type de serveur"
; EN: Description="Check in which environment this action is executed on."
Description="Vérifiez dans quel environnement cette action est exécutée."
