package tnmc::general_config;

use strict;
use DBI;

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(get_general_config set_general_config);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub get_general_config{
        my ($name, $value_ref, $junk) = @_;
        my ($sql, $sth, @row);

        $sql = "SELECT value from GeneralConfig WHERE name = '$name'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        ($$value_ref, $junk) = $sth->fetchrow_array();
        $sth->finish;

        return $$value_ref;
}

sub set_general_config{
        my ($name, $value, $junk) = @_;
        my ($sql, $sth, @row);

        $sql = "DELETE FROM GeneralConfig WHERE name='$name'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;

        $sql = "REPLACE INTO GeneralConfig (name, value) VALUES ('$name', " . $dbh_tnmc->quote($value) . ")";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;
}

1;
