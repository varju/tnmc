#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::pics::album;
use tnmc::cgi;

#############
### Main logic

&tnmc::template::header();

my $albumID = &tnmc::cgi::param('albumID');
&show_album_edit_admin_form($albumID);

&tnmc::template::footer();

#
# subs
#

sub show_album_edit_admin_form {
    my ($albumID) = @_;
    my %album;
    &tnmc::pics::album::get_album($albumID, \%album);

    print qq {

        <form action="pics/album_edit_admin_submit.cgi" method="post">
            <table>
    };

    foreach my $key (keys %album) {
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
