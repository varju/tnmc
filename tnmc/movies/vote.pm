package tnmc::movies::vote;

use strict;


#
# module configuration
#
BEGIN{
    use tnmc::db;
    use tnmc::movies::night;
    
    use Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    @EXPORT = qw(get_vote set_vote list_votes_by_movie get_movie_votes_hash);
    @EXPORT_OK = qw();
    
}

#
# module routines
#

sub get_vote{
        my ($movieID, $userID, $junk) = @_;
        my ($sql, $sth, @row, $vote);

        $userID = 0 unless $userID;
        $sql = "SELECT type from MovieVotes WHERE movieID = '$movieID' AND userID = '$userID'";
	my $dbh = &tnmc::db::db_connect();
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
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

	my $dbh = &tnmc::db::db_connect();

        $sql = "DELETE FROM MovieVotes WHERE movieID='$movieID' AND userID='$userID'";
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute;
        $sth->finish;

        $sql = "REPLACE INTO MovieVotes (movieID, userID, type) VALUES($movieID, $userID, $type)";
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
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
           AND MovieVotes.type != 0
         ORDER BY username";

	my $dbh = &tnmc::db::db_connect();
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
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

sub get_movie_votes_hash{
    my ($movieID, $userlist) = @_;
    
    my $userlist_sql = join (',', map {'?'} (@$userlist));
    my %votes;
    my $sql = "SELECT userID, type FROM MovieVotes WHERE movieID = ? AND userID IN ($userlist_sql)";
    
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute($movieID, @$userlist);
    while (my @row = $sth->fetchrow_array()){
        $votes{$row[0]} = $row[1]
    }
    $sth->finish;
    
    return \%votes;
}

1;
