##################################################################
#	Scott Thompson - feb 2003
#
# Methods:
#
#       getLink (table, keys, id)                      # scottt (mar 2003)
#       replaceLink (table, [keys], hash)              # scottt (mar 2003)
#       delLink (table, keys, id)                      # scottt (mar 2003)
#
#       listLinks (table, key, sql)                    # scottt (mar 2003)
#
#
##################################################################


package tnmc::db::link;
use strict;
require 5.004;

BEGIN
{
    require tnmc::db;

    use vars qw($dbh);
    $dbh = &tnmc::db::db_connect();
}

#
# Link - Generic Link-access methods
#

sub newLink{
    my ($table, $keys) = @_;
    
    my @cols = &tnmc::db::db_get_cols_list($table);
    my %hash;
    
    foreach my $k (@cols){
	$hash{$k} = undef();
    }
    
    return \%hash;
}

sub getLink{
    my ($table, $keys, $hash) = @_;
    
    my $sql_text = join (" AND ", (map {sprintf "$_ = ?"} @$keys) );
    my @var_list = map {$hash->{$_}} @$keys;
    
    my $sql = "SELECT * FROM $table WHERE $sql_text";
    my $sth = $dbh->prepare($sql);
    $sth->execute(@var_list);
    
    my $hash = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hash;
}

sub replaceLink{
    my ($table, $keys, $hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ', ', @key_list);
    my $ref_list = join ( ', ', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $sql = "REPLACE INTO $table ($key_list) VALUES($ref_list)";
    my $sth = $dbh->do($sql, undef, @var_list);
}

sub delLink{
    my ($table, $keys, $hash) = @_;
    
    my $sql_text = join (" AND ", (map {sprintf "$_ = ?"} @$keys) );
    my @var_list = map {$hash->{$_}} @$keys;
    
    my $sql = "DELETE FROM $table WHERE $sql_text";
    my $sth = $dbh->do($sql, undef, @var_list);
    
    return 1;
}

sub listLinks{
    my ($table, $key, $sql_clause) = @_;
    
    my @list;
    
    my $sql = "SELECT $key from $table $sql_clause";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while (my @row = $sth->fetchrow_array()){
        push (@list, $row[0]);
    }
    $sth->finish;

    return (wantarray())? @list : \@list;
}

return 1;

