##################################################################
#	Scott Thompson (oct 2003)
##################################################################

package tnmc::movies::showtimes;

use tnmc;


#
# vars
#

use vars qw(%status);

my @keys = ("movieID", "theatreID");
my $table = 'MovieShowtimes';

#
# subs (basic)
#

sub new_showtimes{
    # usage: &new_showtimes();
    return &tnmc::db::link::newLink($table, \@keys);
}

sub set_showtimes{
    # usage: &setShowtimes($showtimes_hash);
    return &tnmc::db::link::replaceLink($table, \@keys, $_[0]);
}

sub del_showtimes{
    # usage: &delShowtimes($movieID, $theatreID);
    my %hash = ("movieID" => $_[0],
		"theatreID" => $_[1]);
    return &tnmc::db::link::delLink($table, \@keys, \%hash);
}

sub del_all_showtimes
{
    &tnmc::db::link::delAllLinks($table);
}

sub list_theatres{
    # usage: &listTheatres($movieID);
    return &tnmc::db::link::listLinks($table, "theatreID", "WHERE movieID = $_[0]");
}

sub list_movies{
    # usage: &listMovies($theatreID);
    return &tnmc::db::link::listLinks($table, "movieID", "WHERE theatreID = $_[0]");
}

sub list_all_movies{
    # usage: &list_all_Movies();
    my @movies = &tnmc::db::link::listLinks($table, "movieID", "");
    
    # remove duplicates
    my %seen;
    @movies = grep(!$seen{$_}++, @movies);
    
    return @movies;
}

1;
