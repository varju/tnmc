#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::template;
use tnmc::pics::new;
use tnmc::pics::search;

#############
### Main logic

&tnmc::template::header();

&show_search_index();

&tnmc::template::footer();

#
# subs
#

sub show_search_index {
    &show_search_form_text();
    &show_search_form_date_span();
    &show_search_form_my_unreleased();
    &show_search_form_untitled();
    &show_search_form_user();
}

sub show_search_form_text {

    my $url = "pics/search_thumb.cgi";

    &tnmc::template::show_heading("search by text");

    print qq{
        <table>
        <tr><td>
          <form method="get" action="$url">
          <input type="hidden" name="search" value="text">
          <input type="text" name="search_text" value="">
        </td>
        <td>
          <input type="radio" checked name="search_text_join" value="OR">any
          <input type="radio" name="search_text_join" value="AND">all
        </td>
        <td>
          <input type="submit" value="Search">
          </form>
        </td></tr>
        </table>
        
    };

}

sub show_search_form_date_span {

    my $url = "pics/search_thumb.cgi";

    &tnmc::template::show_heading("search by date");

    print qq{
        <table>
        <tr><td>
          <form method="get" action="$url">
          <p>
          <input type="hidden" name="search" value="date-span">
          <b>From:</b><br>
          <input type="text" name="search_from" value="0000-00-00 00:00">
        </td>
        <td>
          <b>To:</b><br>
          <input type="text" name="search_to" value="0000-00-00 00:00">
        </td>
        <td>
          <input type="submit" value="Search">
          </form>
        </td></tr>
        </table>
        
    };

}

sub show_search_form_my_unreleased {

    my $url = "pics/search_thumb.cgi";

    &tnmc::template::show_heading("search for my unreleased");

    print qq{
        <table>
        <tr><td>
          <form method="get" action="$url">
          <p>
          <input type="hidden" name="search" value="my_unreleased">
          <input type="submit" value="Search">
          </form>
        </td></tr>
        </table>
        
    };

}

sub show_search_form_untitled {

    my $url = "pics/search_thumb.cgi";

    &tnmc::template::show_heading("search for untitled pics");

    print qq{
        <table>
        <tr><td>
          <form method="get" action="$url">
          <p>
          <input type="hidden" name="search" value="untitled">
          <input type="submit" value="Search">
          </form>
        </td></tr>
        </table>
        
    };

}

sub show_search_form_user {

    require tnmc::user;

    my $url = "pics/search_thumb.cgi";

    &tnmc::template::show_heading("search by user");

    print qq{
        <table>
        <tr><td>
          <form method="get" action="$url">
          <input type="hidden" name="search" value="user">
          <select name="userID">
    };

    my $userlist = &tnmc::user::get_user_list("WHERE groupMovies >= '1'");
    foreach my $username (sort keys %$userlist) {
        print "<option value=\"$userlist->{$username}\">$username\n";
    }

    print qq{
          </select>
        </td>
        <td>
          <input type="submit" value="Search">
          </form>
        </td></tr>
        </table>

        };

}
