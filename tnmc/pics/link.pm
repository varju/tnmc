package tnmc::pics::link;

use strict;

use tnmc::security::auth;
use tnmc::db;
use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(add_link del_link get_link list_links 
             list_links_for_album list_links_for_date);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#


sub add_link{
    my ($picID, $albumID) = @_;
    my ($sql, $sth, $return);
    
    my $dbh_tnmc = &tnmc::db::db_connect();

    $sql = "DELETE FROM PicLinks WHERE picID = '$picID' AND albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;

    $sql = "REPLACE INTO PicLinks SET picID = '$picID', albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}


sub update_link{
    my ($link) = @_;
    my ($sql, $sth, $return);
    
    my $dbh_tnmc = &tnmc::db::db_connect();
    
    ## remove *any* conflicting picLinks
    $sql = "DELETE FROM PicLinks WHERE (linkID = ?) OR (picID = ? AND albumID = ?)";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($link->{'linkID'}, $link->{'picID'}, $link->{'albumID'});
    
    ## insert into db, explicitly specifying linkID
    $sql = "INSERT INTO PicLinks SET picID = ?, albumID = ?, linkID = ? ";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($link->{'picID'}, $link->{'albumID'}, $link->{'linkID'});
    
    $sth->finish;
}

sub del_link{
    my ($picID, $albumID) = @_;
    my ($sql, $sth, $return);
    
    my $dbh_tnmc = &tnmc::db::db_connect();
    
    $sql = "DELETE FROM PicLinks WHERE picID = '$picID' AND albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}

sub del_link_by_linkID{
    my ($linkID) = @_;
    my ($sql, $sth, $return);
    
    my $dbh_tnmc = &tnmc::db::db_connect();
    
    $sql = "DELETE FROM PicLinks WHERE linkID = ?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($linkID);
    $sth->finish;
}

sub get_link{
    my ($picID, $albumID) = @_;
    my ($sql, $sth, $return, $ret);

    my $dbh_tnmc = &tnmc::db::db_connect();
    
    $sql = "SELECT * FROM PicLinks WHERE picID = '$picID' AND albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
        $ret = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $ret;
}

sub get_link_by_linkID{
    my ($linkID) = @_;
    my ($sql, $sth, $ret);

    my $dbh_tnmc = &tnmc::db::db_connect();
    
    $sql = "SELECT * FROM PicLinks WHERE linkID = ?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($linkID);
        $ret = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $ret;
}

sub list_links{
    my ($link_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    my $dbh_tnmc = &tnmc::db::db_connect();
    
    @$link_list_ref = ();

    $sql = "SELECT picID from PicLinks $where_clause $by_clause";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$link_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$link_list_ref);
}

sub list_links_for_album{
    my ($link_list_ref, $albumID, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    my $dbh_tnmc = &tnmc::db::db_connect();
    
    @$link_list_ref = ();

    $sql = "SELECT l.picID
                  FROM PicLinks as l LEFT JOIN Pics as p USING (picID)
                 WHERE l.albumID = '$albumID'
                   AND ((ownerID = '$USERID') OR typePublic = 1)
                 ORDER BY p.timestamp, p.picID";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$link_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$link_list_ref);
}

sub list_links_for_pic{
    my ($link_list_ref, $picID) = @_;
    my (@row, $sql, $sth);
    
    my $dbh_tnmc = &tnmc::db::db_connect();
    
    @$link_list_ref = ();
    
    $sql = "SELECT l.albumID
                  FROM PicLinks as l LEFT JOIN PicAlbums as a USING (albumID)
                 WHERE l.picID = ?
                   AND ((a.AlbumOwnerID = '$USERID') OR a.AlbumTypePublic >= 1)
                 ORDER BY a.albumDateStart, a.albumID";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($picID);
    while (@row = $sth->fetchrow_array()){
        push (@$link_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$link_list_ref);
}

sub list_links_for_date{
    my ($link_list_ref, $dateID, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    my $dbh_tnmc = &tnmc::db::db_connect();
    
    @$link_list_ref = ();

    $sql = "SELECT picID
            FROM Pics
            WHERE (timestamp LIKE '$dateID%')
              AND ((ownerID = '$USERID') OR typePublic = 1)
            ORDER BY timestamp, picID";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$link_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$link_list_ref);
}

1;
