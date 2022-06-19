// Class for managing player user configurations.
Class UnrealUserManager extends Object
	transient
	config(User);

var protected bool bIsSpectator;
var protected string InitName;
var protected byte InitTeam;

var private config string CurrentClass,CurrentSkin,CurrentFace;
var private config byte CurrentTeam;
var private UnrealUserManager Manager;

struct FPairInfo
{
	var string Value,Desc;
};
var array<FPairInfo> MeshList, SkinList, FaceList;
var int FirstCustomMesh;

// Initialize.
static final function UnrealUserManager GetManager()
{
	if( !Default.Manager )
	{
		Default.Manager = new Class'UnrealUserManager';
		Default.Manager.Init();
	}
	return Default.Manager;
}
private function Init()
{
	local string Value,Desc;
	
	foreach Class'PlayerPawn'.Static.IntDescIterator(string(Class'UnrealIPlayer'),Value,Desc,true)
	{
		if( Len(Desc)==0 )
			Desc = GetItemName(Value);
		if ( !(Value~=string(Class'Spectator')) && !(Value~=string(Class'UnrealSpectator')) )
		{
			MeshList[FirstCustomMesh].Value = Value;
			MeshList[FirstCustomMesh].Desc = Desc;
			++FirstCustomMesh;
		}
	}
}
final function string GetItemName( string S )
{
	local int i;
	
	while( true )
	{
		i = InStr(S,".");
		if( i==-1 )
			break;
		S = Mid(S,i+1);
	}
	return S;
}

// Should be called every time menu is opened.
final function Refresh()
{
	local string S;
	
	S = Class'PlayerPawn'.Static.GetDefaultURL("Class", "");
	bIsSpectator = (S~=string(Class'Spectator') || S~=string(Class'UnrealSpectator'));
	InitName = Class'PlayerPawn'.Static.GetDefaultURL("Name", "Player");
	InitTeam = bIsSpectator ? CurrentTeam : byte(Class'PlayerPawn'.Static.GetDefaultURL("Team", "255"));
}

// Build list of player classes and return selected player index.
final function GetMeshList( out array<PlayerClassManager> Managers )
{
	local PlayerClassManager M;
	local Class<PlayerPawn> P;
	local int i;
	
	if( MeshList.Size()>FirstCustomMesh )
		MeshList.Remove(MeshList.Size()-FirstCustomMesh);
	
	i = FirstCustomMesh;
	foreach Managers(M)
	{
		if( !M || M.bDeleteMe || !M.bEnabled )
			continue;
		foreach M.AdditionalClasses(P)
		{
			if ( !P || MeshList.Find(Value,string(P))>=0 )
				Continue;
			MeshList[i].Value = string(P);
			if ( P.Default.MenuName!="" )
				MeshList[i].Desc = P.Default.MenuName;
			else MeshList[i].Desc = string(P.Name);
			++i;
		}
	}
}

final function string GetCurrentClass()
{
	return bIsSpectator ? CurrentClass : Class'PlayerPawn'.Static.GetDefaultURL("Class", CurrentClass);
}

// Build a list of skins
final function int GetMeshSkins( class<Pawn> PlayerClass, out array<PlayerClassManager> Managers )
{
	local string Value,Desc,MeshName,MeshDotted;
	local int i,Index,MeshLen;
	local PlayerClassManager M;
	local array<Texture> Tex;
	local Texture T;
	
	FaceList.Empty();
	SkinList.Empty();
	
	if( !PlayerClass.Default.Mesh ) // Invalid mesh!
		return -1;
	MeshName = string(PlayerClass.Default.Mesh.Name);
	MeshDotted = MeshName$";";
	MeshLen = Len(MeshName);

	// Gather stock skins.
	foreach Class'PlayerPawn'.Static.IntDescIterator(string(Class'Texture'),Value,Desc,true)
	{
		if( (Left(Value,MeshLen)~=MeshName || (Len(Desc) && Left(Desc,MeshLen+1)~=MeshDotted)) &&
			(!PlayerClass.Default.bIsMultiSkinned || (Len(Desc) && Len(GetItemName(Value))<=5))) // Test if this is a multiskin.
		{
			SkinList[Index].Value = PlayerClass.Default.bIsMultiSkinned ? Left(Value,Len(Value)-1) : Value;
			if( !Len(Desc) )
				SkinList[Index].Desc = GetItemName(Value);
			else
			{
				i = InStr(Desc,";");
				if( i==-1 )
					SkinList[Index].Desc = Desc;
				else SkinList[Index].Desc = Mid(Desc,i+1);
			}
			++Index;
		}
	}
	
	foreach Managers(M)
	{
		if( !M || M.bDeleteMe || !M.bEnabled )
			continue;
		M.GetMeshSkins(Tex,MeshName);
		foreach Tex(T)
		{
			if( SkinList.Find(Value,string(T))>=0 || (PlayerClass.Default.bIsMultiSkinned && Len(string(T.Name))>5) )
				continue;
			Value = string(T);
			SkinList[Index].Value = PlayerClass.Default.bIsMultiSkinned ? Left(Value,Len(Value)-1) : Value;
			SkinList[Index].Desc = string(T.Name);
			++Index;
		}
		Tex.Empty();
	}
	
	return SkinList.Find(Value,CurrentSkin);
}

final function string GetCurrentSkin()
{
	return (SkinList.Find(Value,CurrentSkin)>=0) ? CurrentSkin : "";
}

// Build a list of faces
final function int GetMeshFaces( class<Pawn> PlayerClass, string PlayerSkin, out array<PlayerClassManager> Managers )
{
	local string Value,Desc,MeshName,MeshDotted,S,SkinName;
	local int Index,MeshLen;
	local PlayerClassManager M;
	local array<Texture> Tex;
	local Texture T;
	
	FaceList.Empty();
	
	if( !PlayerClass.Default.Mesh || !PlayerClass.Default.bIsMultiSkinned ) // Invalid mesh!
		return -1;
	MeshName = string(PlayerClass.Default.Mesh.Name);
	MeshDotted = MeshName$";";
	MeshLen = Len(MeshName);
	SkinName = GetItemName(PlayerSkin);

	// Gather stock skins.
	foreach Class'PlayerPawn'.Static.IntDescIterator(string(Class'Texture'),Value,Desc,true)
	{
		if( Len(Desc) && (Left(Value,MeshLen)~=MeshName || Left(Desc,MeshLen+1)~=MeshDotted) )
		{
			S = GetItemName(Value);
			if( Len(S)<=5 || !(Left(S,4)~=SkinName) )
				continue;
			
			FaceList[Index].Value = Left(Value,Len(Value)-Len(S))$Mid(S,5);
			FaceList[Index].Desc = Desc;
			++Index;
		}
	}
	
	foreach Managers(M)
	{
		if( !M || M.bDeleteMe || !M.bEnabled )
			continue;
		M.GetMeshSkins(Tex,MeshName);
		foreach Tex(T)
		{
			Value = string(T);
			S = string(T.Name);
			if( FaceList.Find(Value,Value)>=0 || Len(S)<=5 || !(Left(S,4)~=SkinName) )
				continue;
			FaceList[Index].Value = Left(Value,Len(Value)-Len(S))$Mid(S,5);
			FaceList[Index].Desc = S;
			++Index;
		}
		Tex.Empty();
	}
	
	return FaceList.Find(Value,CurrentFace);
}

final function string GetCurrentFace()
{
	return (FaceList.Find(Value,CurrentFace)>=0) ? CurrentFace : "";
}

// Should be called when menu is closed.
final function Save( const out string NewName, const out string NewClass, const out string NewSkin, const out string NewFace, byte NewTeam, bool bNewSpectator )
{
	local string S;
	
	if( NewName!=InitName )
	{
		S = ReplaceStr(Left(NewName,20)," ","_");
		SanitizeString(S);
		GetLocalPlayerPawn().ChangeName(S);
		Class'PlayerPawn'.Static.UpdateURL("Name", S, True);
		InitName = S;
	}
	bIsSpectator = bNewSpectator;
	if( bNewSpectator )
	{
		Class'PlayerPawn'.Static.UpdateURL("Class", string(Class'UnrealSpectator'), True);
		Class'PlayerPawn'.Static.UpdateURL("Skin", "", True);
		Class'PlayerPawn'.Static.UpdateURL("Face", "", True);
		Class'PlayerPawn'.Static.UpdateURL("Team", "", True);
	}
	else
	{
		Class'PlayerPawn'.Static.UpdateURL("Class", NewClass, True);
		Class'PlayerPawn'.Static.UpdateURL("Skin", NewSkin, True);
		Class'PlayerPawn'.Static.UpdateURL("Face", NewFace, True);
		Class'PlayerPawn'.Static.UpdateURL("Team", string(NewTeam), True);
		
		// if the same class as current class, change skin
		if ( NewClass ~= String( GetLocalPlayerPawn().Class ))
			GetLocalPlayerPawn().ServerChangeSkin(NewSkin, NewFace, NewTeam);
		
		if( NewTeam!=GetLocalPlayerPawn().GetTeamNum() )
			GetLocalPlayerPawn().ChangeTeam(NewTeam);
	}
	CurrentClass = NewClass;
	CurrentSkin = NewSkin;
	CurrentFace = NewFace;
	CurrentTeam = NewTeam;
	SaveConfig();
}

defaultproperties
{
	CurrentClass="UnrealShare.FemaleOne"
	CurrentTeam=255
}