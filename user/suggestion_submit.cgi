#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::broadcast;
use tnmc::security::auth;
use tnmc::general_config;
use tnmc::db;
use tnmc::cgi;

{
    #############
    ### Main logic
    
    &db_connect();
    &tnmc::security::auth::authenticate();

    my $sql = "SELECT NOW()";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($time) = $sth->fetchrow_array();
    $sth->finish();
    
    my $tnmc_cgi = &tnmc::cgi::get_cgih();
    my $newSuggestion  =  $tnmc_cgi->param('suggestion');
    my $oldSuggestions =  &get_general_config("suggestions");

    my $SUGG = 
        "$USERID{username} $USERID - $time \n"
        . "====================================\n"
        . $newSuggestion . "\n\n"
        . $oldSuggestions;

    &set_general_config('suggestions', $SUGG);

    sms_admin_notify("IDEA: $newSuggestion");

    &db_disconnect();

    print "Location: /user/suggestion_add.cgi\n\n";
}
