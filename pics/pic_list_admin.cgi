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

	&db_connect();
	&header();

        my @PICS;

        &list_pics(\@PICS, "", "ORDER BY timestamp");

        &show_heading('view pics');
        print qq{
            <ol>
        };

        foreach $picID (@PICS){
       
            &get_album($picID, \%pic);
	  	
            if (!$pic{title}){
                $pic{title} = '(untitled)';
            }

            print qq {
                <li value="$picID">
                <a href="pic_view.cgi?picID=$picID">$pic{title}</a>
            };
        }
	
	print qq{
            </ol>
	}; 

	
	&footer();

	&db_disconnect();
}

