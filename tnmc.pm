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

BEGIN
{
        use Exporter ();

        use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS
		$dbh_tnmc
		$USERID $LOGGED_IN $tnmc_cgi %tnmc_cookie_in $HOMEPAGE);

        @ISA = qw(Exporter);

        @EXPORT_OK = qw(
                        );

        @EXPORT = qw(
			&header
			&footer
			&show_heading
			&get_cookie
			&get_general_config
			&set_general_config
                        &get_user
                        &set_user
			&del_user
			&list_users
			&show_bulletins

			&db_connect
			&db_disconnect
                        $dbh_tnmc

			$USERID
			$LOGGED_IN
			$tnmc_cgi

			&db_get_cols_list
			&db_get_row
			&db_set_row
			
                        );

	%EXPORT_TAGS = ( );
}

##########################################################
sub get_cookie{

	$tnmc_cgi = new CGI;
	
	%tnmc_cookie_in = $tnmc_cgi->cookie('TNMC');
	if ($tnmc_cookie_in{'logged-in'} eq '1'){
		$USERID = $tnmc_cookie_in{'userID'};
		$LOGGED_IN = $tnmc_cookie_in{'logged-in'};
	}
}

##########################################################
#### Sub Procedures:
##########################################################


require 'db_access.pl';
require 'template.pl';
require 'user.pl';
require 'general_config.pl';

if (1 ne 1){
	require 'broadcast/BROADCAST.pl';

	&header();
	print qq{
		<br>$USERID<br><br><b>TNMC is temporarilly offline while we upgrade the server,
		it should be back up shortly.
	};
	&footer();
	
	exit(1);
}


# keepin perl happy...
return 1;
