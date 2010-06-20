package tnmc::updater::imdb;

use strict;

#
# module configuration
#
BEGIN
{
    use LWP::UserAgent;
    use HTTP::Request::Common qw(POST);
}    

#
# module routines
#
  
sub imdb_get_movie_list {
    my %results;

    my $URL = "http://www.imdb.com/";
    my $req = new HTTP::Request GET => $URL;
    my $ua = new LWP::UserAgent;
    my $res = $ua->request($req);
    
    my $text = $res->content;

    $text =~ s/.*Opening This Week\"\>\<\/A\>\<br\>//s;
    $text =~ s/\<p\>\<img src=\"http:\/\/i.imdb.com\/f97.gif\" width=170 height=19 border=0 ALT=\"New Videos This Week\"\>\<\/A\>\<br\>.*//s;
    $text =~ s/.*?\<A HREF=\"\/Title(.*?)\<\/A\>/\<A HREF=\"\/Title$1\<\/A\>\n/sg;
    $text =~ s/\<\/font\>.*//sg;

    my @list = split("\n", $text);
    
    foreach my $item (@list){
        $item =~ /.+\"\/Title\?([\da]+)\"\>(.*)\<\/A\>/;
        next unless $1;
        next unless $2;
        $results{$1} = $2;
    }

    return %results;
}

sub imdb_get_movie_info {
    my ($mID) = @_;
    my %info;

#    my $URL = "http://www2.mybc.com/movies/movies/$mID.html";
    my $URL = "http://www.imdb.com/Title?$mID";
    my $req = new HTTP::Request GET => $URL;
    my $ua = new LWP::UserAgent;
    my $res = $ua->request($req);
    
    my $mTheatres;

    my $text = $res->content;

    if ($text =~ m%.*?Plot (Outline|Summary): </B>(.*?)<BR.*%s) {
        $info{premise} = $2;
        $info{premise} =~ s%<A HREF=\"/(.*?)\"%<A HREF=\"http://www.imdb.com/$1\"%sg;
        chomp $info{premise};
    }

    if (0==1) {
        if ($text =~ s/.*?movies\/images\/title2\.gif\" width\=111 height\=33 alt\=\"\" border\=\"0\"\>//s) {
            $text =~ /<font size=\"?3\"?><b>((.)*)<\/b><\/font>/im;
            $info{title} = $1;
            $info{title} =~ s/^(The|A)\s+(.*)$/$2, $1/;

            $info{stars} = 0;
            if ($text =~ /<IMG SRC=\"\/movies\/images\/star_(.*)\.gif/m) {
                $info{stars} = $1;
                $info{stars} =~ s/_half/.5/;
            }
            
            if ($text =~ m|<b>PREMISE</b>\n<BR>(.*?)<P>|s) {
                $info{premise} = $1;
                chomp $info{premise};
            }
            
            if ($text =~ m|<B><I>@ THESE LOCATIONS</I></B>:</font><br>\n<FONT FACE="Verdana,Arial" SIZE="1">(.*)</FONT>|s) {
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
        $info{theatres} = \%mTheatres;
    }
    return %info;
}

1;





