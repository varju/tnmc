package tnmc::movies::show;

use strict;

use tnmc::db;
use tnmc::general_config;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(show_favorite_movie_select show_current_movie list_movies);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub show_favorite_movie_select{

	my ($effectiveUserID) = @_;
	my ($sql, $sth, @row, $favoriteMovie, $faveSel);

	print qq{
		<select name="favoriteMovie">
		<option value="0">none
		<option value="0">
	};

	$sql = "SELECT movieID
	         FROM MovieVotes
	        WHERE userID = '$effectiveUserID' AND type = '2'";
	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute;
	($favoriteMovie) = $sth->fetchrow_array();

	$sql = "SELECT movieID, title
	         FROM Movies
	        WHERE statusShowing = '1' AND statusSeen != '1' AND statusBanned != 1
		
	        ORDER BY title";

	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute;

	while (@row = $sth->fetchrow_array()){
	        if ($favoriteMovie == $row[0]){         $faveSel = 'selected';}
	        else{                                   $faveSel = '';}
	        print qq{               <option value="$row[0]" $faveSel>$row[1]\n};
	}

        $sth->finish;

	print qq{
		</select>
	};
}

sub show_current_movie
{
        
        my ($current_movie, $current_cinema, $current_showtime, $current_meeting_place, $current_meeting_time, $current_winner_blurb);
        my (%movie);
        
        my $sql = "SELECT DATE_ADD(NOW(), INTERVAL ((9 - DATE_FORMAT(NOW(), 'w') ) % 7) DAY)";
        my $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($next_tuesday) = $sth->fetchrow_array();
        $sth->finish();

        $sql = "SELECT DATE_FORMAT('$next_tuesday', 'W M D, Y')";
        $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($next_tuesday_string) = $sth->fetchrow_array();
        $sth->finish();
 
	$current_movie = get_general_config('movie_current_movie');
        $current_cinema = get_general_config('movie_current_cinema');
        $current_showtime = get_general_config('movie_current_showtime');
        $current_meeting_place = get_general_config('movie_current_meeting_place');
        $current_meeting_time = get_general_config('movie_current_meeting_time');
        $current_winner_blurb = get_general_config('movie_winner_blurb');

	$current_winner_blurb =~ s/\n/<br>/g;
	
        if (!$current_movie)
        {
	        print qq
                {
			<!-- no movie selected -->
                };
                return (0);
        }
	else{
	        %movie = {};
	        &get_movie($current_movie, \%movie);

                print qq{
		        <TABLE CELLSPACING=0 CELLPADDING=0 width="100">
                        <TR>
                        <TD colspan="2">$current_winner_blurb<p><br></TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Movie: </TD>
                        <TD nowrap><a href="javascript:window.open(
                                                '/movies/movie_view.cgi?movieID=$current_movie',
                                                'ViewMovie',
                                                'resizable,height=350,width=450');
                                                index.cgi
                                           ">$movie{'title'}</a></TD>
                        </TR>
                        
                        <TR>
                        <TD nowrap><B>Cinema: </TD>
                        <TD nowrap>$current_cinema</TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Showtime: </TD>
                        <TD nowrap>$current_showtime</TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Meeting time: </TD>
                        <TD nowrap>$current_meeting_time</TD>
                        </TR>

                        <TR>
                        <TD nowrap><B>Meeting place: </TD>
                        <TD nowrap>$current_meeting_place</TD>
                        </TR>

                        </TABLE>
                        <P>
                };
		return (1);
	}
}

sub list_movies{
	my ($movie_list_ref, $where_clause, $by_clause, $junk) = @_;
	my (@row, $sql, $sth);

	@$movie_list_ref = ();

	$sql = "SELECT movieID from Movies $where_clause $by_clause";
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	while (@row = $sth->fetchrow_array()){
		push (@$movie_list_ref, $row[0]);
	}
	$sth->finish;

	return $#$movie_list_ref;
}

1;
