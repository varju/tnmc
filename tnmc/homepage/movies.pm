package tnmc::homepage::movies;

use strict;
use tnmc;

use tnmc::security::auth;

#
# module configuration
#

#
# module routines
#
sub show{
    &tnmc::homepage::movies::show_movies();
}

sub show_movies {
    
    
    ## heading
    if ($USERID && $USERID{groupMovies}){
	
	my @nights = &tnmc::movies::night::list_future_nights();
	my $nightID = &tnmc::cgi::param('nightID') || $nights[0];
	
	&tnmc::template::show_heading ("Movie Attendance");
        &tnmc::movies::attendance::show_my_attendance_chooser($USERID, $nightID);
        
        my $night = &tnmc::movies::night::get_night($nightID);
	my $show_date = &tnmc::util::date::format("short_wday", $night->{date});
	&tnmc::template::show_heading ("Movie - $show_date");
	
        if ($night->{movieID}){
            &tnmc::movies::show::show_night($nightID);
        }
        else{
            ## show movies form
            &show_movies_home($USERID, $nightID);
        }
	
    }else{
	
        ## show active (picked) nights
	my @active_nights = tnmc::movies::night::list_active_nights();
	foreach my $nightID (@active_nights){
	    &tnmc::template::show_heading ("Movies - Upcoming Nights");
	    &tnmc::movies::show::show_night($nightID);
	}
	
	## show basic movie votes
	my @nights = &tnmc::movies::night::list_future_nights();
	my $nightID = &tnmc::cgi::param('nightID') || $nights[0];
	&tnmc::template::show_heading ("Movies - General Voting");
	&show_movies_anon($nightID);
        
    }
    
    ## show movie conversation
    if (!$tnmc::security::auth::USERID{i_like_silence})
    {
	&tnmc::message::show_conv(1);
    }

}

##########################################################
sub show_movies_anon{
    my ($nightID) = @_;
    
    print qq{
        <table cellpadding="0" cellspacing="0" border="0">
            <tr><th colspan="4" height="14">
                &nbsp;now showing</th></tr>
    };
    
    my @movies = &tnmc::movies::showtimes::list_all_movies();
    
    &show_movie_list_home(\@movies, '', $nightID);
    print qq{\n    </table><p>\n};
    
}

##########################################################
sub show_movies_home{
    my ($effectiveUserID, $nightID) = @_;
    
    ## show movie form - headings
    print qq{
        <table cellpadding="0" cellspacing="0" border="0">
            <tr><th>&nbsp;N / ? / Y</th>
                <th>&nbsp;&nbsp;\#</th>
                <th colspan="3" height="14">
                    <form action="movies/update_votes.cgi" method="post">
                    <input type="hidden" name="userID" value="$effectiveUserID">
                    &nbsp;now showing</th>
                </tr>
    };
    ## show movie form - content
    my @movie_list = &tnmc::movies::night::list_cache_movieIDs($nightID);
    &show_movie_list_home(\@movie_list, $effectiveUserID, $nightID);
    
    ## show movie form - close table
    print qq{
                <tr><td></td>
                    <td></td>
                    <td colspan="3">
                        <a href="/movies/index.cgi?sortOrder=order&nightID=$nightID">
                        More movies....</a><br>
                        </td>
                        </tr>
            </table>
    };
    
    print qq{
	<table border=0 cellspacing=0 cellpadding=0><tr valign="bottom"><td>
            <font face="verdana">
            <b>Favourite Movie:</b><br>
    };
    &tnmc::movies::show::show_special_movie_select($effectiveUserID, 2, $nightID);
    print qq{
	</td>
	<td>
	    <input type="image" border="0" src="/template/update_votes_submit.gif" alt="Update Votes">
	    </td></tr>
        </form>
	    </table>
    };
    
}


##########################################################
sub show_movie_list_home{
    my ($movielist_ref, $effectiveUserID, $nightID) = @_;
    
    my (@movies, $anon, $movieID, %movieInfo);
    my (%vote_status_word, $vote, @list);

    ## get movie info
    my @list = @$movielist_ref;
    foreach $movieID (@list){
        $anon = {};     ### create an anonymous hash.
        &tnmc::movies::movie::get_movie_extended2($movieID, $anon, $nightID);
        $movieInfo{$movieID} = $anon;
    }
    
    ## sort movies
    @list = ( sort { $movieInfo{$b}->{order}
                     <=>     $movieInfo{$a}->{order}}
              (@list) );
    
    ## prune movielist
    my $cutoff = 0.5 * $movieInfo{$list[0]}->{rank};
    my $min_listing_size = 7;
    my $max_listing_size = 15;
    my $listing_index = 0;
    
    foreach $movieID (@list){
        
        $listing_index ++;
        
        if (  (! $movieInfo{$movieID}->{statusNew})
              && (  (  (  ($movieInfo{$movieID}->{rank} < $cutoff)
                      && ($listing_index > $min_listing_size))  )
                 || ($listing_index > $max_listing_size)
              )
                   ){
	    next;
        }
	push (@movies, $movieID);
    }
    
    
    ## display movielist
    foreach $movieID (@movies){
        
        my $bold = ($movieInfo{$movieID}->{statusNew})? '<b>' : '';
        
        print qq{
            <tr valign="top">
        };
        
        if ($effectiveUserID ){
            %vote_status_word = ('-1','', '0','', '1','', '2','');
            $vote = &tnmc::movies::vote::get_vote($movieID, $effectiveUserID);
            $vote_status_word{$vote} = "CHECKED";
            
            print qq{
                <td valign="top" nowrap><input type="radio" name="v$movieID" value="-1" $vote_status_word{'-1'}><input type="radio" name="v$movieID" value="0" $vote_status_word{'0'}><input type="radio" name="v$movieID" value="1" $vote_status_word{'1'} $vote_status_word{'2'}></td>
            };
        }
        
        print qq{
            <td align="right">&nbsp;&nbsp;$movieInfo{$movieID}->{rank}&nbsp;&nbsp;</td>
            <td valign="top">$bold
                <a href="/movies/movie_view.cgi?movieID=$movieID" target="viewmovie">
                $movieInfo{$movieID}->{title}</a></td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td>$movieInfo{$movieID}->{votesHTML}</td>
            </tr>
        };
        
    }
}

1;
