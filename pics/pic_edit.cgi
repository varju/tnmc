#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::user;
use tnmc::cgi;

use tnmc::pics::pic;
use tnmc::pics::new;

#############
### Main logic

&tnmc::template::header();

my %pic;
my $picID = &tnmc::cgi::param('picID');

&tnmc::pics::pic::get_pic($picID, \%pic);

# show the user a scaled down pic
my $pic_img = &tnmc::pics::pic::get_pic_url($picID, [ 'mode' => 'big' ]);
print qq{  <img width="320" src="$pic_img">\n};

# give admin users a link
print qq{  <br><a href="pics/pic_edit_admin.cgi?picID=$picID">Admin</a>\n} if ($USERID{groupPics} >= 100);

# Give the owner an edit section:
if (&tnmc::pics::new::auth_access_pic_edit($picID, \%pic)) {
    &show_pic_edit_form();
}
else {
    print "You don't have permission to edit thie pic";
}
if (&tnmc::pics::new::auth_access_pic_view($picID, \%pic)) {

    # show the exif info
    &tnmc::template::show_heading("Exif info");
    my $exif = &tnmc::pics::pic::get_exif($picID);
    print "<table>";
    foreach my $key (keys %$exif) {
        print "<tr><td>$key</td> <td>$exif->{$key}</td></tr>\n";
    }
    print "</table>";

}

&tnmc::template::footer();

#
# subs
#

######################################################################
sub show_pic_edit_form {
    my ($pic) = @_;

    my %pic;
    &tnmc::pics::pic::get_pic($picID, \%pic);

    my %typePublic;
    $typePublic{ $pic{typePublic} } = 'selected';

    my %sel_content;
    my %sel_image;
    my %sel_normalize;
    $sel_content{ int($pic{rateContent}) } = 'checked';
    $sel_image{ int($pic{rateImage}) }     = 'checked';
    $sel_normalize{ int($pic{normalize}) } = 'checked';

    print qq{

        <form action="pics/pic_edit_submit.cgi" method="post">
        <input type="hidden" name="picID" value="$picID">
        <input type="hidden" name="destination" value="">
        <input type="submit" value="Submit">
        <table>

            <tr><td><b>Title</td>
                <td><input type="text" name="title" value="$pic{title}" size="30"></td>
            </tr>

            <tr><td><b>Description</td>
                <td><textarea name="description" wrap="virtual" cols="30" rows="3">$pic{description}</textarea></td>
            </tr>
	    <tr><td><b>Rating</td>
                <td>low
                    <input type="radio" name="rateContent" $sel_content{-2} value="-2"><input type="radio" name="rateContent" $sel_content{-1} value="-1"><input type="radio" name="rateContent" $sel_content{0} value="0"><input type="radio" name="rateContent" $sel_content{1} value="1"><input type="radio" name="rateContent" $sel_content{2} value="2"> high
                    </td>
                </tr>
	    <tr><td><b>Image Quality</td>
                <td>

                    <input type="radio" name="rateImage" $sel_image{-1} value="-1"> bad <input type="radio" name="rateImage" $sel_image{0} value="0"> good

                </tr>
	    <tr><td><b>Normalize</td>
                <td>

                    <input type="radio" name="normalize" $sel_normalize{0} value="0"> no <input type="radio" name="normalize" $sel_normalize{1} value="1"> yes

                </tr>
	    <tr><td><b>OwnerID</td>
                <td><select name="ownerID">
    };

    my $user_list_ref = &tnmc::user::get_user_list();
    foreach $username (sort keys %$user_list_ref) {
        my $selected = 'selected' if ($pic{ownerID} == $user_list_ref->{$username});
        print qq{<option $selected value="$user_list_ref->{$username}">$username\n};
    }

    print qq{
                     </select>
                     </td>
                </tr>
            };
    if ($USERID == $pic{ownerID}) {
        print qq{
                    <tr><td><b>Access</td>
                        <td>
                        <select name="typePublic">
                        <option $typePublic{2} value="2">public view/edit
                        <option $typePublic{1} value="1">public view
                        <option $typePublic{0} value="0">hidden
                            </select>
                        </td>
                    </tr>
                };
    }

    print qq{

	    <tr><td><b>Timestamp</td>
                <td><input type="text" name="timestamp" value="$pic{timestamp}" size="30"></td>
                </tr>

		</table>
		<input type="submit" value="Submit">
                </form>
    };

}

