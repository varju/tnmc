#!/usr/bin/perl

##################################################################
# Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::cgih

use tnnc::pics::pic;

#############
### Main logic

$cgih = &tnmc::cgi::get_cgih;
$picID = $cgih->param('picID');	

if ($picID){
    &del_pic($picID);
}

print "Location: index.cgi\n\n";
