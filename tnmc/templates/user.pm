package tnmc::templates::user;

use strict;

use tnmc::security::auth;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(show_user_homepage);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub show_user_homepage {
    ############################
    ### Do the date stuff.
    open (DATE, "/bin/date |");
    my $today = <DATE>;
    chomp $today;
    close (DATE);
    
    if (!-d "user/log") {
        mkdir("user/log",0755);
    }

    if ($USERID != 1){
        open (LOG, '>>user/log/splash.log');
        print LOG "$today\t$ENV{REMOTE_ADDR}";
        print LOG "\t$USERID";
        print LOG "\t$USERID{username}" if defined $USERID{username};
        
        print LOG "\n";
        close (LOG);
    }
}

1;
