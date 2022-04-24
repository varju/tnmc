package tnmc::pics::album;

use strict;

use tnmc::security::auth;
use tnmc::db;
use tnmc::user;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub set_album {
    my (%album, $junk) = @_;
    my ($sql, $sth, $return);

    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_set_row(\%album, $dbh, 'PicAlbums', 'albumID');
}

sub del_album {
    my ($albumID) = @_;
    my ($sql, $sth, $return);

    my $dbh = &tnmc::db::db_connect();

    ###############
    ### Delete the album

    $sql = "DELETE FROM PicAlbums WHERE albumID = '$albumID'";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;

}

sub get_album {
    my ($albumID, $album_ref, $junk) = @_;
    my ($condition);

    $condition = "(albumID = '$albumID')";
    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_get_row($album_ref, $dbh, 'PicAlbums', $condition);
}

# sub get_user_cache;
{
    my %get_album_cache;

    sub get_album_cache {
        my ($albumID, $album_ref, $junk) = @_;
        my ($condition);

        if (!$get_album_cache{$albumID}) {
            my %hash;
            &get_album($albumID, \%hash);
            $get_album_cache{$albumID} = \%hash;
        }
        if (defined $album_ref) {
            %$album_ref = %{ $get_album_cache{$albumID} };
        }
        return $get_album_cache{$albumID};
    }
}

sub list_albums {
    my ($album_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    my $dbh = &tnmc::db::db_connect();

    @$album_list_ref = ();

    $sql = "SELECT albumID from PicAlbums $where_clause $by_clause";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()) {
        push(@$album_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$album_list_ref);
}

sub list_valid_albums {
    my ($album_list_ref, $timestamp) = @_;
    my (@row, $sql, $sth);

    use tnmc::security::auth;

    my $dbh = &tnmc::db::db_connect();

    @$album_list_ref = ();

    $sql = "SELECT albumID 
              FROM PicAlbums
             WHERE (albumDateStart <= ? && albumDateEnd >= ?)
               AND (albumTypePublic >= 2 OR albumOwnerID = $USERID)";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($timestamp, $timestamp);
    while (@row = $sth->fetchrow_array()) {
        push(@$album_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$album_list_ref);
}

1;

