#!/usr/bin/perl

##################################################################
#       Scott Thompson - (jun/2000)
##################################################################


###################################################################
sub set_trip{
	my (%trip, $junk) = @_;
	my ($sql, $sth, $return);
	
	&db_set_row(\%trip, $dbh_tnmc, 'Fieldtrips', 'tripID');
	
	###############
	### Return the Trip ID
	
	$sql = "SELECT tripID FROM Fieldtrips WHERE title = " . $dbh_tnmc->quote($trip{title});
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	($return) = $sth->fetchrow_array();
	$sth->finish;
	
	return $return;
}

###################################################################
sub get_trip{
	my ($tripID, $trip_ref, $junk) = @_;
	my ($condition);

	&db_get_row($trip_ref, $dbh_tnmc, 'Fieldtrips', "tripID = '$tripID'");
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
	$sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
	$sth->execute;
	$sth->finish;
}

###################################################################
sub get_tripSurvey{
        my ($tripID, $userID, $survey_ref) = @_;
        my ($sql, $sth, @row);

	&db_get_row($survey_ref, $dbh_tnmc, 'FieldtripSurvey', "(tripID = '$tripID') AND (userID = '$userID')");
}

###################################################################
sub set_tripSurvey{
        my (%survey, $junk) = @_;
        my ($sql, $sth);

        $sql = "DELETE FROM FieldtripSurvey WHERE tripID='$survey{tripID}' AND userID='$survey{userID}'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;

	&db_set_row(\%survey, $dbh_tnmc, 'FieldtripSurvey', 'userID');
}


# keepin perl happy...
return 1;
