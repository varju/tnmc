package tnmc::templates::movies;

use strict;

#
# module configuration
#

BEGIN{
    use tnmc::security::auth;
    
    use Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    
    @EXPORT = qw(show_movies);
    
    @EXPORT_OK = qw();
    
}

#
# module routines
#

sub show_movies {
    
    require tnmc::util::date;
    require tnmc::movies::night;
    require tnmc::template;
    require tnmc::movies::show;
    require tnmc::movies::attendance;
    require tnmc::movies::faction;
    require tnmc::movies::night;
    require tnmc::cgi;
    
    ## heading
    my $movies_heading = "Movies";
    &tnmc::template::show_heading ($movies_heading);
    
    my $cgih = &tnmc::cgi::get_cgih();
    
    my @nights = &tnmc::movies::night::list_future_nights();
    my $nightID = $cgih->param('nightID') || $nights[0];
    
    if ($USERID && $USERID{groupMovies}){
        
        &tnmc::movies::attendance::show_my_attendance_chooser($USERID, $nightID);
        
        my %night;
        &tnmc::movies::night::get_night($nightID, \%night);
        if ($night{movieID}){
            &tnmc::movies::show::show_night($nightID);
        }
        else{
            ## show movies form
            &show_movies_home($USERID, $nightID);
        }
       
    }else{
        ## show basic movielist
        if (!&tnmc::movies::show::show_current_nights()){
            &show_movies_home_anon_old($nightID);
        }
        
    }
}

##########################################################
sub show_movies_home_anon_old{
    my ($nightID) = @_;
    
    print qq{
        <table cellpadding="0" cellspacing="0" border="0">
            <tr><th colspan="4" height="14">
                &nbsp;now showing</th></tr>
    };
    my @movie_list;
    &tnmc::movies::show::list_movies(\@movie_list, "WHERE (statusShowing)", '');
    &show_movie_list_home_old(\@movie_list, '', $nightID);
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
                    <form action="/movies/update_votes.cgi" method="post">
                    <input type="hidden" name="userID" value="$effectiveUserID">
                    &nbsp;now showing</th>
                </tr>
    };
    ## show movie form - content
    my @movie_list = &tnmc::movies::night::list_cache_movieIDs($nightID);
    &show_movie_list_home_old(\@movie_list, $effectiveUserID, $nightID);
    
    ## show movie form - close table
    print qq{
                <tr><td></td>
                    <td></td>
                    <td colspan="3">
                        <a href="/movies/index.cgi?sortOrder=order&nightID=$nightID">
                        More movies....</a><br>
                        </td>
                        </tr>
            </table><p>
    };
    
    print qq{
            <font face="verdana">
            <b>Favorite Movie:</b><br>
    };
    &tnmc::movies::show::show_special_movie_select($effectiveUserID, 2, $nightID);
    print qq{
        <br>
        <input type="image" border="0" src="/template/update_votes_submit.gif" alt="Update Votes">
        </form>
    };
    
}


##########################################################
sub show_movie_list_home_old{
    my ($movielist_ref, $effectiveUserID, $nightID) = @_;
    
    require tnmc::movies::movie;
    require tnmc::movies::show;
    require tnmc::movies::vote;
    
    my (@movies, $anon, $movieID, %movieInfo);
    my ($boldNew, %vote_status_word, $vote, @list);
    
    my @list = @$movielist_ref;
    foreach $movieID (@list){
        $anon = {};     ### create an anonymous hash.
        &tnmc::movies::movie::get_movie_extended2($movieID, $anon, $nightID);
        $movieInfo{$movieID} = $anon;
    }
    
    @list = ( sort { $movieInfo{$b}->{order}
                     <=>     $movieInfo{$a}->{order}}
              (@list) );
    
    # my $cutoff = sqrt ($movieInfo{$list[0]}->{rank});
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
