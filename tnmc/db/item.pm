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
require 5.004;


BEGIN
{
    require tnmc::db;
    
    use vars qw($dbh);
    $dbh = &tnmc::db::db_connect();
}

#
# Item - Generic Item-access methods
#

sub newItem{
    my ($table, $key) = @_;
    
    my @cols = &tnmc::db::db_get_cols_list($table);
    my %hash;
    
    foreach my $k (@cols){
	$hash{$k} = undef();
    }
    
    $hash{$key} = 0; ### For sql auto increment.
    
    return \%hash;
}

sub getItem{
    my ($table, $key, $id) = @_;
    
    my $sql = "SELECT * FROM $table where $key = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($id);
    
    my $hash = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hash;
}

sub replaceItem{
    my ($table, $key, $hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ', ', @key_list);
    my $ref_list = join ( ', ', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $sql = "REPLACE INTO $table ($key_list) VALUES($ref_list)";
    my $sth = $dbh->do($sql, undef, @var_list);
}

sub addItem{
    my ($table, $key, $hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ', ', @key_list);
    my $ref_list = join ( ', ', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $sql = "INSERT INTO $table ($key_list) VALUES($ref_list)";
    my $sth = $dbh->do($sql, undef, @var_list);
    
    ### KLUDGE: may have race-condition errors
    
    $sql = "SELECT max($key) FROM $table" ;
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    
    my ($last_key) = $sth->fetchrow_array();
    $sth->finish();
    
    return $last_key;
}

sub delItem{
    my ($table, $key, $id) = @_;
    
    my $sql = "DELETE FROM $table WHERE $key = ?";
    print STDERR $sql, "- $id\n\n";
    my $sth = $dbh->prepare($sql);
    $sth->execute($id);
    $sth->finish;
    
    return 1;
}

sub listItems{
    my ($table, $key, $sql_clause) = @_;
    
    my @list;
    
    my $sql = "SELECT $key from $table $sql_clause";
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    while (my @row = $sth->fetchrow_array()){
        push (@list, $row[0]);
    }
    $sth->finish;
    
    return (wantarray())? @list : \@list;
}


# keeping perl happy
return 1;

