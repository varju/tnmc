package tnmc::pics::new;

use strict;
use warnings;

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::cgi;
use tnmc::user;
use tnmc::util::date;

use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::show;
use tnmc::pics::link;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub album_get_piclist_from_nav {
    my ($nav) = @_;

    my @pics;

    # TODO: proper selection based on pic rating
    my $min_rating = 0;

    ### HACK: this really should be in a sub-function. (or in a lib file)
    {
        # used to be:
        #
        #&list_links_for_album(\@pics, $nav->{albumID});
        #
        my $dbh     = &tnmc::db::db_connect();
        my $albumID = $nav->{'albumID'};

        my (@row, $sql, $sth);

        $sql = "SELECT l.picID
                  FROM PicLinks as l LEFT JOIN Pics as p USING (picID)
                 WHERE l.albumID = '$albumID'
                   AND ((ownerID = '$USERID') OR typePublic = 1)
                   AND (p.rateContent >= '$min_rating')
                 ORDER BY p.timestamp, p.picID";
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr
\n";
        $sth->execute;
        while (@row = $sth->fetchrow_array()) {
            push(@pics, $row[0]);
        }
        $sth->finish;

    }
    return \@pics;
}

sub get_nav {

    my %nav;
    foreach my $key (&tnmc::cgi::param()) {
        $nav{$key} = &tnmc::cgi::param($key);
    }

    ## KLUDGE: figure out what we're looking at
    my $script = $ENV{'REQUEST_URI'};
    $script =~ /\/([a-z]+)_([a-z]+)\.cgi/;
    $nav{'_nav_select'} = $1;
    $nav{'_nav_view'}   = $2;

    return \%nav;
}

sub show_thumbs {
    my ($piclist, $nav) = @_;

    &tnmc::template::show_heading("Pictures");

    # no pictures... bail
    if (!scalar @$piclist) {
        print "<p>\n";
        print "No Pictures available.<br>\n";
        print "<p>\n";
        return 0;
    }

    ## help the user get around a bit
    &show_album_nav_menu_basic($nav, $piclist);

    ## list all the pictures
    &show_piclist($nav, $piclist);

    ## help the user get around a bit
    &show_album_nav_menu_full($nav, $piclist);

}

sub auth_access_album_edit {
    my ($albumID, $album) = @_;
    use tnmc::security::auth;
    return &_has_access_album('edit', $albumID, $album, $USERID, undef);
}

sub auth_access_album_view {
    my ($albumID, $album) = @_;
    use tnmc::security::auth;
    return &_has_access_album('view', $albumID, $album, $USERID, undef);
}

sub _has_access_album {
    my ($access, $albumID, $album, $userID, $user) = @_;

    # get the info if we have to.
    if (!defined $album) {
        %$album = ();
        &tnmc::pics::album::get_album($albumID, $album);
    }
    if (!defined $userID) {
        $userID = $user->{userID};
    }

    # decide if user has access
    if ($album->{albumOwnerID} == $userID) {
        return 1;
    }
    elsif ($album->{albumTypePublic} eq 2) {
        return 1 if $access eq 'view';
        return 1 if $access eq 'edit';
    }
    elsif ($album->{albumTypePublic} eq 1) {
        return 1 if $access eq 'view';
        return 0 if $access eq 'edit';
    }
    elsif ($album->{albumTypePublic} eq 0) {
        return 0;
    }
    else {
        return 0;
    }
}

sub auth_access_pic_edit {
    my ($picID, $pic) = @_;
    use tnmc::security::auth;
    return &_has_access_pic('edit', $picID, $pic, $USERID, undef);
}

sub auth_access_pic_view {
    my ($picID, $pic) = @_;
    use tnmc::security::auth;
    return &_has_access_pic('view', $picID, $pic, $USERID, undef);
}

sub _has_access_pic {
    my ($access, $picID, $pic, $userID, $user) = @_;

    # get the info if we have to.
    if (!defined $pic) {
        %$pic = ();
        &tnmc::pics::pic::get_pic($picID, $pic);
    }
    if (!defined $userID) {
        $userID = $user->{userID};
    }

    # decide if user has access
    if ($pic->{ownerID} == $userID) {
        return 1;
    }
    elsif ($pic->{typePublic} eq 2) {
        return 1 if $access eq 'view';
        return 1 if $access eq 'edit';
    }
    elsif ($pic->{typePublic} eq 1) {
        return 1 if $access eq 'view';
        return 0 if $access eq 'edit';
    }
    elsif ($pic->{typePublic} eq 0) {
        return 0;
    }
    else {
        return 0;
    }
}

sub show_album_thumb_header {
    my ($albumID, $nav, $piclist) = @_;

    # load info
    my %album;
    &tnmc::pics::album::get_album($albumID, \%album);
    my %owner;
    &tnmc::user::get_user($album{albumOwnerID}, \%owner);

    # set defaults
    my $displayLevel = 'admin';
    $album{albumTitle} ||= '(Untitled)';

    ## heading
    &tnmc::template::show_heading("Album");

    my $edit_links;
    if (&auth_access_album_edit($albumID, \%album)) {
        $edit_links = qq{
            [ <a href="pics/album_edit.cgi?albumID=$albumID">Edit</a>
            - <a href="pics/album_edit_admin.cgi?albumID=$albumID">Admin</a>
            - <a href="pics/album_del.cgi?albumID=$albumID">Del</a>
            - <a href="pics/album_view.cgi?albumID=$albumID">View</a> ]
        };
    }

    my $show_start_date = &tnmc::util::date::format_date('short_date', $album{albumDateStart});
    my $show_end_date   = &tnmc::util::date::format_date('short_date', $album{albumDateEnd});

    print qq{
        <p>
        <b>$album{albumTitle}</b> ($owner{username}) $edit_links<br>
        $show_start_date - $show_end_date<br>
        $album{albumDescription}
        <p>
    };

    ### TODO: proper selection based on rating, etc

}

########################################
sub show_album_nav_menu_basic {
    my ($nav, $piclist) = @_;

    # load info
    my %nav       = %$nav;
    my $listType  = delete($nav{'listType'});
    my $listStart = delete($nav{'listStart'});

    print qq{

        <table cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td>
        <form name="album_basic_nav_menu" id="album_basic_nav_menu" method="get" action="pics/$nav{_nav_select}_thumb.cgi">
    };
    foreach my $key (keys %nav) {
        print qq{        <input type="hidden" name="$key" value="$nav{$key}">\n};
    }
    print qq{
                Display</td>
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
                    <option value="admin">admin
                    </select>
                    </td>
                <td>
                    <select name="listStart">
    };

    # note: make sure listLimit is real or we'll loop forever
    my $listLimit = int($nav{'listLimit'});
    $listLimit = ($listLimit > 0) ? $nav->{'listLimit'} : 20;
    my $max           = scalar(@$piclist);
    my $options_curr  = 0;
    my $options_count = 0;

    for (my $i = 0 ; $i < $max ; $i += $listLimit) {
        last if ($i > 1000);    # don't go crazy, give up after 1000 pics

        my $top = $i + $listLimit;
        $top = $max if ($max < $top);
        $options_count++;

        if ($nav->{listStart} == $i) {
            $options_curr = $options_count - 1;
            print "<option selected value=\"$i\">" . ($i + 1) . " - " . $top . "\n";
        }
        else {
            print "<option value=\"$i\">" . ($i + 1) . " - " . $top . "\n";
        }
    }

    # next, prev link info
    my $options_next = $options_curr + 1;
    my $options_prev = $options_curr - 1;
    $options_next = $options_count if ($options_next > $options_count);
    $options_prev = 0              if ($options_prev < 0);

    print qq{
                    </select>
                    </td>
                <td><input type="submit" value="go"></td>
                    <td> &nbsp;
                    <a href="javascript:
                        document.album_basic_nav_menu.listStart.selectedIndex = $options_prev;
                        document.album_basic_nav_menu.submit();
                    ">Prev</a> -
                    <a href="javascript:
                        document.album_basic_nav_menu.listStart.selectedIndex = $options_next;
                        document.album_basic_nav_menu.submit();
                    ">Next</a></td>
            </tr>
        </table>
        </form>
    };

}

########################################
sub show_album_nav_menu_full {
    my ($nav, $piclist) = @_;

    # load info
    my %nav         = %$nav;
    my $listType    = delete($nav{'listType'});
    my $listSize    = delete($nav{'listSize'});
    my $listStart   = delete($nav{'listStart'});
    my $listLimit   = delete($nav{'listLimit'});
    my $listColumns = delete($nav{'listColumns'});

    # set defaults
    my $show_listColumns = $listColumns || 'auto';

    #
    print qq{
        <form method="get" action="pics/$nav{_nav_select}_thumb.cgi">
    };
    foreach my $key (keys %nav) {
        print qq{        <input type="hidden" name="$key" value="$nav{$key}">\n};
    }
    print qq{
        <table cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td>Display</td>
                <td>Img Size</td>
                <td>Start</td>
                <td>\#/Page</td>
                <td>Columns</td>
            </tr>
            <tr>
                <td>
                    <select name="listType">
                    <option value="$listType">$listType
                    <option value="$listType">------
                    <option value="list">list
                    <option value="thumbnail">thumbnail
                    <option value="grid">grid
                    <option value="admin">admin
                    </select>
                    </td>
                <td>
                    <select name="listSize">
                    <option value="$listSize">$listSize
                    <option value="$listSize">------
                    <option value="mini">mini
                    <option value="thumb">thumb
                    <option value="small">small
                    <option value="big">big
                    </select>
                    </td>
                <td><input type="text" size="5" name="listStart" value="$listStart"></td>
                <td><input type="text" size="5" name="listLimit" value="$listLimit"></td>
                 <td>
                    <select name="listColumns">
                    <option value="$listColumns">$show_listColumns
                    <option value="$listColumns">
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
sub show_piclist {
    my ($nav, $piclist) = @_;

    ## get info
    my %nav          = %$nav;
    my $albumID      = $nav{albumID};
    my $listType     = delete($nav{listType});
    my $listColumns  = delete($nav{listColumns});
    my $start        = delete($nav{listStart});
    my $limit        = delete($nav{listLimit});
    my $listSize     = delete($nav{listSize});
    my $limitContent = delete($nav{limitContent});

    ## security: make sure the person should be given admin mode
    if ($listType eq 'admin' && !$USERID) {
        $listType = 'grid';
    }

    ## get defaults
    if (   ($listSize ne 'mini')
        && ($listSize ne 'big')
        && ($listSize ne 'small'))
    {
        $listSize = 'thumb';
    }
    if (   ($listType ne 'list')
        && ($listType ne 'admin')
        && ($listType ne 'thumbnail'))
    {
        $listType = 'grid';
    }
    $limit ||= 20;
    if ($listColumns < 1) {    ## automatic columns
        $listColumns = 1;
        $listColumns = 5 if ($listType eq 'grid');
        $listColumns = 2 if ($listType eq 'thumbnail');
        $listColumns = 2 if ($listType eq 'admin');
    }
    my $nav_query = &make_nav_url($nav);

    ## grab the pics that we'll be using
    my @pics = splice(@$piclist, $start, $limit);

    my %pic;
    my $i = $start;

    ## display the list

    print qq{
        <table cellpadding="0" cellspacing="0" border="0">
    };

    if ($listType eq 'admin') {
        print qq{
            <form method="post" action="pics/bulk_edit_submit.cgi">
            <input type="hidden" name="destination" value="$ENV{REQUEST_URI}">
            <tr><th>&nbsp;</th><th>Rating: Worse < - > Better</th></tr>
        };
    }

    my %static;

    ### HACK!!! (maybe part of get_pic_url?)
    my $list_picHeight;
    my $list_picWidth;
    if ($listSize eq 'mini') {
        $list_picHeight = 64;
        $list_picWidth  = 80;
    }
    elsif ($listSize eq 'thumb') {
        $list_picHeight = 128;
        $list_picWidth  = 160;
    }
    elsif ($listSize eq 'small') {
        $list_picHeight = 256;
        $list_picWidth  = 320;
    }
    elsif ($listSize eq 'big') {
        $list_picHeight = 480;
        $list_picWidth  = 640;
    }

    for my $picID (@pics) {

        ## loop-related stuff
        $i++;
        print '<tr>' unless ($static{count} % $listColumns);
        $static{count}++;

        ## get pic info
        &tnmc::pics::pic::get_pic($picID, \%pic);

        my $slide_url = "pics/$nav{_nav_select}_slide.cgi?picID=$picID&$nav_query";
        my $img_url   = &tnmc::pics::pic::get_pic_url($picID, [ 'mode' => $listSize ]);
        my $img_src   = qq{src="$img_url" height="$list_picHeight" width="$list_picWidth"};
        my $pic_src   = $img_src;
        my $can_edit =
          (($pic{'typePublic'}) || ($pic{'ownerID'} eq $tnmc::security::auth::USERID));

        ### showpic: list
        if ($listType eq 'list') {

            my %owner;
            &tnmc::user::get_user($pic{ownerID}, \%owner);

            my $DISPLAYtitle = $pic{title} || '(untitled)';
            print qq{
                <tr>
                <td>$i</td>
                <td nowrap><a href="$slide_url">
                           $DISPLAYtitle</a></td>
                <td nowrap>$pic{timestamp}</td>
                <td>&nbsp;&nbsp;</td>
                <td>$owner{username}</td>
                </tr>
            };
        }
        ### showpic: grid
        elsif ($listType eq 'grid') {
            print qq{
                <td valign="top"><a href="$slide_url">
                <img $pic_src alt="$i. $pic{title}" border="0" hspace="1" vspace="1" >
                </a></td>
            };
        }
        ### showpic: thumb
        elsif ($listType eq 'thumbnail') {

            my $DISPLAYtitle = $pic{title} || '(untitled)';
            my $pic_desc;
            $pic_desc .= $pic{description} . '<br>' if ($pic{description});
            $pic_desc .= $pic{comments} . '<br>'    if ($pic{comments});

            my $show_listContent = pack "a" . ($pic{rateContent} + 3), "*****";

            print qq{
                <td valign="top"><a href="$slide_url">
                    <img $pic_src border="0" ></a>
                    <br><br></td>
                <td valign="top">
                    <b><a href="$slide_url">$DISPLAYtitle</a></b><br>
                    $pic_desc
                    <br>
                    $i $show_listContent ($pic{width}&nbsp;x&nbsp;$pic{height})<br>
                    $pic{timestamp}<br>
                </td>
            };
        }
        ### showpic: admin - can edit
        elsif (($listType eq 'admin') && $can_edit) {

            my %owner;
            &tnmc::user::get_user($pic{ownerID}, \%owner);

            my %sel_content;
            my %sel_image;
            my %sel_public;
            $sel_content{ int($pic{rateContent}) } = 'checked';
            $sel_image{ int($pic{rateImage}) }     = 'checked';
            $sel_public{ int($pic{typePublic}) }   = 'selected';

            ### pic, title, description
            print qq{
                <td valign="top"><a href="$slide_url">
                    <img $pic_src border="0" ></a></td>
                <td valign="top">
                    <input type="text" name="PIC${picID}_title" value="$pic{title}" size="20"><br>

                    <textarea rows=2 columns=18 wrap="virtual"  name="PIC${picID}_description">$pic{description}</textarea><br>
            };

            ### other usefull info
            print qq{
                    $i. $pic{timestamp} - $owner{username}
            };

            ### edit/admin links
            if ($USERID eq $pic{ownerID}) {
                print qq{
                    &\#149;   <a href="pics/pic_edit.cgi?picID=$picID">edit</a>
                    <br>
                };
            }

            ### width/height
            print qq{
                    ($pic{width} x $pic{height})<br>
            };

            ### rating
            print qq{
                    <input type="radio" name="PIC${picID}_rateContent" $sel_content{-2} value="-2"><input type="radio" name="PIC${picID}_rateContent" $sel_content{-1} value="-1"><input type="radio" name="PIC${picID}_rateContent" $sel_content{0} value="0"><input type="radio" name="PIC${picID}_rateContent" $sel_content{1} value="1"><input type="radio" name="PIC${picID}_rateContent" $sel_content{2} value="2">
            };

            ### access control
            if ($USERID == $pic{ownerID}) {
                print qq{
                        <select name="PIC${picID}_typePublic">
                        <option $sel_public{2} value="2">view/edit
                        <option $sel_public{1} value="1">view
                        <option $sel_public{0} value="0">hidden
                        </select>
                };
            }

            ### image rating
#print qq{
#        <br>
#        <input type="radio" name="PIC${picID}_rateImage" $sel_image{-1} value="-1"><input type="radio" name="PIC${picID}_rateImage" $sel_image{0} value="0">
#        Image<br>
#};

            ### album info
            my @valid_albums;
            &tnmc::pics::album::list_valid_albums(\@valid_albums, $pic{'timestamp'},);
            my @pic_albums;
            &tnmc::pics::link::list_links_for_pic(\@pic_albums, $picID);
            if (scalar(@valid_albums)) {
                push @pic_albums, 0;    #allow creation of a new link
            }
            foreach my $albumID (@pic_albums) {
                my %album;
                if ($albumID) {
                    &tnmc::pics::album::get_album_cache($albumID, \%album);
                    my $link = &tnmc::pics::link::get_link($picID, $albumID,);

                    # print current album separately in case it's not in valid list
                    print "<select name=\"LINK$link->{'linkID'}_albumID\">\n";
                    print "<option  value=\"$albumID\">$albumID. $album{'albumTitle'}</option>\n";

                    if (!&auth_access_album_edit($albumID, \%album)) {
                        print "</select>\n";
                        next;
                    }

                }
                else {
                    print "<select name=\"NEWLINK${picID}_albumID\">\n";
                }
                print "<option value=\"0\">(none)</option>\n";
                print "<option value=\"$albumID\">-----</option>\n";
                foreach my $valid_albumID (@valid_albums) {
                    my %valid_album;
                    &tnmc::pics::album::get_album_cache($valid_albumID, \%valid_album);
                    print "<option value=\"$valid_albumID\">$valid_albumID. $valid_album{'albumTitle'}</option>\n";
                }
                print "</select><br>\n";

            }

            ### the end
            print qq{
                </td>
            };
        }
        ### showpic: admin - can NOT edit
        elsif ($listType eq 'admin') {

            my $DISPLAYtitle = $pic{title} || '(untitled)';
            my $pic_desc;
            $pic_desc .= $pic{description} . '<br>' if ($pic{description});
            $pic_desc .= $pic{comments} . '<br>'    if ($pic{comments});

            my $show_listContent = pack "a" . ($pic{rateContent} + 3), "*****";

            print qq{
                <td valign="top"><a href="$slide_url">
                    <img $pic_src border="0" ></a>
                    <br><br></td>
                <td valign="top">
                    <b><a href="$slide_url">$DISPLAYtitle</a></b><br>
                    $pic_desc
                    <br>
                    $i $show_listContent ($pic{width}&nbsp;x&nbsp;$pic{height})<br>
                    $pic{timestamp}<br>
                </td>
            };
        }
    }

    print qq{
        </table>
    };
    if ($listType eq 'admin') {
        print qq{
            <input type="submit" value="Save Changes">
            </form>
        };
    }

}

#### slide code

sub show_album_slide_header {
    my ($nav, $piclist) = @_;

    my $albumID   = $nav->{'albumID'};
    my $listLimit = 20;
    my $index     = &array_get_index($piclist, $nav->{'picID'});
    my $listStart = int($index / $listLimit) * $listLimit;

    my %album;
    &tnmc::pics::album::get_album($albumID, \%album);

    my $album_url =
      "pics/$nav->{_nav_select}_thumb.cgi?albumID=$nav->{albumID}&listStart=$listStart&listLimit=$listLimit";

    ## album navigation stuff
    print qq{
        <b>
        <a href="/">TNMC</a> &nbsp; -> &nbsp;
        <a href="pics/index.cgi">Pics</a> &nbsp; -> &nbsp;
        <a href="pics/album_list.cgi">Albums</a> &nbsp; -> &nbsp;
        <a href="$album_url">$album{albumTitle}</a> &nbsp; -> &nbsp;
        Slideshow &nbsp;&nbsp;
        </b>
    };
}

sub show_slide {
    my ($nav, $piclist) = @_;

    # show slideshow nav
    &show_slide_nav_menu_basic($nav, $piclist);

    # show slideshow thumbs
    &show_slide_thumbnails($nav, $piclist);

    # show slideshow pic
    &show_slide_pic($nav, $piclist);
}

sub array_get_index {
    my ($array, $element) = @_;

    my $index = 0;
    foreach my $item (@$array) {
        if ($item eq $element) {
            return $index;
        }
        else {
            $index++;
        }
    }
    return undef();
}

sub show_slide_nav_menu_basic {
    my ($nav, $piclist) = @_;

    ## get info
    my %nav        = %$nav;
    my $picID      = delete($nav{'picID'});
    my $scale      = delete($nav{'scale'});
    my $span       = delete($nav{'span'});
    my $play_delay = int(delete($nav{'play_delay'}));
    my $index      = &array_get_index($piclist, $picID);
    my $list_max   = scalar(@$piclist);

    ## javascript
    my $js_next = $index + 1;
    my $js_prev = $index - 1;
    print "
        <script language=\"javascript\">
        function slide_next(){
            if ($js_next < $list_max){
                document.slide_nav_menu.picID.selectedIndex = $js_next;
                document.slide_nav_menu.submit();
            }
        }
        function slide_prev(){
            if ($js_prev > 0){
                document.slide_nav_menu.picID.selectedIndex = $js_prev;
                document.slide_nav_menu.submit();
            }
        }
        function play_start(){
            if ($play_delay > 0){
                setTimeout('slide_next()', 1000 * $play_delay)
            }
        }
        </script>
    ";

    ## show the menu
    print qq{
        <table cellpadding="0" cellspacing="0" border="0">
        <tr><td nowrap><b>
        <form name="slide_nav_menu">
    };

    ## form elements that we're not allowing configuration of:
    foreach my $key (keys %nav) {
        printf("<input type=\"hidden\" name=\"%s\" value=\"%s\">\n", $key, $nav->{$key});
    }

    ## piclist
    my %sel = ($index => 'selected');
    my $i   = 0;
    print qq{    <select name="picID" onchange="form.submit()"> \n};
    foreach my $otherPicID (@$piclist) {
        my %otherPic;
        &tnmc::pics::pic::get_pic($otherPicID, \%otherPic);
        print qq{<option $sel{$i} value="$otherPicID">};
        printf("%4i - %s\n", $i + 1, $otherPic{title});
        $i++;
    }
    print qq{    </select> \n};

    print "<br>\n";

    ## scale
    $scale ||= 'auto';
    %sel = ($scale => 'selected');
    print qq{    <select name="scale"> \n};
    print qq{    <option value="auto" $sel{auto}>auto-scale \n};
    print qq{    <option value="4" $sel{4}>400% \n};
    print qq{    <option value="2" $sel{2}>200% \n};
    print qq{    <option value="1" $sel{1}>100% \n};
    print qq{    <option value="0.75" $sel{0.75}>75% \n};
    print qq{    <option value="0.5" $sel{0.5}>50% \n};
    print qq{    <option value="0.33" $sel{0.33}>33% \n};
    print qq{    <option value="0.25" $sel{0.25}>25% \n};
    print qq{    <option value="0.1" $sel{0.10}>10% \n};
    print qq{    </select> \n};

    ## thumbnails (span)
    $span ||= 0;
    %sel = ($span => 'selected');
    print qq{    <b>Thumbnails</b>};
    print qq{    <select name="span"> \n};
    print qq{    <option value="-1" $sel{-1}>None \n};
    print qq{    <option value="3" $sel{3}>3  \n};
    print qq{    <option value="5" $sel{5}>5  \n};
    print qq{    <option value="5" $sel{6}>6  \n};
    print qq{    <option value="7" $sel{7}>7  \n};
    print qq{    <option value="5" $sel{8}>8  \n};
    print qq{    <option value="9" $sel{9}>9  \n};
    print qq{    <option value="5" $sel{10}>10  \n};
    print qq{    <option value="5" $sel{20}>20  \n};
    print qq{    </select> \n};

    ## playback
    $play_delay ||= 0;
    %sel = ($play_delay => 'selected');
    print qq{    <b>Play</b>};
    print qq{    <select name="play_delay"> \n};
    print qq{    <option value="-1" $sel{-1}>None \n};
    print qq{    <option value="5" $sel{5}>5 sec \n};
    print qq{    <option value="10" $sel{10}>10 sec \n};
    print qq{    <option value="15" $sel{15}>15 sec \n};
    print qq{    <option value="30" $sel{30}>30 sec \n};
    print qq{    <option value="60" $sel{60}>1 min \n};
    print qq{    </select>};

    if ($play_delay > 0) {
        print qq{
           <script language="javascript">
           top.onload = play_start;
           </script>
        };
    }

    ## submit
    print qq{
        <input type="submit" value="go">
        </form>
    };

    ## the end
    print qq{
        </td></tr>
        </table>
    };

}

sub show_slide_thumbnails {
    my ($nav, $piclist) = @_;

    ## get info
    my %nav  = %$nav;
    my $max  = scalar(@$piclist);
    my $span = $nav->{'span'} || 0;
    $span = ($span > $max) ? $max : $span;

    return if (!$span);    # no thumbnails

    my $picID = delete($nav{'picID'});
    my $index = &array_get_index($piclist, $picID);
    my $start = int($index / $span) * $span;

    my $end     = $start + $span - 1;
    my $end     = ($max <= $end) ? $max - 1 : $end;
    my $nav_url = &make_nav_url(\%nav);

    print "<table><tr>\n";
    for (my $i = $start ; $i <= $end ; $i++) {

        my $target_picID = @{$piclist}[$i];
        my %target_pic;
        &tnmc::pics::pic::get_pic($target_picID, \%target_pic);
        my $url   = "pics/$nav->{_nav_select}_slide.cgi?picID=$target_picID&$nav_url";
        my $image = &tnmc::pics::pic::get_pic_url($target_picID, [ 'mode' => 'thumb' ]);

        print "<td>";
        printf("%i - %18.18s<br>", $i + 1, $target_pic{'title'});
        print qq{<a href="$url"><img border="0" height="128" width="160" src="$image"></a>};
        print "</td>\n";

    }
    print "</tr></table><br>\n";

}

sub show_slide_pic {
    my ($nav, $piclist) = @_;

    ## get info
    my $picID = $nav->{'picID'};
    my $scale = $nav->{'scale'};

    my %pic;
    &tnmc::pics::pic::get_pic($picID, \%pic);

    my %owner;
    &tnmc::user::get_user($pic{ownerID}, \%owner);

    ## setup the edit links
    my $edit_link;
    if ($USERID && (($pic{ownerID} eq $USERID) || $USERID{groupPics} >= 100)) {
        $edit_link = qq{
            [ <a href="pics/pic_edit.cgi?picID=$picID">Edit</a>
            - <a href="pics/pic_edit_admin.cgi?picID=$picID">Admin</a> ]
        };
    }

    ## setup the fancy timestamp;
    my $sql = "SELECT DATE_FORMAT('$pic{timestamp}', '%a, %b %d %Y - %l:%i %p')";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($fancy_timestamp) = $sth->fetchrow_array();
    $sth->finish();

    ## setup the big picture
    $scale = $nav->{'scale'} || 'auto';
    if ($scale eq 'auto') {

        my $min_pic_width = 500;
        my $max_pic_width = 999;
        if ($pic{width} < $min_pic_width) {
            $scale = 1 + int($min_pic_width / $pic{width});
        }
        elsif ($pic{width} > $max_pic_width) {
            $scale = (1 / int($pic{width} / $min_pic_width));
        }
        else {
            $scale = 1;
        }
    }

    my $WIDTH  = $pic{width} * $scale;
    my $HEIGHT = $pic{height} * $scale;

    #    my $img_src = &tnmc::pics::pic::get_pic_url($picID, ['mode'=>'full']);
    my $img_src = "pics/serve_pic.cgi?picID=$picID";

    ## print it all out
    print qq{
        <table align="center" border="0">
            <tr><td>
                    <a href="javascript: slide_prev();">prev</a> -
                    <a href="javascript: slide_next();">next</a>
                    </td>
                </tr>
            <tr><td colspan="2"><img
                width="$WIDTH" height="$HEIGHT"
                    src="$img_src"
                ></td></tr>
            <tr>
                <td valign="top"><b>$pic{title}</b></td>
                <td valign="top" align="right">
                    ($owner{username}) - $fancy_timestamp
                    $edit_link
                    <td>
            </tr>
                <tr><td colspan="2">$pic{description}</td></tr>
                <tr><td colspan="2">$pic{comments}</td></tr>
        </table>
    };

}

sub make_nav_url {
    require tnmc::util::url;

    my ($nav) = @_;
    return join('&',
        (map { &tnmc::util::url::url_encode($_) . '=' . &tnmc::util::url::url_encode($nav->{$_}) } (keys(%$nav))));
}

return 1;

