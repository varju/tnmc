#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
use tnmc::user;
require 'pics/PICS.pl';

	#############
	### Main logic

	&db_connect();
	&header();

	%album;	
	$cgih = new CGI;
	$albumID = $cgih->param('albumID');
	
        &show_album($albumID);

	&footer();

	&db_disconnect();


################################################################################
sub show_album{
    my ($albumID) = @_;
    
    
    &get_album($albumID, \%album);
    
    ## some info about the album
    
    &get_user($album{albumOwnerID}, \%owner);
    
    if (! $album{albumTitle}){
        $album{albumTitle} = '(Untitled)';
    }
    
    if ($album{albumOwnerID} == $USERID){
        $editLink = qq{ - <a href="album_edit_admin.cgi?albumID=$albumID"><font color="ffffff">Edit</font></a> };
        $delLink = qq{ - <a href="album_del.cgi?albumID=$albumID"><font color="ffffff">Del</font></a> };
    }
    $backLink = qq{ - <a href="album_list.cgi"><font color="ffffff">All Albums</font></a> };
    
    show_heading("View Album  $editLink $delLink $backLink");
    
    print qq {
        <p>
        <b>$album{albumTitle}</b> - $album{albumDate} - $owner{username}
        <p>
        $album{albumDescription}
        <p>
    };
    
    ## options for the owner
    if ($album{albumOwnerID} == $USERID){
        print qq{<p>
            <form action="link_add.cgi" method="post">
            <b>Add PicID:</b>
                <input type="hidden" name="groupID" value="$groupID">
                <input type="text" name="picID">
                <input type="submit" value="Add">
            </form>
        };
    }
    
    
    ## list all the pictures
    
    my @pics;
    &list_links_for_album(\@pics, $albumID);
    
    &show_piclist_thumb(\@pics, $albumID, '');

}


########################################
sub show_piclist_thumb{
    my ($pics_ref, $albumID) = @_;

    my @PICS = @$pics_ref;

    my $start = $cgih->param(listStart);
    my $limit = $cgih->param(listLimit) || 20;
    
    @pics = splice (@PICS, $start, $limit);

    my %pic;
    my $i = $start;

    for my $picID (@pics){

        $i++;
        last if ($i >= $start + $limit);

        &get_pic($picID, \%pic);
        
        $pic{title} = '(untitled)' if (!$pic{title});
        if (!$pic{typePublic}){
            $pic{flags} .= '*';
        }
        if (! defined ($owners{$pic{ownerID}})){
            my %user;
            &get_user($pic{ownerID}, \%user);
            $owners{$pic{ownerID}} = $user{username};
        }
        
        my $pic_url = "pic_view.cgi?picID=$picID&albumID=$albumID&dateID=$dateID";

        my $pic_desc;
        $pic_desc .= $pic{description} . '<br>' if ($pic{description});
        $pic_desc .= $pic{comments} . '<br>' if ($pic{comments});
        
        print qq{
            <table>
            <tr>
            <td valign="top"><a href="$pic_url">
                <img src="serve_pic.cgi?mode=thumb&picID=$picID" height="128" width="160" border="0" ></a></td>
            <td valign="top">
                <a href="$pic_url">$pic{title}</a><br>
                $pic_desc
                $pic{width} x $pic{height}<br>
                Content: $pic{rateContent} Image: $pic{rateImage}<br>
                <br>
                $pic{timestamp} - $owners{$pic{ownerID}} $pic{flags}<br>
            </td>
            </tr>
            </table>
        };
    }
    
    $start_prev =  $start - $limit;
    $start_next =  $start + $limit;
    print qq{
        <a href="album_view.cgi?albumID=$albumID&listLimit=$limit&listStart=$start_prev">prev $limit</a>
        <a href="album_view.cgi?albumID=$albumID&listLimit=$limit&listStart=$start_next">next $limit</a>
    };
}

########################################
sub show_piclist_basic{
    my ($pics_ref, $albumID) = @_;

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
        if (! defined ($owners{$pic{ownerID}})){
            my %user;
            &get_user($pic{ownerID}, \%user);
            $owners{$pic{ownerID}} = $user{username};
        }
        print qq{
            <tr>
            <td>$i</td>
            <td nowrap><a href="pic_view.cgi?picID=$picID&albumID=$albumID&dateID=$dateID">$pic{title}</a> $pic{flags}</td>
            <td nowrap>$pic{timestamp}</td>
            <td>&nbsp;&nbsp;</td>
            <td>$owners{$pic{ownerID}}</td>
            </tr>
        };
    }
    
    print qq{
        </table>
    };
    
}
