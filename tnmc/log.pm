package tnmc::log;

use strict;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(log_login);

@EXPORT_OK = qw();

#
# module vars
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
    
    my (@elements) = ($today, $ENV{REMOTE_ADDR}, $ENV{REMOTE_HOST},
                      $oldid, $oldname, $newid, $newname, $pass);
    push(@elements,'FAILED') unless $success;

    my $entry = join('\t', @elements);

    open (LOG, '>>log/login.log');
    print LOG $entry, "\n";
    close LOG;
}

1;