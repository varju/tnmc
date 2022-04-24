#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::user;
use tnmc::config;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

if ($USERID) {
    my @cols = &tnmc::db::db_get_cols_list('Personal');

    my $user = &tnmc::user::get_user($USERID);
    my %user = %$user;

    print qq{
            <form action="user/my_prefs_submit.cgi" method="post">
            <input type="hidden" name="userID" value="$USERID">
            };

    ### Let's not let the demo user change their prefs.
    if ($user{username} eq 'demo') {
        print qq{
                </form>
                <form method="post">
                };
    }

    foreach my $key (@cols) {
        if ($key =~ /^group/) {
            print qq{
                    <input type="hidden" name="$key" value="$user{$key}">
                    };
        }
    }

    &tnmc::template::show_heading("basic info");

    $user{birthdate} = substr($user{birthdate}, 0, 10);
    my %sel_gender = ($user{gender} => 'checked');
    print qq{
            <table>
                                <tr><td><b>username</td>
                                    <td><input type="text" name="username" value="$user{username}"></td>
                                </tr>

                                <tr><td><b>fullname</td>
                                    <td><input type="text" name="fullname" value="$user{fullname}"></td>
                                </tr>
                                
                                <tr><td><b>email</td>
                                    <td><input type="text" name="email" value="$user{email}"></td>
                                </tr>
                                
                                <tr><td><b>password</td>
                                    <td><input type="text" name="password" value="$user{password}"></td>
                                </tr>

                                <tr><td><b>homepage</td>
                                    <td><input type="text" name="homepage" value="$user{homepage}"></td>
                                </tr>

                                <tr><td><b>address</td>
                                    <td><textarea name="address" wrap="virtual" rows="3">$user{address}</textarea></td>
                                </tr>
                                };
    if (!$user{birthdate}) { $user{birthdate} = '0000-00-00'; }
    if ($user{birthdate} eq '0000-00-00') {
        print qq{
                                <tr><td><b>birthdate</td>
                                    <td><input type="text" name="birthdate" value="$user{birthdate}"></td>
                                </tr>
                                };
    }
    else {
        print qq{
                                <tr><td><b>birthdate</td>
                                    <td><input type="hidden" name="birthdate" value="$user{birthdate}">
                                        $user{birthdate}</td>
                                </tr>
                                };
    }
    print qq{
	      <tr><td><b>gender</td>
		  <td>
		  <input type="radio" name="gender" value="F" $sel_gender{F}> Girl 
		  <input type="radio" name="gender" value="M" $sel_gender{M}> Boy
                                </td></tr>
            </table>
            <p>
            };

    &tnmc::template::show_heading("phones and text mail");

    my (%sel_primary_phone, %sel_text_mail, %sel_movie_notify);
    $sel_primary_phone{ $user{phonePrimary} } = 'selected';
    $sel_text_mail{ $user{phoneTextMail} }    = 'selected';

    print qq{
            <table>

            <tr>
            <td><b>Home</b><br>
                <input type="text" name="phoneHome" value="$user{phoneHome}" size="9"></td>
            <td><b>Office</b><br>
                <input type="text" name="phoneOffice" value="$user{phoneOffice}" size="9"></td>
            <td><b>Other</b><br>
                <input type="text" name="phoneOther" value="$user{phoneOther}" size="9"></td>
            </tr>
            <tr>
            <td><b>Fido</b><br>
                <input type="text" name="phoneFido" value="$user{phoneFido}" size="9"></td>
            <td><b>Telus</b><br>
                <input type="text" name="phoneTelus" value="$user{phoneTelus}" size="9"></td>
            <td><b>Rogers</b><br>
                <input type="text" name="phoneRogers" value="$user{phoneRogers}" size="9"></td>
            </tr>
            <tr>
            <td><b>Vstream</b><br>
                <input type="text" name="phoneVstream" value="$user{phoneVstream}" size="9"></td>
            <td><b>Clearnet</b><br>
                <input type="text" name="phoneClearnet" value="$user{phoneClearnet}" size="9"></td>
            </tr>
            <tr>
            <td><b>Primary number</b><br>
                <select name="phonePrimary">
                <option $sel_primary_phone{Home}>Home</option>
                <option $sel_primary_phone{Office}>Office</option>
                <option $sel_primary_phone{Fido}>Fido</option>
                <option $sel_primary_phone{Telus}>Telus</option>
                <option $sel_primary_phone{Rogers}>Rogers</option>
                <option $sel_primary_phone{Clearnet}>Clearnet</option>
                <option $sel_primary_phone{Vstream}>Vstream</option>
                <option $sel_primary_phone{Other}>Other</option>
                </select>
                </td>
            <td valign="top" nowrap><b>Text mail</b><br>
                <select name="phoneTextMail">
                <option $sel_text_mail{none}>none</option>
                <option $sel_text_mail{all}>all</option>
                <option $sel_text_mail{Fido}>Fido</option>
                <option $sel_text_mail{Telus}>Telus</option>
                <option $sel_text_mail{Rogers}>Rogers</option>
                <option $sel_text_mail{Clearnet}>Clearnet</option>
                <option $sel_text_mail{Vstream}>Vstream</option>
                </select>
                </td>
            </tr>
            </table>
            <p>

            };

    &tnmc::template::show_heading("template");
    my $sel_template_colour_bg = $user{template_colour_bg} || '#99ff00';
    my %sel_template_html      = ($user{template_html} => 'selected');
    print qq{
            <table cellpadding="0" border="0" cellspacing="0">
            <tr>
              <td><b>Template</td>
	      <td valign="top" nowrap><br>
                <select name="template_html">
	     };
    my @templates = &tnmc::template::list_templates();
    foreach my $template (@templates) {
        print qq{
	          <option $sel_template_html{$template} value="$template">$template</option>
		};
    }
    print qq{
                </select>
              </td>
            </tr>
            <tr>
              <td><b>Background colour&nbsp;</td>
              <td><input type="text" name="template_colour_bg" value="$sel_template_colour_bg" size="7"></td>
            </tr>
            </table>
	    };

    &tnmc::template::show_heading("messages");
    my %sel_witty_banter;
    $sel_witty_banter{ $user{i_like_silence} } = 'checked';
    my %forward_banter;
    $forward_banter{ $user{forwardWebMessages} } = 'checked';

    print qq{
            <table cellpadding="0" border="0" cellspacing="0">
                                <tr><td><b>Display witty banter?</td>
                <td><b>    <input type="radio" name="i_like_silence" value="0" $sel_witty_banter{0}>on </td>
                <td><b>    <input type="radio" name="i_like_silence" value="1" $sel_witty_banter{1}>off
                                </td></tr>
                                <tr><td><b>Forward witty banter to your email?</td>
                <td><b>    <input type="radio" name="forwardWebMessages" value="1" $forward_banter{1}>on </td>
                <td><b>    <input type="radio" name="forwardWebMessages" value="0" $forward_banter{0}>off
                                </td></tr>
                        </table>
                        };
    print qq{
            <p>
            <input type="image" border=0 src="$tnmc_url/template/submit.gif" alt="Submit Changes">
            </form>
            };
}

&tnmc::template::footer();
&tnmc::db::db_disconnect();
