package tnmc::movies::night;

use strict;
use POSIX qw(strftime);

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(set_night get_night get_next_night list_nights);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub set_night{
    my (%night, $junk) = @_;
    my ($sql, $sth, $return);
    
    &db_set_row(\%night, $dbh_tnmc, 'MovieNights', 'nightID');

    if (!$night{nightID}){
        $sql = "SELECT nightID FROM MovieNights WHERE date = " . $dbh_tnmc->quote($night{date});
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        ($return) = $sth->fetchrow_array();
        $sth->finish;
    }else{
        $return = $night{nightID};
    }
    return $return;
}

sub get_night{
    my ($nightID, $night_ref, $junk) = @_;
    my ($condition);

    $condition = "(nightID = '$nightID' OR date = '$nightID')";
    &db_get_row($night_ref, $dbh_tnmc, 'MovieNights', $condition);
}

sub get_next_night{
    my ($date, $junk) = @_;
    my ($sql, $sth, $return);

    if (!$date){
        $date = strftime("%Y%m%d", localtime());
    }

    ### BUG ALERT

    $sql = "SELECT DATE_FORMAT(date, '%Y%m%d') FROM MovieNights WHERE date >= '$date' ORDER BY date LIMIT 1";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    ($return) = $sth->fetchrow_array();
    
    return $return;
}

sub list_nights{
    my ($night_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$night_list_ref = ();

    $sql = "SELECT nightID from MovieNights $where_clause $by_clause";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$night_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar @$night_list_ref;
}


1;
