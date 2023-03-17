/*=============================================================================
	UnUWebAdminNative.h: Native function lookup table for static libraries.
	Copyright 2022 OldUnreal. All Rights Reserved.

	Revision history:
		* Created by Stijn Volckaert
=============================================================================*/

#ifndef UNUWEBADMINNATIVE_H
#define UNUWEBADMINNATIVE_H

DECLARE_NATIVE_TYPE(UWebAdmin,UWebQuery);

#define AUTO_INITIALIZE_REGISTRANTS_UWEBADMIN	\
	UWebQuery::StaticClass();					\
	UWebPageContent::StaticClass();				\
	UWebObjectBase::StaticClass();

#endif
