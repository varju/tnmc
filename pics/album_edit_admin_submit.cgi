#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.


use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::pics::album;
use tnmc::cgi;

{
    #############
    ### Main logic
    
    my $cgih = &tnmc::cgi::get_cgih();
    my %album;
    
    my @cols = &db_get_cols_list('PicAlbums');
    foreach my $key (@cols){
     	$album{$key} = $cgih->param($key);
    }
    &set_album(%album);
    
    print "Location: $ENV{HTTP_REFERER}\n\n";
}
