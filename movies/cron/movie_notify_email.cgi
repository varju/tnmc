#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::config;
use tnmc::db;
use tnmc::general_config;
use tnmc::mail::send;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::faction;

{
    #############
    ### Main logic
    
    my $dbh = &tnmc::db::db_connect();

    my @nights = &tnmc::movies::night::list_active_nights();

    # If there is no current movie, don't do anything.
    exit if (! scalar(@nights));
    
    # send the mail
    
    my $to_email = $tnmc_email;
    
    my $sql = "SELECT DATE_FORMAT(NOW(), '%W %M %D, %Y')";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($today_string) = $sth->fetchrow_array();
    my $today_string = &tnmc::util::date::format_date('full_date', &tnmc::util::date::now());
    $sth->finish();
    
    my %headers =
	( 'To' => $to_email,
	  'From' => "TNMC Website <$to_email>",
	  'Subject' => $today_string,
	  );

    my $body = '';
    foreach my $nightID (@nights) {
        my %night; &tnmc::movies::night::get_night($nightID, \%night);
        my $faction = &tnmc::movies::faction::get_faction($night{'factionID'});
        my %god; &tnmc::user::get_user($night{'godID'}, \%god) ;
        my %movie; &tnmc::movies::movie::get_movie($night{'movieID'}, \%movie);
        
        $sql = "SELECT DATE_FORMAT('$night{'date'}', '%W %M %D, %Y')";
        $sth = $dbh->prepare($sql);
        $sth->execute();
        my $date_string = &tnmc::util::date::format_date('full_date', $night{'date'});
        $sth->finish();
        
        $body .= "\n";
        $body .= "Faction $faction->{'name'} (picked by $god{'username'})\n";
        $body .= "------------------------------------------------------------\n";
        $body .= "$night{'winnerBlurb'}\n" if $night{'winnerBlurb'};
        $body .= "\n";
        $body .= "Movie:           $movie{'title'}\n";
        $body .= "Date:            $date_string\n" if ($date_string ne $today_string);
        $body .= "Cinema:          $night{'theatre'}\n";
        $body .= "Showtime:        $night{'showtime'}\n";
        $body .= "Meeting Time:    $night{'meetingTime'}\n";
        $body .= "Meeting Place:   $night{'meetingPlace'}\n";
        $body .= "\n";
    }
    
    &tnmc::mail::send::message_send(\%headers, $body);
    
    &tnmc::db::db_disconnect();
}

##########################################################
#### The end.
##########################################################
