package tnmc::log;

use strict;

#
# module configuration
#

#
# module routines
#

sub log_login {
    my ($success, $oldid, $oldname, $newid, $newname, $pass) = @_;

    my $today;
    open (DATE, "/bin/date |");
    while (<DATE>) {
        chop;
        $today = $_;
    }
    close (DATE);

    my (@elements) = ($today, $ENV{REMOTE_ADDR}, $oldid, $oldname, 
                      $newid, $newname, $pass);
    push(@elements,'FAILED') unless $success;

    my $entry = join("\t", @elements);

    open (LOG, '>>log/login.log');
    print LOG $entry, "\n";
    close LOG;
}

1;
