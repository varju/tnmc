package tnmc::homepage::user;

use strict;

use tnmc;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub show{
    
}

END{
    &tnmc::homepage::user::log_user_homepage();
}

sub log_user_homepage
{
    my $today = &tnmc::util::date::now();
    
    if (!-d "user/log") {
        mkdir("user/log",0755);
    }
    
    if ($tnmc::security::auth::USERID != 1){
        open (LOG, '>>user/log/splash.log');
        print LOG "$today\t$ENV{REMOTE_ADDR}";
        print LOG "\t$tnmc::security::auth::USERID";
        print LOG "\t$tnmc::security::auth::USERID{username}" if defined $tnmc::security::auth::USERID{username};
        
        print LOG "\n";
        close (LOG);
    }
}

1;
