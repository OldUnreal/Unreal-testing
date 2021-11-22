// Command Hook can be used by adding the object to EditPackages like BrushBuilders
// And it will call any exec functions within this object for commands starting with HOOK:
// exec function SpawnLevel() -> HOOK SpawnLevel
Class EdCommandHook extends Object
	native
	abstract;

