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
use tnmc::movies::movie;
use tnmc::movies::night;

{
    #############
    ### Main logic
    
    &db_connect();

    my @nights = &list_active_nights();

    # If there is no current movie, don't do anything.
    exit if (! scalar(@nights));
    
    # send the mail
    
    my $to_email = $tnmc_email;
    $to_email = 'scottt@interchange.ubc.ca';
    
    my $sql = "SELECT DATE_FORMAT(NOW(), 'W M D, Y')";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($today_string) = $sth->fetchrow_array();
    $sth->finish();
    
    
    open(SENDMAIL, "| /usr/sbin/sendmail $to_email");
    print SENDMAIL "From: TNMC Website <scottt\@interchange.ubc.ca>\n";
    print SENDMAIL "To: tnmc-list <$to_email>\n";
    print SENDMAIL "Subject: $today_string\n";
    print SENDMAIL "\n";
    
    foreach my $nightID (@nights){
        
        my %night;
        &get_night($nightID, \%night);
        
        my %movie;
        &get_movie($night{'movieID'}, \%movie);
        
        $sql = "SELECT DATE_FORMAT('$night{'date'}', 'W M D, Y')";
        $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($date_string) = $sth->fetchrow_array();
        $sth->finish();
        
        print SENDMAIL "\n";
        print SENDMAIL "$night{'winnerBlurb'}\n";
        print SENDMAIL "\n";
        print SENDMAIL "Movie:           $movie{'title'}\n";
        print SENDMAIL "Date:            $date_string\n" if ($date_string ne $today_string);
        print SENDMAIL "Cinema:          $night{'theatre'}\n";
        print SENDMAIL "Showtime:        $night{'showtime'}\n";
        print SENDMAIL "Meeting Time:    $night{'meetingTime'}\n";
        print SENDMAIL "Meeting Place:   $night{'meetingPlace'}\n";
    }
    
    close SENDMAIL;
    
    
    &db_disconnect();

}

##########################################################
#### The end.
##########################################################




