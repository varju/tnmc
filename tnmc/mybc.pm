package tnmc::mybc;

use strict;

#
# module configuration
#
BEGIN
{
    use LWP::UserAgent;
    use HTTP::Request::Common qw(POST);
    
    use tnmc::general_config;
}

#
# module routines
#

sub mybc_get_movie_list
{
    my %results;

    my $URL = "http://www.mytelus.com/movies/releases.do";
    my $req = new HTTP::Request GET => $URL;
    my $ua = new LWP::UserAgent;
    my $res = $ua->request($req);

    my $text = $res->content;
    if ($text =~ m|<select name="movieID">(.*)</select>|si)
    {
	my $movies = $1;
	my @list = split("\n", $movies);

	foreach my $item (@list)
	{
	    if ($item =~ m|<option value="(\w+)">(.*)$|)
	    {
		next unless $1 && $2;
		$results{$1} = $2;
	    }
	}
    }

    return %results;
}

sub mybc_get_valid_theatres {
    my %results;

    my $valid_theatres = &tnmc::general_config::get_general_config("movie_valid_theatres");
    my @valid_theatres = split(/\s/, $valid_theatres);
    foreach my $theatre (@valid_theatres){
        $results{$theatre} = 1;
    }

    return %results;
}

sub mybc_get_movie_info {
    my ($mID) = @_;
    my %info;

    my $URL = "http://www2.mybc.com/movies/movies/$mID.html";
    my $req = new HTTP::Request GET => $URL;
    my $ua = new LWP::UserAgent;
    my $res = $ua->request($req);
    
    my $mTheatres;

    my $text = $res->content;

    if ($text =~ s/.*?<font face="Verdana, Arial, sans-serif" size="1">//s) {
        $text =~ /<font size=\"?\d\"?><b>((.)*)<\/b><\/font>/im;
        $info{title} = $1;
        $info{title} =~ s/^(The|A)\s+(.*)$/$2, $1/;

        if ($text =~ m|<b>PREMISE</b></font>\s*<BR>\s*(.*?)\s*<br><br>|si) {
            $info{premise} = $1;
            chomp $info{premise};
        }
        
        $info{stars} = 0;
        if ($text =~ /<IMG SRC=\"\/movies\/images\/star_(.*)\.gif/m) {
            $info{stars} = $1;
            $info{stars} =~ s/_half/.5/;
        }
        
        if ($text =~ m|<B><I>@ THESE LOCATIONS</I></B>\:</font><br>\s+<font face="Verdana,Arial" size="1">\s(.*?)</font>|si) {
            $mTheatres = $1;
        }
    }
    else {
        return ();
    }
    
    # Extract the Theatres
    my @lines = split('\n', $mTheatres);
    my %mTheatres = ();
    foreach my $mTh (@lines) {
        next unless $mTh;

        if ($mTh =~ /.*?theatres\/(.+)\.html\">(.+)<\/a>/) {
            $mTheatres{$1} = $2;
        }
    }
    $mTheatres{foo} = "bar";
    $info{theatres} = \%mTheatres;

    return %info;
}

1;
