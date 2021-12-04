﻿/*===========================================================================
    C++ class definitions exported from UnrealScript.
    This is automatically generated by the tools.
    DO NOT modify this manually! Edit the corresponding .uc files instead!
===========================================================================*/
#if ((_MSC_VER) || (HAVE_PRAGMA_PACK))
#pragma pack (push,OBJECT_ALIGNMENT)
#endif

#ifndef UWEBADMIN_API
#define UWEBADMIN_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern UWEBADMIN_API FName UWEBADMIN_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(AllowAccess)
AUTOGENERATE_NAME(NotEnoughPrivileges)
AUTOGENERATE_NAME(LoadUpClassContent)
AUTOGENERATE_NAME(SendBunch)

#ifndef NAMES_ONLY

#define UCONST_WebAdminVersion "1.000.2"

class UWEBADMIN_API UWebObjectBase : public UObject
{
public:
	DECLARE_CLASS(UWebObjectBase,UObject,CLASS_Abstract,UWebAdmin)
	NO_DEFAULT_CONSTRUCTOR(UWebObjectBase)
};

class UWEBADMIN_API UWebPageContent : public UWebObjectBase
{
public:
	BYTE RequiredPrivileges GCC_PACK(INT_ALIGNMENT);
	BITFIELD bStandardForm:1 GCC_PACK(INT_ALIGNMENT);
	void eventLoadUpClassContent(class UWebQuery* Query)
	{
		ProcessEvent(FindFunctionChecked(UWEBADMIN_LoadUpClassContent),&Query);
	}
	void eventNotEnoughPrivileges(class UWebQuery* Query)
	{
		ProcessEvent(FindFunctionChecked(UWEBADMIN_NotEnoughPrivileges),&Query);
	}
	BITFIELD eventAllowAccess(class UWebQuery* Query)
	{
		struct { class UWebQuery* Query; BITFIELD ReturnValue; } Parms = { Query, 0 };
		ProcessEvent(FindFunctionChecked(UWEBADMIN_AllowAccess),&Parms);
		return Parms.ReturnValue;
	}
	DECLARE_CLASS(UWebPageContent,UWebObjectBase,CLASS_Config,UWebAdmin)
	NO_DEFAULT_CONSTRUCTOR(UWebPageContent)
};

class UWEBADMIN_API UWebQuery : public UWebObjectBase
{
public:
	INT DataSize GCC_PACK(INT_ALIGNMENT);
	INT PendingCount;
	class AWebConnection* Connection;
	class USubWebManager* Manager;
	TArrayNoInit<BYTE> Data;
	TArrayNoInit<BYTE> PendingSend;
	FStringNoInit User;
	FStringNoInit Password;
	FStringNoInit URL;
	FStringNoInit Header;
	FStringNoInit UpFileName;
	FStringNoInit FileTrailing;
	FStringNoInit ContentType;
	FStringNoInit MiscInfo;
	TMultiMap<FString,FString>* DataMap;
	BYTE UserPrivileges;
	BYTE PendingData[255];
	BITFIELD bHeaderReceived:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bCompleted:1;
	BITFIELD bIsPost:1;
	BITFIELD bHeaderAtached:1;
	BITFIELD bReceivedBinary:1;
	DECLARE_FUNCTION(execSetVariable);
	DECLARE_FUNCTION(execGetVariables);
	DECLARE_FUNCTION(execGetPreferences);
	DECLARE_FUNCTION(execMovePackage);
	DECLARE_FUNCTION(execUploadedFiles);
	DECLARE_FUNCTION(execSaveFileUpload);
	DECLARE_FUNCTION(execSettingsEnabled);
	DECLARE_FUNCTION(execSendData);
	DECLARE_FUNCTION(execLocalizeWebPage);
	DECLARE_FUNCTION(execParseSafeText);
	DECLARE_FUNCTION(execSendTextLine);
	DECLARE_FUNCTION(execIncludeFile);
	DECLARE_FUNCTION(execMultiValue);
	DECLARE_FUNCTION(execAllValues);
	DECLARE_FUNCTION(execGetValue);
	DECLARE_FUNCTION(execReceivedBytes);
	void eventSendBunch()
	{
		ProcessEvent(FindFunctionChecked(UWEBADMIN_SendBunch),NULL);
	}
	DECLARE_CLASS(UWebQuery,UWebObjectBase,CLASS_Transient,UWebAdmin)
	#include "UWebQuery.h"
};

#endif

AUTOGENERATE_FUNCTION(UWebQuery,1195,execSetVariable);
AUTOGENERATE_FUNCTION(UWebQuery,1194,execGetVariables);
AUTOGENERATE_FUNCTION(UWebQuery,1193,execGetPreferences);
AUTOGENERATE_FUNCTION(UWebQuery,1192,execMovePackage);
AUTOGENERATE_FUNCTION(UWebQuery,1191,execUploadedFiles);
AUTOGENERATE_FUNCTION(UWebQuery,1190,execSaveFileUpload);
AUTOGENERATE_FUNCTION(UWebQuery,1189,execSettingsEnabled);
AUTOGENERATE_FUNCTION(UWebQuery,1188,execSendData);
AUTOGENERATE_FUNCTION(UWebQuery,1187,execLocalizeWebPage);
AUTOGENERATE_FUNCTION(UWebQuery,1186,execParseSafeText);
AUTOGENERATE_FUNCTION(UWebQuery,1185,execSendTextLine);
AUTOGENERATE_FUNCTION(UWebQuery,1184,execIncludeFile);
AUTOGENERATE_FUNCTION(UWebQuery,1183,execMultiValue);
AUTOGENERATE_FUNCTION(UWebQuery,1182,execAllValues);
AUTOGENERATE_FUNCTION(UWebQuery,1181,execGetValue);
AUTOGENERATE_FUNCTION(UWebQuery,1180,execReceivedBytes);

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif // NAMES_ONLY

#if ((_MSC_VER) || (HAVE_PRAGMA_PACK))
#pragma pack (pop)
#endif

#ifdef VERIFY_CLASS_SIZES
VERIFY_CLASS_SIZE_NODIE(UWebObjectBase)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebPageContent,RequiredPrivileges)
VERIFY_CLASS_SIZE_NODIE(UWebPageContent)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,DataSize)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,PendingCount)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,Connection)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,Manager)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,Data)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,PendingSend)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,User)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,Password)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,URL)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,Header)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,UpFileName)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,FileTrailing)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,ContentType)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,MiscInfo)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,DataMap)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,UserPrivileges)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,WebQuery,PendingData)
VERIFY_CLASS_SIZE_NODIE(UWebQuery)
#endif // VERIFY_CLASS_SIZES