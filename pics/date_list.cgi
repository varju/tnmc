#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';

{	
    #############
    ### Main logic
    	
    &db_connect();	
    
    &header();
    
    my $cgih = new CGI;
    my $dateID = $cgih->param('dateID');
    my $show = $cgih->param('show');

    ## determine the parts as we like to split them up
    $dateID =~ /^(\d\d\d\d)-?(\d\d)?-?(\d\d)? ?(\d\d)?:?(\d\d)?:?(\d\d)?/;
    my @dateID = ($1, $2, $3, $4, $5, $6, $7);
    my @dateIDSeparators = ('', '-', '-', ' ', ':', ':');

    
    ## make a silly link for the user to see next to the heading.
    my $u_r_here_links = '';
    my $date_temp;
    for ($i = 0; $i <= scalar(@dateID); $i++){
        if (!$dateID[$i+1]){
            $u_r_here_links .= qq{$dateIDSeparators[$i]$dateID[$i]};
            last;
        }
        $date_temp .= $dateIDSeparators[$i] . $dateID[$i];
        $u_r_here_links .= qq{$dateIDSeparators[$i]<a href="date_list.cgi?dateID=$date_temp"><font color="ffffff">$dateID[$i]</font></a>};
    }
    
    ## show the heading
    &show_heading("<a href='date_list.cgi'><font color=ffffff>View pictures by date</font></a> - $u_r_here_links");

    &show_date_listing($dateID, $show);
    
    &footer();
    &db_disconnect();
}


###################################################################
sub show_date_listing{

    my ($dateID, $show) = @_;
    my ($sql, $sth);

    ## determine the parts as we like to split them up  (HACK)
    $dateID =~ /^(\d\d\d\d)-?(\d\d)?-?(\d\d)? ?(\d\d)?:?(\d\d)?:?(\d\d)?/;
    my @dateID = ($1, $2, $3, $4, $5, $6);
    my @dateIDSeparators = ('', '-', '-', ' ', ':', ':');

    while (scalar @dateID &&'' eq pop @dateID){}; # get rid of empty fields at the end.
    my $max_elements_dateID = scalar(@dateID);

    # grab the dates where we have something that we're allowed to look at.
    $sql = "SELECT picID, timestamp FROM Pics
             WHERE ((ownerID = '$USERID') OR typePublic = 1)
               AND (timestamp LIKE '$dateID%')
             ORDER BY timestamp, picID";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();


    my @pics;

    while (($picID, $timestamp) = $sth->fetchrow_array() ){

        push (@pics, $picID);

        # grab the bit of the date that we care about
        $timestamp =~ /^(\d\d\d\d)-?(\d\d)?-?(\d\d)? ?(\d\d)?:?(\d\d)?:?(\d\d)?/;
        my @timestamp = ($1, $2, $3, $4, $5, $6);
        
        $date_option = '';
        for ($i = 0; $i <= $max_elements_dateID + 1; $i++){
            $date_option .= $dateIDSeparators[$i] . $timestamp[$i];
        }

        # only get unique dates
        next if ($date_option eq $last_date_option);
        $last_date_option = $date_option;

        print qq{<a href="date_list.cgi?dateID=$date_option">$date_option</a><br>\n};
    }
    
    $sth->finish();

    $num_pics = scalar(@pics);

    if ($show || $num_pics <= 100){
        print qq{
            <p>
                $num_pics pictures were taken during $dateID
            <p>
        };

        &show_pic_listing(\@pics, '', $dateID);
        
    }else{
        if ($dateID){
            print qq{
                <p>
                <a href="date_list.cgi?dateID=$dateID&show=$num_pics">
                List</a> the $num_pics pictures that were taken during $dateID
                <p>
            };
        }else{
            print qq{
                <p>
                <a href="date_list.cgi?dateID=$dateID&show=$num_pics">
                List</a> all $num_pics pictures.
                <p>
            };
        }
    }

    
}










