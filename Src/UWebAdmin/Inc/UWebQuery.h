	UWebQuery(){}

	void LocalizeContents( const TCHAR* InSection, BYTE bFirstLevel=1 );
	void AddSendString( const TCHAR* Str, BYTE bNewLine=0 );
	void AddSendStrCommands( const TCHAR* Line );
	void AddHeader();
	void Destroy();
	BYTE FileUploadEnabled();
	BYTE PreferencesEnabled();