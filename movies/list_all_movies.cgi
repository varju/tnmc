#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca 
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::template;
use tnmc::movies::movie;
use tnmc::movies::show;


#############
### Main logic

&tnmc::template::header();

&tnmc::template::show_heading('List all Movies');
&show_admin_movie_list();

&tnmc::template::footer();

#
# subs
#


#########################################
sub show_admin_movie_list{
    my (@movies, %movie, $movieID, $key);

    &tnmc::movies::show::list_movies(\@movies, '', 'ORDER BY title');

    print qq{
                <table cellspacing="3" cellpadding="0" border="0">
        <tr>
        <td>
        <form method="post" action="movie_edit_admin.cgi">
        <input type="submit" value="Add">
        </form>
        </td>
    };

    foreach $key (keys %movie){
        if ($key eq 'description') {next;}
        print "<td><b>$key</b></td>";
    }
    print qq{</tr>\n};


        foreach $movieID (@movies){
                &get_movie($movieID, \%movie);
        print qq{
            <tr>
                <td nowrap>
                <a href="movie_edit_admin.cgi?movieID=$movieID">[Edit]</a> 
                <a href="movie_delete_submit.cgi?movieID=$movieID">[Del]</a>
                </td>
        };
        foreach $key (keys %movie){
            if ($key eq 'description') {next;}
            print "<td nowrap>$movie{$key}</td>";
        }
        print qq{</tr>\n};
        }

    print qq{
        <tr>
        <form method="post" action="movie_edit.cgi">
        <td><input type="submit" value="Add"></td>
        </form>
        </tr>
                </table>
        };
}
