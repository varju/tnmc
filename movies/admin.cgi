#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;
use tnmc::general_config;
use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::show;

{
    #############
    ### Main logic

    &db_connect();
    &header();

    if ($USERID){
        
        ## List of Future Nights
        &show_heading ("upcoming movie nights");
        my @NIGHTS = &list_future_nights();
        foreach my $nightID (@NIGHTS){
            my %night;
            &get_night ($nightID, \%night);
            print qq{
                <a href="night_edit.cgi?nightID=$nightID">$night{date}</a>
                ($nightID)<br>
            };
        }
        print qq{<br><p>};
        &show_heading ("administration");
        
        my $valid_theatres = &get_general_config("movie_valid_theatres");
        my $other_theatres = &get_general_config("movie_other_theatres");

        print qq{
            <form action="admin_submit.cgi" method="post">
            <table>

            <tr>
            <td><b>Valid Theatres</td>
            <td><textarea cols="19" rows="6" wrap="virtual" name="movie_valid_theatres">$valid_theatres</textarea></td>
            </tr>

            <tr>
            <td><b>Other Theatres</td>
            <td><textarea cols="19" rows="6" wrap="virtual" name="movie_other_theatres">$other_theatres</textarea></td>
            </tr>
            
            </table>

            <p>    
            <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
            </form>
        }; 

    }

    &footer();
    db_disconnect();
}
