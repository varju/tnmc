#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic

	&db_connect();
	&header();

#	&show_movies();
#	&show_add_movie_form();



	$next = &get_next_night();
	&get_night($next, \%next);
	print qq{<a href="night_edit_admin.cgi?nightID=$next{nightID}">$next{date}</a>};


	

	$next{nightID} = 10;
	$next{date} = '2000-07-11';
	$next{movieID} = '';
#
#	&show_movie($movieID);

	print qq{
	    <br><hr><br>

	    $next

	    <br><hr><br>
	};

&set_night(%next);
&show_night($next);

#	&show_movie_extended($movieID, \%movie, $USERID);

	&footer();
	&db_disconnect();



##########################################################
sub get_movie_extended{

	my ($movieID, $movie, $userID, $junk) = @_;

	### Get basic info.
       	&get_movie($movieID, $movie);


	$thisTues = &get_next_night();
	$nextTues = &get_next_night($thisTues);

	$sql = "SELECT p.userID, p.username, v.type,
                       DAYOFYEAR(p.birthdate) - DAYOFYEAR($thisTues),
                       a.movieDefault, a.movie$thisTues, a.movie$nextTues
                 FROM           MovieVotes as v
                      LEFT JOIN Personal as p USING (userID)
                      LEFT JOIN MovieAttendance as a USING (userID)
		WHERE v.movieID = '$movieID'
		ORDER BY p.username ASC";

	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();

	# find out who voted for the movie...
	while (@row = $sth->fetchrow_array()){


		$VuserID = $row[0];
		$Vperson = $row[1];
		$Vtype = $row[2];
		$Ubday = $row[3];
		$Udefault = $row[4];
		$Uthis = $row[5];
		$Unext = $row[6];

		if ( ($Vperson eq 'demo')
		   && ($userID != 38)){
			#
			# Do nothing
			#
		}
			
		elsif (	($Uthis eq 'no')
			|| ($Uthis eq '' and $Udefault eq 'no')	){

			if (	($Unext eq 'no')
				|| ($Unext eq '' and $Udefault eq 'no')	){

				if ($Vtype >= 1){
					$movie->{votes} .= "<font color='cccccc'>$Vperson</font> ";
					$movie->{votesText} .= "[$Vperson] ";
					$movie->{votesForLost} ++;
				}
			}
			elsif ($Vtype == 1){
				$movie->{votes} .= "<font color='888888'>$Vperson</font> ";
				$movie->{votesText} .= "[$Vperson] ";
				$movie->{votesForAway} ++;
			}
			elsif ($Vtype == 2){
				$movie->{votes} .= "<font color='888888'><b>$Vperson</b></font> ";
				$movie->{votesText} .= "[$Vperson!] ";
				$movie->{votesFaveAway} ++;
			}
		}
		elsif ($Vtype == 2){
		    if ($Ubday ne '' && $Ubday <= 3 && $Ubday >= -3){
			$movie->{votes} .= "<b><font style='background-color: #ff88ff'>&nbsp;$Vperson&nbsp;</font></b> ";
			$movie->{votesText} .= "***${Vperson}*** ";
			$movie->{votesFaveBday} ++;
			
		    }else{
			$movie->{votes} .= "<b>$Vperson</b> ";
			$movie->{votesText} .= "${Vperson}! ";
			$movie->{votesFave} ++;
		    }
		}
		elsif ($Vtype == 1){
			$movie->{votes} .= "$Vperson ";
			$movie->{votesText} .= "${Vperson} ";
			$movie->{votesFor} ++;
		}
		elsif ($Vtype == -1){
			$movie->{votes} .= "<font color='ff2222'>$Vperson</font> ";
			$movie->{votesText} .= "(${Vperson}) ";
			$movie->{votesAgainst} ++;
		}

	}
	$sth->finish();


	### Do the rank stuff
	$movie->{rank} += 1.0 *  $movie->{votesFor};
	$movie->{rank} += 1.5 *  $movie->{votesFave};
	$movie->{rank} -= 0.5 *  $movie->{votesAgainst};
	$movie->{rank} -= 0.4 *  $movie->{votesForAway};
	$movie->{rank} -= 0.8 *  $movie->{votesFaveAway};
	$movie->{rank} += 10  *  $movie->{votesFaveBday};

	# encourage movies with good ratings!
	my $rating = $movie->{rating};
	if ($rating != 0){
		$rating -= 2.5;
		if ($rating >= 1){
			$rating *= $rating;
		}
		$movie->{rank} +=        $rating;
	}

}
	
	


##################################################################
sub show_movie_extended
{
	my ($movieID, $junk) = @_;	
	my (@cols, $movie, %movie, $key);
	
	if ($movieID)
	{ 
	 	@cols = &db_get_cols_list($dbh_tnmc, 'Movies');
        	&get_movie_extended($movieID, \%movie);

		print qq 
		{
			<table>
		};
	
		foreach $key (sort(keys(%movie)))
        	{       if ($key eq 'movieID')
			{  	next;
			}
			if ($key eq 'mybcID')
			{	next;
			}

			print qq 
			{	
				<tr valign=top><td><B>$key</B></td>
				    <td>$movie{$key}</td>
				</tr>
			};
        	}

		if ($movie{'mybcID'})
		{	$mybcID = $movie{'mybcID'};
			print qq 
			{	<tr><td><b><a href="
				javascript:window.open(
					'http://www2.mybc.com/aroundtown/movies/playing/movies/$mybcID.html',
				        'ViewMYBC'); index.cgi">myBC Info</a>
			};
		}
		print qq
		{
			</table>
		}; 
	}
}

##################################################################
sub show_movie
{
	my ($movieID, $junk) = @_;	
	my (@cols, $movie, %movie, $key);
	
	if ($movieID)
	{ 
	 	@cols = &db_get_cols_list($dbh_tnmc, 'Movies');
        	&get_movie($movieID, \%movie);
	  	print %movie;

		print qq 
		{
			<table>
		};
	
		foreach $key (@cols)
        	{       if ($key eq 'movieID')
			{  	next;
			}
			if ($key eq 'mybcID')
			{	next;
			}

			print qq 
			{	
				<tr valign=top><td><B>$key</B></td>
				    <td>$movie{$key}</td>
				</tr>
			};
        	}

		if ($movie{'mybcID'})
		{	$mybcID = $movie{'mybcID'};
			print qq 
			{	<tr><td><b><a href="
				javascript:window.open(
					'http://www2.mybc.com/aroundtown/movies/playing/movies/$mybcID.html',
				        'ViewMYBC'); index.cgi">myBC Info</a>
			};
		}
		print qq
		{
			</table>
		}; 
	}
}


##################################################################
sub show_night
{
	my ($nightID, $junk) = @_;	
	my (@cols, $night, %night, $key);
	
	if ($nightID)
	{ 
        	&get_night($nightID, \%night);

print $nightID;

		print qq 
		{
			<table>
		};
	
		foreach $key (sort(keys(%night)))
        	{
			print qq 
			{	
				<tr valign=top><td><B>$key</B></td>
				    <td>$night{$key}</td>
				</tr>
			};
        	}

		print qq
		{
			</table>
		}; 
	}
}
	

##########################################################
#### The end.
##########################################################

