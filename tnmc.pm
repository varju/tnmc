##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca (nov/98)
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

use Exporter ();

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS 
            $HOMEPAGE);

@ISA = qw(Exporter);

@EXPORT_OK = qw(
                );

@EXPORT = qw(
             &get_general_config
             &set_general_config
             &get_user
             &set_user
             &del_user
             &list_users
             &show_bulletins
             &new_nav_menu

             %user

             get_cookie 
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
             );

%EXPORT_TAGS = ( );

##########################################################
#### Sub Procedures:
##########################################################

require 'menu.pl';
require 'user.pl';
require 'general_config.pl';

# keepin perl happy...
return 1;
