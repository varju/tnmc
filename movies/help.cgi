#!/usr/bin/perl
        
##################################################################
#       Scott Thompson - scottt@css.sfu.ca (nov/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';


        #############
        ### Main logic

        &db_connect();
        &header();


        &show_movieMenu();

	&show_heading("Here's how the database bits map to the movie status:");

	print qq{
	<pre>
			seen	showing	new	
	coming soon	0	0	1	
	just released	0	1	1
	showing		0	1	0
	not showing	0	0	0
	seen		1	-	-	
	</pre>
	};


	&show_heading("Here's now the rank gets calculated");

	$moo = q{
        ### Do the rank stuff
        $movie->{order} += 1.0 *  $movie->{votesFor};
        $movie->{order} += 1.5 *  $movie->{votesFave};
        $movie->{order} += 10  *  $movie->{votesFaveBday};
        $movie->{order} -= 0.5 *  $movie->{votesAgainst};
        $movie->{order} -= 0.4 *  $movie->{votesForAway};
        $movie->{order} -= 0.8 *  $movie->{votesFaveAway};

        # encourage movies with good ratings!
        my $rating = $movie->{rating};
        if ($rating != 0){
                $rating -= 2.5;
                if ($rating >= 1){
                        $movie->{order} *=     1 + ( $rating / 5 );
                }else{
                        $movie->{order} +=        $rating;
                }
        }
                        
        ### stoopid f---ed up rounding math.
        $movie->{rank} = $movie->{order};
        if ($movie->{rank} > 0) {       $movie->{rank} += 0.5; }
        $movie->{rank} = int($movie->{rank});
	};

	$moo =~ s/\</&lt;/g;	
	$moo =~ s/\>/&gt;/g;	
	print "<pre>$moo</pre>";


        &footer();
        &db_disconnect();

#######################################

