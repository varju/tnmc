package tnmc::db;

use strict;
use DBI;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK $dbh_tnmc);

@ISA = qw(Exporter);

@EXPORT = qw(db_connect 
             db_disconnect 
             db_get_cols_list
             db_get_row
             db_set_row
             $dbh_tnmc);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

##################################################################
#
# Database Access Methods:
#       db_connect()
#       db_disconnect()
#    db_get_cols_list (table)
#    db_set_row (hash_ref, dbh, table, primary_key)
#    db_get_row (hash_ref, dbh, table, where)
#
##################################################################

sub db_connect{
    my ($database, $host, $user, $password);

    $database = "tnmc";
    $host = "localhost";
    $user = "tnmc";
    $password = "password";

    if ($dbh_tnmc) {
        # since we only have one database, we can just reuse the
        # handle
        return;
    }

    # say hello.
    $dbh_tnmc = DBI->connect("DBI:mysql:$database:$host", $user, $password)
        or die "Can't connect: $dbh_tnmc->errstr\n";
}

sub db_disconnect{
    $dbh_tnmc->disconnect;
}

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
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
    
    ###############
    ### Question: should i try to return the primary_key?
}

sub db_get_row{
    my ($hash_ref, $dbh, $table, $where, $junk) = @_;
    my ($sql, $sth, @cols, @row, $cols_string, $key, $val);

    ### clear the hash
    %$hash_ref = ();
    
    ###############
    ### Build Select Statement

    @cols = db_get_cols_list($table);
    foreach (@cols){
        $cols_string .= ", $_";
    }
    $sql = "SELECT NOW() $cols_string FROM $table WHERE $where";
    
    ###############
    ### Get The Data

    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    @row = $sth->fetchrow_array();
    while ($key = pop (@cols)){
        $val = pop @row;
        $hash_ref->{$key} = $val;
    }
    $sth->finish;
}

1;
