#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::db;
use tnmc::general_config;
use tnmc::broadcast;
use tnmc::user;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::faction;

{
    #############
    ### Main logic

    &tnmc::db::db_connect();

    my @nights = &tnmc::movies::night::list_active_nights();

    # If there is no current movie, don't do anything.
    exit if (!scalar(@nights));

    foreach my $nightID (@nights) {

        my %night;
        &tnmc::movies::night::get_night($nightID, \%night);

        ### Put the message together
        my %movie;
        &tnmc::movies::movie::get_movie($night{'movieID'}, \%movie);

        my $message =
" $movie{'title'} ---------------- Meet at $night{'meetingPlace'} \@ $night{'meetingTime'}\. ---------------- $night{'theatre'} \@ $night{'showtime'}\.";

        ### List of people who want movie notification for this night
        my @users = &tnmc::movies::faction::list_faction_members($night{'factionID'}, "notify_phone = 1");

        ### Broadcast the message
        print "$nightID ---", join(" ", @users), "\n";
        &tnmc::broadcast::smsBroadcast(\@users, $message);
    }

    &tnmc::db::db_disconnect();
}

##########################################################
#### The end.
##########################################################
