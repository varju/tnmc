#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::movies::vote;
use tnmc::template;

{
    #############
    ### Main logic
    
    &db_connect();
    
    cookie_get();

    my $userID = $tnmc_cgi->param('userID');
    my @params =  $tnmc_cgi->param();
    
    my %vote_count = {};
    my $favoriteMovie = $tnmc_cgi->param('favoriteMovie');
    
    ### count the number of positive/negative/neutral votes.
    foreach $_ (@params){
        if (! /^v/) { next; }
        my $type = $tnmc_cgi->param($_);
        $vote_count{$type} += 1;
    }
    
    ### Tell alex M to get rid of his silly username.
    if ($USERID{username} =~ 'bambi'){
        &header();
        print qq{
                <p><b>$USERID{username}?!?</b>
                <p>Go on and give yourself a normal username first, <i>then</i> you can vote.
                };
        &footer();
        exit(1);
    }
    
    ### grumpy people who make too many negative votes get denied.
    if ($vote_count{'1'} < $vote_count{'-1'}){
        &header();
        print qq{
            <p><b>Hey silly...</b>
                <p>What\'s the point in having $vote_count{-1} anti-votes
                and only $vote_count{1} real votes?
                <p>Why don\'t ya go back and try to be a little more positive next time \'round.
                };
        &footer();
        exit(1);
    }
    
    ### do the processing.
    foreach $_ (@params){
        if (! s/^v//) { next; }
        &set_vote($_, $userID, $tnmc_cgi->param("v$_"));
    }
    
    if ($favoriteMovie ne ''){
        ### Kill old Fave.
        my $sql = "UPDATE MovieVotes SET type = '1' WHERE type = '2' AND userID = '$userID'";
        my $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        $sth->finish();
        
        ### Set new Fave.
        if ($favoriteMovie){ &set_vote($favoriteMovie, $userID, '2');}
    }
    
    print "Location: $ENV{HTTP_REFERER}\n\n";
    
    &db_disconnect();
}
