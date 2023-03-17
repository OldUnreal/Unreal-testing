/*=============================================================================
	UnUPakNative.h: Native function lookup table for static libraries.
	Copyright 2022 OldUnreal. All Rights Reserved.

	Revision history:
		* Created by Stijn Volckaert
=============================================================================*/

#ifndef UNUPAKNATIVE_H
#define UNUPAKNATIVE_H

DECLARE_NATIVE_TYPE(UPak,APathNodeIterator);
DECLARE_NATIVE_TYPE(UPak,APawnPathNodeIterator);

#define AUTO_INITIALIZE_REGISTRANTS_UPAK		\
	APathNodeIterator::StaticClass();			\
	APawnPathNodeIterator::StaticClass();

#endif
