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

#############
### Main logic

&db_connect();
&header();

if ($USERID){ 
    my @cols = &db_get_cols_list('Personal');

    my %user;
    &get_user($USERID, \%user);
    
    print qq{
            <form action="my_prefs_submit.cgi" method="post">
            <input type="hidden" name="userID" value="$USERID">
            };
    
    ### Let's not let the demo user change their prefs.
    if ($user{username} eq 'demo'){
        print qq{
                </form>
                <form method="post">
                };
    }
    
    foreach my $key (@cols){
        if ($key =~ /^group/){
            print qq{
                    <input type="hidden" name="$key" value="$user{$key}">
                    };
        }
    }
    
    
    &show_heading ("basic info");
    
    $user{birthdate} = substr($user{birthdate}, 0, 10);
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
    if (!$user{birthdate}) {    $user{birthdate} = '0000-00-00';}
    if ($user{birthdate} eq '0000-00-00'){
        print qq{
                                <tr><td><b>birthdate</td>
                                    <td><input type="text" name="birthdate" value="$user{birthdate}"></td>
                                </tr>
                                };
    }else{
        print qq{
                                <tr><td><b>birthdate</td>
                                    <td><input type="hidden" name="birthdate" value="$user{birthdate}">
                                        $user{birthdate}</td>
                                </tr>
                                };
    }
    print qq{

            </table>
            <p>
            };

    &show_heading ("phones and text mail");
    
    my (%sel_primary_phone, %sel_text_mail, %sel_movie_notify);
    $sel_primary_phone{$user{phonePrimary}} = 'selected';
    $sel_text_mail{$user{phoneTextMail}} = 'selected';
    
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
    
    &show_heading("movies");
    
    $sel_movie_notify{$user{movieNotify}} = 'checked';
    
    
    print qq{
            <table cellpadding="0" border="0" cellspacing="0">
                                
                                <tr><td><b>Movie notification?</td>
                <td><b>    <input type="radio" name="movieNotify" value="1" $sel_movie_notify{1}>on </td>
                <td><b>    <input type="radio" name="movieNotify" value="0" $sel_movie_notify{0}>off
                                </td></tr>
                        </table>
                        <br>
                        };

    &show_heading("pics");
    my %sel_random_pic;
    $sel_random_pic{$user{I_am_a_misanthrope}} = 'checked';
    
    
    print qq{
            <table cellpadding="0" border="0" cellspacing="0">
                                
                                <tr><td><b>Random nav-bar Picture?</td>
                <td><b>    <input type="radio" name="I_am_a_misanthrope" value="0" $sel_random_pic{0}>on </td>
                <td><b>    <input type="radio" name="I_am_a_misanthrope" value="1" $sel_random_pic{1}>off
                                </td></tr>
                        </table>
                        };

    &show_heading("colours");
    my $sel_colour_bg = $user{colour_bg} || '#99ff00';
    print qq{
            <table cellpadding="0" border="0" cellspacing="0">
            <tr>
              <td><b>Background colour&nbsp;</td>
              <td><input type="text" name="colour_bg" value="$sel_colour_bg" size="7"></td>
            </tr>
            </table>
	    };

    print qq{
            <p>
            <input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
            </form>
            }; 
}

&footer();
db_disconnect();
