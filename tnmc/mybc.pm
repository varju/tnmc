package tnmc::mybc;

use strict;

#
# module configuration
#
BEGIN {
    use LWP::UserAgent;
    use HTTP::Request::Common qw(POST);
    
    use tnmc::general_config;
    
    use Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter);
    
    @EXPORT = qw(mybc_get_movie_list mybc_get_valid_theatres mybc_get_movie_info);
    
    @EXPORT_OK = qw();
}

#
# module routines
#

sub mybc_get_movie_list {
    my %results;
    
    my $URL = "http://www2.mybc.com/movies/";
    my $req = new HTTP::Request GET => $URL;
    my $ua = new LWP::UserAgent;
    my $res = $ua->request($req);
    
    my $text = $res->content;
    $text =~ s/.*\n\<SELECT name\=\"movieid\"\>\n//si;
    $text =~ s/\n\<\/SELECT\>\n.*//si;
    
    my @list = split("\n", $text);
    
    foreach my $item (@list){
        $item =~ /.+\"([\da]+)\"\>(.*)$/;
        next unless $1;
        next unless $2;
        $results{$1} = $2;
    }

    return %results;
}

sub mybc_get_valid_theatres {
    my %results;

    my $valid_theatres = get_general_config("movie_valid_theatres");
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
        $text =~ /<font size=\"?4\"?><b>((.)*)<\/b><\/font>/im;
        $info{title} = $1;
        $info{title} =~ s/^(The|A)\s+(.*)$/$2, $1/;

        $info{stars} = 0;
        if ($text =~ /<IMG SRC=\"\/movies\/images\/star_(.*)\.gif/m) {
            $info{stars} = $1;
            $info{stars} =~ s/_half/.5/;
        }
        
        if ($text =~ m|<b>PREMISE</b></font>\n<BR>(.*?)<br><br>|si) {
            $info{premise} = $1;
            chomp $info{premise};
        }
        
        if ($text =~ m|<B><I>@ THESE LOCATIONS</I></B>:</font><br>\n<FONT FACE="Verdana,Arial" SIZE="1">(.*?)</FONT>|si) {
            $mTheatres = $1;
        }
    }
    else {
        return undef;
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
