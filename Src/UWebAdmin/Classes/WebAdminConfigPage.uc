//=============================================================================
// WebAdminConfigPage.
//=============================================================================
class WebAdminConfigPage expands WebPageContent;

var int EditLineNum;

Static function LoadUpClassContent( WebQuery Query )
{
	local int i;

	Query.SendTextLine("<div class='WebAdminConfigPage'>");
	Query.SendTextLine("<!-- WebServer config -->");
	Query.SendTextLine("<form action=\"Mod_"$Default.Class$"?"$Default.Class$"\" method=\"post\">");
	Query.SendTextLine("<table><tr><th colspan=\"2\">User name</th><th>User password</th><th>Privileges (0-255)</th></tr>");
	for( i=0; i<Array_Size(Query.Manager.Accounts); ++i )
	{
		if( Default.EditLineNum==i )
		{
			Query.SendTextLine("<tr><td><input class=\"textbox\" class=\"text\" name=\"USR\" size=\"25\" value=\""$Query.Manager.Accounts[i].Username$"\" maxlength=\"25\"></td>");
			Query.SendTextLine("<td><input class=\"textbox\" class=\"text\" name=\"PSW\" size=\"25\" value=\""$Query.Manager.Accounts[i].Password$"\" maxlength=\"25\"></td>");
			Query.SendTextLine("<td><input class=\"textbox\" class=\"text\" name=\"PRV\" size=\"3\" value=\""$Query.Manager.Accounts[i].Privileges$"\" maxlength=\"3\"></td>");
			Query.SendTextLine("<td><input class=\"button\" type=\"submit\" name=\"edi"$i$"\" value=\"Update\">");
			Query.SendTextLine("<input class=\"button\" type=\"submit\" name=\"edi"$i$"\" value=\"Delete\"></td></tr>");
		}
		else
		{
			Query.SendTextLine("<tr><td>"$Query.Manager.Accounts[i].Username$"</td><td>"$Query.Manager.Accounts[i].Password$"</td><td>"$Query.Manager.Accounts[i].Privileges$"</td>");
			Query.SendTextLine("<td><input class=\"button\" type=\"submit\" name=\"edi"$i$"\" value=\"Edit\"></td></tr>");
		}
	}
	Default.EditLineNum = -1;
	Query.SendTextLine("<tr><td></td><td></td><td></td><td><input class=\"button\" type=\"submit\" name=\"edit\" value=\"Add\"></td></tr>");
	Query.SendTextLine("</table></form><!-- End of WebServer config code-->");
	Query.SendTextLine("</div>");
}

Static function ProcessReceivedData( WebQuery Query )
{
	local int i;
	local string ID,V;

	if( Query.GetValue("edit")=="Add" )
	{
		i = Array_Size(Query.Manager.Accounts);
		Array_Size(Query.Manager.Accounts,i+1);
		Default.EditLineNum = i;
		return;
	}
	i = -1;

	// Figure out which button was pressed.
	foreach Query.AllValues(ID,V,"edi")
	{
		i = int(Mid(ID,3));

		switch( V )
		{
		case "Edit":
			Class'WebAdminConfigPage'.Default.EditLineNum = i;
			return;
		case "Update":
			break;
		case "Delete":
			Array_Remove(Query.Manager.Accounts,i);
			Query.Manager.SaveConfig();
			return;
		default:
			return; // Unknown button.
		}
	}
	if( i==-1 )
		return; // No button?

	Query.Manager.Accounts[i].Username = Query.GetValue("USR",Query.Manager.Accounts[i].Username);
	Query.Manager.Accounts[i].Password = Query.GetValue("PSW",Query.Manager.Accounts[i].Password);
	Query.Manager.Accounts[i].Privileges = int(Query.GetValue("PRV",string(Query.Manager.Accounts[i].Privileges)));
	Query.Manager.SaveConfig();
}

defaultproperties
{
	RequiredPrivileges=255
	EditLineNum=-1
}
