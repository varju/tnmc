package tnmc::pics::show;

use strict;

use AutoLoader 'AUTOLOAD';

use tnmc::db;
use tnmc::pics::pic;

#
# module configuration
#

#
# module routines
#

#
# autoloaded module routines
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
        &tnmc::pics::pic::get_pic($picID, \%pic);
        
        $pic{title} = '(untitled)' if (!$pic{title});
        if (!$pic{typePublic}){
            $pic{flags} .= '*';
        }
        print qq{
            <tr>
            <td>$i</td>
            <td><a href="pics/pic_view.cgi?picID=$picID&albumID=$albumID&dateID=$dateID">$pic{title}</a> $pic{flags}</td>
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

sub show_album_listing_info{
    my ($albums_ref, $params_ref) = @_;
    my @albums = (@$albums_ref);

    foreach my $albumID(@albums){
        &show_album_info($albumID);
    }
}

########################################
sub show_album_listing{
    my ($albums_ref, $params_ref) = @_;
    
    use tnmc::pics::album;
    use tnmc::pics::link;
    use tnmc::util::date;
    use tnmc::user;
    
    my @albums = (@$albums_ref);

    my %album;

    print qq{
        <table cellpadding="1" cellspacing="0" border="0" width="100%">
            <tr>
                <td><b>Title</td>
                <td>&nbsp;&nbsp;</td>
                <td><b>Date</td>
                <td>&nbsp;&nbsp;</td>
                <td><b>Pub</td>
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
                    <th colspan="9">&nbsp;$curr_date</th>
                </tr>
            };
        }
        my $date_string =  &tnmc::util::date::format_date('short_month_day', $album{albumDateStart}) . ' - ' . &tnmc::util::date::format_date('short_month_day', $album{albumDateEnd});
        
        my $sql = "SELECT count(*) FROM PicLinks WHERE albumID = $albumID";
	my $dbh = &tnmc::db::db_connect();
        my $sth = $dbh->prepare($sql); 
        $sth->execute();
        my ($num_pics) = $sth->fetchrow_array();
        
        my %owner;
        &tnmc::user::get_user($album{albumOwnerID}, \%owner);
        
        print qq{
            <tr>
                <td><a href="pics/album_thumb.cgi?albumID=$albumID">$album{albumTitle}</a></td>
                <td></td>
                <td>$date_string</td>
                <td></td>
                <td>$album{albumTypePublic}</td>
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

    use tnmc::pics::album;
    use tnmc::pics::link;
    use tnmc::user;
    
    my %album;
    &get_album($albumID, \%album);

    if (! $album{albumTitle}){
        $album{albumTitle} = '(Untitled)';
    }

    my $sql = "SELECT DATE_FORMAT('$album{albumDateStart}', '%b %d %Y') ";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql); 
    $sth->execute();
    my ($date_string) = $sth->fetchrow_array();

    $sql = "SELECT count(*) FROM PicLinks WHERE albumID = $albumID";
    $sth = $dbh->prepare($sql); 
    $sth->execute();
    my ($num_pics) = $sth->fetchrow_array();

    my %owner;
    &tnmc::user::get_user($album{albumOwnerID}, \%owner);

    if (!$album{albumCoverPic}){
        my @pics;
        &tnmc::pics::link::list_links_for_album(\@pics, $albumID);
        $album{albumCoverPic} = @pics[0];
    }
    
    my $pic_img = &tnmc::pics::pic::get_pic_url($album{albumCoverPic}, ['mode'=>'thumb']);
    
    print qq{
        <table>
            <tr>
                <td valign="top"><a href="pics/album_thumb.cgi?albumID=$albumID">
                    <img src="$pic_img" width="80" height="64" border="0"></a></td>
                <td valign="top"><a href="pics/album_thumb.cgi?albumID=$albumID">
                    <b>$album{albumTitle}</b></a><br>
                    $album{albumDescription}<br>
                    $date_string - 
                     $owner{username} - 
                    $num_pics pics<br>
                    </td>
            </tr>
        </table>
    };
        
}

1;

__END__

1;
