package tnmc::menu;

use strict;

#
# module configuration
#

BEGIN {
    use tnmc::config;
    use tnmc::security::auth;
    require tnmc::util::date;
    
    require Exporter;
    require AutoLoader;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter AutoLoader);
    @EXPORT = qw(new_nav_menu new_nav_login);
    @EXPORT_OK = qw();
    
}

#
# module routines
#


sub show_menu_item{
    my ($indent, $url, $name, $text) = @_;
    
    my $indent_text = '';
    while($indent--){
        $indent_text .= '&nbsp;&nbsp;&nbsp;';
    }
    if ($ENV{REQUEST_URI} =~ /^\Q$url\E/){
        print qq{\t\t$indent_text<b><a href="$url" class="menulink">$name</a>$text</b><br>\n};
        return 1;
    }
    else{
        print qq{\t\t$indent_text<a href="$url" class="menulink">$name</a>$text<br>\n};
        return 0;
    }
}

sub new_nav_menu{
    
    ### this test should probably be elsewhere.
    my $HOMEPAGE =  ($ENV{REQUEST_URI} eq '/' || $ENV{REQUEST_URI} eq '/index.cgi');
    
    &show_menu_item( 0, "", "", "");
    &show_menu_item( 0, "/", "Home", "");
    &show_menu_item( 0, "", "", "");

    if ($USERID{groupTrusted} >= 1){
        if (&show_menu_item( 0, "/people/", "People", "")){
            &show_menu_item( 1, "/people/who.cgi", "Who's online", "");
            &show_menu_item( 1, "/people/list_by_group.cgi?group=Admin&cutoff=1", "Site&nbsp;Admin", "");
            &show_menu_item( 1, "/people/list_by_group.cgi?group=Movies&cutoff=100", "Movie&nbsp;Admin", "");
        }elsif ($HOMEPAGE){
            &show_menu_item( 1, "/people/who.cgi", "Who's online", "");
        }            
        &show_menu_item( 0, "", "", "");
    }
    
    if ($USERID{groupMovies} >= 1){
        if (&show_menu_item( 0, "/movies/", "Movies", "")){
            &show_menu_item( 1, "/movies/list_seen_movies.cgi", "Seen", "");
            &show_menu_item( 1, "/movies/list_showing_movies.cgi", "All&nbsp;Showing", "");
            &show_menu_item( 1, "/movies/attendance.cgi", "Attendance", "");
            &show_menu_item( 1, "/movies/movie_add.cgi", "Add&nbsp;a&nbsp;Movie", "");
            &show_menu_item( 1, "/movies/help.cgi", "Info", "");
            if ($USERID{groupMovies} >= 100){
                &show_menu_item( 1, "", "", "");
                &show_menu_item( 1, "/movies/admin.cgi", "Admin", "");
                &show_menu_item( 1, "/movies/list_all_movies.cgi", "All&nbsp;Movies", "");
                &show_menu_item( 1, "/movies/night_list.cgi", "Nights", "");
            }
        }
        &show_menu_item( 0, "", "", "");
    }

    if ($USERID{groupTrusted} >= 1) {
        if (&show_menu_item( 0, "/news/", "News", "")) {
            if ($USERID{groupAdmin}) {
                &show_menu_item( 1, "/news/add_news.cgi", "Add News", "");
            }
        }
        &show_menu_item( 0, "", "", "");
    }
    
    if ($USERID{groupAdmin}) {
        if (&show_menu_item( 0, "/mail/", "Mail", "")) {
            &show_menu_item( 1, "/mail/compose_message.cgi", "Compose", "");
            &show_menu_item( 1, "/mail/show_prefs.cgi", "Prefs", "");
        }
        &show_menu_item( 0, "", "", "");
    }
    
    if ($USERID{groupTrusted} >= 1){
        &show_menu_item( 0, "/broadcast/", "Broadcast", "");
        &show_menu_item( 0, "", "", "");
    }
    
    if ($USERID{groupTrusted} >= 1){
        &show_menu_item( 0, "/fieldtrip/", "FieldTrips", "");
        &show_menu_item( 0, "", "", "");
    }
    
    if ($USERID{groupCabin}){
        &show_menu_item( 0, "/cabin/", "Cabin", "");
        &show_menu_item( 0, "", "", "");
    }
    
    if ($USERID{groupPics}){
        if (&show_menu_item( 0, "/pics/", "Pics", "")){
            &show_menu_item( 1, "/pics/album_index.cgi", "Albums", "");
            &show_menu_item( 1, "/pics/search_index.cgi", "Search", "");
            &show_menu_item( 0, "", "", "");
            &show_menu_item( 1, "/pics/upload_index.cgi", "Upload Pics", "");
            &show_menu_item( 1, "/pics/album_add.cgi", "Add Album", "");
        }
        &show_menu_item( 0, "", "", "");
        
    }
    
    ## Random-Pic
    if ($USERID{groupPics} && ! $USERID{'I_am_a_misanthrope'}){
        require tnmc::pics::random;
        &tnmc::pics::random::show_random_pic(); 
        &show_menu_item( 0, "", "", "");
        &show_menu_item( 0, "", "", "");
    }
    else{
        &show_menu_item( 0, "", "", "<hr noshade size='1'>");
    }
    
    if ($USERID{groupDev} || $USERID{groupAdmin}){
    
        if ($USERID{groupAdmin}){
            if (&show_menu_item( 0, "/admin/", "Admin", "")){
                &show_menu_item( 1, "/admin/user_list.cgi", "All users", "");
                &show_menu_item( 1, "/admin/groups.cgi", "Groups", "");
                &show_menu_item( 1, "/admin/user_edit.cgi?userID=0", "Add User", "");
                &show_menu_item( 1, "/admin/security/", "Security", "");
            }
            &show_menu_item( 0, "", "", "");
        }
        if ( $USERID == 1 || $USERID == 5 ){
            if (&show_menu_item( 0, "/user/log/", "Log", "") || $HOMEPAGE){
                &show_menu_item( 1, "/user/log/login.log", "Login", "");
                &show_menu_item( 1, "/user/log/splash.log", "Splash", "");
            }
            &show_menu_item( 0, "", "", "");
        }
        if ($USERID{groupDev}){
            if (&show_menu_item( 0, "/development/", "Development", "")){
                &show_menu_item( 1, "/development/todo_list.cgi", "To&nbsp;do&nbsp;List", "");
                &show_menu_item( 1, "/development/suggestions.cgi", "Suggestions", "");
                &show_menu_item( 1, "/development/env.cgi", "Enviroment", "");
                &show_menu_item( 1, "/admin/errorlog.cgi", "Error Log", "");
                &show_menu_item( 1, "/development/code_index.cgi", "View Code", "");
                &show_menu_item( 1,  "/development/db_explorer/database.cgi?tnmc", "db&nbsp;Explorer", "");
            }elsif ($USERID == 1){
                &show_menu_item( 1,  "/development/db_explorer/database.cgi?tnmc", "db&nbsp;Explorer", "");
            }
            &show_menu_item( 0, "", "", "");
            
        }
    
        &show_menu_item( 0, "br", "", "<hr noshade size='1'>");
    }
    
    &show_menu_item( 0, "/user/my_prefs.cgi", "Preferences", "");
    &show_menu_item( 0, "", "", "");
    &show_menu_item( 0, "/user/suggestion_add.cgi", "Ideas&nbsp;&amp;&nbsp;Bugs", "");
    &show_menu_item( 0, "", "", "");
    &show_menu_item( 0, "/user/logout.cgi", "Log Out", "");
    &show_menu_item( 0, "", "", "");
    
    my $date = &tnmc::util::date::now();
    $date = &tnmc::util::date::format_date('day_time', $date);
    &show_menu_item( 0, "time", "", "$date");
}

1;

__END__

#
# autoloaded module routines
#

sub new_nav_login{

    use tnmc::db;
    use tnmc::user;
    
    my (@row, $userID, %user, $hits, $sth, $sql);

                print qq
                {
            <form action="/user/login.cgi" method="post">
                <br><b>Fast Login:</b><br>
                        <!-- <select onChange="form.submit();" name="userID"> -->
            <select name="userID">
                        <option value="0">Pick a user...
                        <option value="0">---------------
                };

		if ($USERID_LAST_KNOWN){
			&get_user($USERID_LAST_KNOWN, \%user);
			if (!$user{username} && $user{fullname}){
				print qq{<option value="$USERID_LAST_KNOWN" selected>$user{fullname}\n};
			}
		}

                $sql = "SELECT userID, username FROM Personal WHERE groupDead != '1' && username != '' ORDER BY username";
                $sth = $dbh_tnmc->prepare($sql);
                $sth->execute();
                
    while (@row = $sth->fetchrow_array()){
        if ($row[0] eq $USERID_LAST_KNOWN){
            print qq{
                                   <option value="$row[0]" selected>$row[1]
                                   };
        }else{
            print qq{
                                   <option value="$row[0]">$row[1]
                                   };
        }
    }
    $sth->finish();

                print qq 
                {       </select><br>
            <b>Password:</b><br>
            <input type="password" name="password" size="10"><br>
                        <input type="image" border=0 src="/template/go_submit.gif" alt="Go"><br>
                        </form>
            <p>
	    <b><a href="/user/entry_page.cgi">Entry Page:<br>
                <li>Visitors<li>New Users<li>Enhanced Login<li>Lost Passwords</a></b>
	    <p>
            Hello there!<br>
            <br>
            Welcome to TNMC<I>Online</I>, <BR>a perl web-app and<BR>
            full-fledged sql <BR>database, dedicated<BR>
            solely to figuring <BR>out which movie to<BR>
            go to every week.
            <p>
            <br>
                };
            
}

1;
