package tnmc::db;

use strict;
use vars qw($dbh_tnmc);

use DBI;
use AutoLoader 'AUTOLOAD';

#
# module configuration
#

#
# module routines
#

sub db_connect{
    my ($database, $host, $user, $password);

    $database = "tnmc";
    $host = "db";
    $user = "tnmc";
    $password = "password";
    
    if ($dbh_tnmc) {
        # since we only have one database, we can just reuse the
        # handle
        return $dbh_tnmc;
    }
    
    # say hello.
    $dbh_tnmc = DBI->connect("DBI:mysql:database=$database:host=$host", $user, $password)
        or die "Can't connect: $dbh_tnmc->errstr\n";
    
    return $dbh_tnmc;
}

sub db_disconnect{
    $dbh_tnmc->disconnect;
}

#
# module conf - automatically connect and disconnect to the db 
#

BEGIN
{
    db_connect();
}

END
{
    db_disconnect();
}

1;

#
# autoloaded module routines
#

__END__

sub db_get_cols_list{
    my ($table) = @_;
    my (@cols, $sql, $sth);

    @cols = ();
    $sql = "SHOW COLUMNS FROM $table";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (my @row = $sth->fetchrow_array()){
        push (@cols, $row[0]);
    }
    $sth->finish;

    return @cols;
}

sub db_set_row{
    my ($hash_ref, $dbh, $table, $primary_key, $junk) = @_;
    my ($sql, $sth, @columns, $cols_string, $item, $key, %db_hash);
    
    if ($hash_ref->{$primary_key}){
        
        ###############
        ### Get Old Row Info
        
        @columns = db_get_cols_list($table);    
        $cols_string = '';
        foreach $item (@columns){
            $cols_string .= ", $item";
        }
        
        $sql = "SELECT NOW() $cols_string FROM $table WHERE $primary_key = '$hash_ref->{$primary_key}'";

        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        my @row = $sth->fetchrow_array();
        while ($key = pop(@columns)){
            $db_hash{$key} = pop @row;
        }
        $sth->finish;
    }
    
#    print STDERR %db_hash;
    
    ###############
    ### Set New Row Info
    
    
    foreach $key (keys %$hash_ref){
        $db_hash{$key} = $hash_ref->{$key};
    }
    
    @columns = db_get_cols_list($table);    
    $cols_string = "$primary_key";
    my $vals_string = "'$hash_ref->{$primary_key}'";
    foreach $item (@columns){
        if ($item eq $primary_key) {next;}
        $cols_string .= ", $item";
        $vals_string .= ", " . $dbh_tnmc->quote($db_hash{$item});
    }
    $sql = "REPLACE INTO $table ($cols_string) VALUES ($vals_string)";
#    print $sql, "\n\n\n";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
    
    ###############
    ### Question: should i try to return the primary_key?
}

sub db_get_row{
    my ($hash_ref, $dbh, $table, $where) = @_;
    my ($sql, $sth, $ref);
    
    ### clear the hash
    %$hash_ref = ();
    
    $sql = "SELECT * FROM $table WHERE $where";
    $sth = $dbh_tnmc->prepare($sql)
        or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute();
    $ref = $sth->fetchrow_hashref();
    $sth->finish;
    
    %$hash_ref = %$ref;
}

1;
