package tnmc::movies::movie;

use strict;

use tnmc::db;
use tnmc::cookie;
use tnmc::movies::night;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(set_movie get_movie get_movie_extended del_movie);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub set_movie{
    my (%movie, $junk) = @_;
    my ($sql, $sth, $return);
    
    &db_set_row(\%movie, $dbh_tnmc, 'Movies', 'movieID');
    
    ###############
    ### Return the Movie ID
    
    $sql = "SELECT movieID FROM Movies WHERE title = " . $dbh_tnmc->quote($movie{title});
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    ($return) = $sth->fetchrow_array();
    $sth->finish;
    
    return $return;
}

sub get_movie{
    my ($movieID, $movie_ref, $junk) = @_;
    my ($condition);

    $condition = "(movieID = '$movieID' OR title = '$movieID')";
    &db_get_row($movie_ref, $dbh_tnmc, 'Movies', $condition);
}

sub get_movie_extended{

    my ($movieID, $movie, $userID, $junk) = @_;

    ### Get basic info.
           &get_movie($movieID, $movie);


    my $thisTues = &get_next_night();
    my $nextTues = &get_next_night($thisTues);
    
    my ($sql, $sth, @row);

    $sql = "SELECT p.userID, p.username, v.type,
                       DAYOFYEAR(p.birthdate) - DAYOFYEAR($thisTues),
                       a.movieDefault, a.movie$thisTues, a.movie$nextTues
                 FROM           MovieVotes as v
                      LEFT JOIN Personal as p USING (userID)
                      LEFT JOIN MovieAttendance as a USING (userID)
        WHERE v.movieID = '$movieID'
        ORDER BY p.username ASC";

    $sth = $dbh_tnmc->prepare($sql);

    $sth->execute();

    my ($VuserID, $Vperson, $Vtype, $Ubday, $Udefault, $Uthis, $Unext);

    # find out who voted for the movie...
    while (@row = $sth->fetchrow_array()){


        $VuserID = $row[0];
        $Vperson = $row[1];
        $Vtype = $row[2];
        $Ubday = $row[3];
        $Udefault = $row[4];
        $Uthis = $row[5];
        $Unext = $row[6];

        if ( ($USERID != 38)
                     && ($Vperson eq 'demo') ){

            #
            # Do nothing
            #
        }
            
        elsif (    ($Uthis eq 'no')
            || ($Uthis eq '' and $Udefault eq 'no')    ){

            if (    ($Unext eq 'no')
                || ($Unext eq '' and $Udefault eq 'no')    ){

                if ($Vtype >= 1){
                    $movie->{votesHTML} .= "<font color='cccccc'>$Vperson</font> ";
                    $movie->{votesText} .= "[$Vperson] ";
                    $movie->{votesForLost} ++;
                }
            }
            elsif ($Vtype == 1){
                $movie->{votesHTML} .= "<font color='888888'>$Vperson</font> ";
                $movie->{votesText} .= "[$Vperson] ";
                $movie->{votesForAway} ++;
            }
            elsif ($Vtype == 2){
                $movie->{votesHTML} .= "<font color='888888'><b>$Vperson</b></font> ";
                $movie->{votesText} .= "[$Vperson!] ";
                $movie->{votesFaveAway} ++;
            }
        }
        elsif ($Vtype == 2){
            if ($Ubday ne '' && $Ubday <= 3 && $Ubday >= -3){
            $movie->{votesHTML} .= "<b><font style='background-color: #ff88ff'>&nbsp;$Vperson&nbsp;</font></b> ";
            $movie->{votesText} .= "***${Vperson}*** ";
            $movie->{votesFaveBday} ++;
            
            }else{
            $movie->{votesHTML} .= "<b>$Vperson</b> ";
            $movie->{votesText} .= "${Vperson}! ";
            $movie->{votesFave} ++;
            }
        }
        elsif ($Vtype == 1){
            $movie->{votesHTML} .= "$Vperson ";
            $movie->{votesText} .= "${Vperson} ";
            $movie->{votesFor} ++;
        }
        elsif ($Vtype == -1){
            $movie->{votesHTML} .= "<font color='ff2222'>$Vperson</font> ";
            $movie->{votesText} .= "(${Vperson}) ";
            $movie->{votesAgainst} ++;
        }

    }
    $sth->finish();


    ### Do the rank stuff
    $movie->{order} += 1.0 *  $movie->{votesFor};
    $movie->{order} += 1.5 *  $movie->{votesFave};
    $movie->{order} += 10  *  $movie->{votesFaveBday};
    $movie->{order} -= 0.5 *  $movie->{votesAgainst};
    $movie->{order} -= 0.4 *  $movie->{votesForAway};
    $movie->{order} -= 0.8 *  $movie->{votesFaveAway};

    $movie->{votesForTotal} = $movie->{votesFave}
                                + $movie->{votesFor}
                                + $movie->{votesFaveBday};
    $movie->{votesAway} = $movie->{votesFaveAway}
                            + $movie->{votesForAway}
                            + $movie->{votesForLost};

    # encourage movies with good ratings!
    # my $rating = $movie->{rating};
    # if ($rating != 0){
    #    $rating -= 2.5;
    #    if ($rating >= 1){
    #        $movie->{order} *=     1 + ( $rating / 5 );
    #    }else{
    #        $movie->{order} +=        $rating;
    #    }
    # }

    ### stoopid f---ed up rounding math.
    $movie->{rank} = $movie->{order};
    if ($movie->{rank} > 0)    {    $movie->{rank} += 0.5; }
    $movie->{rank} = int($movie->{rank});

}

sub del_movie{
    my ($movieID) = @_;
    my ($sql, $sth, $return);
    
    ###############
    ### Delete the movie
    
    $sql = "DELETE FROM Movies WHERE movieID = '$movieID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}

1;
