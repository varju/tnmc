#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
use tnmc::user;
use tnmc::cookie;
require 'pics/PICS.pl';


#############
### Main logic

&db_connect();
&header();

%album;	
$cgih = new CGI;

my %navInfo;
&get_nav_info_from_url(\%navInfo);

$albumID = $cgih->param('albumID');

&nav_show_album($albumID, \%navInfo);

&footer();
&db_disconnect();



################################################################################
sub get_nav_info_from_url{
    my ($nav_ref) = @_;
    
    $nav_ref->{albumID} = $tnmc_cgi->param('albumID');
    $nav_ref->{picID} = $tnmc_cgi->param('picID');
    $nav_ref->{listStart} = $tnmc_cgi->param('listStart') || 0;
    $nav_ref->{listLimit} = $tnmc_cgi->param('listLimit') || 20;
    $nav_ref->{limitContent} = $tnmc_cgi->param('limitContent') || 0;
    $nav_ref->{listType} = $tnmc_cgi->param('listType') || $tnmc_cgi->param('list_type');
    $nav_ref->{listSize} = $tnmc_cgi->param('listSize');
    $nav_ref->{listColumns} = $tnmc_cgi->param('listColumns');
    
    my @pics;
    &list_links_for_album(\@pics, $nav_ref->{albumID});
    $nav_ref->{pics} = \@pics;
    
    my %album;
    &get_album($nav_ref->{albumID}, \%album);
    $nav_ref->{album} = \%album;
}

################################################################################
sub nav_show_album{
    my ($albumID, $nav) = @_;
    
    ## heading
    $backLink = qq{<a href="album_list.cgi"><font color="ffffff">All Albums</font></a> };
    &show_heading("$backLink -> $nav->{album}->{albumTitle}");
    
    ## some info about the album
    &show_album_info_full($nav->{albumID}, $nav->{listType});
    
    ## help the user get around a bit
    &show_album_nav_menu_basic($nav);
    
    ## list all the pictures
    &show_piclist($nav);

    ## help the user get around a bit
    &show_album_nav_menu_full($nav);
    

}

########################################
sub show_album_info_full{
    my ($albumID, $displayLevel)= @_;
    
    &get_album($albumID, \%album);
    
    &get_user($album{albumOwnerID}, \%owner);
    
    if (! $album{albumTitle}){
        $album{albumTitle} = '(Untitled)';
    }
    

    my $admin_links;
    if ($album{albumOwnerID} == $USERID){
        $admin_links = qq{
            - <a href="album_edit_admin.cgi?albumID=$albumID">Edit</a>
            - <a href="album_del.cgi?albumID=$albumID">Del</a>
        };
    }
    
    print qq{
        <p>
        <b>$album{albumTitle}</b> $admin_links<br>
        $album{albumDescription}
        <p>
        Date: $album{albumDateStart} - $album{albumDateEnd}<br>
        Owner: $owner{username}
        <p>
    };


    if ($displayLevel eq 'admin'){
        ## options for the owner
        if ($album{albumOwnerID} == $USERID){
            print qq{<p>
                <hr noshade size="2"><p>
                Release All Pics!!! (to do)

                <form action="link_add.cgi" method="post">
                <b>Add PicID:</b>
                <input type="hidden" name="groupID" value="$groupID">
                <input type="text" name="picID">
                <input type="submit" value="Add">
                </form>
            };
        }
    }
}

########################################
sub show_album_nav_menu_basic{
    my ($nav) = @_;

    print qq{

        <form method="get" action="/pics/album_view.cgi">
        <input type="hidden" name="albumID" value="$nav->{albumID}">
        <input type="hidden" name="listSize" value="$nav->{listSize}">
        <input type="hidden" name="listLimit" value="$nav->{listLimit}">
        <input type="hidden" name="listContents" value="$nav->{listContent}">
        <input type="hidden" name="listColumns" value="$nav->{listColumns}">
        <table cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td>List Type</td>
                <td>Show Range:</td>
            </tr>
            <tr>
                <td>
                    <select name="listType">
                    <option value="$nav->{listType}">$nav->{listType}
                    <option value="$nav->{listType}">------
                    <option value="list">list
                    <option value="thumbnail">thumbnail
                    <option value="grid">grid
                    };
                    print qq{
                        <option value="admin">admin
                    } if (&access_pics_admin());
                    print qq{
                    </select>
                    </td>
                <td>
                    <select name="listStart">
    };

    ## HACK - need better number for album size
    for (my $i = 0; $i <= 200; $i += $nav->{listLimit}){
        if ($nav->{listStart} == $i){
            print "<option selected value=\"$i\">" . ($i + 1) . " - " . ($i + $nav->{listLimit}) . "\n";
        }
        else{
            print "<option value=\"$i\">" . ($i + 1) . " - " . ($i + $nav->{listLimit}) . "\n";
        }
    }

   print qq{
                    </select>
                    </td>
                <td><input type="submit" value="go"></td>
            </tr>
        </table>
        </form>
    };

}


########################################
sub show_album_nav_menu_full{
    my ($nav) = @_;

    my $show_limitContent = pack "a" . ($nav->{limitContent} + 3), "*****";
    my $show_listColumns = $nav->{listColumns} || 'auto';

    print qq{

        <form method="get" action="/pics/album_view.cgi">
        <input type="hidden" name="albumID" value="$nav->{albumID}">
        <table cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td>Display</td>
                <td>Img Size</td>
                <td>Start</td>
                <td>#/Page</td>
                <td>Min Rating</td>
                <td>Columns</td>
            </tr>
            <tr>
                <td>
                    <select name="listType">
                    <option value="$nav->{listType}">$nav->{listType}
                    <option value="$nav->{listType}">------
                    <option value="list">list
                    <option value="thumbnail">thumbnail
                    <option value="grid">grid
                    };
                    print qq{
                        <option value="admin">admin
                    } if (&access_pics_admin());
                    print qq{
                    </select>
                    </td>
                <td>
                    <select name="listSize">
                    <option value="$nav->{listSize}">$nav->{listSize}
                    <option value="$nav->{listSize}">------
                    <option value="mini">mini
                    <option value="thumb">thumb
                    <option value="small">small
                    <option value="big">big
                    </select>
                    </td>
                <td><input type="text" size="5" name="listStart" value="$nav->{listStart}"></td>
                <td><input type="text" size="5" name="listLimit" value="$nav->{listLimit}"></td>
                <td>
                    <select name="limitContent">
                    <option value="$nav->{limitContent}">$show_limitContent
                    <option value="$nav->{limitContent}">
                    <option value="2">*****
                    <option value="1">****
                    <option value="0">***
                    <option value="-1">**
                    <option value="-2">*
                    </select>
                    </td>
                <td>
                    <select name="listColumns">
                    <option value="$nav->{listColumns}">$show_listColumns
                    <option value="$nav->{listColumns}">
                    <option value="0">auto
                    <option value="1">1
                    <option value="2">2
                    <option value="3">3
                    <option value="4">4
                    <option value="5">5
                    <option value="10">10
                    </select>
                    </td>
                <td><input type="submit" value="go"></td>
            </tr>
        </table>
        </form>
    };
            

}

########################################
sub access_pics_admin{
    my ($picID, $albumID) = @_;

    if ($USERID{groupPics} >= 10 ){
        return 1;
    }
    return 0;
}


########################################
sub show_piclist{
    my ($nav) = @_;

    my @PICS = @{$nav->{pics}};
    my $albumID = $nav->{albumID};
    my $listType = $nav->{listType} || 'thumbnail';
    my $listColumns = $nav->{listColumns};
    my $start = $nav->{listStart};
    my $limit = $nav->{listLimit} || 20;
    my $limitContent = $nav->{limitContent};

    ## security: make sure the person should be given admin mode
    if ($listType eq 'admin' && ! &access_pics_admin()){
        $listType = 'thumbnail';
    }
    


    ## automatic columns
    if ($listColumns < 1){
        $listColumns = 1;
        $listColumns = 5 if ($listType eq 'grid');
        $listColumns = 2 if ($listType eq 'thumbnail');
        $listColumns = 2 if ($listType eq 'admin');
    }
    
    ## grab the pics that we'll be using

    @pics = splice (@PICS, $start, $limit);
    
    my %pic;
    my $i = $start;


    ## display the list

    print qq{
        <table cellpadding="0" cellspacing="0" border="0">
    };

    if($listType eq 'admin'){
        print qq{
            <form method="post" action="pic_edit_list_submit.cgi">
            <input type="hidden" name="destination" value="$ENV{REQUEST_URI}">
            <tr><th>&nbsp;</th><th>Rating: Worse < - > Better</th></tr>
        };
    }

    my %static;

    for my $picID (@pics){

        $i++;

        &get_pic($picID, \%pic);

        ## only show the good pics
        next if ($pic{rateContent} <= $limitContent && $nav->{listType} ne 'admin');

        $pic{DISPLAYtitle} = $pic{title} || '(untitled)';

        if (!$pic{typePublic}){
            $pic{flags} .= '*';
        }
        if (! defined ($owners{$pic{ownerID}})){
            my %user;
            &get_user($pic{ownerID}, \%user);
            $owners{$pic{ownerID}} = $user{username};
        }

        my $pic_url = "pic_view.cgi?picID=$picID&albumID=$albumID&dateID=$dateID";
        my $pic_src;

        if ($nav->{listSize} eq 'mini'){
            $pic_src = qq{src="serve_pic.cgi?mode=thumb&picID=$picID" height="64" width="80"};
        }
        elsif ($nav->{listSize} eq 'small'){
            $pic_src = qq{src="serve_pic.cgi?picID=$picID" height="256" width="320"};
        }
        elsif ($nav->{listSize} eq 'big'){
            $pic_src = qq{src="serve_pic.cgi?picID=$picID" height="480" width="640"};
        }
        else{ ## thumb
            $pic_src = qq{src="serve_pic.cgi?mode=thumb&picID=$picID" height="128" width="160"};
        }

        my $pic_desc;
        $pic_desc .= $pic{description} . '<br>' if ($pic{description});
        $pic_desc .= $pic{comments} . '<br>' if ($pic{comments});


        print '<tr>' unless ($static{count} % $listColumns );
        $static{count} ++;

        
        if ($listType eq 'list'){
            
            print qq{
                <tr>
                <td>$i</td>
                <td nowrap><a href="pic_view.cgi?picID=$picID&albumID=$albumID&dateID=$dateID">$pic{DISPLAYtitle}</a> $pic{flags}</td>
                <td nowrap>$pic{timestamp}</td>
                <td>&nbsp;&nbsp;</td>
                <td>$owners{$pic{ownerID}}</td>
                </tr>
            };
        }
        elsif ($listType eq 'grid'){
            print qq{
                <td valign="top"><a href="$pic_url"><img $pic_src alt="$i. $pic{title}" border="0" hspace="1" vspace="1" ></a></td>
            };
        }
        elsif($listType eq 'admin'){
            my %sel_content;
            my %sel_image;
            $sel_content{int($pic{rateContent})} = 'checked';
            $sel_image{int($pic{rateImage})} = 'checked';
            $sel_public{int($pic{typePublic})} = 'selected';
            print qq{
                <td valign="top"><a href="$pic_url">
                    <img $pic_src border="0" ></a></td>
                <td valign="top">
                    <input type="text" name="PIC${picID}_title" value="$pic{title}" size="20"><br>
                    
                    <textarea rows=2 columns=18 wrap="virtual"  name="PIC${picID}_description">$description</textarea><br>
                    
                    <input type="radio" name="PIC${picID}_rateContent" $sel_content{-2} value="-2"><input type="radio" name="PIC${picID}_rateContent" $sel_content{-1} value="-1"><input type="radio" name="PIC${picID}_rateContent" $sel_content{0} value="0"><input type="radio" name="PIC${picID}_rateContent" $sel_content{1} value="1"><input type="radio" name="PIC${picID}_rateContent" $sel_content{2} value="2"> 

                        <select name="PIC${picID}_typePublic">
                        <option $sel_public{1} value="1">show
                        <option $sel_public{0} value="0">hide
                        </select>
                            <br>

                    <input type="radio" name="PIC${picID}_rateImage" $sel_image{-1} value="-1"><input type="radio" name="PIC${picID}_rateImage" $sel_image{0} value="0">
                    Image ($pic{width} x $pic{height})<br>

                    $pic{timestamp} - $owners{$pic{ownerID}} $pic{flags}<br>
                    
                </td>
            };
        }else{

            my $show_listContent = pack "a" . ($pic{rateContent} + 3), "*****";

            print qq{
                <td valign="top"><a href="$pic_url">
                    <img $pic_src border="0" ></a>
                    <br><br></td>
                <td valign="top">
                    <a href="$pic_url"><b>$pic{DISPLAYtitle}</b></a><br>
                    $pic_desc
                    <br>
                    $show_listContent ($pic{rateImage}) -
                    $pic{width} x $pic{height}<br>
                    $pic{timestamp} - $owners{$pic{ownerID}} $pic{flags} $i<br>
                </td>
            };
        }
    }

    print qq{
        </table>
    };
    if ($listType eq 'admin'){
        print qq{
            <input type="submit">
            </form>
        };
    }

}






