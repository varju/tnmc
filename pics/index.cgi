#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'pics/PICS.pl';

{	
    #############
    ### Main logic
    	
    &db_connect();	
    
    &header();
    
    my $cgih = new CGI;
    
    &show_all_albums();
    
#    &show_daily_listing();
    
#    &show_create_album($cgih);
#  
#    if ($cgih->param('date')){
#        &show_my_album($cgih);
#    }
    
    &footer();
    &db_disconnect();
}


###################################################################
sub show_all_albums{

    &show_heading("Albums");

    my @albums;
    &list_albums(\@albums, 
                 "WHERE (( albumOwnerID = '$USERID') OR albumTypePublic >= 1)",
                 "ORDER BY albumDateStart DESC, albumTitle LIMIT 10");


    &show_album_listing(\@albums, );
    print qq{
        <a href="album_list.cgi">More albums...</a>
        <p>
    };
}



###################################################################
sub show_daily_listing{

#    print qq{
#        <form action="album_by_date.cgi" method="get">
#            <table><tr>
#    };

 
    ############################
    ### Date picker

#    print qq{
#        <td>
#        Date:<br>
#        <select name="date">
#            <option value="">All
#    };

    show_heading("View pictures by date");
    print qq{<p>};
    
    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT DATE_FORMAT(timestamp, '%Y-%m') FROM Pics
               WHERE (ownerID = '$USERID') OR typePublic = 1
               ORDER BY timestamp";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    
    while (($date_option) = $sth->fetchrow_array() ){

        # only get unique dates
        next if ($date_option eq $last_date_option);
        $last_date_option = $date_option;

        print qq{<a href="date_list.cgi?dateID=$date_option">$date_option</a><br>\n};
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
                     


    $sth->finish();
#    print qq{
#        <td><input type="submit" value="Go"></td></tr></table>
#        </form>
#    };

}

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







