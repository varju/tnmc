##################################################################
#	Scott Thompson - mar 2003
#
# Methods:
#
#     Generic Item-access
#       getItem (table, key, id)                       # scottt (mar 2003)
#       replaceItem (table, [key], hash)               # scottt (mar 2003)
#       addItem (table, key, hash)                     # scottt (mar 2003)
#       delItem (table, key, id)                       # scottt (mar 2003)
#
#       listItems (table, key, id)                     # scottt (mar 2003)
#
#
##################################################################

package tnmc::db::item;

use strict;
use warnings;

require 5.004;

BEGIN {
    require tnmc::db;

    use vars qw($dbh);
    $dbh = &tnmc::db::db_connect();
}

#
# Item - Generic Item-access methods
#

sub newItem {
    my ($table, $key) = @_;

    my @cols = &tnmc::db::db_get_cols_list($table);
    my %hash;

    foreach my $k (@cols) {
        $hash{$k} = undef();
    }

    $hash{$key} = 0;    ### For sql auto increment.

    return \%hash;
}

sub getItem {
    my ($table, $key, $id) = @_;

    my $sql = "SELECT * FROM $table where $key = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($id);

    my $hash = $sth->fetchrow_hashref();

    $sth->finish;
    return &de_meta($hash);
}

sub replaceItem {
    my ($table, $key, $hash) = @_;

    $hash = &en_meta_safe($hash, $table);

    my @key_list = sort(keys(%$hash));
    my $key_list = join(', ', @key_list);
    my $ref_list = join(', ', (map { sprintf '?' } @key_list));
    my @var_list = map { $hash->{$_} } @key_list;

    # save to the db
    my $sql = "REPLACE INTO $table ($key_list) VALUES($ref_list)";
    my $sth = $dbh->do($sql, undef, @var_list);
}

sub addItem {
    my ($table, $key, $hash) = @_;

    $hash = &en_meta_safe($hash, $table);

    my @key_list = sort(keys(%$hash));
    my $key_list = join(', ', @key_list);
    my $ref_list = join(', ', (map { sprintf '?' } @key_list));
    my @var_list = map { $hash->{$_} } @key_list;

    # save to the db
    my $sql = "INSERT INTO $table ($key_list) VALUES($ref_list)";
    my $sth = $dbh->do($sql, undef, @var_list);

    ### KLUDGE: may have race-condition errors

    $sql = "SELECT max($key) FROM $table";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my ($last_key) = $sth->fetchrow_array();
    $sth->finish();

    return $last_key;
}

sub delItem {
    my ($table, $key, $id) = @_;

    my $sql = "DELETE FROM $table WHERE $key = ?";

    my $sth = $dbh->prepare($sql);
    $sth->execute($id);
    $sth->finish;

    return 1;
}

sub listItems {
    my ($table, $key, $sql_clause) = @_;

    my @list;

    my $sql = "SELECT $key from $table $sql_clause";
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    while (my @row = $sth->fetchrow_array()) {
        push(@list, $row[0]);
    }
    $sth->finish;

    return (wantarray()) ? @list : \@list;
}

#
# META encoding (KLUDGE: "meta" is a bad name for this stuff)
#

sub de_meta {
    my ($hash) = @_;

    # no META
    if (!exists($hash->{META})) {
        return $hash;
    }

    # parse meta
    my $META = delete($hash->{META});

    my @pairs = split(":::1", $META);
    foreach my $pair (@pairs) {
        my ($key, $val) = split(":::2", $pair);
        ## KLUDGE: should be de-escaping key and val here
        $hash->{$key} = $val;
    }
    return $hash;
}

sub en_meta {
    my ($hash, $table) = @_;

    my @cols = &tnmc::db::db_get_cols_list($table);

    my @META;
    foreach my $key (keys %$hash) {
        next if (grep { /^$key$/ } @cols);
        my $val = delete($hash->{$key});
        ## KLUDGE: should be escaping key and val here
        push @META, "$key\:\:\:2$val";
    }
    if (@META) {
        my $META = join ":::1", @META;
        $hash->{META} = $META;
    }

    return $hash;
}

sub en_meta_safe {
    my ($hash, $table) = @_;

    my %safe = %$hash;
    return en_meta(\%safe, $table);
}

sub de_meta_safe {
    my ($hash) = @_;

    my %safe = %$hash;
    return de_meta(\%safe);
}

# keeping perl happy
return 1;

