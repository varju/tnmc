##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

require 5.004;
use strict;


###################################################################
sub new_nav_menu{

	my (%user);
	&get_user($USERID, \%user);

	### this test should probably be elsewhere.
	$HOMEPAGE =  ($ENV{REQUEST_URI} eq '/' || $ENV{REQUEST_URI} eq '/index.cgi');

	&show_menu_item( 0, "", "", "");
	&show_menu_item( 0, "http://tnmc.dhs.org/", "Home", "");
	&show_menu_item( 0, "", "", "");
	# &show_menu_item( 0, "/announcements/", "Announcements", "");
	# &show_menu_item( 0, "", "", "");

	if ($user{groupTrusted} >= 1){
            if (&show_menu_item( 0, "/people/", "People", "")){
		&show_menu_item( 1, "/people/list_all.cgi", "Everybody", "");
		&show_menu_item( 1, "/people/list_by_group.cgi?group=Movies&cutoff=10", "Movie&nbsp;Junkies", "");
            }
            &show_menu_item( 0, "", "", "");
        }
	
	if ($user{groupMovies} >= 1){
            if (&show_menu_item( 0, "/movies/", "Movies", "")){
		&show_menu_item( 1, "/movies/list_seen_movies.cgi", "Seen", "");
		&show_menu_item( 1, "/movies/list_showing_movies.cgi", "All&nbsp;Showing", "");
		&show_menu_item( 1, "/movies/attendance.cgi", "Attendance", "");
		&show_menu_item( 1, "/movies/movie_add.cgi", "Add&nbsp;a&nbsp;Movie", "");
		&show_menu_item( 1, "/movies/help.cgi", "Info", "");
		if ($user{groupMovies} >= 100){
			&show_menu_item( 1, "", "", "");
			&show_menu_item( 1, "/movies/admin.cgi", "Admin", "");
			&show_menu_item( 1, "/movies/list_all_movies.cgi", "All&nbsp;Movies", "");
			&show_menu_item( 1, "/movies/movies.cgi", "Testing", "");
		}
	    }
	    &show_menu_item( 0, "", "", "");
	}

	if ($user{groupTrusted} >= 1){
            &show_menu_item( 0, "/broadcast/", "Broadcast", "");
            &show_menu_item( 0, "", "", "");
        }

        if ($user{groupTrusted} >= 1){
            &show_menu_item( 0, "/fieldtrip/", "FieldTrips", "");
            &show_menu_item( 0, "", "", "");
        }
	if ($user{groupCabin}){
		&show_menu_item( 0, "/cabin/", "Cabin", "");
		&show_menu_item( 0, "", "", "");
	}

	if ($user{groupAdmin}){
		&show_menu_item( 0, "", "", "<hr noshade size='1'>");
		&show_menu_item( 0, "/bulletins/", "Bulletins", "");
		&show_menu_item( 0, "", "", "");
		if (&show_menu_item( 0, "/admin/", "Admin", "") || $USERID == 1){
			&show_menu_item( 1, "/admin/", "All users", "");
			&show_menu_item( 1, "/admin/groups.cgi", "Groups", "");
		}
		&show_menu_item( 0, "", "", "");
	}
	if ( ($USERID == 1) || ($USERID == 16) ){
		if (&show_menu_item( 0, "/user/log/", "Log", "") || $HOMEPAGE){
			&show_menu_item( 1, "/user/log/login.log", "Login", "");
			&show_menu_item( 1, "/user/log/splash.log", "Splash", "");
		}
		&show_menu_item( 0, "", "", "");
		&show_menu_item( 0, "/pics/", "Pics", "");
		&show_menu_item( 0, "", "", "");
	}
	if ($user{groupDev}){
		if (&show_menu_item( 0, "/development/", "Development", "")){
			&show_menu_item( 1, "/development/todo_list.cgi", "To&nbsp;do&nbsp;List", "");
			&show_menu_item( 1, "/development/suggestions.cgi", "Suggestions", "");
			&show_menu_item( 1, "/development/env.cgi", "Enviroment", "");
			&show_menu_item( 1,  "/development/db_explorer/database.cgi?tnmc", "db&nbsp;Explorer", "");
		}elsif ($USERID == 1){
			&show_menu_item( 1,  "/development/db_explorer/database.cgi?tnmc", "db&nbsp;Explorer", "");
		}
		&show_menu_item( 0, "", "", "");
	}
	
	&show_menu_item( 0, "", "", "<hr noshade size='1'>");
	&show_menu_item( 0, "/user/my_prefs.cgi", "Preferences", "");
	&show_menu_item( 0, "", "", "");
	&show_menu_item( 0, "/user/suggestion_add.cgi", "Ideas&nbsp;&amp;&nbsp;Bugs", "");
	&show_menu_item( 0, "", "", "");
	&show_menu_item( 0, "/user/logout.cgi", "Log Out", "");
	&show_menu_item( 0, "", "", "");
}

###################################################################
sub new_nav_login{

	my (@row, $userID, %user, $hits, $sth, $sql);

                print qq
                {
			<form action="/user/login.cgi" method="post">
		        <br><b>Login:</b><br>
                        <!-- <select onChange="form.submit();" name="userID"> -->
			<select name="userID">
                        <option value="0">Pick a user...
                        <option value="0">---------------
                };

                $sql = "SELECT userID, username FROM Personal WHERE groupDead != '1' ORDER BY username";
                $sth = $dbh_tnmc->prepare($sql);
                $sth->execute();
                
                while (@row = $sth->fetchrow_array()){
                        print qq{
                               <option value="$row[0]">$row[1]
                        };
                };
    
                print qq 
                {       </select><br>
			<b>Password:</b><br>
			<input type="password" name="password" size="10"><br>
                        <input type="image" border=0 src="http://tnmc.dhs.org/template/go_submit.gif" alt="Go"><br>
                        </form>
			<p>
			Hello there!<br>
			<br>
			Welcome to TNMC<I>Online</I>, <BR>a perl web-app and<BR>
			full-fledged sql <BR>database, dedicated<BR>
			solely to figuring <BR>out which movie to<BR>
			go to every week.
			<p>
			
			<u><b>Notice to Visitors:</b></u><br>
			If you are not a<br> regular user and<br>
			would like to browse<br> the site, please<br>
			login as user <b>demo</b>.<br>
			<br>
			<b><a href="/user/create_1.cgi">
			Create a New Account</a></b><br>
			<br>
			<p>
                };
			
}

###################################################################
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

#Make Perl happy
return 1;
