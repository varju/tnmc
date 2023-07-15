#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::movies::vote;
use tnmc::template;
use tnmc::cgi;

#############
### Main logic

&tnmc::security::auth::authenticate();
&do_update_votes();

#
# subs
#

sub do_update_votes {

    my $userID = &tnmc::cgi::param('userID');
    my @params = &tnmc::cgi::param();

    my %vote_count = ();

    ### count the number of positive/negative/neutral votes.
    foreach $_ (@params) {
        if (!/^v/) { next; }
        my $type = &tnmc::cgi::param($_);
        $vote_count{$type} += 1;
    }

    ### grumpy people who make too many negative votes get denied.
    $vote_count{'1'}  = 0 unless defined $vote_count{'1'};
    $vote_count{'-1'} = 0 unless defined $vote_count{'-1'};
    if ($vote_count{'1'} < $vote_count{'-1'}) {
        &tnmc::template::header();
        print qq{
            <p><b>Hey silly...</b>
                <p>What\'s the point in having $vote_count{-1} anti-votes
                and only $vote_count{1} real votes?
                <p>Why don\'t ya go back and try to be a little more positive next time \'round.
                };
        &tnmc::template::footer();
        exit(1);
    }

    ### do the processing.
    foreach $_ (@params) {
        if (!s/^v//) { next; }
        &tnmc::movies::vote::set_vote($_, $userID, &tnmc::cgi::param("v$_"));
    }

    ### Special votes
    foreach my $vote_type ('2', '3', '4') {
        my $movieID = &tnmc::cgi::param("SpecialVote_$vote_type");
        if (defined($movieID)) {
            ### Kill old Special vote.
            my $sql = "UPDATE MovieVotes SET type = '1' WHERE type = '$vote_type' AND userID = '$userID'";
            my $dbh = &tnmc::db::db_connect();
            my $sth = $dbh->prepare($sql);
            $sth->execute();
            $sth->finish();

            ### Set new Special Vote.
            if ($movieID) {
                &tnmc::movies::vote::set_vote($movieID, $userID, $vote_type);
            }
        }
    }

    print "Location: $ENV{HTTP_REFERER}\n\n";

}
