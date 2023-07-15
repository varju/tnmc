package tnmc::util::temp;

use strict;
use warnings;

use tnmc::util::file;

BEGIN {
    use vars qw($temp_dir);
    $temp_dir = "/tmp/";
}

#
# module routines
#

sub get_dir {

    my $PID = $$;

    # get a unique name
    my $dir = $temp_dir . 'tnmc_' . $PID . '/';
    my $i;
    while (-e $dir) {
        $i++;
        $dir = $temp_dir . 'tnmc_' . $PID . '_' . $i . '/';
    }

    # make the dir
    &tnmc::util::file::make_directory($dir);

    # return the dir name
    return $dir;
}

sub kill_dir {
    my ($dir) = @_;

    # make sure it's actually in the data/temp dir.
    return 0 if ($dir !~ /^$temp_dir\/tnmc/);

    # delete the dir
    &tnmc::util::file::kill_tree($dir);

    return 1;
}

1;

