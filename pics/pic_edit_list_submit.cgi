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

        my %PICS = ();

        # grab the cgi info into a big 2-d hash

        my @params = $cgih->param();
        foreach $param (@params){
            next unless($param =~ /^PIC(\d+)_(.*)$/);
            my $picID = $1;
            my $field = $2;
            
            if(! defined $PICS{$picID}){
                my %pic;
                &get_pic($picID, \%pic);
                $PICS{$picID} = \%pic;
            }
            $PICS{$picID}->{$field} = $cgih->param($param);
        }

        # save all the pics to the db
 
#        &header();
#        foreach $picID (keys(%PICS)){
#            print  %{$PICS{$picID}};
#            print "<p>";
#        }
#        &footer();

        # save all the pics to the db
        
        foreach $picID (keys(%PICS)){
            &set_pic( %{$PICS{$picID}} );
        }

        # goodbye 

	&db_disconnect();
        
        my $destination = $cgih->param(destination);
	print "Location: $destination\n\n";
}
