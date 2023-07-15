#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::cgi;

use tnmc::pics::album;
use tnmc::pics::new;

#############
### Main logic

my %album;
my $albumID = &tnmc::cgi::param('albumID');

if (!$albumID) {
    &tnmc::template::header();
    print "Error: Invalid form data\n";
    &tnmc::template::footer();
}
elsif (!&tnmc::pics::new::auth_access_album_edit($albumID, undef)) {
    &tnmc::template::header();
    print "Error: Invalid user permissions\n";
    &tnmc::template::footer();
}
else {
    &tnmc::pics::album::get_album($albumID, \%album);
    foreach my $key (keys %album) {
        my $val = &tnmc::cgi::param($key);
        if (defined $val) {
            $album{$key} = $val;
        }
    }
    &tnmc::pics::album::set_album(%album);

    print "Location: /pics/album_view.cgi?albumID=$albumID\n\n";

}
