#!/usr/bin/perl

##################################################################
#       Scott Thompson - (jun/2000)
##################################################################


###################################################################
sub set_trip{
    my (%trip, $junk) = @_;
    my ($sql, $sth, $return);
    
    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_set_row(\%trip, $dbh, 'Fieldtrips', 'tripID');
    
    ###############
    ### Return the Trip ID
    
    $sql = "SELECT tripID FROM Fieldtrips WHERE title = " . $dbh->quote($trip{title});
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    ($return) = $sth->fetchrow_array();
    $sth->finish;
    
    return $return;
}

###################################################################
sub get_trip{
    my ($tripID, $trip_ref, $junk) = @_;
    my ($condition);

    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_get_row($trip_ref, $dbh, 'Fieldtrips', "tripID = '$tripID'");
}

##########################################################
sub get_trip_extended{

    my ($tripID, $trip, $junk) = @_;

    ### Get basic info.
           &get_trip($tripID, $trip);

    $trip->{cow} = 'mooo';

}

###################################################################
sub del_trip{
    my ($tripID) = @_;
    my ($sql, $sth, $return);
    
    ###############
    ### Delete the movie
    
    $sql = "DELETE FROM Fieldtrips WHERE tripID = '$tripID'";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;
}


###################################################################
sub list_trips{
    my ($list_ref, $where, $order) = @_;

    @$list_ref = ();
    $sql = "SELECT tripID FROM Fieldtrips $where $order";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (my @row = $sth->fetchrow_array()){
        push @$list_ref, $row[0];
    }
    $sth->finish;
    return (scalar @$list_ref);
}


###################################################################
sub get_tripSurvey{
    my ($tripID, $userID, $survey_ref) = @_;
    my ($sql, $sth, @row);

    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_get_row($survey_ref, $dbh, 'FieldtripSurvey', "(tripID = '$tripID') AND (userID = '$userID')");
}

###################################################################
sub set_tripSurvey{
    my (%survey, $junk) = @_;
    my ($sql, $sth);

    $sql = "DELETE FROM FieldtripSurvey WHERE tripID='$survey{tripID}' AND userID='$survey{userID}'";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;

    &tnmc::db::db_set_row(\%survey, $dbh, 'FieldtripSurvey', 'userID');
}

# keepin perl happy...
return 1;
