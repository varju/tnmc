#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';

{
    #############
    ### Main logic
    
    $cgih = new CGI;
    
    &db_connect();
    
    my %pic;
    
    @cols = &db_get_cols_list('Pics');
    foreach $key (@cols){
        $pic{$key} = $cgih->param($key);
    }
    
    &set_pic(%pic);
    
    &db_disconnect();
    
    print "Location: pic_edit.cgi?picID=$pic{picID}\n\n";
}





