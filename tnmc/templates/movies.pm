package tnmc::templates::movies;

use strict;

use tnmc::cookie;
use tnmc::db;
use tnmc::user;
use tnmc::template;
use tnmc::movies::night;
use tnmc::movies::show;
use tnmc::movies::attend;
use tnmc::movies::movie;
use tnmc::movies::vote;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(show_movies);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub show_movies {
    &db_connect();

    my ($next_tuesday, $next_tuesday_string, $sql, $sth);

    $next_tuesday = &get_next_night();
    $sql = "SELECT DATE_FORMAT('$next_tuesday', 'W M D, Y')";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    ($next_tuesday_string) = $sth->fetchrow_array();
    $sth->finish();

    my $movies_heading = qq{
        Movie for $next_tuesday_string
    };
    &show_heading ($movies_heading);
    if (!&show_current_movie()){
    
        if ($USERID && $USERID{groupMovies}){
            &show_movies_home($USERID);
        }else{
            &show_movies_home();
        }
    }
}


##########################################################
sub show_movies_home
{
    my ($effectiveUserID) = @_;
    
    if ($effectiveUserID){
        &list_my_attendance($effectiveUserID);
        
        print qq{
            <table cellpadding="0" cellspacing="0" border="0">
                            <tr><th>&nbsp;N / ? / Y</th>
                                <th>&nbsp;&nbsp;#</th>
                    <th colspan="3" height="14">
                                    <form action="/movies/update_votes.cgi" method="post">
                                    <input type="hidden" name="userID" value="$effectiveUserID">
                                    &nbsp;now showing</th>
                    </tr>
        };
        show_movie_list_home($effectiveUserID,  "WHERE (statusShowing AND ( NOT (statusSeen OR 0)) AND NOT (statusBanned or 0) )");

        print qq{
                            <tr><td></td>
                                <td></td>
                    <td colspan="3">

                    <a href="/movies/index.cgi?sortOrder=order">
                    More movies....</a><br>
                    </td>
                    </tr>

            </table><p>
        };

        print qq{
            <font face="verdana">
            <b>Favorite Movie:</b><br>

        };

        &show_favorite_movie_select($effectiveUserID);

        print qq{
            <br>
            <input type="image" border="0" src="/template/update_votes_submit.gif" alt="Update Votes">
            </form>
        };

    }else{
        print qq{
            <table cellpadding="0" cellspacing="0" border="0">
                            <tr><th colspan="4" height="14">
                                    &nbsp;now showing</th></tr>
        };
        show_movie_list_home($effectiveUserID,  "WHERE (statusShowing AND ( NOT (statusSeen OR 0)) AND NOT (statusBanned or 0) )");
        print qq{\n    </table><p>\n};
    }
}


##########################################################
sub show_movie_list_home{

    my ($effectiveUserID, $whereClause, $junk) = @_;
    
    my (@movies, $anon, $movieID, %movieInfo);
    my ($boldNew, %vote_status_word, $vote, @list);
    
    &list_movies(\@list, $whereClause, 'ORDER BY title');
    foreach $movieID (@list){
        $anon = {};     ### create an anonymous hash.
        &get_movie_extended($movieID, $anon);
        $movieInfo{$movieID} = $anon;
    }
    
        @list = sort  {       $movieInfo{$b}->{order}
                        <=>     $movieInfo{$a}->{order}}
                        @list ;

    # my $cutoff = sqrt ($movieInfo{$list[0]}->{rank});
    my $cutoff = 0.5 * $movieInfo{$list[0]}->{rank};
    my $min_listing_size = 7;
    my $max_listing_size = 15;
    my $listing_index = 0;
    foreach $movieID (@list){
    
        $listing_index ++;

        if (  (! $movieInfo{$movieID}->{statusNew})
              && (  (  (  ($movieInfo{$movieID}->{rank} < $cutoff)
                      && ($listing_index > $min_listing_size))  )
                 || ($listing_index > $max_listing_size)
              )
                   ){
            next;
        }

        %vote_status_word = ('-1','', '0','', '1','', '2','');
        $vote = &get_vote($movieID, $effectiveUserID);
        $vote_status_word{$vote} = "CHECKED";
        
        print qq{
            <tr valign="top">
        };
        if ($effectiveUserID ){
            print qq{
                <td valign="top" nowrap><input type="radio" name="v$movieID" value="-1" $vote_status_word{'-1'}><input type="radio" name="v$movieID" value="0" $vote_status_word{'0'}><input type="radio" name="v$movieID" value="1" $vote_status_word{'1'} $vote_status_word{'2'}></td>
            };
        }
        print qq{
                <td align="right">&nbsp;&nbsp;$movieInfo{$movieID}->{rank}&nbsp;&nbsp;</td>
                <td valign="top">
        };
        if ($movieInfo{$movieID}->{statusNew}){ print qq{<b>}; }
        print qq{
                    <a href="
                    javascript:window.open(
                        '/movies/movie_view.cgi?movieID=$movieID',
                        'ViewMovie',
                        'resizable,height=350,width=450');
                        index.cgi
                    ">$movieInfo{$movieID}->{title}</a></td>
                <td>&nbsp;&nbsp;&nbsp;</td>
                <td>$movieInfo{$movieID}->{votesHTML}</td>

            </tr>
        };

    }
}

1;
