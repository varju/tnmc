#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@css.sfu.ca 
#	Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc/';
use tnmc;

require 'basic_testing_tools.pl';

	#############
	### Main logic
	
	&header();
	&db_connect();

                &show_heading('<a id="personal">Personal</a>');
                &show_edit_users_list();

 	&db_disconnect();
	&footer();

##########################################################
#### sub procedures.
##########################################################


#########################################
sub show_edit_users_list{
	my (@users, %user, $userID, $key);

	&list_users(\@users, '', 'ORDER BY username');
	get_user($users[0], \%user);

	print qq{
                <table cellspacing="3" cellpadding="0" border="0">
		<tr>	<td></td>
	};

	foreach $key (keys %user){
		print "<td><b>$key</b></td>";
	}
	print qq{</tr>\n};


        foreach $userID (@users){
                get_user($userID, \%user);
		print qq{
			<tr>
				<td nowrap>
				<a href="user_edit.cgi?userID=$userID">[Edit]</a> 
				<a href="user_delete_submit.cgi?userID=$userID">[Del]</a>
				</td>
		};
		foreach $key (keys %user){
			print "<td>$user{$key}</td>";
		}
		print qq{</tr>\n};
        }

	print qq{
		<tr>
		<form method="post" action="user_edit_submit.cgi">
		<td><input type="submit" value="Add:"></td>
	};

	foreach $key (keys %user){
		$len = length($user{$key}) + 1;
		print qq{
			<td><input type="text" name="$key" size="$len"></td>
		};
	}
 
	print qq{
		</form>
		</tr>
	};
        print qq{
                </table>
        };
}

#########################################
sub show_edit_movie_list{
	my (@movies, %movie, $movieID, $key);

	&list_movies(\@movies, '', 'ORDER BY title');
	&get_movie($movie[0], \%movie);

	print qq{
                <table cellspacing="3" cellpadding="0" border="0">
		<tr>
		<td>
		<form method="post" action="movie_edit.cgi">
		<input type="submit" value="Add">
		</form>
		</td>
	};

	foreach $key (keys %movie){
		if ($key eq 'description') {next;}
		print "<td><b>$key</b></td>";
	}
	print qq{</tr>\n};


        foreach $movieID (@movies){
                &get_movie($movieID, \%movie);
		print qq{
			<tr>
				<td nowrap>
				<a href="movie_edit.cgi?movieID=$movieID">[Edit]</a> 
				<a href="movie_delete_submit.cgi?movieID=$movieID">[Del]</a>
				</td>
		};
		foreach $key (keys %movie){
			if ($key eq 'description') {next;}
			print "<td>$movie{$key}</td>";
		}
		print qq{</tr>\n};
        }

	print qq{
		<tr>
		<form method="post" action="movie_edit.cgi">
		<td><input type="submit" value="Add"></td>
		</form>
		</tr>
                </table>
        };
}


##########################################################
#### The end.
##########################################################


