#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::template;
use tnmc::movies::movie;
use tnmc::cgi;

#############
### Main logic

&header();

my $cgih = &tnmc::cgi::get_cgih();
my $movieID = $cgih->param('movieID');
&show_movie_edit_form($movieID);

&footer();


#
# subs
#

sub show_movie_edit_form{    
    my ($movieID) = @_;

    my %movie;    
    &get_movie($movieID, \%movie);
    
    my ($checkboxSeen, $checkboxNotSeen);
    if ($movie{statusSeen}){
        $checkboxSeen = 'CHECKED';
    }else{
        $checkboxNotSeen = 'CHECKED';
    }
    
    my ($checkboxShowing, $checkboxNotShowing);
    if ($movie{statusShowing}){
        $checkboxShowing = 'CHECKED';
    }else{
        $checkboxNotShowing = 'CHECKED';
    }

    my ($checkboxNew, $checkboxNotNew);
    if ($movie{statusNew}){
        $checkboxNew = 'CHECKED';
    }else{
        $checkboxNotNew = 'CHECKED';
    }
    
    my ($checkboxBanned, $checkboxNotBanned);
    if ($movie{statusBanned}){
        $checkboxBanned = 'CHECKED';
    }else{
        $checkboxNotBanned = 'CHECKED';
    }
    
    print qq{
        <form action="movie_edit_submit.cgi" method="post">
        <input type="hidden" name="movieID" value="$movieID">
        <table>

        <tr valign=top>
            <td><b>Title</b></td>
            <td><input type="text" size="40" name="title" value="$movie{title}"></td>
        </tr>

        <tr valign=top>
            <td><b>Type</b></td>
            <td><input type="text" size="40" name="type" value="$movie{type}"></td>
        </tr>

        <tr valign=top>
            <td><b>Rating</b></td>
            <td><input type="text" size="4" name="rating" value="$movie{rating}"></td>
        </tr>

        <tr valign=top>
            <td><b>Description</b></td>
            <td><textarea cols="50" rows="4" wrap="virtual" name="description">$movie{description}</textarea></td>
        </tr>

        <tr valign=top>
            <td><b>Status</b></td>
            <td>
                <input type="radio" name="statusNew" value="1" $checkboxNew>Y
                <input type="radio" name="statusNew" value="0" $checkboxNotNew>N &nbsp; <b>New</b><br>
                <input type="radio" name="statusShowing" value="1" $checkboxShowing>Y
                <input type="radio" name="statusShowing" value="0" $checkboxNotShowing>N &nbsp; <b>Showing</b><br>
                <input type="radio" name="statusSeen" value="1" $checkboxSeen>Y
                <input type="radio" name="statusSeen" value="0" $checkboxNotSeen>N &nbsp <b>Seen</b><br>
                <input type="radio" name="statusBanned" value="1" $checkboxBanned>Y
                <input type="radio" name="statusBanned" value="0" $checkboxNotBanned>N &nbsp <b>Banned</b><br>
            </td>
        </tr>


        <tr valign=top>
            <td><b>MyBC ID</b></td>
            <td><input type="text" size="10" name="mybcID" value="$movie{mybcID}"></td>
        </tr>

        <tr valign=top>
            <td><b>IMDB ID</b></td>
            <td><input type="text" size="10" name="imdbID" value="$movie{imdbID}"></td>
        </tr>


        </table>
        <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
        </form>
    }; 
}
