package tnmc::movies::faction;

use strict;

#
# module configuration
#
BEGIN {
    use tnmc::db;
}

#
# module routines
#


sub set_faction{
    my ($ref) = @_;
    
    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    
    my @keys = sort keys %$ref;
    
    my $key_list = join (',', @keys);
    my $ref_list = join (',', (map {sprintf '?'} @keys));
    my @var_list = map {$ref->{$_}} @keys;
    
    # save to the db
    my $sql = "REPLACE INTO MovieFactions ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;
    
    $sth->finish;
}

sub get_faction{
    my ($factionID) = @_;
    my $row_ref;
    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    
    # fetch from the db
    my $sql = "SELECT * from MovieFactions WHERE factionID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($factionID) or return();
    my $row = $sth->fetchrow_hashref();
    $sth->finish;
    if ($row){
        %{$row_ref} = %{$row};
    }
    return $row_ref;
}

sub list_factions{
    
    my @list;
    
    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    
    # fetch from the db
    my $sql = "SELECT factionID FROM MovieFactions";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute();
    
    while (my @row = $sth->fetchrow_array()){
        push @list, $row[0];
    }
    $sth->finish;
    
    # return the data
    return @list;
}

sub list_faction_members{
    my ($factionID, $WHERE_statement) = @_;
    
    my @list;
    my $sql;
    
    my $dbh = &tnmc::db::db_connect();
    
    # fetch from the db
    if ($WHERE_statement){
        $sql = "SELECT userID FROM MovieFactionPrefs WHERE factionID = ? AND ($WHERE_statement)";
    }
    else{
        $sql = "SELECT userID FROM MovieFactionPrefs WHERE factionID = ?";
    }
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($factionID);
    
    while (my @row = $sth->fetchrow_array()){
        push @list, $row[0];
    }
    $sth->finish;
    
    # return the data
    return @list;
}

sub save_faction_prefs{
    my ($prefs) = @_;
    
    my $dbh = &tnmc::db::db_connect();
    
    if ($prefs->{'membership'} != -1){
        
        my @keys = sort keys %$prefs;
        
        my $key_list = join (',', @keys);
        my $ref_list = join (',', (map {sprintf '?'} @keys));
        my @var_list = map {$prefs->{$_}} @keys;
        
        # save to the db
        my $sql = "REPLACE INTO MovieFactionPrefs ($key_list) VALUES($ref_list)";
        my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute(@var_list) or return 0;
        $sth->finish;
    }
    else{
        # delete from the db
        my $sql = "DELETE FROM MovieFactionPrefs WHERE factionID = ? AND userID = ?";
        my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute($prefs->{'factionID'}, $prefs->{'userID'}) or return 0;
        $sth->finish;
    }
}

sub load_faction_prefs{
    my ($factionID, $userID) = @_;
    
    my $dbh = &tnmc::db::db_connect();
    
    # fetch from the db
    my $sql = "SELECT * from MovieFactionPrefs WHERE factionID = ? AND userID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($factionID, $userID) or return();
    my $ref = $sth->fetchrow_hashref();
    $sth->finish();
    
    ## no record, return a blank one.
    if (!$ref){
        my @cols = &tnmc::db::db_get_cols_list("MovieFactionPrefs");
        my %hash = map {($_, '')} @cols;
        $hash{'factionID'} = $factionID;
        $hash{'userID'} = $userID;
        $ref = \%hash;
    }
    
    return $ref;
}


1;

