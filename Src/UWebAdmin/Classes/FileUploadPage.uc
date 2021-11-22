//=============================================================================
// FileUploadPage.
//=============================================================================
class FileUploadPage expands ModPageContent;

var byte LastStatus;
var string LastFileName,StatusLines[3];

Static function LoadUpClassContent( WebQuery Query )
{
	Query.SendTextLine("<div class='FileUploadPage'>");
	if( !Query.SettingsEnabled(0) )
	{
		Query.SendTextLine("<h1>File uploading is disabled on this server.</h1><br />");
		Query.SendTextLine("To enable it, edit ../WebServer/WebServer.ini and change AllowUploads=True");
	}
	else
	{
		Query.SendTextLine("<h2>"$Default.PageName$"</h2><br /><a href=\"/ModLinksPage\" target=\"menumain\">Return</a> to last page.<br />");
		AddModBasedString(Query);
	}
    Query.SendTextLine("</div>");
}
Static function AddModBasedString( WebQuery Query )
{
	local string S,P;
	local byte i;
	local array<name> MN;

	Query.SendTextLine("<table>");
	Query.SendTextLine("<form action=\"Mod_"$Default.Class$"?"$Default.Class$"\" method=\"post\" enctype=\"multipart/form-data\">");
	Query.SendTextLine("<tr><td>Please specify a file, or a set of files (uncompressed or uz compressed)</td></tr>");
	Query.SendTextLine("<tr><td><input type=\"file\" name=\"datafile\" size=\"80\"></td>");
	Query.SendTextLine("<td><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Upload file\"></td></form></tr>");
	if( Default.LastStatus>0 )
	{
		S = ReplaceStr(Default.StatusLines[Default.LastStatus-1],"%ls",Default.LastFileName);
		Default.LastStatus = 0;
	}
	else S = "-";
	Query.SendTextLine("<tr><td><font color=\"red\">"$S$"</font></td></tr>");
	Query.SendTextLine("<tr><td>Uploaded files</td><td>Missing files</td><td>Move file</td></tr>");
	Query.SendTextLine("<form action=\"Mod_"$Default.Class$"?"$Default.Class$"\" method=\"post\">");

	foreach Query.UploadedFiles(S,MN)
	{
		P = "OK";
		for( i=0; i<Min(5,Array_Size(MN)); ++i )
		{
			if( i==0 )
				P = string(MN[i]);
			else P = P$", "$string(MN[i]);
		}
		Query.SendTextLine("<tr><td>"$S$"</td><td>"$P$"</td><td>");
		Query.SendTextLine("<input class=\"checkbox\" name=\"MOV\" value=\""$S$"\" type=\"checkbox\"></td></tr>");
	}

	Query.SendTextLine("<tr><td></td><td></td><td><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Submit\"></td></form></tr>");

	EndTable(Query);
}
Static function ProcessReceivedData( WebQuery Query )
{
	local string S,F;

	if( Query.GetValue("edit")=="Submit" )
	{
		foreach Query.MultiValue("MOV",S)
		{
			if( !Query.MovePackage(S) )
			{
				if( F=="" )
					F = S;
				else F = F$", "$S;
			}
		}
		if( F!="" )
		{
			Default.LastStatus = 3;
			Default.LastFileName = F;
		}
	}
	else
	{
		Default.LastFileName = Query.UpFileName;

		if( !Query.SaveFileUpload() )
			Default.LastStatus = 1;
		else Default.LastStatus = 2;
	}
}

defaultproperties
{
	bNoExtraInfo=true

	StatusLines(0)="File '%ls' failed to be written, or it is not a valid Unreal package."
	StatusLines(1)="File '%ls' was successfully uploaded."
	StatusLines(2)="Couldn't move: %ls"

	RequiredPrivileges=250
}
