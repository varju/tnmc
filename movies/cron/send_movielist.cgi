#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::config;
use tnmc::db;
use tnmc::general_config;
use tnmc::movies::movie;
use tnmc::movies::show;

    #############
    ### Main logic

    &db_connect();
#    print "Content-type: text/html\n\n<pre>";
#    &print_email_movielist(">-");


    my $sql = "SELECT DATE_ADD(NOW(), INTERVAL ((9 - DATE_FORMAT(NOW(), 'w') ) % 7) DAY)";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($next_tuesday) = $sth->fetchrow_array();
    $sth->finish();

    $sql = "SELECT DATE_FORMAT('$next_tuesday', 'W M D, Y')";
    $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($next_tuesday_string) = $sth->fetchrow_array();
    $sth->finish();

    

    #
    # put the movielist in a temporary file
    #

    my $filename = "$tnmc_basepath/movies/cron/send_movielist.txt";
    open (FILE, ">$filename");
    close(FILE);
    &print_email_movielist(">>$filename");

    #
    # send the mail
    #

        my $to_email = $tnmc_email;
    
        my $vote_blurb =  &get_general_config("movie_vote_blurb");

    open(SENDMAIL, "| /usr/sbin/sendmail $to_email");
    print SENDMAIL "From: TNMC Website <scottt\@interchange.ubc.ca>\n";
    print SENDMAIL "To: tnmc-list <$to_email>\n";
    print SENDMAIL "Subject: $next_tuesday_string\n";
    print SENDMAIL "\n";

    print SENDMAIL $vote_blurb;

    open(MESSAGE, "<$filename");
    while (<MESSAGE>){
        print SENDMAIL $_;
    }
    close MESSAGE;

    close SENDMAIL;

    &db_disconnect();

    
###################################################################
sub print_email_movielist{

        my ($movieID, %movie, @movies, @votes, $vote, $num_votes, $userID, %user, @junk);

    my ($filename) = @_;
    if (!$filename) {$filename = ">-";}

    open (RELEASES, $filename);

        print RELEASES "\nnew releases:\n=============\n";
        list_movies(\@movies, "WHERE statusShowing AND statusNew AND NOT (statusSeen OR 0)", 'ORDER BY Title');

        foreach $movieID (@movies){
                get_movie($movieID, \%movie);
                $movie{description} =~ s/\s+/ /g;    # kill extra spaces and <cr>s
                $movie{description} =~ s/^ //g;        # kill leading whitespace
                print RELEASES "        $movie{title} \n$movie{description}\n\n";
        }
    close (RELEASES);

    open (CURRENT, $filename);
        print CURRENT "\nnow showing:\n============\n";

    # load up the movie info
        list_movies(\@movies, "WHERE statusShowing AND NOT (statusSeen OR 0)", '');

        my %movieInfo;
        foreach $movieID (@movies){
                my $anon = {};     ### create an anonymous hash.
                &get_movie_extended($movieID, $anon);
                $movieInfo{$movieID} = $anon;
        }

    # sort the movies (based on 'order')
        @movies = sort  {       $movieInfo{$b}->{order}
                        <=>     $movieInfo{$a}->{order}}
                        @movies ;

    # print out a line for each movie 
        foreach $movieID (@movies){

        # These next few lines format the output.
        #
format CURRENT =
@< @<<<<<<<<<<<<<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$movieInfo{$movieID}->{rank}, $movieInfo{$movieID}->{title}, $movieInfo{$movieID}->{votesText}
~                          ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                           $movieInfo{$movieID}->{votesText}
~                          ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                           $movieInfo{$movieID}->{votesText}
.
        # okay, now print it out
        write CURRENT;

        }
    close (CURRENT);


    open (COMING, $filename);
        print COMING "\ncoming soon:\n============\n";

    # load up the movie info
        list_movies(\@movies, "WHERE statusNew AND NOT ((statusShowing OR 0) OR (statusSeen OR 0))", '');
        foreach $movieID (@movies){
                my $anon = {};     ### create an anonymous hash.
                &get_movie_extended($movieID, $anon);
                $movieInfo{$movieID} = $anon;
        }

    # sort the movies (based on 'order')
        @movies = sort  {       $movieInfo{$b}->{order}
                        <=>     $movieInfo{$a}->{order}}
                        @movies ;

    # print a little ditty out for each movie
        foreach $movieID (@movies){

format COMING =
@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$movieInfo{$movieID}->{rank}, $movieInfo{$movieID}->{title}
        ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        $movieInfo{$movieID}->{votesText}
~       ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        $movieInfo{$movieID}->{votesText}
.
        # okay, now print it out
        write COMING;

        }

    close (COMING);

}

##########################################################
#### The end.
##########################################################

