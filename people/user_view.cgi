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

&header();

&show_heading("user detail");
my $tnmc_cgi = &tnmc::cgi::get_cgih();

my $userID = $tnmc_cgi->param('userID');

&show_user($userID);

&footer("userView");


##################################################################
sub show_user
{
    my ($userID, $junk) = @_;    
    return unless $userID;
    
    my (@cols, $user, $key, %user);
    
    &db_connect();

    @cols = qw (
                username
                fullname
                email
                homepage
                birthdate
                phoneHome
                phoneOffice
                phoneOther
                phoneFido
                phoneTelus
                phoneRogers
                phoneClearnet
                phonePrimary
                phoneTextMail
                address
                blurb
                );
    
    &get_user_extended($userID, \%user);
    &db_disconnect();
    
    print qq 
    {
            <table>
            };
    
    foreach $key (@cols){
        
        if ($key eq 'userID')    {    next;    }
        if ($key eq 'password')    {    next;    }
        
        print qq 
        {    
                <tr valign=top><td><B>$key</B></td>
                    <td>$user{$key}</td>
                </tr>
                };
    }
    
    print qq
    {    <input type="submit" value="Submit">
            </table>
            </form>
            };
}
    
