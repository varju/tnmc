#!/usr/bin/perl

# this file simply pre-loads some modules that we're going to want to
# use later

use CGI;
use DBI;

use lib '/tnmc';

use tnmc::config;
use tnmc::cookie;
use tnmc::db;
use tnmc::menu;
use tnmc::template;
use tnmc::general_config;
use tnmc::user;
use tnmc::movies::attend;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::show;
use tnmc::movies::vote;
use tnmc::broadcast;
use tnmc::log;
use tnmc::templates::bulletins;
use tnmc::templates::movies;
use tnmc::templates::user;
use tnmc::pics;

1;
