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

use strict;


#############
### Main logic

&db_connect();
&header();

$cgih = new CGI;
$albumID = $cgih->param('albumID');
&show_album_edit_admin_form($albumID);

&footer();

&db_disconnect();

#
# subs
#

sub show_album_edit_admin_form{
    my ($albumID) = @_;
    my %album;	
    &get_album($albumID, \%album);
    
    print qq {
        
        <form action="album_edit_admin_submit.cgi" method="post">
            <table>
    };
    
    foreach $key (keys %album){
        print qq{	
            <tr><td><b>$key</td>
                <td><input type="text" name="$key" value="$album{$key}"></td>
                </tr>
	};
    }
    
    print qq{
        </table>
        <input type="submit" value="Submit">
        </form>
    }; 
    
}
