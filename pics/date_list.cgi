#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::cookie;
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




#    print qq{
#        </select>
#        </td>
#    };

    ############################
    ### Owner
#    print qq{
#        <td>
#        Owner:<br>
#        <select name="owner">
#            <option value="">All
#    };
#
#    # grab the dates where we have something that we're allowed to look at.
#    my $sql = "SELECT ownerID FROM Pics
#               WHERE (ownerID = '$USERID') OR typePublic = 1
#               ORDER BY ownerID";
#    my $sth = $dbh_tnmc->prepare($sql);
#    $sth->execute();
#
#    while (($option) = $sth->fetchrow_array() ){
#
#        # only get unique dates
#        next if ($option eq $last_option);
#        $last_option = $option;
#
#        my $sel = '';
#        if ($owner eq $option){
#            $sel = 'selected';
#        }
#        my %user;
#        &get_user($option, \%user);
#
#        print "<option $sel>$user{username}\n";
#    }
#    print qq{
#        </select>
#        </td>
#    };

#    print qq{
#        <td><input type="submit" value="Go"></td></tr></table>
#        </form>
#    };


###################################################################
sub generate_my_album{
    my ($cgih) = @_;
    
    my $date = $cgih->param('date');
    my $owner = $cgih->param('owner');

    # make the sql call;
    my $sql = "SELECT picID 
               FROM Pics 
               WHERE (1)
               ";
    
    if ($date){    $sql .= " AND (DATE_FORMAT(timestamp, '%Y-%m-%d') = '$date')";   }
    if ($owner){   $sql .= " AND (ownerID = '$owner')";   }
    if ($date){    $sql .= " AND (DATE_FORMAT(timestamp, '%Y-%m-%d') = '$date')";   }


    $sql .= " ORDER BY timestamp, picID";
 

    ## grab the ids from the db.
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();

    my @LIST;
    while ( ($picID) = $sth->fetchrow_array() ){
        push (@LIST , $picID);

    }

    return @LIST;
}



######################################################################
sub show_create_album{

    my ($cgih) = @_;

    my $date = $cgih->param('date');
    my $owner = $cgih->param('owner');

    print qq{
        <form action="album_by_date.cgi" method="get">
            <table><tr>
    };


    ############################
    ### Date picker
    print qq{
        <td>
        Date:<br>
        <select name="date">
            <option value="">All
    };

    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT DATE_FORMAT(timestamp, '%Y-%m-%d') FROM Pics
               WHERE (ownerID = '$USERID') OR typePublic = 1
               ORDER BY timestamp";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();

    while (($date_option) = $sth->fetchrow_array() ){

        # only get unique dates
        next if ($date_option eq $last_date_option);
        $last_date_option = $date_option;

        my $sel = '';
        if ($date eq $date_option){
            $sel = 'selected';
        }

        print "<option $sel>$date_option\n";
    }
    print qq{
        </select>
        </td>
    };

    ############################
    ### Owner
    print qq{
        <td>
        Owner:<br>
        <select name="owner">
            <option value="">All
    };

    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT ownerID FROM Pics
               WHERE (ownerID = '$USERID') OR typePublic = 1
               ORDER BY ownerID";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();

    while (($option) = $sth->fetchrow_array() ){

        # only get unique dates
        next if ($option eq $last_option);
        $last_option = $option;

        my $sel = '';
        if ($owner eq $option){
            $sel = 'selected';
        }
        my %user;
        &get_user($option, \%user);

        print "<option $sel>$user{username}\n";
    }
    print qq{
        </select>
        </td>
    };
                     





    $sth->finish();
    print qq{
        <td><input type="submit" value="Go"></td></tr></table>
        </form>
    };

}








