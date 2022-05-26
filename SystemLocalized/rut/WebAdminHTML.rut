// Feel free to edit this file, expand it or w/e.
// Just make sure you don't mess up your own administration interface.
// Functions/Keywords:
// /Cdate = Current date
// /Ctime = Current time
// /MapT = Current map title
// /MapF = Current map filename
// /WebVer = Current webadmin version
// /n = New line (Note that next Web line automatly includes new line code)
// %frd: <Redirect name>% = Forward code to some other int file or keep in this file but different part
// WARNING!!!! Redirecting from part A to part B, then in part B to part A will always crash (runaway loop)!
// %Content: <Webpage content classname>% = Add HTML codes from a UScript class
// Line type: "Alive/" will keep the connection refreshing page every 5 seconds.

// Web site content
[Index]
WebContentLen=6
Web0=<!-- Server WebAdministration code /WebVer written by .:..: (2008) -->
Web1=<HTML><HEAD><TITLE>WebAdmin server administration</TITLE></HEAD>
Web2=<frameset rows="80,*,50" cols="*" frameborder="No" framespacing="0" border="0">
Web3=<frame src="/MainLinksPage" name="menu" noresize frameborder="0" marginheight="0" scrolling="no" framespacing="0">
Web4=<frame src="/IndexX" name="menumain" scrolling="yes" frameborder="no" noresize framespacing="0" marginheight="0">
Web5=<frame src="/ServerConsoleLine" name="consoleline" scrolling="no" frameborder="no" noresize framespacing="0" marginheight="0">
Web6=</frameset>/n<noframes><body bgcolor="#FFFFFF">If you get that message your browser doesn't support frames.</body></ noframes>/n</html>

// The links page
[MainLinksPage]
WebContentLen=3
Web0=%frd:PageHeader%
Web1=<center><A href="/MapRestartPage" target="_parent">Restart map</A>, <A href="/MapSwitch" target="menumain">Switch map</A>, <A href="/IndexX" target="menumain">Current</A>, <A href="/BanListPage" target="menumain">Banlist</A>, <A href="/ServerConsole" target="menumain">Server console</A>, <A href="/Logout" target="menumain">Logout user</A><BR>
Web2=Config links: <A href="/GameDefaults" target="menumain">Main GameConfig</A>, <A href="/Mod_UWebAdmin.RepPageConfig" target="menumain">ServerInfo Config</A>, <A href="/MapLinksPage" target="menumain">Maplists</A>, <A href="/ModLinksPage" target="menumain">Mod Configures</A></center><BR>/n
Web3=%frd:PageEnding%

[IndexX]
WebContentLen=5
Web0=%frd:PageHeader%
Web1=Welcome %Content:UWebAdmin.GetClientUser% to server webadmin site<BR>Current players in this server:<BR>
Web2=<form method="post" action="Index?UWebAdmin.PlayersListDebug">
Web3=%Content:UWebAdmin.PlayersListDebug%</form>/n
Web4=<BR>Your IP: %Content:UWebAdmin.GetClientIP% has been logged on server.
Web5=%frd:PageEnding%

// Server console page
[ServerConsole]
WebContentLen=5
Web0=%frd:PageHeader%
Web1=<CENTER><TABLE BORDER=1 WIDTH="75%"><TR><TH>Message window (Playing on /MapF: /MapT):</TH></TR><TR><TD>/n
Web2=%Content:UWebAdmin.WebChatWindow%/n</TD></TR></table></CENTER>
Web3=<script>/nvar parselimit=4;/nfunction beginrefresh(){/nif(!document.images) return/nif (parselimit==1) window.location.replace("/ServerConsole")
Web4=else{/nparselimit-=1/nsetTimeout("beginrefresh()",1000)/n}/n}/nwindow.onload=beginrefresh/n</script>
Web5=%frd:PageEnding%

[ServerConsoleLine]
WebContentLen=4
Web0=%frd:PageHeader%
Web1=<form method="post" action="ServerConsoleLine?UWebAdmin.WebChatWindow">/n
Web2=<TABLE BORDER=0><TR><TH>Console Command: <input class="textbox" type="text" name="Cmd" size="56" value="Say " maxlength="80"></TH>
Web3=<TH><input class="button" type="submit" name="edit" value="Enter"></TH></TABLE>/n</form>
Web4=%frd:PageEnding%
// <- End of server console.

// Restart map
[MapRestartPage]
WebContentLen=1
Web0=%frd:PageHeader%
Web1=Restarting map, please wait.%Content:UWebAdmin.RestartMapCode%/n Please click <A href="/Index" target="_parent">here</A> once its done.</BODY></HTML>

// Switch map
[MapSwitchingPage]
WebContentLen=1
Web0=%frd:PageHeader%
Web1=Server is now switching map, please wait. Please click <A href="/Index" target="_parent">here</A> once its done.</BODY></HTML>

// Banlist page
[BanListPage]
WebContentLen=2
Web0=%frd:PageHeader%
Web1=<form method="post" action="BanListPage?UWebAdmin.BanListGen">/n   Banlist page, here you can unban banned players./n%Content:UWebAdmin.BanListGen%</form>/n
Web2=%frd:PageEnding%

// User logging out
[Logout]
WebContentLen=2
Web0=%frd:PageHeader%
Web1=<BR>You have successfully logged out from webadministration page.%Content:UWebAdmin.UserLogout%
Web2=%frd:PageEnding%

// Basic game configures (server packages/server actors/admin/game passwords).
[GameDefaults]
WebContentLen=3
Web0=%frd:PageHeader%
Web1=<form method="post" action="GameDefaults?UWebAdmin.GameConfigPage">/n%Content:UWebAdmin.GameConfigPage%</form><BR>/n
Web2=<form method="post" action="GameDefaults?UWebAdmin.NetConfigPage">/n%Content:UWebAdmin.NetConfigPage%</form>/n
Web3=%frd:PageEnding%

// Maplist Links page
[MapLinksPage]
WebContentLen=3
Web0=%frd:PageHeader%
Web1=<form method="post" action="MapLinksPage?UWebAdmin.MapListLinkPage">
Web2=<h2>Custom maplist configures:</h2>%Content:UWebAdmin.MapListLinkPage%<BR></form>
Web3=%frd:PageEnding%

// Mod Link page
[ModLinksPage]
WebContentLen=2
Web0=%frd:PageHeader%
Web1=<h2>Custom mod configures:</h2>%Content:UWebAdmin.ModLinkPage%<BR>
Web2=%frd:PageEnding%

// Mod based game configures (works using special hacks).
[ModConfigPage]
WebContentLen=2
Web0=%frd:PageHeader%<BR>
Web1=%MODBASED%<BR>
Web2=%frd:PageEnding%

// Maplist game configures (also works using special hacks).
[MapLConfigPage]
WebContentLen=2
Web0=%frd:PageHeader%<BR>
Web1=%Content:UWebAdmin.MapListPage%<BR>
Web2=%frd:PageEnding%

// Map switch page.
[MapSwitch]
WebContentLen=2
Web0=%frd:PageHeader%
Web1=<form method="post" action="MapSwitchingPage?UWebAdmin.MapSwitchPage">/n%Content:UWebAdmin.MapSwitchPage%</form><BR>/n
Web2=%frd:PageEnding%

// Global stuff
[PageHeader]
WebContentLen=0
Web0=<HTML><HEAD></HEAD><BODY bgcolor="#33CCCC">

// The "ending" part of this page.
[PageEnding]
WebContentLen=0
Web0=</BODY></HTML>
