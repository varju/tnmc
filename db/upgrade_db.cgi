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

&upgrade_db_20221219();

&tnmc::template::footer();

#
# subs
#

sub upgrade_db_20221219 {
    my $dbh = &tnmc::db::db_connect();

    $dbh->do("UPDATE MovieTheatres SET cineplexID=NULL WHERE theatreID = 1;");  #cn imax
    $dbh->do("UPDATE MovieTheatres SET cineplexID=1149 WHERE theatreID = 4;");  # 5th ave
    $dbh->do("UPDATE MovieTheatres SET cineplexID=1147 WHERE theatreID = 6;");  # tinseltown
    $dbh->do("UPDATE MovieTheatres SET cineplexID=1422 WHERE theatreID = 17;");  # scotiabank
}

sub upgrade_db_20161123 {
    my $dbh = &tnmc::db::db_connect();

    $dbh->do(
        "ALTER TABLE MovieTheatres
      MODIFY cineplexID varchar(255)
    "
    );
    $dbh->do(
        "ALTER TABLE Movies
      MODIFY cineplexID varchar(255)
    "
    );
}

sub upgrade_db_20161115 {
    my $dbh = &tnmc::db::db_connect();

    $dbh->do(
        "ALTER TABLE MovieTheatres
      ADD COLUMN cineplexID varchar(32)
    "
    );
    $dbh->do(
        "ALTER TABLE Movies
      ADD COLUMN cineplexID varchar(32)
    "
    );
}

sub upgrade_db_20100620 {
    my $dbh = &tnmc::db::db_connect();

    $dbh->do(
        "ALTER TABLE MovieTheatres
      CHANGE COLUMN cinemaclockid cinemaclockID varchar(32)
    "
    );
    $dbh->do(
        "ALTER TABLE MovieTheatres
      ADD COLUMN googleID varchar(32)
    "
    );
    $dbh->do(
        "ALTER TABLE Movies
      ADD COLUMN googleID varchar(32)
    "
    );
}

sub upgrade_db_03 {

    my $dbh = &tnmc::db::db_connect();

    $dbh->do(
        "ALTER TABLE Personal
      ADD forwardWebMessages int(1) NOT NULL default '0'
    "
    );
}

sub upgrade_db_02 {

    # scott - oct 2003
    #
    # add META field
    # change movies for filmcan
    #

    my $dbh = &tnmc::db::db_connect();

    $dbh->do(
        "ALTER TABLE Personal
      ADD META text
    "
    );

    $dbh->do(
        "ALTER TABLE Movies
      ADD filmcanid char(32)
    "
    );

    $dbh->do(
        "ALTER TABLE MovieTheatres
      ADD otherid char(32)
    "
    );

    $dbh->do(
        "ALTER TABLE MovieTheatres
      ADD filmcanid char(32)
    "
    );

    $dbh->do(
        "CREATE TABLE MovieShowtimes (
      movieID int NOT NULL,
      theatreID int NOT NULL,
      showtimes text,
      PRIMARY KEY (movieID, theatreID)
      )
    "
    );

    $dbh->do(
        "DROP TABLE MovieAttendance
    "
    );

}

sub upgrade_db_01 {

    # create teams db (scott - mar 2003)

    my $dbh = &tnmc::db::db_connect();

    $dbh->do(
        "CREATE TABLE Teams (
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
    "
    );

    $dbh->do(
        "CREATE TABLE TeamRooster (
      teamID int(11) NOT NULL,
      userID int(11) NOT NULL,
      gender char(1) NOT NULL default '?',
      status char(16) NOT NULL default 'player',
      is_admin int(1) NOT NULL default '0',
      answers text NOT NULL default '',
      PRIMARY KEY (teamID, userID)
      )
    "
    );

    $dbh->do(
        "CREATE TABLE TeamMeets (
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
    "
    );

    $dbh->do(
        "CREATE TABLE TeamMeetAttendance (
      meetID int(11) NOT NULL,
      userID int(11) NOT NULL,
      type char(255) NOT NULL default 'undef',
      timestamp timestamp NOT NULL,
      PRIMARY KEY (meetID, userID) 
      )
    "
    );

}

sub upgrade_db_00 {

    # create starting database (as of ~feb 2003)

    my $dbh = &tnmc::db::db_connect();

    $dbh->do("
CREATE TABLE FieldtripSurvey (
  userID int(11) default NULL,
  tripID int(11) default NULL,
  interest int(11) default NULL,
  driving int(11) default NULL,
  drivingWith int(11) default NULL,
  drivingSeats int(11) default NULL,
  departDate datetime default NULL,
  returnDate datetime default NULL,
  MoneyExpenseShared float(10,2) default NULL,
  MoneyExpenseProRated float(10,2) default NULL,
  MoneyExpensePortion float(10,2) default NULL,
  MoneyPaid float(10,2) default NULL,
  MoneyNotes text,
  comments text
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE Fieldtrips (
  tripID int(11) NOT NULL auto_increment,
  title varchar(255) default NULL,
  description text,
  blurb text,
  startTime datetime default NULL,
  endTime datetime default NULL,
  cost float(10,2) default NULL,
  AdminUserID int(11) default NULL,
  useCost int(11) default NULL,
  useRides int(11) default NULL,
  useWhen int(11) default NULL,
  is_active int(1) NOT NULL default '0',
  PRIMARY KEY  (tripID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE GeneralConfig (
  name varchar(255) default NULL,
  value text
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE Mail (
  Id int(11) NOT NULL auto_increment,
  UserId int(11) default NULL,
  Date timestamp(14) NOT NULL,
  AddrTo blob,
  AddrFrom blob,
  ReplyTo blob,
  Subject blob,
  Body blob,
  Header blob,
  Sent int(11) default NULL,
  PRIMARY KEY  (Id)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MailPrefs (
  UserId int(11) default NULL,
  Pref varchar(20) default NULL,
  Value varchar(20) default NULL
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MovieAttendance (
  userID int(11) NOT NULL default '0',
  movieDefault char(20) default NULL,
  movie20020205 char(20) default NULL,
  movie20020212 char(20) default NULL,
  movie20020219 char(20) default NULL,
  PRIMARY KEY  (userID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MovieFactionPrefs (
  userID int(11) NOT NULL default '0',
  factionID int(11) NOT NULL default '0',
  membership int(11) default NULL,
  attendance int(11) default NULL,
  notify_phone int(11) default NULL,
  PRIMARY KEY  (userID,factionID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MovieFactions (
  factionID int(11) NOT NULL auto_increment,
  name varchar(20) default NULL,
  description text,
  godID int(11) default NULL,
  night_creation int(11) default NULL,
  theatres text,
  PRIMARY KEY  (factionID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MovieNightAttendance (
  userID int(11) NOT NULL default '0',
  nightID int(11) NOT NULL default '0',
  type int(11) default NULL,
  PRIMARY KEY  (userID,nightID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MovieNights (
  nightID int(11) NOT NULL auto_increment,
  date datetime default NULL,
  movieID int(11) default NULL,
  theatre varchar(32) default NULL,
  showtime varchar(32) default NULL,
  meetingTime varchar(32) default NULL,
  meetingPlace varchar(32) default NULL,
  voteBlurb text,
  winnerBlurb text,
  godID int(11) default NULL,
  cache_movieIDs text,
  factionID int(11) default NULL,
  valid_theatres text,
  PRIMARY KEY  (nightID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MovieTheatres (
  theatreID int(11) NOT NULL auto_increment,
  mybcid char(32) default NULL,
  name char(64) default NULL,
  PRIMARY KEY  (theatreID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE MovieVotes (
  movieID int(11) NOT NULL default '0',
  userID int(11) NOT NULL default '0',
  type char(32) default NULL,
  KEY vote (movieID,userID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE Movies (
  movieID int(11) NOT NULL auto_increment,
  title varchar(64) NOT NULL default '',
  type varchar(255) default NULL,
  rating float(10,2) default NULL,
  description text,
  mybcID varchar(11) default NULL,
  statusShowing int(1) unsigned zerofill NOT NULL default '0',
  statusSeen int(1) unsigned zerofill NOT NULL default '0',
  statusNew int(1) unsigned zerofill NOT NULL default '0',
  date datetime default NULL,
  theatres varchar(255) default NULL,
  statusBanned int(1) unsigned zerofill NOT NULL default '0',
  imdbID varchar(16) default NULL,
  PRIMARY KEY  (movieID),
  KEY title (title)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE News (
  newsID int(11) NOT NULL auto_increment,
  userID int(11) default NULL,
  value blob,
  date timestamp(14) NOT NULL,
  expires timestamp(14) NOT NULL,
  PRIMARY KEY  (newsID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE Personal (
  userID int(11) NOT NULL auto_increment,
  username varchar(64) NOT NULL default '',
  fullname varchar(255) default NULL,
  email varchar(255) default NULL,
  password varchar(16) default NULL,
  phoneFido varchar(32) default NULL,
  phoneTelus varchar(32) default NULL,
  phoneRogers varchar(32) default NULL,
  phoneClearnet varchar(32) default NULL,
  phoneHome varchar(32) default NULL,
  phoneOffice varchar(32) default NULL,
  phoneOther varchar(32) default NULL,
  phonePrimary varchar(32) default NULL,
  groupDev int(1) NOT NULL default '0',
  groupAdmin int(1) NOT NULL default '0',
  groupLost int(1) NOT NULL default '0',
  birthdate datetime default NULL,
  phoneTextMail varchar(32) default NULL,
  homepage varchar(255) default NULL,
  phoneVstream varchar(32) default NULL,
  groupMovies int(11) NOT NULL default '0',
  groupCabin int(1) NOT NULL default '0',
  groupDead int(1) NOT NULL default '0',
  groupTest int(1) NOT NULL default '0',
  groupTrusted int(1) NOT NULL default '0',
  address varchar(255) default NULL,
  groupPics int(11) NOT NULL default '0',
  comments text,
  blurb text,
  I_am_a_misanthrope int(1) default NULL,
  colour_bg varchar(7) default NULL,
  PRIMARY KEY  (userID),
  KEY userid (username)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE PicAlbums (
  albumID int(11) NOT NULL auto_increment,
  albumDate datetime default NULL,
  albumTitle varchar(255) default NULL,
  albumDescription text,
  albumOwnerID int(11) default NULL,
  albumTypePublic int(11) default NULL,
  albumDateStart datetime default NULL,
  albumDateEnd datetime default NULL,
  albumCoverPic int(11) default NULL,
  PRIMARY KEY  (albumID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE PicLinks (
  albumID int(11) NOT NULL default '0',
  picID int(11) NOT NULL default '0',
  linkID int(11) NOT NULL auto_increment,
  KEY link (picID,albumID),
  KEY linkID (linkID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE Pics (
  picID int(11) NOT NULL auto_increment,
  timestamp datetime default NULL,
  filename varchar(255) default NULL,
  description text,
  comments text,
  ownerID int(11) default NULL,
  typePublic int(11) default NULL,
  width int(11) default NULL,
  height int(11) default NULL,
  title varchar(255) default NULL,
  rateContent int(2) default NULL,
  rateImage int(2) default NULL,
  normalize int(2) default NULL,
  PRIMARY KEY  (picID)
) TYPE=ISAM PACK_KEYS=1;
    ");

    $dbh->do("
CREATE TABLE SessionInfo (
  sessionID char(128) NOT NULL default '',
  userID int(11) default NULL,
  lastOnline timestamp(14) NOT NULL,
  firstOnline timestamp(14) NOT NULL,
  IP char(255) default NULL,
  host char(255) default NULL,
  hits int(11) default NULL,
  open int(1) default NULL,
  PRIMARY KEY  (sessionID)
) TYPE=ISAM PACK_KEYS=1;
    ");

}

