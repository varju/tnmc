#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::vote;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

&tnmc::template::header();

&tnmc::template::show_heading("compare movies");

my $movieID = &tnmc::cgi::param('movieID');
my @movies;

foreach my $key (&tnmc::cgi::param()) {
    if ($key =~ /movie/i) {
        push(@movies, &tnmc::cgi::param($key));
    }
}

&show_movie_vote_comparison(@movies);

&tnmc::template::footer();

##################################################################
sub show_movie_vote_comparison {
    my (@movies) = @_;

    print qq{<table cellpadding="0" cellspacing="0">};

    foreach my $field ('title', 'theatres') {
        print qq{<tr><td></td>};
        foreach $movieID (@movies) {
            my %movie;
            &tnmc::movies::movie::get_movie($movieID, \%movie);
            print "<th> $movie{$field} </td>";
        }
        print "</tr>";
    }

    my @users;
    &tnmc::user::list_users(\@users, "", "ORDER BY userID");

    my %movie_vote_count = ();

    foreach my $userID (@users) {
        my %user;
        &tnmc::user::get_user($userID, \%user);

        my $vote_count = 0;
        foreach $movieID (@movies) {
            my $vote = &tnmc::movies::vote::get_vote($movieID, $userID);
            $vote_count++ if ($vote != 0);
        }
        next if (!$vote_count);

        print qq{
            <tr><td>$user{username}</td>
        };

        foreach $movieID (@movies) {
            my $vote = &tnmc::movies::vote::get_vote($movieID, $userID);
            if (($vote_count < scalar(@movies)) && ($vote > 0)) {
                print qq{<td align="center"><b>$vote</b></td>};
                $movie_vote_count{$movieID}++;
            }
            else {
                print qq{<td align="center">$vote</td>};
            }
        }
        print "</tr>";
    }

    print qq{<tr><td></td>};
    foreach $movieID (@movies) {
        my %movie;
        &tnmc::movies::movie::get_movie($movieID, \%movie);
        print qq{<td align="center"><hr> $movie_vote_count{$movieID} </td>};
    }
    print "</td></table>";
}
