#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc;
use tnmc::cookie;
use tnmc::db;
use tnmc::template;
use tnmc::config;

# set up the random number generator
srand;

#############
### Main logic

&db_connect();
&header();

&show_full_login();

&footer();
&db_disconnect();



##########################################################
#### Sub Procedures
##########################################################

sub show_full_login{
	
    my (@row, $userID, %user, $hits, $sth, $sql);

                print qq{

            <form action="/user/login.cgi" method="post">
	    <input type="hidden" name="location" value="$tnmc_url">
                <br><b>Login:</b><br>
                        <!-- <select onChange="form.submit();" name="userID"> -->
            <select name="userID" size="1">
                        <option value="0">Pick a user...
                        <option value="0">---------------
                };

                $sql = "SELECT userID, username, fullname FROM Personal WHERE groupDead != '1' ORDER BY fullname ASC";
                $sth = $dbh_tnmc->prepare($sql);
                $sth->execute();
                
                while (@row = $sth->fetchrow_array()){
	    if ($row[1] ne ''){
		$row[1] = "(" . $row[1] . ")";
	    }
            if ($row[0] eq $USERID_LAST_KNOWN){
                            print qq{
                                   <option value="$row[0]" selected>$row[2] $row[1]
                            };
            }else{
                            print qq{
                                   <option value="$row[0]">$row[2] $row[1]
                            };
            }
                };
    
                print qq 
                {       </select><br>
            <b>Password:</b><br>
            <input type="password" name="password" size="10"><br>
                        <input type="image" border=0 src="/template/go_submit.gif" alt="Go"><br>
                        </form>
            <p>

	    <u><b>Where did my username go?</b></u><br>
	    Since there are <b>so</b> many people who want TNMC accounts, we needed to
	    clean up the login form a bit. As an added benefit, infrequent users don't
	    have a silly username that they have to remember. (We already have 3
	    different creative spellings of michael.) So unless you <i>really</i> want a
	    username, the site defaults to a concatenation of your full name.
	    <p>

            <u><b>Notice to Visitors:</b></u><br>
            If you are not a regular user and would like to browse the site,
            please login as <b>Demonstration User (demo)</b>.<br>
            <br>
            <b><a href="/user/create_1.cgi">
            Create a New Account</a></b><br>
            <br>
            <p>
                };
            
	
}


##########################################################
#### The end.
##########################################################
