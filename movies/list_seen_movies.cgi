#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::movies::movie;
use tnmc::movies::show;

#############
### Main logic

&tnmc::template::header();

&show_seen_movie_list();

&tnmc::template::footer();

#
# subs
#

#########################################
sub show_seen_movie_list {
    my (@movies, %movie, $movieID, $key, %USER, $isAdmin);

    &tnmc::movies::show::list_movies(\@movies, "WHERE statusSeen = '1'", 'ORDER BY date DESC, title');

    # it occurs to me that there's a proper way to do this... oh well, too late now.
    my $i = 0;
    foreach (@movies) {
        $i++;
    }

    &tnmc::template::show_heading("Movies that we've been to (well, at least $i of them)");

    &tnmc::user::get_user($USERID, \%USER);
    if ($USER{groupAdmin}) {
        $isAdmin = 'e';
    }

    print qq{
                <table cellspacing="0" cellpadding="1" border="0" width="100%">
    };

    my $year = '';
    foreach $movieID (@movies) {
        &tnmc::movies::movie::get_movie($movieID, \%movie);

        $movie{date} =~ /^(....)/;    # grab the year
        if ($year ne $1) {
            $year = $1;
            print qq{
                <tr><th colspan="5">$year</th></tr>
                };
        }
        my $sql = "SELECT DATE_FORMAT('$movie{date}', '%b %d')";
        my $dbh = &tnmc::db::db_connect();
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        my ($dateString) = $sth->fetchrow_array();
        $sth->finish();

        print qq{
            <tr>
                <td nowrap>$movie{title}</td>
                <td nowrap>$dateString</td>
                <td nowrap>&nbsp;<a href="movies/movie_view.cgi?movieID=$movieID" target="viewmovie">v</a>
                    <a href="movies/movie_edit_admin.cgi?movieID=$movieID">$isAdmin</a></td>
            </tr>
        };
    }

    print qq{
                </table>
        };
}
