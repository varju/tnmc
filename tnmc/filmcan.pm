package tnmc::filmcan;

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

my $ua;
sub get_valid_ua{

    if (! $ua){
	$ua = new LWP::UserAgent;
	$ua->cookie_jar({});
	
	my $URL1 = "http://www.film-can.com/cgi-bin/main/region.cgi?PID=BC";
	my $req = new HTTP::Request GET => $URL1;
	my $res = $ua->request($req);
	
	my $URL2 = "http://www.film-can.com/cgi-bin/main/index.cgi?REGION=20";
	my $req = new HTTP::Request GET => $URL2;
	my $res = $ua->request($req);
    }
    return $ua;
}

sub get_theatre_showtimes(){
    my ($filmcanid) = @_;
    
    ## get webpage
    my $ua = &get_valid_ua();
    my $URL = "http://www.film-can.com/cgi-bin/main/tview.cgi?TID=$filmcanid";
    my $req = new HTTP::Request GET => $URL;
    my $res = $ua->request($req);
    my $text = $res->content;

    ## parse webpage
    my @MOVIES;
    if ($text =~ m|<STRONG>Welcome to(.*)<!-- row 5 -->|si){
	my $movie_text = $1;
	
	while ($movie_text =~ s|mview.cgi\?FID\=(.*?)\">(.*?)</A>.*?SIZE\=2>\s+([^\<]*)||s){
	    my $FID = $1;
	    my $title = $2;
	    $title = &tnmc::movies::movie::reformat_title($title);
	    my %movie = (
			 "filmcanid" => $FID,
			 "title" => $title,
			 );
	    push @MOVIES, \%movie;
	}
    }
    
    return \@MOVIES;
}


1;
