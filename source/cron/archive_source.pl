#!/usr/bin/perl

use POSIX qw(strftime);

my $base = "/tnmc";
my $cvs = "/var/db/tnmc-cvs";

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
rename("/tmp/$tmp/tnmc.tar.gz","source/tnmc.tar.gz");

system("rm -rf /tmp/$tmp");
