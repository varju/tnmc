#!/usr/bin/perl

##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'movies/MOVIES.pl';

	#############
	### Main logic

	&db_connect();
#	print "Content-type: text/html\n\n<pre>";
#	&print_email_movielist(">-");


	$sql = "SELECT DATE_ADD(NOW(), INTERVAL ((9 - DATE_FORMAT(NOW(), 'w') ) % 7) DAY)";
	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();
	($next_tuesday) = $sth->fetchrow_array();
	$sth->finish();

	$sql = "SELECT DATE_FORMAT('$next_tuesday', 'W M D, Y')";
	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();
	($next_tuesday_string) = $sth->fetchrow_array();
	$sth->finish();

	

	#
	# put the movielist in a temporary file
	#

	$filename = "send_movielist.txt";
	open (FILE, ">$filename");
	close(FILE);
	&print_email_movielist(">>$filename");

	#
	# send the mail
	#

	$to_email = 'tnmc-list@interchange.ubc.ca';

        $vote_blurb =  &get_general_config("movie_vote_blurb");

	open(SENDMAIL, "| /usr/lib/sendmail $to_email");
	print SENDMAIL "From: TNMC Website <scottt\@interchange.ubc.ca>\n";
	print SENDMAIL "To: tnnc-list <$to_email>\n";
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
				$movie{description} =~ s/\s+/ /g;	# kill extra spaces and <cr>s
				$movie{description} =~ s/^ //g;		# kill leading whitespace
                print RELEASES "        $movie{title} \n$movie{description}\n\n";
        }
	close (RELEASES);

	open (CURRENT, $filename);
        print CURRENT "\nnow showing:\n============\n";
        list_movies(\@movies, "WHERE statusShowing AND NOT (statusSeen OR 0)", '');

        @movies = sort  {       list_votes_by_movie(\@junk, $b)
                        <=>     list_votes_by_movie(\@junk, $a)}
                        @movies ;

        foreach $movieID (@movies){
                get_movie($movieID, \%movie);
                $num_votes = list_votes_by_movie(\@votes, $movieID);

                ### stoopid f---ed up rounding math.
                if ($num_votes > 0) { $num_votes += 0.5; }
                $num_votes = int($num_votes);
				
		$votes_string = '';
                foreach $userID (@votes){
                        &get_user($userID, \%user); 
                        $vote = &get_vote($movieID, $userID);
			if (!$user{movieAttendance}){
	                        if ($vote > 0){         $votes_string .= "($user{username}) ";       }                       
			}else{
	                        if ($vote > 0){         $votes_string .= "$user{username} ";       }                       
        	                if ($vote < 0){         $votes_string .= "!$user{username} ";      }
			}
                }

		# These next few lines format the output.
		#
format CURRENT =
@< @<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$num_votes, $movie{title},  $votes_string
.
		# okay, now print it out
		write CURRENT;

        }
	close (CURRENT);

	open (COMING, $filename);
        print COMING "\ncoming soon:\n============\n";
        list_movies(\@movies, "WHERE statusNew AND NOT ((statusShowing OR 0) OR (statusSeen OR 0))", '');

        @movies = sort  {       list_votes_by_movie(\@junk, $b)
                        <=>     list_votes_by_movie(\@junk, $a)}
                        @movies ;
        foreach $movieID (@movies){
                get_movie($movieID, \%movie);
                $num_votes = list_votes_by_movie(\@votes, $movieID);
		$votes_string = '{ ';

                foreach $userID (@votes){
                        &get_user($userID, \%user);
                        $vote = &get_vote($movieID, $userID);
			if (!$user{movieAttendance}){
	                        if ($vote > 0){         $votes_string .= "($user{username}) ";       }                       
			}else{
	                        if ($vote > 0){         $votes_string .= "$user{username} ";       }                       
        	                if ($vote < 0){         $votes_string .= "!$user{username} ";      }
			}
                }
		$votes_string .= '}';

format COMING =
@<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$num_votes, $movie{title}
        @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        $votes_string
.
		# okay, now print it out
		write COMING;

        }

	close (COMING);

}

##########################################################
#### The end.
##########################################################

