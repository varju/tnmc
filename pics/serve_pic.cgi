#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
use tnmc::cookie;
require 'pics/PICS.pl';

$force = 0;

{
    #############
    ### Main logic
    
    $basePicDir = "data/";
    &db_connect();
    
    &cookie_get();
    

    $cgih = new CGI;
    
    my $picID = $cgih->param(picID);
    my $mode = $cgih->param(mode);

    &serve_picture($mode, $picID);

    &db_disconnect();
}


sub serve_picture{

    my ($mode, $picID) = @_;

    my %pic;
    &get_pic($picID, \%pic);
    $picfile = "$basePicDir$pic{filename}";

    ## Access control
    if ( (!$pic{typePublic}) && ($USERID ne $pic{ownerID}) ){
        errorExit( "access not allowed!");
    }
    ## Does pic exist?
    elsif (! -e $picfile){
        errorExit( "pic not found!");
    }
    
    ## THUMBNAIL
    if ($mode eq "thumb"){

        ## serve it from the cache if we can
        my $cache_file = "$basePicDir/cache/$mode/$picID";
        if (! $force && -f "$cache_file"){
            &serve_file($cache_file);
        }
        else{

            use Image::Magick;
            
            # use POSIX qw(strftime);
            # my @file_status = stat("$path");
            # my $file_stamp = strftime "%Y-%m-%d %H:%M:%S ", localtime $file_status[9];
            # print "Last-Modified: Monday, 11-Dec-00 01:58:33 GMT\n\n";

            #HTTP/1.1 200 OK
            #Date: Mon, 11 Dec 2000 02:07:13 GMT
            #Server: Apache/1.3.6 (Unix)
            #Last-Modified: Mon, 18 Jan 1999 13:29:20 GMT
            #ETag: "74431-1572-36a33730"
            #Accept-Ranges: bytes
            #Content-Length: 5490
            #Connection: close
            #Content-Type: text/html            

            print "Content-type: image/jpeg\n\n";

            my($image, $x);
            
            $image = Image::Magick->new;
            $x = $image->Read($picfile);
            $x = $image->Sample(width=>'160', height=>'128');
            $x = $image->Write(file=>STDOUT, compress=>'JPEG');
            open (CACHE, ">$cache_file");
            $x = $image->Write(file=>CACHE, compress=>'JPEG');
            close (CACHE);

            # $x = $image->Sample(width=>'320', height=>'240');
            # $x = $image->Rotate(degrees=>'90');

            # warn "$x" if "$x";

            # $p = Image::Magick->new;
            # $p->Read($picfile);
            # $p->Set(attribute => value, ...)
            # ($a, ...) = p->Get("attribute", ...)
            # $p->routine(parameter => value, ...)
            # $p->Mogrify("Routine", parameter => value, ...)
            # $p->Write(STDOUT);
        }
    }
    else{
        &serve_file($picfile);
    }

}

sub serve_file{

    my ($picfile) = @_;

    print "Content-type: image/jpeg\n\n";
    open (PICFILE, "<$picfile");
    foreach $chunk (<PICFILE>){
        print $chunk;
    }
    close (PICFILE);

}

############################
sub errorExit{
    ($message) = @_;
    
    &header();
    print "$message";
    &footer();
}
    


