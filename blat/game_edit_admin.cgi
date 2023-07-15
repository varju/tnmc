#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib::db;
use lib::blat;
use lib::template;
use lib::cgi;

#############
### Main logic

&header();

my $gameid = $cgih->param('gameid');
my $hash   = &lib::blat::get_game($gameid);

print qq {
    <form action="game_edit_admin_submit.cgi" method="post">
    <table>
};

foreach $key (&lib::db::db_get_cols_list('Games')) {
    if ($key eq 'gameid') {
        print qq{<input type="hidden" name="$key" value="$hash->{$key}">};
        next;
    }
    print qq{
        <tr><td><b>$key</td>
        <td><input type="text" name="$key" value="$hash->{$key}"></td>
        </tr>
    };
}

print qq{
    </table>
    <input type="submit" value="Submit">
    </form>
};

&footer();
