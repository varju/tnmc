#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.


use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::cgi;

use tnmc::pics::album;
use tnmc::pics::new;

#############
### Main logic

my $cgih = &tnmc::cgi::get_cgih();
my %album;
my $albumID = $cgih->param('albumID');

if (!$albumID){
    &header();
    print "Error: Invalid form data\n";
    &footer();
}
elsif(!&has_access_album_edit($albumID, undef, $USERID, undef)){
    &header();
    print "Error: Invalid user permissions\n";
    &footer();
}
else{
    &get_album($albumID, \%album);
    foreach my $key (keys %album){
     	my $val = $cgih->param($key);
        if (defined $val){
            $album{$key} = $val;
        }
    }
    &set_album(%album);
    
    print "Location: /pics/album_view.cgi?albumID=$albumID\n\n";
    
}