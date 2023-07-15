#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::broadcast;
use tnmc::security::auth;
use tnmc::general_config;
use tnmc::db;
use tnmc::cgi;

{
    #############
    ### Main logic

    my $dbh = &tnmc::db::db_connect();
    &tnmc::security::auth::authenticate();

    my $sql = "SELECT NOW()";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($time) = $sth->fetchrow_array();
    $sth->finish();

    my $newSuggestion  = &tnmc::cgi::param('suggestion');
    my $oldSuggestions = &tnmc::general_config::get_general_config("suggestions");

    my $SUGG =
        "$USERID{username} $USERID - $time \n"
      . "====================================\n"
      . $newSuggestion . "\n\n"
      . $oldSuggestions;

    &tnmc::general_config::set_general_config('suggestions', $SUGG);

    &tnmc::broadcast::sms_admin_notify("IDEA: $newSuggestion");

    &tnmc::db::db_disconnect();

    print "Location: /user/suggestion_add.cgi\n\n";
}
