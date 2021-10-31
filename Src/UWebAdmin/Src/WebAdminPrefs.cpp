
#include "UWebAdminPrivate.h"

static TCHAR AllowPrefName[]=TEXT("AllowPreferences");

BYTE UWebQuery::PreferencesEnabled()
{
	static BYTE bCheckedEnabled = 2;
	if( bCheckedEnabled==2 )
	{
		UBOOL bRes=0;
		if( !GConfig->GetBool(SettingsText,AllowPrefName,bRes,ConfigFileText) )
		{
			GConfig->SetBool(SettingsText,AllowPrefName,0,ConfigFileText);
			GConfig->Flush(0,ConfigFileText);
		}
		bCheckedEnabled = (bRes!=0);
	}
	return (bCheckedEnabled && !GIsClient && GIsServer && Connection);
}

FVariableInfo::FVariableInfo( UProperty* P )
	: VarName(P->GetFName()), NumElements(Max<INT>(P->ArrayDim,1)), VarDesc(P->GetFullName())
{
	UClass* C = P->GetClass();
	if( C==UArrayProperty::StaticClass() ) // Special handling.
	{
		P = ((UArrayProperty*)P)->Inner;
		C = P->GetClass();
		NumElements = 0;
	}

	if( C==UIntProperty::StaticClass() )
		VarType = 0;
	else if( C==UFloatProperty::StaticClass() )
		VarType = 1;
	else if( C==UByteProperty::StaticClass() )
	{
		VarType = 2;
		UEnum* E = ((UByteProperty*)P)->Enum;
		if( E )
		{
			VarType = 3;
			EnumList = E->Names;
		}
	}
	else if( C==UStrProperty::StaticClass() )
		VarType = 4;
	else if( C==UObjectProperty::StaticClass() || C==UClassProperty::StaticClass() )
		VarType = 5;
	else if( C==UStructProperty::StaticClass() )
		VarType = 6;
	else if( C==UBoolProperty::StaticClass() )
		VarType = 7;
	else VarType = 8;
}

QSORT_RETURN CDECL ComparePreferences( const FPreferencesInfo* A, const FPreferencesInfo* B )
{
	return appStricmp(*A->Caption,*B->Caption);
}
void UWebQuery::execGetPreferences(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execGetPreferences);
	P_GET_REFP(TArray<FPreferencesInfo>,Prefs);
	P_GET_STR_OPTX(Category,TEXT("Advanced Options"));
	P_FINISH;

	if( !PreferencesEnabled() )
		return;
	Prefs->Empty();
	UObject::GetPreferences( *Prefs, *Category, 0 );

	// Remove duplicates.
	if( Prefs->Num() )
	{
		// Sort in alphabetical order.
		appQsort(Prefs->GetData(),Prefs->Num(),sizeof(FPreferencesInfo),(QSORT_COMPARE)ComparePreferences);

		// Remove duplicates.
		for( INT i=0; i<Prefs->Num(); ++i )
		{
			for( INT j=(i+1); j<Prefs->Num(); ++j )
				if( (*Prefs)(i).Caption==(*Prefs)(j).Caption && (*Prefs)(i).Class==(*Prefs)(j).Class )
					Prefs->Remove(j--);
		}
	}

	unguard;
}

QSORT_RETURN CDECL CompareVariables( const FVariableInfo* A, const FVariableInfo* B )
{
	return appStricmp(*A->VarName,*B->VarName);
}
void UWebQuery::execGetVariables(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execGetVariables);
	P_GET_STR(ClassName);
	P_GET_STR(Category);
	P_GET_REFP(TArray<FVariableInfo>,VarList);
	P_FINISH;

	*(UBOOL*)Result = 0;
	if( !PreferencesEnabled() )
		return;
	UClass* C = LoadObject<UClass>(NULL,*ClassName,NULL,LOAD_NoWarn,NULL);
	if( !C )
		return;

	if( Category==TEXT("None") )
		Category.Empty();
	VarList->Empty();

	*(UBOOL*)Result = 1;
	BYTE* DefaultObj = &C->Defaults(0);
	for( TFieldIterator<UProperty> It(C); It; ++It )
	{
		UProperty* P = *It;
		if( !(P->PropertyFlags & (CPF_Config | CPF_GlobalConfig)) || ((P->PropertyFlags & CPF_GlobalConfig) && P->GetOuterUField()!=C) || (Category.Len() && Category!=*P->Category) )
			continue;
		FVariableInfo* VI = new(*VarList)FVariableInfo(P);

		INT Count=0;
		BYTE* DataOffset = DefaultObj + P->Offset;
		if( !VI->NumElements ) // Dynamic array.
		{
			FArray* A = (FArray*)DataOffset;
			Count = A->Num();
			VI->NumElements = -Count;
			DataOffset = (BYTE*)A->GetData();
			P = ((UArrayProperty*)P)->Inner;
		}
		else Count = VI->NumElements;

		if( Count )
		{
			VI->Value.AddZeroed(Count);
			for( INT i=0; i<Count; ++i )
			{
				BYTE* Dat = DataOffset+(P->ElementSize*i);
				P->ExportTextItem(VI->Value(i),Dat,Dat,0);
			}
		}
	}

	// Sort in alphabetical order.
	if( VarList->Num() )
		appQsort(VarList->GetData(),VarList->Num(),sizeof(FVariableInfo),(QSORT_COMPARE)CompareVariables);

	unguard;
}
void UWebQuery::execSetVariable(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execSetVariable);
	P_GET_STR(ClassName);
	P_GET_STR(VarName);
	P_GET_STR(VarValue);
	P_GET_UBOOL(bImmediate);
	P_FINISH;

	*(UBOOL*)Result = 0;
	if( !PreferencesEnabled() )
		return;

	UClass* Class = LoadObject<UClass>(NULL,*ClassName,NULL,LOAD_NoWarn,NULL);
	if( Class )
	{
		// Parse property name for array macros.
		BYTE ArOp=0;
		INT ArIndex = 0;
		{
			const TCHAR* S = *VarName;
			while( *S && *S!='-' && *S!='+' && *S!='|' )
				++S;
			const TCHAR* E = S;
			if( *S=='+' )
			{
				++S;
				if( *S=='+' )
					ArOp = 1; // Add
				else
				{
					ArOp = 2; // Insert
					ArIndex = appAtoi(S);
				}
			}
			else if( *S=='-' )
			{
				++S;
				ArOp = 3; // Delete
				ArIndex = appAtoi(S);
			}
			else if( *S=='|' ) // Set
			{
				++S;
				ArIndex = appAtoi(S);
			}
			VarName = VarName.Left(INT(E-(*VarName)));
		}

		UProperty* P = FindField<UProperty>(Class,*VarName);
		if( P && (P->PropertyFlags & (CPF_Config | CPF_GlobalConfig)) )
		{
			BYTE* DefObj = &Class->Defaults(0) + P->Offset;
			if( P->GetClass()==UArrayProperty::StaticClass() )
			{
				UProperty* In = ((UArrayProperty*)P)->Inner;
				FArray* AR = (FArray*)DefObj;
				BYTE* InDef = (BYTE*)AR->GetData();

				switch( ArOp )
				{
				case 0: // Set value.
					if( ArIndex<0 || ArIndex>=AR->Num() )
					{
						Stack.Logf(NAME_ScriptWarning,TEXT("SetVariable: Accessed array (%ls) out of bounds (%i/%i)"),P->GetName(),ArIndex,AR->Num());
						return;
					}
					In->ImportText(*VarValue,InDef+(In->ElementSize*ArIndex),0);
					break;
				case 1: // Add
					AR->AddZeroed(In->ElementSize);
					break;
				case 2: // Insert
					if( ArIndex<0 || ArIndex>=AR->Num() )
					{
						Stack.Logf(NAME_ScriptWarning,TEXT("SetVariable: Accessed array (%ls) out of bounds (%i/%i)"),P->GetName(),ArIndex,AR->Num());
						return;
					}
					AR->InsertZeroed(ArIndex,1,In->ElementSize);
					break;
				case 3: // Delete
					if( ArIndex<0 || ArIndex>=AR->Num() )
					{
						Stack.Logf(NAME_ScriptWarning,TEXT("SetVariable: Accessed array (%ls) out of bounds (%i/%i)"),P->GetName(),ArIndex,AR->Num());
						return;
					}
					if( In->PropertyFlags & CPF_NeedCtorLink )
					{
						BYTE* BaseOffset = InDef+(ArIndex*In->ElementSize);
						for( UProperty* D=In; D; D=D->ConstructorLinkNext )
							D->DestroyValue(BaseOffset+D->Offset);
					}
					AR->Remove(ArIndex,1,In->ElementSize);
					break;
				default:
					return;
				}
				ArIndex = 0;
			}
			else
			{
				if( ArOp )
				{
					Stack.Logf(NAME_ScriptWarning,TEXT("SetVariable: Can't do array operators on non-dynamic arrays (%ls)"),P->GetFullName());
					return;
				}
				if( ArIndex<0 || ArIndex>=P->ArrayDim )
				{
					Stack.Logf(NAME_ScriptWarning,TEXT("SetVariable: Accessed array (%ls) out of bounds (%i/%i)"),P->GetName(),ArIndex,P->ArrayDim);
					return;
				}
				P->ImportText(*VarValue,DefObj+(P->ElementSize*ArIndex),0);
			}
			if( bImmediate )
			{
				INT OffsetSize = P->ElementSize*ArIndex;
				DefObj+=OffsetSize;
				for( FObjectIterator It(Class); It; ++It )
				{
					BYTE* ThisObj = ((BYTE*)*It) + P->Offset + OffsetSize;
					P->CopySingleValue(ThisObj,DefObj);
					It->PostEditChange();
				}
			}
			Class->GetDefaultObject()->SaveConfig();
			*(UBOOL*)Result = 1;
		}
	}
	unguard;
}
