// ===========================================================================
// UWebAdmin code written by .:..:
// ===========================================================================

#include "Engine.h"

struct FVariableInfo
{
	FString VarDesc; // Variable description
	FName VarName; // Variable name
	BYTE VarType; // Variable type
	INT NumElements; // Number of elements, 1> = static array, 0< = dynamic array
	TArray<FString> Value; // Current value
	TArray<FName> EnumList; // Enum elements available.

	FVariableInfo( UProperty* P );
};
#include "UWebAdminClasses.h"

extern TCHAR SettingsText[],ConfigFileText[];

inline void CopyString( TCHAR* Dest, const TCHAR* Src, INT Len )
{
	for( INT i=0; i<Len; ++i )
		Dest[i] = Src[i];
	Dest[Len] = 0;
}
