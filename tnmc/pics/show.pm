package tnmc::pics::show;

use strict;

use tnmc::security::auth;
use tnmc::db;
use tnmc::user;
use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::link;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(show_random_pic show_pic_listing show_album_info show_album_listing);


@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub show_random_pic{
    my ($offset) = @_;
    
    my $sql = "SELECT DATE_FORMAT(NOW(), '%m%j%H%i')";
    my $sth = $dbh_tnmc->prepare($sql); 
    $sth->execute();
    my ($seed) = $sth->fetchrow_array();
    $seed = int ($seed / 10);
    my $picID = &get_random_pic($seed, $offset);
    
    my %pic;
    &get_pic($picID, \%pic);
    
    my $pic_img = &get_pic_url($picID, ['mode'=>'thumb']);
    $pic{description} &&= " ($pic{description})";
    my $date = $pic{timestamp};
    $date =~ s/\s.*//;
    my $pic_url = "pics/search_slide.cgi?search=date-span&search_from=$date+00%3A00&search_to=$date+23%3A59%3A59&picID=$picID";
    print qq{
        <a href="$pic_url"><img src="$pic_img" width="80" height="64" border="0" alt="$pic{title}$pic{description}"></a>
    };
    
}

# to-do: move this function
sub get_random_pic{
    my ($seed, $offset) = @_;

    my $sql = "SELECT count(*) FROM Pics WHERE typePublic = '1'";
    my $sth = $dbh_tnmc->prepare($sql); 
    $sth->execute();
    my ($count_pics) = $sth->fetchrow_array();
    
    if ($seed){
        srand($seed);
    }
    
    my $index;
    $offset++;
    while ($offset--){
        $index = int(rand($count_pics/100)) . int(rand(100)) ;
    }
    
    $sql = "SELECT picID FROM Pics WHERE typePublic = '1' LIMIT $index, 1";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($picID) = $sth->fetchrow_array();
     
    return $picID;
}

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
                <td><a href="album_thumb.cgi?albumID=$albumID">$album{albumTitle}</a></td>
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
    
    my $pic_img = &get_pic_url($album{albumCoverPic}, ['mode'=>'thumb']);
    
    print qq{
        <table>
            <tr>
                <td valign="top"><a href="album_thumb.cgi?albumID=$albumID">
                    <img src="$pic_img" width="80" height="64" border="0"></a></td>
                <td valign="top"><a href="album_thumb.cgi?albumID=$albumID">
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
