#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@css.sfu.ca (dec/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use LWP::UserAgent;
# use HTTP::Request::Form;
use HTTP::Request::Common qw(POST);

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'movies/MOVIES.pl';

        #############
        ### Main logic

        print "Content-type: text/html\n\n<pre>\n";

	print "***********************************************************\n";
	print "****                 Get The Movie List                ****\n";
	print "***********************************************************\n";
	print "\n";

	######################
	print "Searching through Directory Listing\n";

	$URL = "http://www2.mybc.com/aroundtown/movies/playing/movies/";

        ### Get a User agent
        $ua = new LWP::UserAgent;
        $ua->agent("tnmcWebAgent/01 " . $ua->agent);

        ### Make the Request
        $req = new HTTP::Request GET => $URL;
        $res = $ua->request($req);

	$directory = $res->content;
	@directory = split("\n", $directory);

	foreach $line (@directory){
		#print "	$line\n";
		if ($line =~ /^<A HREF=\"(\d+).html\"/i) {
	#		print "$1\n";
			$list{$1} = '';
		}
	}
	######################
	print "Searching through Drop-down menu\n";
	
        ### Make the Request
	$URL = "http://www2.mybc.com/aroundtown/movies/";
        $req = new HTTP::Request GET => $URL;
        $res = $ua->request($req);

	$list = $res->content;
	$list =~ s/.*\n\<SELECT name\=\"movieid\"\>\n//s;
	$list =~ s/\n\<\/SELECT\>\n.*//s;

	@list = split("\n", $list);

	foreach $item (@list){
		$item =~ /.+\"(\d+)\"\>(.*)$/;
		$list{$1} = $2;
	}

	#	foreach $mybcID (sort(keys(%list))){
	#		print "$mybcID	$list{$mybcID}\n";
	#	}

	$i = 0;
	foreach (keys(%list)){
		$i++;
	}	
	print "\n" . $i . " movies found online at mybc.com\n\n";
	

	### list of valid theatres
	print "Ordered List of Acceptable Theatres:\n";
	print "------------------------------------\n";
	&db_connect();
	$valid_theatres = &get_general_config("movie_valid_theatres");
	@valid_theatres = split(/\s/, $valid_theatres);
	foreach (@valid_theatres){
		$valid_theatres{$_} = 1;
		print $_ . "\n";
	}
	
	print "\n";


	print "***********************************************************\n";
	print "****               Retrieve the Movie Info             ****\n";
	print "***********************************************************\n";

	@mShowing = ();

	foreach $mID (sort(keys(%list))){
		
		#################
		### Request the page

		$URL = "http://www2.mybc.com/aroundtown/movies/playing/movies/$mID.html";
		my $req = new HTTP::Request GET => $URL;
		$res = $ua->request($req);

		$mPage = $res->content;
		
		#################
		### Parse the page

		if ($mPage =~ s/.*\n<TD WIDTH="456" VALIGN="top">\n//s){

			$mPage =~ /<FONT SIZE="4">((.)*)<\/FONT>/m;
			$mTitle{$mID} = $1;
			$mTitle{$mID} =~ s/^(The|A)\s+(.*)$/$2, $1/;

			$mStars{$mID} = 0;
			if ($mPage =~ /<IMG SRC="\/aroundtown\/movies\/images\/star_(.*)\.gif/m){
				$mStars{$mID} = $1;
				$mStars{$mID} =~ s/_half/.5/;
			}
			
			$mPage =~ s/.*\n<B><I>\@ THESE LOCATIONS<\/I><\/B>\:\n<BR>\n//s;
			$mPage =~ s/^(.*)\n//;
			$mTheatres = $1;

			$mPage =~ s/^<P>(.*)<P>\n//s;
			$mInfo = $1;
			
			if ($mInfo =~ s/\n<B>PREMISE<\/B>\:<BR>\n//m){
				($mPremise{$mID}, $mInfo) = split("\n", $mInfo, 2);
			}
		}
		else{
			### Could not parse
			print "\n$mID (failed)";
			next;
		}

		print "\n$mID	$mStars{$mID}	$mTitle{$mID}";

		#################
		### Extract the Theatres

		@mTheatres = split('<BR>&#160;&#160;', $mTheatres);
		%mTheatres = ();
		foreach $mTh (@mTheatres){
			if (!$mTh) {	next;	}
			$mTh =~ /cinemas\/(.+)\.html">(.+)<\/A>$/;
			$mTheatres{$1} = $2;
			print ".";
		}

		#################
		### Pick out the theatres that we like

		foreach $_ (sort(keys(%mTheatres))){
			if ($valid_theatres{$_}){
				push (@mShowing, $mID);
				print " $_";
			}
		}
	}

	print "\n\n";
	print "***********************************************************\n";
	print "****               Update the Database                 ****\n";
	print "***********************************************************\n";

        &db_connect();

	$sql = "UPDATE Movies SET statusShowing = '0'";
	$sth = $dbh_tnmc->prepare($sql);
	$sth->execute();
	$sth->finish();


	foreach $mID (@mShowing){
	  if ($mID){
		print "$mTitle{$mID} ($mID) ";
	
		####################
		### Try to find movie in DB via mybcID

		$sql = "SELECT movieID FROM Movies WHERE mybcID = '$mID'";
		$sth = $dbh_tnmc->prepare($sql);
		$sth->execute();
		@row = $sth->fetchrow_array();
		$movieID = $row[0];
		
		if ($movieID){
			print "			...Found (mybcID)\n";
		}
		else {
		
			####################
			### Try to find movie in DB via Title
	
			$sql = "SELECT movieID FROM Movies
				 WHERE title = " . $dbh_tnmc->quote($mTitle{$mID});
			$sth = $dbh_tnmc->prepare($sql);
			$sth->execute();
			@row = $sth->fetchrow_array();
			$movieID = $row[0];
			
			if ($movieID){
				print "			...Found (Title)\n";
			}
		}

		if ($movieID){
			
			&get_movie($movieID, \%dbMovie);

			$dbMovie{mybcID} = $mID;
			$dbMovie{statusShowing} = '1';

			if (! $dbMovie{rating}){
				$dbMovie{rating} = $mStars{$mID};
			}

			if (20 > length($dbMovie{description})){
				$dbMovie{description} = $mPremise{$mID};
			}
			
			&set_movie(%dbMovie);

			next;
		}
		
		####################
		### Can't find movie in DB. Let's make a new one.
		
		$newMovie{movieID} = '0';
		$newMovie{mybcID} = $mID;
		$newMovie{title} = $mTitle{$mID};
		$newMovie{rating} = $mStars{$mID};
		$newMovie{description} = $mPremise{$mID};
		$newMovie{statusShowing} = '1';
		$newMovie{statusNew} = '1';
		$newMovie{statusSeen} = '0';
		$newMovie{date} = '0000-00-00';
		$newMovie{type} = '';
		
		&set_movie(%newMovie);
		
		print "			...New Movie\n";
		
		
	  }
	}

	$sth->finish();

        &db_disconnect();


