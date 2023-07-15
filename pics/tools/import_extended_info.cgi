#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::db;

require 'pics/PICS.pl';

{
    #############
    ### Main logic

    &db_connect();

    $where = '';

    print "loading extended info $where\n";

    my @pics;
    &list_pics(\@pics, $where, '');
    foreach $picID (@pics) {

        print "$picID\n";
        &import_extended_info($picID);
    }

    print "extended info loaded\n";

    &db_disconnect();

}

sub import_extended_info {

    my ($picID) = @_;

    my %pic;
    &get_pic($picID, \%pic);
    use Image::Magick;
    my ($image, $x);

    # load in the pic data
    $image = Image::Magick->new;
    $x     = $image->Read("data/$pic{filename}");

    # grab the height and width
    my ($height, $width) = $image->Get('base_rows', 'base_columns');
    $pic{height} = $height;
    $pic{width}  = $width;

    &set_pic(%pic);

    # make a thumbnail
    $x = $image->Sample(width => '160', height => '128');
    open(CACHE, ">data/cache/thumb/$picID");
    $x = $image->Write(file => CACHE, compress => 'JPEG');
    close(CACHE);

}

