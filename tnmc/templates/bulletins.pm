package tnmc::bulletins;

use strict;

use tnmc::cookie;
use tnmc::general_config;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(show_bulletins);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub show_bulletins
{
        my ($bulletins);

        $bulletins = get_general_config('bulletins');

        if (!$bulletins)
        {
	        print qq
                {
			<!-- no bulletins -->
                };
                return;
        }
        elsif(!$USERID){
	        print qq
                {
			<!-- no bulletins -->
                };
                return;
	}
        else{
		# &show_heading ("bulletins");
		print qq
                {
		       <TABLE border="0" cellpadding="0" cellspacing="0">
                        <TR>
                        <TD>$bulletins</TD>
                        </TR>
                        </TABLE>
                        <P>
                };
        }
}

1;
