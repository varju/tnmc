#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::template::wml;
use tnmc::db;


#############
### Main logic

#&db_connect();

&wml_header();

## menu
my $splash_menu =
    qq{
        <p>
        <a href="/wap/movies/">Movies</a><br/>
        <a href="#sites">Other Sites</a><br/>
        <br/>
        <a href="/wap/test/">Testing</a><br/>
        </p>
        };

&show_card("menu", "TNMC Splash", $splash_menu);

## sites
my $sites_card =
    qq{
        <p>
        <a href="http://wap.fido.ca/NASApp/wportal/homepage.jsp#fidomenu">fido</a><br/>
        <a href="http://ca.wap.yahoo.com/">yahoo.ca</a><br/>
        </p>
        };

&show_card("sites", "Other Sites", $sites_card);


&wml_footer();

#&db_disconnect();

