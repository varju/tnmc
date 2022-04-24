package tnmc::general_config;

use strict;

#
# module configuration
#

#
# module routines
#

sub get_general_config {
    my ($name, $value_ref, $junk) = @_;

    require tnmc::db;
    my $dbh = &tnmc::db::db_connect();

    my $sql = 'SELECT value from GeneralConfig WHERE name = ?';
    my $sth = $dbh->prepare($sql);
    $sth->execute($name);
    ($$value_ref) = $sth->fetchrow_array();
    $sth->finish;

    return $$value_ref;
}

sub set_general_config {
    my ($name, $value, $junk) = @_;

    require tnmc::db;
    my $dbh = &tnmc::db::db_connect();

    my ($sql, $sth);

    $sql = 'DELETE FROM GeneralConfig WHERE name = ?';
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($name);

    $sql = "REPLACE INTO GeneralConfig (name, value) VALUES ('$name', " . $dbh->quote($value) . ")";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;
}

1;
