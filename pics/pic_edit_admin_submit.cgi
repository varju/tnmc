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

use tnmc::pics::pic;

#############
### Main logic
    
my %pic;

my @cols = &tnmc::db::db_get_cols_list('Pics');
foreach $key (@cols){
    $pic{$key} = &tnmc::cgi::param($key);
}

&set_pic(%pic);

print "Location: pic_edit.cgi?picID=$pic{picID}\n\n";





