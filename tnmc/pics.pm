package tnmc::pics;

use strict;

use tnmc::cookie;
use tnmc::db;
use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(show_pic_listing show_album_info show_album_listing set_pic del_pic
             get_pic list_pics set_album del_album get_album 
             list_albums add_link del_link get_link list_links 
             list_links_for_album list_links_for_date);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub show_pic_listing{
    my ($pics_ref, $albumID, $dateID) = @_;

    my @pics = @$pics_ref;

    print qq{
            <table cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
            <th>#</td>
            <th>Title</td>
            <th>Date</td>
            <th>&nbsp;</td>
            <th>Owner</td>
            </tr>
    };


    my %pic;
    my $i = 0;
    foreach my $picID (@pics){
        $i++;
        &get_pic($picID, \%pic);
        
        $pic{title} = '(untitled)' if (!$pic{title});
        if (!$pic{typePublic}){
            $pic{flags} .= '*';
        }
        print qq{
            <tr>
            <td>$i</td>
            <td><a href="pic_view.cgi?picID=$picID&albumID=$albumID&dateID=$dateID">$pic{title}</a> $pic{flags}</td>
            <td>$pic{timestamp}</td>
            <td>&nbsp;&nbsp;</td>
            <td>$pic{ownerID}</td>
            </tr>
        };
    }
    
    print qq{
        </table>
    };
    
}

########################################
sub show_album_listing{
    my ($albums_ref, $params_ref) = @_;

    my @albums = (@$albums_ref);

    my %album;

    print qq{
        <table cellpadding="1" cellspacing="0" border="0" width="100%">
            <tr>
                <td><b>Title</td>
                <td>&nbsp;&nbsp;</td>
                <td><b>Date</td>
                <td>&nbsp;&nbsp;</td>
                <td><b>Owner</td>
                <td>&nbsp;&nbsp;</td>
                <td><b>Size</td>
            </tr>
    };



    my $curr_date = '0';
    foreach my $albumID (@albums){

        &get_album($albumID, \%album);

        if (! $album{albumTitle}){
            $album{albumTitle} = '(Untitled)';
        }

        if( $curr_date ne substr($album{albumDateStart}, 0, 4)){
            $curr_date = substr($album{albumDateStart}, 0, 4);
            print qq{
                <tr>
                    <th colspan="7">&nbsp;$curr_date</th>
                </tr>
            };
        }
        
        my $sql = "SELECT DATE_FORMAT('$album{albumDateStart}', '%b %d')";
        my $sth = $dbh_tnmc->prepare($sql); 
        $sth->execute();
        my ($date_string) = $sth->fetchrow_array();

        $sql = "SELECT count(*) FROM PicLinks WHERE albumID = $albumID";
        $sth = $dbh_tnmc->prepare($sql); 
        $sth->execute();
        my ($num_pics) = $sth->fetchrow_array();

        my %owner;
        &get_user($album{albumOwnerID}, \%owner);

        print qq{
            <tr>
                <td><a href="album_view.cgi?albumID=$albumID">$album{albumTitle}</a></td>
                <td></td>
                <td>$date_string</td>
                <td></td>
                <td>$owner{username}</td>
                <td></td>
                <td>$num_pics</td>
            </tr>
        };
        
    }
    print qq{
        </table>
    };
}

########################################
sub show_album_info{
    my ($albumID) = @_;

    my %album;
    &get_album($albumID, \%album);

    if (! $album{albumTitle}){
        $album{albumTitle} = '(Untitled)';
    }

    my $sql = "SELECT DATE_FORMAT('$album{albumDateStart}', '%b %d %Y') ";
    my $sth = $dbh_tnmc->prepare($sql); 
    $sth->execute();
    my ($date_string) = $sth->fetchrow_array();

    $sql = "SELECT count(*) FROM PicLinks WHERE albumID = $albumID";
    $sth = $dbh_tnmc->prepare($sql); 
    $sth->execute();
    my ($num_pics) = $sth->fetchrow_array();

    my %owner;
    &get_user($album{albumOwnerID}, \%owner);

    if (!$album{albumCoverPic}){
        my @pics;
        &list_links_for_album(\@pics, $albumID);
        $album{albumCoverPic} = @pics[0];
    }
    
    print qq{
        <table>
            <tr>
                <td valign="top"><a href="album_view.cgi?albumID=$albumID">
                    <img src="serve_pic.cgi?picID=$album{albumCoverPic}&mode=thumb" width="80" height="64" border="0"></a></td>
                <td valign="top"><a href="album_view.cgi?albumID=$albumID">
                    <b>$album{albumTitle}</b></a><br>
                    $album{albumDescription}<br>
                    Date: $date_string - 
                    Owner: $owner{username} - 
                    Pics: $num_pics<br>
                    </td>
            </tr>
        </table>
    };
        
}

########################################
sub set_pic{
    my (%pic, $junk) = @_;
    my ($sql, $sth, $return);
    
    &db_set_row(\%pic, $dbh_tnmc, 'Pics', 'picID');
}

########################################
sub del_pic{
    my ($picID) = @_;
    my ($sql, $sth, $return);
    
    ###############
    ### Delete the pic
    
    $sql = "DELETE FROM Pics WHERE picID = '$picID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}

########################################
sub get_pic{
    my ($picID, $pic_ref, $junk) = @_;
    my ($condition);

    $condition = "(picID = '$picID')";
    &db_get_row($pic_ref, $dbh_tnmc, 'Pics', $condition);
}

########################################
sub list_pics{
    my ($pic_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$pic_list_ref = ();

    $sql = "SELECT picID from Pics $where_clause $by_clause";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$pic_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$pic_list_ref);
}

########################################
sub set_album{
    my (%album, $junk) = @_;
    my ($sql, $sth, $return);
    
    &db_set_row(\%album, $dbh_tnmc, 'PicAlbums', 'albumID');
}

sub del_album{
    my ($albumID) = @_;
    my ($sql, $sth, $return);
    
    ###############
    ### Delete the album
    
    $sql = "DELETE FROM PicAlbums WHERE albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
    
}

sub get_album{
    my ($albumID, $album_ref, $junk) = @_;
    my ($condition);

    $condition = "(albumID = '$albumID')";
    &db_get_row($album_ref, $dbh_tnmc, 'PicAlbums', $condition);
}

sub list_albums{
    my ($album_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$album_list_ref = ();

    $sql = "SELECT albumID from PicAlbums $where_clause $by_clause";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$album_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$album_list_ref);
}

sub add_link{
    my ($picID, $albumID) = @_;
    my ($sql, $sth, $return);
    
    $sql = "DELETE FROM PicLinks WHERE picID = '$picID' AND albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;

    $sql = "REPLACE INTO PicLinks SET picID = '$picID', albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}

sub del_link{
    my ($picID, $albumID) = @_;
    my ($sql, $sth, $return);
    
    $sql = "DELETE FROM PicLinks WHERE picID = '$picID' AND albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}

sub get_link{
    my ($picID, $albumID) = @_;
    my ($sql, $sth, $return, $ret);

    $sql = "SELECT * FROM PicLinks WHERE picID = '$picID' AND albumID = '$albumID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
        $ret = ($sth->fetchrow_array());
    $sth->finish;

        return $ret;
}

sub list_links{
    my ($link_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

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

sub list_links_for_date{
    my ($link_list_ref, $dateID, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

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
