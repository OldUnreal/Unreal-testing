
#include "UWebAdminPrivate.h"

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) UWEBADMIN_API FName UWEBADMIN_##name=FName(TEXT(#name),FNAME_Intrinsic);
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION (cls, idx, name)
#include "UWebAdminClasses.h"
#undef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION

IMPLEMENT_PACKAGE(UWebAdmin);
IMPLEMENT_CLASS(UWebQuery);
IMPLEMENT_CLASS(UWebPageContent);
IMPLEMENT_CLASS(UWebObjectBase);

TCHAR SettingsText[]=TEXT("Settings");
TCHAR ConfigFileText[]=TEXT("..") PATH_SEPARATOR TEXT("WebServer") PATH_SEPARATOR TEXT("WebServer.ini");

void UWebQuery::execSettingsEnabled(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execSettingsEnabled);
	P_GET_BYTE(Type);
	P_FINISH;

	switch( Type )
	{
	case 0:
		*(UBOOL*)Result = FileUploadEnabled()!=0;
		break;
	case 1:
		*(UBOOL*)Result = PreferencesEnabled()!=0;
		break;
	default:
		*(UBOOL*)Result = 0;
	}
	unguard;
}

inline INT FindInString( BYTE* D, INT DataSize, const TCHAR* ToFind )
{
	INT CompSize=appStrlen(ToFind);
	DataSize-=CompSize;
	for( INT i=0; i<=DataSize; ++i )
	{
		INT j=0;
		for( ; j<CompSize; ++j )
			if( D[i+j]!=ToFind[j] )
				break;
		if( j==CompSize )
			return i;
	}
	return -1;
}
inline INT FindInStringRight( BYTE* D, INT DataSize, const TCHAR* ToFind )
{
	INT CompSize=appStrlen(ToFind);
	for( INT i=(DataSize-(CompSize+1)); i>=0; --i )
	{
		INT j=0;
		for( ; j<CompSize; ++j )
			if( D[i+j]!=ToFind[j] )
				break;
		if( j==CompSize )
			return i;
	}
	return -1;
}
inline void SkipWhiteSpaces( const TCHAR*& Str )
{
	while( *Str==' ' || *Str=='\t' )
		++Str;
}
inline TCHAR* GrabNextWord( const TCHAR*& Str )
{
	static TCHAR Result[256];
	SkipWhiteSpaces(Str);

	const TCHAR* Start = Str;
	while( *Str && *Str!=' ' && *Str!='\t' && *Str!='\r' && *Str!='\n' )
		++Str;
	CopyString(Result,Start,Min<INT>(255,(Str-Start)));
	while( *Str==' ' || *Str=='\t' )
		++Str;
	return Result;
}
inline BYTE GrabNextLine( TCHAR* Dest, const TCHAR*& Str )
{
	SkipWhiteSpaces(Str);
	if( !*Str )
		return 0;

	const TCHAR* Start = Str;
	while( *Str && *Str!='\r' && *Str!='\n' )
		++Str;
	CopyString(Dest,Start,(Str-Start));
	while( *Str=='\r' || *Str=='\n' )
		++Str;
	return 1;
}
inline BYTE ComparePartialStr( const TCHAR*& Str, const TCHAR* CmpStr )
{
	INT Num = appStrlen(CmpStr);
	if( appStrncmp(Str,CmpStr,Num)!=0 )
		return 0;
	Str+=Num;
	return 1;
}
inline void AppendStrSegment( FString& Dest, const TCHAR* Start, const TCHAR* End )
{
	if( Start!=End )
	{
		if( !*End )
			Dest+=Start;
		else
		{
			TCHAR* E = const_cast<TCHAR*>(End);
			TCHAR Old = *E;
			*E = 0;
			Dest+=Start;
			*E = Old;
		}
	}
}

FString Base64Decode( const TCHAR* Str )
{
	INT EncodeLen = appStrlen(Str);
	TCHAR *Decoded = (TCHAR *)appAlloca((EncodeLen / 4 * 3 + 1) * sizeof(TCHAR));
	check(Decoded);

	FString Base64Map(TEXT("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"));
	INT ch, i=0, j=0;
	TCHAR Junk[2] = {0, 0};
	TCHAR *Current = const_cast<TCHAR*>(Str);

    while((ch = (INT)(*Current++)) != '\0')
	{
		if (ch == '=')
			break;

		Junk[0] = ch;
		ch = Base64Map.InStr(Junk);
		if( ch == -1 )
			return FString();

		switch(i % 4)
		{
		case 0:
			Decoded[j] = ch << 2;
			break;
		case 1:
			Decoded[j++] |= ch >> 4;
			Decoded[j] = (ch & 0x0f) << 4;
			break;
		case 2:
			Decoded[j++] |= ch >>2;
			Decoded[j] = (ch & 0x03) << 6;
			break;
		case 3:
			Decoded[j++] |= ch;
			break;
		}
		i++;
	}

    /* clean up if we ended on a boundary */
    if (ch == '=')
	{
		switch(i % 4)
		{
		case 0:
		case 1:
			return FString();
		case 2:
			j++;
		case 3:
			Decoded[j++] = 0;
		}
	}
	Decoded[j] = '\0';
	return FString(Decoded);
}

inline BYTE FromHEX( const TCHAR C )
{
	if( C>='0' && C<='9' )
		return C-'0';
	else if( C>='A' && C<='F' )
		return C-'A'+10;
	else if( C>='a' && C<='f' )
		return C-'a'+10;
	return 0;
}
inline TCHAR ToHEX( const TCHAR C )
{
	INT i = (C & 15);
	if( i<10 )
		return '0'+i;
	return 'A'+i-10;
}

FString ParseFromHTMLCode( const TCHAR* In )
{
	INT Len = appStrlen(In);
	if( !Len )
		return FString();

	TCHAR* Result = new TCHAR[Len+1];

	TCHAR* S = Result;
	while( *In )
	{
		if( *In=='+' )
			*S = ' ';
		else if( *In=='%' )
		{
			++In;
			if( *In=='%' )
				*S = '%';
			else if( In[0] && In[1] )
			{
				*S = (FromHEX(In[0]) << 4) | FromHEX(In[1]);
				++In;
			}
			else break;
		}
		else if( *In=='&' )
		{
			if( appToUpper(In[1])=='L' && appToUpper(In[2])=='T' && appToUpper(In[3])==';' )
			{
				In+=4;
				*S = '<';
			}
			else if( appToUpper(In[1])=='G' && appToUpper(In[2])=='T' && appToUpper(In[3])==';' )
			{
				In+=4;
				*S = '>';
			}
			else *S = *In;
		}
		else *S = *In;
		++S;
		++In;
	}
	*S = 0;

	FString Res(Result);
	delete[] Result;

	return Res;
}
FString ParseToHTMLCode( const TCHAR* In )
{
	INT Len = appStrlen(In);
	if( !Len )
		return FString();

	FString Result;
	TArray<TCHAR>& Res = Result.GetCharArray();
	Res.Empty(Len+16);

	while( *In )
	{
		if( *In=='<' ) // &lt;
		{
			INT i = Res.Add(4);
			Res(i) = '&';
			Res(i+1) = 'l';
			Res(i+2) = 't';
			Res(i+3) = ';';
		}
		else if( *In=='>' ) // &gt;
		{
			INT i = Res.Add(4);
			Res(i) = '&';
			Res(i+1) = 'g';
			Res(i+2) = 't';
			Res(i+3) = ';';
		}
		else if( *In=='"' ) // &quot;
		{
			INT i = Res.Add(6);
			Res(i) = '&';
			Res(i+1) = 'q';
			Res(i+2) = 'u';
			Res(i+3) = 'o';
			Res(i+4) = 't';
			Res(i+5) = ';';
		}
		else if( *In!='\n' ) // Don't add new lines
			Res.AddItem(*In);
		++In;
	}
	Res.AddItem(0);
	return Result;
}

// Helper function.
inline TCHAR* AllocateToTCHAR(const BYTE* Input, INT l=-1)
{
	if (l == -1)
	{
		l = 0;
		while (Input[l] != 0)
			++l;
	}
	if (!l)
	{
		TCHAR* Res = new TCHAR[2];
		Res[0] = 0;
		return Res;
	}
	TCHAR* Result = new TCHAR[l + 1];
	Result[l] = 0;
	for (INT i = 0; i < l; ++i)
		Result[i] = Input[i];
	return Result;
}

void UWebQuery::execReceivedBytes(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execReceivedBytes);
	P_GET_REFP(BYTE,BytesData);
	P_GET_INT(Count);
	P_FINISH;

	if( !Count || Count>255 || bCompleted )
		return;

	if( !bHeaderReceived )
	{
		if( DataMap )
			DataMap->Empty();
		else DataMap = new TMultiMap<FString,FString>();

		// Add data.
		INT Offset = Data.Add(Count);
		appMemcpy(&Data(Offset),BytesData,Count);
		INT Found = FindInString(&Data(0),Data.Num(),TEXT("\r\n\r\n"));

		if( Found==-1 )
			return; // Keep looking.

		TCHAR* TAdd = AllocateToTCHAR(&Data(0),Found);
		Header = TAdd;
		delete[] TAdd;

		bHeaderReceived = 1;
		bReceivedBinary = 0;
		UpFileName.Empty();
		Data.Remove(0,Found+4);
		DataSize = 0;

		// Parse header.
		BYTE bFirstLine=1;
		const TCHAR* Str = *Header;
		TCHAR StrLine[512]; // need to add some overflow check!!!

		while( GrabNextLine(StrLine,Str) )
		{
			const TCHAR* L = StrLine;
			if( bFirstLine )
			{
				bFirstLine = 0;

				bIsPost = (appStricmp(GrabNextWord(L),TEXT("POST"))==0);
				URL = ParseFromHTMLCode(GrabNextWord(L));
			}
			else if( ComparePartialStr(L,TEXT("Authorization: Basic ")) )
			{
				FString Decode = Base64Decode(L);
				INT j = Decode.InStr(TEXT(":"));
				if( j==-1 )
					User = Decode;
				else
				{
					User = Decode.Left(j);
					Password = Decode.Mid(j+1);
				}
			}
			else if( ComparePartialStr(L,TEXT("Content-Length: ")) )
				DataSize = appAtoi(L);
		}
	}
	else
	{
		// Receiving other data feed.
		INT Offset = Data.Add(Count);
		appMemcpy(&Data(Offset),BytesData,Count);
	}

	if( bHeaderReceived && !bReceivedBinary && Data.Num()>0 )
	{
		// Check if received another header (file upload).
		INT Found = FindInString(&Data(0),Data.Num(),TEXT("\r\n\r\n"));

		if( Found>=0 )
		{
			bReceivedBinary = 1;

			TCHAR* TAdd = AllocateToTCHAR(&Data(0), Found);
			FString HeaderB = TAdd;
			delete[] TAdd;

			// Append to the original header.
			Header+=TEXT("\r\n\r\n");
			Header+=HeaderB;

			Data.Remove(0,Found+4);
			DataSize -= (Found+4);

			// Parse second header.
			const TCHAR* Str = *HeaderB;
			TCHAR StrLine[512];
			BYTE bFirst=1;

			while( GrabNextLine(StrLine,Str) )
			{
				const TCHAR* L = StrLine;
				if( bFirst )
				{
					bFirst = 0;
					FileTrailing = FString(TEXT("\r\n"))+L+TEXT("\r\n");
				}
				else if( ComparePartialStr(L,TEXT("Content-Length: ")) )
					DataSize = appAtoi(L);
				else if( ComparePartialStr(L,TEXT("Content-Disposition: ")) )
					Parse(L,TEXT("filename="),UpFileName);
			}
		}
	}
	if( bHeaderReceived && Data.Num()>=DataSize )
	{
		if( DataSize && !bReceivedBinary ) // Parse the posted data.
		{
			Data.AddZeroed(1);
			TCHAR* AllocedChar = AllocateToTCHAR(&Data(0));
			const TCHAR* Line = AllocedChar;
			Data.Pop();

			while( *Line )
			{
				const TCHAR* Start = Line;
				while( *Line && *Line!='=' )
					++Line;
				if( !*Line || Start==Line )
					break;

				FString Key,Value;
				AppendStrSegment(Key,Start,Line);
				++Line;

				Start = Line;
				while( *Line && *Line!='&' )
					++Line;

				AppendStrSegment(Value,Start,Line);
				DataMap->Add(*Key,*ParseFromHTMLCode(*Value));

				if( *Line )
					++Line;
			}
			delete[] AllocedChar;
		}
		else if( DataSize && bReceivedBinary ) // Remove trailing data.
		{
			INT Size = Min(300,Data.Num());
			INT Start = Data.Num()-Size;
			INT Offset = FindInStringRight(&Data(Start),Size,*FileTrailing);
			if( Offset>=0 )
			{
				Offset+=Start;
				Size = Data.Num()-Offset;
				Data.Remove(Offset,Size);
				DataSize-=Size;
			}
		}

		bCompleted = 1;
	}
	unguard;
}
void UWebQuery::execGetValue(FFrame& Stack, RESULT_DECL)
{
	guardSlow(UWebQuery::execGetValue);
	P_GET_STR(ValueID);
	P_GET_STR_OPTX(DefValue,TEXT(""));
	P_FINISH;

	FString* V = NULL;

	if( DataMap )
		V = DataMap->Find(*ValueID);

	if( V )
		*(FString*)Result = *V;
	else *(FString*)Result = DefValue;

	unguardSlow;
}
void UWebQuery::execAllValues(FFrame& Stack, RESULT_DECL)
{
	guardSlow(UWebQuery::execAllValues);
	P_GET_REFP(FString,ValueID);
	P_GET_REFP_OPTX(FString,Value);
	P_GET_STR_OPTX(Prefix,TEXT(""));
	P_FINISH;

	StartIterator;
	if( DataMap )
	{
		for( TMultiMap<FString,FString>::TIterator It(*DataMap); It; ++It )
		{
			if( Prefix.Len() && Prefix!=It.Key().Left(Prefix.Len()) )
				continue;
			*ValueID = It.Key();
			if( Value )
				*Value = It.Value();
			LoopIterator(return);
		}
	}
	EndIterator;

	unguardSlow;
}
void UWebQuery::execMultiValue(FFrame& Stack, RESULT_DECL)
{
	guardSlow(UWebQuery::execMultiValue);
	P_GET_STR(ValueID);
	P_GET_REFP(FString,Value);
	P_FINISH;

	StartIterator;
	if( DataMap )
	{
		TArray<FString> Results;
		DataMap->MultiFind(*ValueID,Results);

		for( INT i=0; i<Results.Num(); ++i )
		{
			*Value = Results(i);
			LoopIterator(return);
		}
	}
	EndIterator;

	unguardSlow;
}
void UWebQuery::execIncludeFile(FFrame& Stack, RESULT_DECL)
{
	FString ReadFile;
	guard(UWebQuery::execIncludeFile);
	P_GET_STR(InFile);
	ReadFile = InFile;
	P_FINISH;

	// Don't allow parent directories to be accessed.
	if( InFile.InStr(TEXT(".\\"))>=0 || InFile.InStr(TEXT("./"))>=0 || InFile.InStr(TEXT(":"))>=0 )
		return;

	InFile = FString(TEXT("..") PATH_SEPARATOR TEXT("WebServer")) * InFile;
	FArchive* Ar = GFileManager->CreateFileReader(*InFile);

	if( Ar )
	{
		INT Size = Ar->TotalSize();
		INT Offset = PendingSend.Add(Size);
		Ar->Serialize(&PendingSend(Offset),Size);
		delete Ar;
	}

	unguardf((TEXT("(%ls)"),*ReadFile));
}
void UWebQuery::execSendTextLine(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execSendTextLine);
	P_GET_STR(TextLine);
	P_GET_UBOOL_OPTX(bNewLine,1);
	P_FINISH;

	AddSendString(*TextLine,bNewLine==1);
	unguard;
}
void UWebQuery::execParseSafeText(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execSendParsedText);
	P_GET_STR(TextLine);
	P_FINISH;

	*(FString*)Result = ParseToHTMLCode(*TextLine);
	unguard;
}
void UWebQuery::execLocalizeWebPage(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execLocalizeWebPage);
	P_GET_STR(InSection);
	P_FINISH;

	LocalizeContents(*InSection);
	unguard;
}
void UWebQuery::execSendData(FFrame& Stack, RESULT_DECL)
{
	guard(UWebQuery::execSendData);
	P_FINISH;

	if( !bHeaderAtached )
		AddHeader();

	BYTE N=0;
	while( PendingSend.Num() && ++N<5 )
	{
		PendingCount = Min(PendingSend.Num(),255);
		appMemcpy(PendingData,&PendingSend(0),PendingCount);
		PendingSend.Remove(0,PendingCount);
		eventSendBunch();
	}

	*(UBOOL*)Result = (PendingSend.Num()==0);
	unguard;
}

void UWebQuery::LocalizeContents( const TCHAR* InSection, BYTE bFirstLevel )
{
	guard(UWebQuery::LocalizeContents);

	if( appStrstr(InSection,TEXT(":")) || appStrstr(InSection,TEXT("./")) || appStrstr(InSection,TEXT(".\\")) ) // Illegal characters.
		return;

	// Grab filename
	FString FindFilePath = FString::Printf(TEXT(".") PATH_SEPARATOR TEXT("WebServer") PATH_SEPARATOR TEXT("%ls.%ls"),InSection,GetLanguage());
	FString FileContents;
	if( !appLoadFileToString(FileContents,*FindFilePath) )
	{
		// Look with international.
		FString FindFilePath = FString::Printf(TEXT("..") PATH_SEPARATOR TEXT("WebServer") PATH_SEPARATOR TEXT("%ls.int"),InSection);
		if( !appLoadFileToString(FileContents,*FindFilePath) )
		{
			// Go with index file then.
			if( !appStricmp(InSection,TEXT("Index")) )
				AddSendString(*FString::Printf(TEXT("Missing locale file: %ls %ls"), InSection, *FindFilePath));
			else LocalizeContents(TEXT("Index"),bFirstLevel);
			return;
		}
	}
	TCHAR FileLine[1024];
	const TCHAR* S = *FileContents;
	while( GrabNextLine(FileLine,S) )
		AddSendStrCommands(FileLine);

	unguardf((TEXT("(%ls)"),InSection));
}
void UWebQuery::AddSendStrCommands( const TCHAR* Line )
{
	guard(UWebQuery::AddSendStrCommands);

	ALevelInfo* Level = ((AActor*)Connection)->Level;

	// Parse commands.
	FString Result;
	const TCHAR* Start = Line;
	while( 1 )
	{
		while( *Line && *Line!='/' && *Line!='%' )
			++Line;
		if( !*Line )
		{
			Result+=Start;
			break;
		}
		const TCHAR* End = Line;
		if( ComparePartialStr(Line,TEXT("/Cdate")) )
		{
			AppendStrSegment(Result,Start,End);
			Result+=FString::Printf(TEXT("%i.%i.%i"),Level->Day,Level->Month,Level->Year);
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("/Ctime")) )
		{
			AppendStrSegment(Result,Start,End);
			Result+=FString::Printf(TEXT("%i:%i"),Level->Hour,Level->Minute);
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("/MapT")) )
		{
			AppendStrSegment(Result,Start,End);
			Result+=ParseToHTMLCode(*Level->Title);
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("/MapF")) )
		{
			AppendStrSegment(Result,Start,End);
			Result+=Level->GetOuter()->GetName();
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("/WebVer")) )
		{
			AppendStrSegment(Result,Start,End);
			Result+=appFromAnsi(UCONST_WebAdminVersion);
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("/n")) )
		{
			AppendStrSegment(Result,Start,End);
			Result+=TEXT("\r\n");
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("%frd:")) )
		{
			AppendStrSegment(Result,Start,End);
			AddSendString(*Result); // Warning: Must flush buffer here!
			Result.Empty();

			Start = Line;
			while( *Line && *Line!='%' )
				++Line;
			FString NextSegment;
			AppendStrSegment(NextSegment,Start,Line);
			LocalizeContents(*NextSegment,0);

			++Line;
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("%Content:")) )
		{
			AppendStrSegment(Result,Start,End);
			AddSendString(*Result); // Warning: Must flush buffer here!
			Result.Empty();

			Start = Line;
			while( *Line && *Line!='%' )
				++Line;
			FString ClassName;
			AppendStrSegment(ClassName,Start,Line);
			UClass* CLS = LoadClass<UWebPageContent>(NULL,*ClassName,NULL,LOAD_None,NULL);

			if( !CLS )
				Result+=FString::Printf(TEXT("'Couldn't find forward class: %ls'"),*ClassName);
			else
			{
				UWebPageContent* UW = ((UWebPageContent*)CLS->GetDefaultObject());
				if( UW->eventAllowAccess(this) )
					UW->eventLoadUpClassContent(this);
				else UW->eventNotEnoughPrivileges(this);
			}

			++Line;
			Start = Line;
		}
		else if( ComparePartialStr(Line,TEXT("%MODBASED%")) )
		{
			AppendStrSegment(Result,Start,End);
			AddSendString(*Result); // Warning: Must flush buffer here!
			Result.Empty();

			UClass* CLS = LoadClass<UWebPageContent>(NULL,*MiscInfo,NULL,LOAD_None,NULL);

			if( !CLS )
				Result+=FString::Printf(TEXT("'Couldn't find forward class: %ls'"),*MiscInfo);
			else
			{
				UWebPageContent* UW = ((UWebPageContent*)CLS->GetDefaultObject());
				if( UW->eventAllowAccess(this) )
					UW->eventLoadUpClassContent(this);
				else UW->eventNotEnoughPrivileges(this);
			}

			Start = Line;
		}
		else ++Line; // Skip this char.
	}
	AddSendString(*Result,1);

	unguard;
}
void UWebQuery::AddSendString( const TCHAR* Str, BYTE bNewLine )
{
	guardSlow(UWebQuery::AddSendString);
	INT Num = appStrlen(Str);
	INT Offset = PendingSend.Add((bNewLine ? (Num+2) : Num));
	BYTE* S = &PendingSend(Offset);

	for( INT i=0; i<Num; ++i )
		S[i] = ToAnsi(Str[i]);

	if( bNewLine )
	{
		S[Num] = '\r';
		S[Num+1] = '\n';
	}
	unguardSlow;
}
void UWebQuery::AddHeader()
{
	guard(UWebQuery::AddHeader);

	// Temporarly move existing data off the sending list to allow header go in front.
	INT DataSize = PendingSend.Num();
	TArray<BYTE> DupeAr;
	PendingSend.ExchangeArray(&DupeAr);

	AddSendString(TEXT("HTTP/1.1 200 OK"),1);
	AddSendString(TEXT("Server: UnrealEngine UWeb Web Server"),1);
	AddSendString(*(FString(TEXT("Content-Type: ")) + ContentType),1);
	AddSendString(*FString::Printf(TEXT("Content-Length: %i"),DataSize),1);
	AddSendString(*FString::Printf(TEXT("cache-control: max-age=315360000, public, immutable")),1);
	AddSendString(TEXT("Connection: Close\r\n\r\n"));
	bHeaderAtached = 1;

	// Now move data to beginning of sending list.
	PendingSend.ExchangeArray(&DupeAr);
	PendingSend.Insert(0,DupeAr.Num());
	appMemcpy(&PendingSend(0),&DupeAr(0),DupeAr.Num());
	unguard;
}

void UWebQuery::Destroy()
{
	guard(UWebQuery::Destroy);
	if( DataMap )
	{
		delete DataMap;
		DataMap = NULL;
	}
	Super::Destroy();
	unguard;
}
