#!/usr/bin/perl

##################################################################
#     Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
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


sub do_update_votes{

    my $tnmc_cgi = &tnmc::cgi::get_cgih();
    my $userID = $tnmc_cgi->param('userID');
    my @params =  $tnmc_cgi->param();
    
    my %vote_count = ();
    
    ### count the number of positive/negative/neutral votes.
    foreach $_ (@params){
        if (! /^v/) { next; }
        my $type = $tnmc_cgi->param($_);
        $vote_count{$type} += 1;
    }
    
    ### grumpy people who make too many negative votes get denied.
    $vote_count{'1'} = 0 unless defined $vote_count{'1'};
    $vote_count{'-1'} = 0 unless defined $vote_count{'-1'};
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
    
    ### Special votes
    foreach my $vote_type ('2', '3', '4'){
        my $movieID =  $tnmc_cgi->param("SpecialVote_$vote_type");
        if (defined ($movieID)){
            ### Kill old Special vote.
            my $sql = "UPDATE MovieVotes SET type = '1' WHERE type = '$vote_type' AND userID = '$userID'";
            my $sth = $dbh_tnmc->prepare($sql);
            $sth->execute();
            $sth->finish();
            
            ### Set new Special Vote.
            if ($movieID){ &set_vote($movieID, $userID, $vote_type);}
        }
    }
    
    print "Location: $ENV{HTTP_REFERER}\n\n";
    
}
