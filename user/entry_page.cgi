#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::config;

# set up the random number generator
srand;

#############
### Main logic

&tnmc::db::db_connect();
&tnmc::template::header();

&show_full_login();

&tnmc::template::footer();
&tnmc::db::db_disconnect();



##########################################################
#### Sub Procedures
##########################################################

sub show_full_login{
	
    my (@row, $userID, %user, $hits, $sth, $sql);
    
    ### Visitors
    print qq 
    {
        <p>
        <u><b>Visitors:</b></u><br>
        If you are not a regular user and would like to browse the site,
        please login as <b>Demonstration User (demo)</b>.<br>
        <br>
    };
    
    
    ### new account
    print qq{
        <p><br><br>
        <u><b>New Users:</b></u><br>
        <a href="user/create_1.cgi">
        Create a New Account</a><br>
        <br>
        <p>
    };


    ### Enhanced Login
    print qq{
        <p><br><br>
            <form action="user/login.cgi" method="post">
	    <input type="hidden" name="location" value="$tnmc_url">
            <b>Enhanced Login:</b><br>
                        <!-- <select onChange="form.submit();" name="userID"> -->
            <select name="userID" size="1">
                        <option value="0">Pick a user...
                        <option value="0">---------------
                        };

    $sql = "SELECT userID, username, fullname FROM Personal WHERE groupDead != '1' ORDER BY fullname ASC";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql);
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
    $sth->finish();
    
    print qq{
        </select><br>
        <b>Password:</b><br>
        <input type="password" name="password" size="10"><br>
                <input type="submit" value="Login"><br>
                </form>
        <p>
    };

    ### lost password
    print qq{
        <p><br>
            <form action="user/forgot_password.cgi" method="post">
	    <input type="hidden" name="location" value="$tnmc_url">
                <br><b>Lost Passwords:</b><br>
                        <!-- <select onChange="form.submit();" name="userID"> -->
            <select name="userID" size="1">
                        <option value="0">Pick a user...
                        <option value="0">---------------
                        };

    $sql = "SELECT userID, username, fullname FROM Personal WHERE groupDead != '1' ORDER BY fullname ASC";
    $sth = $dbh->prepare($sql);
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
    $sth->finish();
    
    print qq 
    {       </select><br>
            <input type="submit" value="Email me my password"><br>
                        </form>
            <p>
            };


}


##########################################################
#### The end.
##########################################################
