package tnmc::menu;

use strict;

use AutoLoader 'AUTOLOAD';

use tnmc::config;
use tnmc::security::auth;
use tnmc::util::date;

#
# module configuration
#

#
# module routines
#


#sub new_nav_menu{
#    &show_menu();
#}
#
#sub show_menu{
#    my $menu = &get_menu();
#    &print_menu($menu);
#}

sub print_menu{
    my ($menu) = @_;
    
    foreach my $item (@$menu){
	my ($type, @params) = @$item;
	&tnmc::template::show_menu_item(@params);
    }
}

sub get_menu{

    ## params: type, indent, url, text, text2, submenu
    
    my @MENU;

    push @MENU, ["link",  0, "index.cgi", "Home", ""];
    push @MENU, ["space", 0, "", "", ""];
    push @MENU, ["link",  0, "people/", "People", "", 1];
    push @MENU, ["link",  1, "people/who.cgi", "Who's&nbsp;Online", ""];
    push @MENU, ["space", 0, "", "", ""];
    
    if ($USERID{groupMovies} >= 1){
	push @MENU, ["link",  0, "movies/", "Movies", "", 1];
        push @MENU, ["link",  1, "movies/factions.cgi", "Factions", ""];
        push @MENU, ["link",  1, "movies/list_seen_movies.cgi", "Seen", ""];
        push @MENU, ["link",  1, "movies/list_showing_movies.cgi", "All&nbsp;Showing", ""];
        push @MENU, ["link",  1, "movies/movie_add.cgi", "Add&nbsp;a&nbsp;Movie", ""];
	if ($USERID{groupMovies} >= 100){
	    push @MENU, ["space", 1, "", "", ""];
	    push @MENU, ["link",  1, "movies/admin.cgi", "Admin", ""];
	    push @MENU, ["link",  1, "movies/theatre_list.cgi", "Theatres", ""];
	    push @MENU, ["link",  1, "movies/list_all_movies.cgi", "All&nbsp;Movies", ""];
	    push @MENU, ["link",  1, "movies/night_list.cgi", "Nights", ""];
	}
	push @MENU, ["space", 0, "", "", ""];
    }
    
    push @MENU, ["link",  0, "teams/", "Teams", "", 1];
    push @MENU, ["link",  1, "teams/team_mod.cgi?ACTION=add", "Add Team", ""];
    push @MENU, ["space", 0, "", "", ""];
    
    push @MENU, ["link",  0, "news/", "News", "", 1];
    if ($USERID{groupAdmin}) {
	push @MENU, ["link",  1, "news/add_news.cgi", "Add News", ""];
    }
    push @MENU, ["space", 0, "", "", ""];
    
    push @MENU, ["space", 0, "", "", "<hr noshade size='1'>"];
    
    if ($USERID{groupDev} || $USERID{groupAdmin}){
	
        if ($USERID{groupAdmin}){
	    push @MENU, ["link",  0, "admin/", "Admin", "", 1];
	    push @MENU, ["link",  1, "admin/user_list.cgi", "All users", ""];
	    push @MENU, ["link",  1, "admin/groups.cgi", "Groups", ""];
	    push @MENU, ["link",  1, "admin/user_edit.cgi?userID=0", "Add User", ""];
	    push @MENU, ["link",  1, "admin/security/", "Security", ""];
	    push @MENU, ["space", 0, "", "", ""];
        }
        if ( $USERID == 1 || $USERID == 5 ){
	    push @MENU, ["link",  0, "user/log/", "Log", "", 1];
	    push @MENU, ["link",  1, "user/log/login.log", "Login", ""];
	    push @MENU, ["link",  1, "user/log/splash.log", "Splash", ""];
	    push @MENU, ["space", 0, "", "", ""];
        }
        if ($USERID{groupDev}){
	    push @MENU, ["link",  0, "development/", "Development", "", 1];
	    push @MENU, ["link",  1, "development/todo_list.cgi", "To&nbsp;do&nbsp;List", ""];
	    push @MENU, ["link",  1, "development/suggestions.cgi", "Suggestions", ""];
	    push @MENU, ["link",  1, "development/env.cgi", "Enviroment", ""];
	    push @MENU, ["link",  1, "admin/errorlog.cgi", "Error Log", ""];
	    push @MENU, ["link",  1, "development/code_index.cgi", "View Code", ""];
	    push @MENU, ["link",  1,  "development/db_explorer/database.cgi?tnmc", "db&nbsp;Explorer", ""];
	    push @MENU, ["space", 0, "", "", ""];
        }
	push @MENU, ["space", 0, "", "", "<hr noshade size='1'>"];
    }
    
    push @MENU, ["link",  0, "user/my_prefs.cgi", "Preferences", ""];
    push @MENU, ["space", 0, "", "", ""];
    push @MENU, ["link",  0, "user/suggestion_add.cgi", "Ideas&nbsp;&amp;&nbsp;Bugs", ""];
    push @MENU, ["space", 0, "", "", ""];
    push @MENU, ["link",  0, "user/logout.cgi", "Log Out", ""];
    push @MENU, ["space", 0, "", "", ""];
    
    my $date = &tnmc::util::date::now();
    $date = &tnmc::util::date::format_date('day_time', $date);
    push @MENU, ["link",  0, "time", "", "$date"];
    

    return \@MENU;
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
            <form action="$tnmc_url/user/login.cgi" method="post">
                <br><b>Fast Login:</b><br>
                        <!-- <select onChange="form.submit();" name="userID"> -->
            <select name="userID">
                        <option value="0">Pick a user...
                        <option value="0">---------------
                };

		if ($USERID_LAST_KNOWN){
			&tnmc::user::get_user($USERID_LAST_KNOWN, \%user);
			if (!$user{username} && $user{fullname}){
				print qq{<option value="$USERID_LAST_KNOWN" selected>$user{fullname}\n};
			}
		}

                my $dbh = &tnmc::db::db_connect();
                $sql = "SELECT userID, username FROM Personal WHERE groupDead != '1' && username != '' ORDER BY username";
                $sth = $dbh->prepare($sql);
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
	    <b><a href="user/entry_page.cgi">Entry Page:<br>
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
