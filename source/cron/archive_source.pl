#!/usr/bin/perl

use strict;

use POSIX qw(strftime);
use File::Copy;

my $base = "/tnmc";
my $cvs = "/home/varju/tnmc/cvs";

my $tmp = $$;
while (-d "/tmp/$tmp")
{
    $tmp++;
}

mkdir("/tmp/$tmp",504);
chdir("/tmp/$tmp");
system("cvs -d $cvs export -rHEAD tnmc");
system("tar cvzf tnmc.tar.gz tnmc");

chdir($base);
if (-e "source/tnmc.tar.gz")
{
    unlink("source/tnmc.tar.gz");
}

copy("/tmp/$tmp/tnmc.tar.gz", "$base/source/tnmc.tar.gz");

system("rm -rf /tmp/$tmp");
