#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::db;
use tnmc::security::auth;
use tnmc::user;
use tnmc::cgi;

#############
### Main logic

&tnmc::db::db_connect();

# &tnmc::template::header();

my $group = &tnmc::cgi::param('group');

#
# fore every user that's been submited,
# see if the rank for this group has changed,
# if so, then save the new rank in the db.
#
foreach $key (&tnmc::cgi::param()) {

    next if ($key !~ s/^USER//);
    $newRank = &tnmc::cgi::param("USER$key");

    &tnmc::user::get_user($key, \%user);
    if ($newRank ne $user{"group$group"}) {
        $user{"group$group"} = $newRank;
        &tnmc::user::set_user(%user);
        ## debugging
        # print "$key : " . &tnmc::cgi::param("USER$key") ." $user{username} <br>";
    }
}

# &tnmc::template::footer();
&tnmc::db::db_disconnect();

print "Location: groups.cgi?groupID=$group\n\n";

