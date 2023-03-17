
#include "UWebAdminPrivate.h"
#include "UnLinker.h"
#include "ZLibCompress.h"

static TCHAR AllowUpName[]=TEXT("AllowUploads");

BYTE UWebQuery::FileUploadEnabled()
{
	static BYTE bCheckedEnabled = 2;
	if( bCheckedEnabled==2 )
	{
		UBOOL bRes=0;
		if( !GConfig->GetBool(SettingsText,AllowUpName,bRes,ConfigFileText) )
		{
			GConfig->SetBool(SettingsText,AllowUpName,0,ConfigFileText);
			GConfig->Flush(0,ConfigFileText);
		}
		bCheckedEnabled = (bRes!=0);
	}
	return (bCheckedEnabled && !GIsClient && GIsServer && Connection);
}

struct FBitArchive : public FArchive
{
public:
	TArray<BYTE>& BAr;
	INT Offset;

	FBitArchive( TArray<BYTE>& B, BYTE bSave=0 )
		: BAr(B), Offset(0)
	{
		ArIsLoading = (bSave==0);
		ArIsSaving = (bSave!=0);
		ArIsTrans = 1;
		ArMaxSerializeSize = 8000;
	}
	void Serialize( void* V, INT Length )
	{
		if( ArIsSaving )
		{
			if( Length )
			{
				if( Offset==BAr.Num() )
					BAr.Add(Length);
				else BAr.Insert(Offset,Length);
				appMemcpy(&BAr(Offset),V,Length);
				Offset+=Length;
			}
		}
		else
		{
			if( ArIsError )
			{
				appMemzero(V,Length);
				return;
			}
			if( (Offset+Length)>BAr.Num() )
			{
				appMemzero(V,Length);
				ArIsError = 1;
				return;
			}
			appMemcpy(V,&BAr(Offset),Length);
			Offset+=Length;
		}
	}
	INT Tell()
	{
		return Offset;
	}
	INT TotalSize()
	{
		return BAr.Num();
	}
	void Seek( INT InPos )
	{
		Offset = InPos;
	}
};
struct FObjNameSer : public FArchive
{
public:
	FArchive* Loader;
	TArray<FString>* NameMap;

	FObjNameSer( FArchive* Parent, TArray<FString>& NM, FPackageFileSummary& Sum )
		: Loader(Parent), NameMap(&NM)
	{
		ArIsLoading = 1;
		ArIsTrans = 1;
		ArMaxSerializeSize = 8000;
		ArVer = Sum.GetFileVersion();
	}
	void Serialize( void* V, INT Length )
	{
		Loader->Serialize(V,Length);
		ArIsError = Loader->IsError();
	}
	INT Tell()
	{
		return Loader->Tell();
	}
	INT TotalSize()
	{
		return Loader->TotalSize();
	}
	void Seek( INT InPos )
	{
		Loader->Seek(InPos);
	}
	FArchive& operator<<( FName& N )
	{
		N = NAME_None;
		if( !NameMap )
			return *this;
		NAME_INDEX NameIndex = 0;
		*Loader << AR_INDEX(NameIndex);

		if( !NameMap->IsValidIndex(NameIndex) )
			return *this;
		N = *(*NameMap)( NameIndex );
		return *this;
	}
};

struct FPackageVerifier
{
	TArray<FName> RefList;
	TArray<FName> Verified;
	TArray<FName> UnVerified;

	FPackageVerifier( const TCHAR* S )
	{
		const TCHAR* Start = S;
		while( *S && *S!='.' )
		{
			if( *S=='\\' || *S=='/' )
				Start = S+1;
			++S;
		}
		TCHAR N[128];
		CopyString(N,Start,Min<INT>(S-Start,127));
		Verified.AddItem(N);
	}
	inline void VerifyPackage( FName N )
	{
		RefList.RemoveItem(N);
		Verified.AddUniqueItem(N);
	}
	inline void AddNeededPackage( FName N )
	{
		if( Verified.FindItemIndex(N)==INDEX_NONE )
			RefList.AddUniqueItem(N);
	}
};
static BYTE VerifyPackageFile( FArchive& Ar, FPackageVerifier& Refs )
{
	// Quick verify first, to not make server crash from obvious file upload errors.
	guard(CheckTag);
	INT TestTag;
	Ar << TestTag;
	if( TestTag != PACKAGE_FILE_TAG )
		return 0;
	unguard;

	FPackageFileSummary Summary;
	guard(LoadSummary);
	Ar.Seek(0);
	Ar << Summary;
	unguard;

	// Gather name map.
	TArray<FString> NameMap;
	FObjNameSer NameLoader(&Ar,NameMap,Summary);
	guard(LoadNameMap);
	if( Summary.NameCount > 0 )
	{
		NameMap.Empty(Summary.NameCount);

		Ar.Seek( Summary.NameOffset );
		for( INT i=0; (i<Summary.NameCount && !Ar.IsError()); i++ )
		{
			// Read the name entry from the file.
			FNameEntry NameEntry;
			NameLoader << NameEntry;

			// Add it to the name table if it's needed in this context.
			new (NameMap) FString(NameEntry.Name);
		}
		if( Ar.IsError() )
			return 0;
	}
	unguard;

	// Check for package references.
	guard(LoadImports);
	if( Summary.ImportCount > 0 )
	{
		Ar.Seek( Summary.ImportOffset );
		for( INT i=0; (i<Summary.ImportCount && !Ar.IsError()); i++ )
		{
			FObjectImport Obj;
			NameLoader << Obj;
			if( Obj.PackageIndex==0 && Obj.ClassName==NAME_Package )
				Refs.AddNeededPackage(Obj.ObjectName);
		}
		if( Ar.IsError() )
			return 0;
	}
	unguard;

	return 1;
}
static void CheckReferencePackages( FPackageVerifier& Refs )
{
	FString ResultPck;
	while( Refs.RefList.Num() )
	{
		FName ThisName = Refs.RefList.Pop();
		Refs.VerifyPackage(ThisName);

		if( appFindPackageFile(*ThisName,NULL,ResultPck) )
		{
			FArchive* LoadAr = GFileManager->CreateFileReader(*ResultPck);
			if( LoadAr && VerifyPackageFile(*LoadAr,Refs) )
			{
				delete LoadAr;
				continue;
			}
			if( LoadAr )
				delete LoadAr;
		}
		Refs.UnVerified.AddUniqueItem(ThisName);
	}
}

static BYTE IsConfigLocalFile( const TCHAR* FileName )
{
	const TCHAR* S = FileName;
	while( *S )
	{
		if( *S=='.' )
			FileName = S+1;
		++S;
	}
	return (!appStricmp(FileName,TEXT("ini")) || !appStricmp(FileName,TEXT("int")) || !appStricmp(FileName,UObject::GetLanguage()));
}
void UWebQuery::execSaveFileUpload(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execSaveFileUpload);
	P_GET_STR_OPTX(FileName,UpFileName);
	P_FINISH;

	*(UBOOL*)Result = 0;
	if( !FileUploadEnabled() || FileName.InStr(TEXT("/"))>=0 || FileName.InStr(TEXT("\\"))>=0 )
		return;

	FBitArchive BitAr(Data);

	// Check compression.
	FZLibFileHeader ZL;
	BitAr << ZL;
	if( ZL.ValidateZLib(BitAr) ) // Must decompress first.
	{
		BitAr.Seek(0);

		TArray<BYTE> DeCompData;
		FBitArchive DeCompAr(DeCompData,1);
		if( ZLibDeCompressData(BitAr,DeCompAr)==ZCOM_Success )
		{
			Data.ExchangeArray(&DeCompData); // Fastest way to do it is to swap pointers.
			BitAr.Seek(0);
			Stack.Logf(NAME_Log,TEXT("SaveFileUpload: Decompressed '%ls' (%ls) %i kb -> %i kb."),*UpFileName,*ZL.OriginalFileName,(DeCompData.Num() >> 10),(Data.Num() >> 10));

			if( UpFileName.Right(3)==TEXT(".uz") ) // Remove compression extension.
				UpFileName = UpFileName.LeftChop(3);
		}
		else
		{
			Stack.Logf(NAME_Warning,TEXT("SaveFileUpload: %ls has invalid compression."),*UpFileName);
			return;
		}
	}
	else BitAr.Seek(0);

	// Verify Unreal package.
	FPackageVerifier RefList(*FileName);
	if( !IsConfigLocalFile(*FileName) && !VerifyPackageFile(BitAr,RefList) )
	{
		Stack.Logf(NAME_Warning,TEXT("SaveFileUpload: %ls is not an Unreal package."),*UpFileName);
		return;
	}

	GFileManager->MakeDirectory(TEXT("Uploads"));
	FArchive* A = GFileManager->CreateFileWriter(*(FString(TEXT("Uploads")) * FileName));

	if( A )
	{
		A->Serialize(&Data(0),Data.Num());
		delete A;
		Data.Empty();
		*(UBOOL*)Result = 1;
	}
	unguard;
}

void UWebQuery::execUploadedFiles(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execUploadedFiles);
	P_GET_REFP(FString,FileName);
	P_GET_REFP_OPTX(TArray<FName>,RefList);
	P_FINISH;

	StartIterator;
	if( FileUploadEnabled() )
	{
		FString BasePath = TEXT("Uploads") PATH_SEPARATOR;
		TArray<FString> PGList = GFileManager->FindFiles(*(BasePath + TEXT("*")),1,0);
		for( INT i=0; i<PGList.Num(); ++i )
		{
			FArchive* Ar = GFileManager->CreateFileReader(*(BasePath + PGList(i)));
			if( !Ar )
				continue;
			BYTE bIsConfig = IsConfigLocalFile(*PGList(i));
			FPackageVerifier VerList(*PGList(i));
			if( !bIsConfig )
			{
				if( !VerifyPackageFile(*Ar,VerList) )
				{
					delete Ar;
					continue;
				}
			}
			delete Ar;
			*FileName = PGList(i);
			if( RefList )
			{
				if( bIsConfig )
					RefList->Empty();
				else
				{
					CheckReferencePackages(VerList);
					*RefList = VerList.UnVerified;
				}
			}
			LoopIterator(return);
		}
	}
	EndIterator;

	unguard;
}
void UWebQuery::execMovePackage(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execMovePackage);
	P_GET_STR(FileName);
	P_FINISH;

	*(UBOOL*)Result = 0;
	FString SrcFile = FString(TEXT("Uploads")) * FileName;
	if( GFileManager->FileSize(*SrcFile)<=0 )
	{
		Stack.Logf(NAME_ScriptWarning,TEXT("MovePackage: File '%ls' not found."),*SrcFile);
		return;
	}

	if( IsConfigLocalFile(*FileName) )
	{
		if( GFileManager->Move(*FileName,*SrcFile,1,1) )
		{
			*(UBOOL*)Result = 1;
			GConfig->UnloadFile(*FileName); // Make sure config is re-read.
		}
		return;
	}

	FString Extension;
	INT iSplit = FileName.InStrRight(TEXT("."));
	if( iSplit==INDEX_NONE )
		Extension = TEXT(".u");
	else
	{
		Extension = FileName.Mid(iSplit);
		FileName = FileName.Left(iSplit);
	}
	INT BestMatch = 0;
	for( INT i=0; i<GSys->Paths.Num(); ++i )
	{
		if( GSys->Paths(i).Right(Extension.Len())==Extension )
		{
			BestMatch = i;
			break;
		}
	}

	FString TargetFile = GSys->Paths(BestMatch);
	iSplit = TargetFile.InStr(TEXT("*"));
	if( iSplit==INDEX_NONE )
	{
		Stack.Logf(NAME_ScriptWarning,TEXT("MovePackage: Invalid path: %ls"),*GSys->Paths(BestMatch));
		return;
	}

	TargetFile = TargetFile.Left(iSplit) + FileName + TargetFile.Mid(iSplit+1);
	if( GFileManager->Move(*TargetFile,*SrcFile,1,1) )
	{
		*(UBOOL*)Result = 1;
		//debugf(TEXT("Moved %ls -> %ls"),*SrcFile,*TargetFile);
	}
	else
	{
		UPackage* P = FindObject<UPackage>(NULL,*FileName,1);
		if( P )
		{
			// Deatach the package from linker memory.
			UObject::ResetLoaders(P,0,1);

			if( GFileManager->Move(*TargetFile,*SrcFile,1,1) )
			{
				*(UBOOL*)Result = 1;
				//debugf(TEXT("SecMoved %ls -> %ls"),*SrcFile,*TargetFile);
			}
		}
	}
	if( !*(UBOOL*)Result )
		Stack.Logf(NAME_ScriptWarning,TEXT("MovePackage: File couldn't be moved: %ls -> %ls"),*SrcFile,*TargetFile);
	unguard;
}
