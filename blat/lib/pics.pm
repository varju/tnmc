package lib::pics;

use strict;
use warnings;

#
# module configuration
#
BEGIN {
    use vars qw($base_path);
    $base_path = "/tnmc/blat/pics/";
}

#
# module routines
#

sub get_pic {
    my ($picID) = @_;
    $picID =~ /^(.*)\/(.*)/;
    my $albumID = $1;
    my $name    = $2;

    my %pic = (
        'picID'   => $picID,
        'url'     => "/blat/pics/pic_view.cgi?picID=$picID&albumID=$albumID",
        'src'     => "/blat/pics/$picID",
        'low_src' => "/blat/pics/cache/thumb/$picID",
        'albumID' => $albumID,
        'name'    => $name,
    );
    return \%pic;
}

sub album_list_pics {
    my ($albumID)  = @_;
    my $album_path = "$base_path$albumID/";
    my @dir        = `ls $album_path`;
    map { chomp; $_ = $albumID . '/' . $_ } @dir;
    @dir = grep { $_ !~ /\.zip$/i } @dir;
    return sort @dir;
}

sub list_albums {
    my @dir = `find $base_path -type d | grep -v cache`;
    shift @dir;
    map { chomp; s/$base_path//; } @dir;
    return sort @dir;
}

1;
