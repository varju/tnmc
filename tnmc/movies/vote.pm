package tnmc::movies::vote;

use strict;

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(get_vote set_vote list_votes_by_movie);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub get_vote{
        my ($movieID, $userID, $junk) = @_;
        my ($sql, $sth, @row, $vote);

        $sql = "SELECT type from MovieVotes WHERE movieID = '$movieID' AND userID = '$userID'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        @row = $sth->fetchrow_array();
        $sth->finish;

        $vote = $row[0];

        if(!$vote){
                $vote = '0';
        }
        return $vote;
}

sub set_vote{
        my ($movieID, $userID, $type, $junk) = @_;
        my ($sql, $sth);

        $sql = "DELETE FROM MovieVotes WHERE movieID='$movieID' AND userID='$userID'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;

        $sql = "REPLACE INTO MovieVotes (movieID, userID, type) VALUES($movieID, $userID, $type)";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;
}

sub list_votes_by_movie{
        my ($votes_list_ref, $movieID, $stats_ref, $junk) = @_;
        my (@row, $sql, $sth, $return, $userID, %user, $vote);

        @$votes_list_ref = ();
        %$stats_ref = ();
        $return = '0';

        $sql = "SELECT Personal.userID, type 
          FROM MovieVotes, Personal
         WHERE movieID = '$movieID'
           AND MovieVotes.userID = Personal.userID
         ORDER BY username";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        while (@row = $sth->fetchrow_array()){
                ($userID, $vote, $junk) = @row;
                push (@$votes_list_ref, $userID);

                if ($vote > 0) { $return += $vote; }
                else           { $return += $vote / 2; }

        }
        $sth->finish;
        
        return $return;
}

1;
