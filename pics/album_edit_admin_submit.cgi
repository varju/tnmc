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

{
    #############
    ### Main logic
    
    my %album;
    
    my @cols = &db_get_cols_list('PicAlbums');
    foreach my $key (@cols){
     	$album{$key} = &tnmc::cgi::param($key);
    }
    &set_album(%album);
    
    print "Location: $ENV{HTTP_REFERER}\n\n";
}
