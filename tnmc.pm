##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca (nov/98)
#       Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

package tnmc;

require 5.004;
use strict;
use DBI;
use CGI;

use tnmc::cookie;
use tnmc::db;
use tnmc::template;
use tnmc::menu;
use tnmc::user;
use tnmc::general_config;

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT_OK = qw();

@EXPORT = qw(
             %user

             cookie_get 
             $tnmc_cgi
             %tnmc_cookie_in
             $USERID 
             $LOGGED_IN 
             $USERID_LAST_KNOWN 
             %USERID

             db_connect 
             db_disconnect 
             db_get_cols_list
             db_get_row
             db_set_row
             $dbh_tnmc

             header
             footer
             show_heading

             new_nav_menu 
             new_nav_login

             set_user del_user get_user get_user_extended list_users

             get_general_config set_general_config
             );

# keepin perl happy...
return 1;
