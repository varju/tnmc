#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
use tnmc::cookie;
require 'pics/PICS.pl';

{
	#############
	### Main logic

	&db_connect();
	
        &cookie_get();

	%pic;
	$cgih = new CGI;
	$picID = $cgih->param('picID');
	$albumID = $cgih->param('albumID');
	$dateID = $cgih->param('dateID');
	
       	&get_pic($picID, \%pic);
        &get_user($pic{ownerID}, \%owner);


        ## get our list of pictures for navigation
        @PICS;
        if ($albumID){
            &get_album($albumID, \%album);
            &list_links_for_album(\@PICS, $albumID);
        }
        elsif ($dateID){
            &list_links_for_date(\@PICS, $dateID);
        }
        else{
            @PICS = ($picID);
        }

        ## find our current index
        $curr_index = 0;
        foreach $otherPicID (@PICS){
            last if ($picID == $otherPicID);
            $curr_index ++;
        }
            
        
        $album_url = "album_view.cgi?albumID=$albumID";
        $album_prev_index =  ($curr_index - 1) % scalar(@PICS);
        $album_next_index =  ($curr_index + 1) % scalar(@PICS);
        
        $album_prev_url = "pic_view.cgi?picID=$PICS[$album_prev_index]&albumID=$albumID&dateID=$dateID";
        $album_next_url = "pic_view.cgi?picID=$PICS[$album_next_index]&albumID=$albumID&dateID=$dateID";
           
        $next_url = $album_next_url;
        $prev_url = $album_prev_url;

        

        ##############################
        ## get some fancy stuff (timestamp)
        my $sql = "SELECT DATE_FORMAT('$pic{timestamp}', '%b %d %Y (%a) - %l:%i %p')";
        my $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        my ($fancy_timestamp) = $sth->fetchrow_array();
        $sth->finish();
        
        ##############################
        ## Print it all out

        ## say "hi"
        print "Content-type: text/html\n\n";
        print qq{<body bgcolor="000000" text="aaaacc" link="9999ff" vlink="6666cc">};

        ## global and local nav
        &show_nav();

        ## thumbnails
        my $span = $cgih->param('span') || 5;
        my $span = ($span > scalar(@PICS))? scalar(@PICS): $span;
        my $start = $curr_index - int(($span - 1) / 2);
        my $start = (($start + $span - 1) >= scalar(@PICS))? scalar(@PICS) - $span: $start;
        $start = 0 if $start < 0;
        &show_thumb_nav(\@PICS, $start, $start + $span - 1);

        
        ## the big picture
        $scale =  $cgih->param('scale') || 0.5;
        $WIDTH = 1280 * $scale;
        $HEIGHT = 960 * $scale;
        print qq{
            <table align="center" border="0">
                <tr><td colspan="3"><img
                        width="$WIDTH" height="$HEIGHT"
                        src="/pics/serve_pic.cgi?picID=$pic{picID}"
                    ></td></tr>
                <tr>
                    <td valign="top"><b>$pic{title}</b></td>
                    <td valign="top"></td>
                    <td align="right" valign="top">
                        $owner{username} - $fancy_timestamp<td>
                </tr>
                    <tr><td colspan="3">$pic{description}</td></tr>
                    <tr><td colspan="3">$pic{comments}</td></tr>
            </table>

        };

	### Give the (owner && cool people) an edit section:
        if (($USERID && ($pic{ownerID} eq $USERID)) || ( $USERID{groupPics} >= 10)){
            &print_edit_form();
        }


	&db_disconnect();

}


######################################################################
sub show_nav{

    my (%sel);

    ## album navigation stuff
    print qq{
        <table align="center"  cellpadding="0" cellspacing="0" border="0">
        <tr><td nowrap><b>
        <a href="index.cgi">Pics</a> &nbsp; -> &nbsp; 
    };
    if ($albumID){
        print qq{    <a href="album_list.cgi">Albums</a> &nbsp; -> &nbsp; \n};
        print qq{    <a href="$album_url">$album{albumTitle}</a> &nbsp;&nbsp; \n};
    }elsif ($dateID){
        print qq{    <a href="date_list.cgi?dateID=$dateID">$dateID</a>\n};
    }
    print "</b></td></tr> \n";

    ## what-i-want-to-see form
    print qq{
        <tr><td nowrap><b>
        <form>
    };

    ## form elements that we're not allowing configuration of:
    foreach my $key ($cgih->param()){
        next if $key eq 'picID';
        next if $key eq 'span';
        next if $key eq 'scale';
        printf("<input type=\"hidden\" name=\"%s\" value=\"%s\">\n", $key, $cgih->param($key));
    }

    ## span
    my $span = $cgih->param("span") || 5;
    %sel = ($span => 'selected');
    print qq{    <select name="span"> \n};
    print qq{    <option value="-1" $sel{-1}>No Thumbnails \n};
    print qq{    <option value="3" $sel{3}>3 Thumbnails \n};
    print qq{    <option value="5" $sel{5}>5 Thumbnails \n};
    print qq{    <option value="7" $sel{7}>7 Thumbnails \n};
    print qq{    <option value="9" $sel{9}>9 Thumbnails \n};
    print qq{    </select> \n};

    ## span
    my $scale = $cgih->param("scale") || 0.5;
    %sel = ($scale => 'selected');
    print qq{    <select name="scale"> \n};
    print qq{    <option value="4" $sel{4}>400% \n};
    print qq{    <option value="2" $sel{2}>200% \n};
    print qq{    <option value="1" $sel{1}>100% \n};
    print qq{    <option value="0.75" $sel{0.75}>75% \n};
    print qq{    <option value="0.5" $sel{0.5}>50% \n};
    print qq{    <option value="0.33" $sel{0.33}>33% \n};
    print qq{    <option value="0.25" $sel{0.25}>25% \n};
    print qq{    </select> \n};

    ## picID
    print qq{    <select name="picID" onchange="form.submit()"> \n};
    my $index = 0;
    %sel = ($curr_index => 'selected');
    foreach $otherPicID (@PICS){
        &get_pic($otherPicID, \%otherPic);
        print qq{<option value="$otherPicID" $sel{$i}>};
        printf("%4i - %s\n", $i + 1, $otherPic{title});
        $i++;
    }
    print qq{    </select> \n};
    
    ## submit
    print qq{
        <input type="submit" value="go">
        </form>
    };
    
    print qq{
        </td></tr>
        </table>
    };

}

######################################################################
sub show_thumb_nav{

    my ($PICS_ref, $start, $end) = @_;

    print "<table align=\"center\" ><tr>\n";
    for (my $i = $start; $i <= $end; $i++){
        my $url = &make_pic_url($i);
        my $image = "serve_pic.cgi?mode=thumb&picID=@PICS[$i]";

        print "<td>";
        printf("%i<br>", $i + 1);
        print qq{<a href="$url"><img border="0" height="128" width="160" src="$image"></a>};
        print "</td>\n";

    }
    print "</tr></table>\n";

}

######################################################################
sub make_pic_url{
    my ($index) = @_;
    
    my $url = "pic_view.cgi?picID=$PICS[$index]";

    foreach my $key ($cgih->param()){
        next if $key eq 'picID';
        $url .= '&' . $key . '=' . $cgih->param($key);
    }
    return $url;

}    

######################################################################
sub print_edit_form{

    my %typePublic;
    $typePublic{$pic{typePublic}} = 'checked';
    
    print qq{

        
        <hr>

        <form id="owner_form" name="owner_form" action="pic_edit_submit.cgi" method="post">
        <input type="hidden" name="picID" value="$picID">
        <input type="hidden" name="destination" value="">
        <table>

            <tr><td><b>Public</td>
                <td><input type="radio" name="typePublic" value="1" $typePublic{1} size="40"> Yes
                    <input type="radio" name="typePublic" value="0" $typePublic{0} size="40">No
                    <input type="submit" value="Submit">
                    Save and Release next: <a href="javascript:
                        document.owner_form.typePublic[0].checked = true;
                        document.owner_form.destination.value = '$album_next_url';
                        document.owner_form.submit();
                        ">Album</a> |
                    <a href="javascript:
                        document.owner_form.typePublic[0].checked = true;
                        document.owner_form.destination.value = '$date_next_url';
                        document.owner_form.submit();
                        ">Date</a>
                </td>
            </tr>

            <tr><td><b>Title</td>
                <td><input type="text" name="title" value="$pic{title}" size="40"></td>
            </tr>

            <tr><td><b>Description</td>
                <td><textarea name="description" wrap="virtual" cols="40" rows="3">$pic{description}</textarea></td>
            </tr>
            <tr><td><b>Comments</td>
                <td><textarea name="comments" wrap="virtual" cols="40" rows="3">$pic{comments}</textarea></td>
                </tr>
	    <tr><td><b>Image Quality</td>
                <td><input type="text" name="rateImage" value="$pic{rateImage}"> (-10 to 10, 0 is average)</td>
                </tr>
	    <tr><td><b>Content Quality</td>
                <td><input type="text" name="rateContent" value="$pic{rateContent}">(-10 to 10, 0 is average)</td>
                </tr>
	    <tr><td><b>Timestamp</td>
                <td><input type="text" name="timestamp" value="$pic{timestamp}" size="40"></td>
                </tr>

		</table>
		<input type="submit" value="Submit">
                </form>
            };



}

