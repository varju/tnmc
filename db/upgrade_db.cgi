#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

# modules
require tnmc::db;
use tnmc::security::auth;
require tnmc::template;

#
# Main logic
#

&tnmc::template::header();

&upgrade_db_01();

&tnmc::template::footer();


#
# subs
#

sub upgrade_db_01{
    
    # create teams db (scott - mar 2003)
    
    my $dbh = &tnmc::db::db_connect();
    
    $dbh->do("CREATE TABLE Teams (
      teamID int(11) NOT NULL auto_increment,
      captainID int(11) NOT NULL default '1',
      name char(255) NOT NULL default '',
      description text NOT NULL default '',
      seasonStart datetime NOT NULL default '0000-00-00 00:00:00',
      seasonEnd datetime NOT NULL default '0000-00-00 00:00:00',
      seasonTimeSlot char(255) NOT NULL default 'no time slot',
      sport char(255) NOT NULL default 'none',
      leagueURL char(255) NOT NULL default '',
      leagueScheduleURL char(255) NOT NULL default '',
      questions text NOT NULL default '',
      htmlTemplate char(255) NOT NULL default '',
      PRIMARY KEY (teamID) 
      )
    ");
    
    $dbh->do("CREATE TABLE TeamRooster (
      teamID int(11) NOT NULL,
      userID int(11) NOT NULL,
      gender char(1) NOT NULL default '?',
      status char(16) NOT NULL default 'player',
      is_admin int(1) NOT NULL default '0',
      answers text NOT NULL default '',
      PRIMARY KEY (teamID, userID)
      )
    ");
    
    $dbh->do("CREATE TABLE TeamMeets (
      meetID int(11) NOT NULL auto_increment,
      teamID int(11) NOT NULL,
      date DATETIME NOT NULL default '0000-00-00 00:00:00',
      type char(16) NOT NULL default 'game',
      location char(255) NOT NULL default 'TBA',
      minFemale int(2) NOT NULL default '0',
      minMale int(2) NOT NULL default '0',
      minTotal int(2) NOT NULL default '0',
      PRIMARY KEY (meetID) 
      )
    ");
    
    $dbh->do("CREATE TABLE TeamMeetAttendance (
      meetID int(11) NOT NULL,
      userID int(11) NOT NULL,
      type char(255) NOT NULL default 'undef',
      timestamp timestamp NOT NULL,
      PRIMARY KEY (meetID, userID) 
      )
    ");
    
}
