/*=============================================================================
	UnUWebAdminNative.cpp: Native function lookup table for static libraries.
	Copyright 2022 OldUnreal. All Rights Reserved.

	Revision history:
		* Created by Stijn Volckaert
=============================================================================*/

#include "UWebAdminPrivate.h"

#if __STATIC_LINK
#include "UnUWebAdminNative.h"

UWebQueryNativeInfo GUWebAdminUWebQueryNatives[] =
{
	MAP_NATIVE(UWebQuery, execSetVariable)
	MAP_NATIVE(UWebQuery, execGetVariables)
	MAP_NATIVE(UWebQuery, execGetPreferences)
	MAP_NATIVE(UWebQuery, execMovePackage)
	MAP_NATIVE(UWebQuery, execUploadedFiles)
	MAP_NATIVE(UWebQuery, execSaveFileUpload)
	MAP_NATIVE(UWebQuery, execSettingsEnabled)
	MAP_NATIVE(UWebQuery, execSendData)
	MAP_NATIVE(UWebQuery, execLocalizeWebPage)
	MAP_NATIVE(UWebQuery, execParseSafeText)
	MAP_NATIVE(UWebQuery, execSendTextLine)
	MAP_NATIVE(UWebQuery, execIncludeFile)
	MAP_NATIVE(UWebQuery, execMultiValue)
	MAP_NATIVE(UWebQuery, execAllValues)
	MAP_NATIVE(UWebQuery, execGetValue)
	MAP_NATIVE(UWebQuery, execReceivedBytes)
	{NULL, NULL}
};
IMPLEMENT_NATIVE_HANDLER(UWebAdmin,UWebQuery);

#endif
