#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::template;
use tnmc::cgi;

use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::link;
use tnmc::pics::show;
use tnmc::pics::new;

$force = 0;

#############
### Main logic

$basePicDir = "data/";

&tnmc::security::auth::authenticate();

my $picID = &tnmc::cgi::param(picID);
my $mode = &tnmc::cgi::param(mode);

&serve_picture($mode, $picID);

#
# subs
#

sub serve_picture{
    
    my ($mode, $picID) = @_;

    my %pic;
    &tnmc::pics::pic::get_pic($picID, \%pic);
    $picfile = "$basePicDir$pic{filename}";
    
    ## Access control
    if (! &tnmc::pics::new::auth_access_pic_view($picID, \%pic) ){
        errorExit( "access not allowed!");
    }
    ## Does pic exist?
    elsif (! -f $picfile){
        errorExit( "pic not found!");
    }
    
    ## THUMB
    if ($mode eq "thumb"){
        
        ## re-cache it if neccessary
        my $cache_file = "$basePicDir/cache/$mode/$picID";
        if ($force || ! -f "$cache_file"){
            &tnmc::pics::pic::update_cache($pic{picID});
            &tnmc::pics::pic::update_cache_pub($pic{picID});
        }
        &serve_file($cache_file);
    }
    ## ORIG
    elsif ($mode eq "orig"){
        &serve_file($picfile);
    }
    ## CUSTOM
    elsif ($mode eq "custom"){
        
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
#         $x = $image->Sample(width=>'160', height=>'128');
        
        $x = $image->Rotate(degrees=>'90');
        
        $x = $image->Minify();
#        $x = $image->Normalize();
#        $x = $image->Gamma('green'=>0.5, 'red' => 0.8,' blue' => 4.8);  
#        $x = $image->Equalize();
#        print STDERR $x;
#        
#        $x = $image->ReduceNoise('radius' => 3);
#        $x = $image->Minify();
#        $x = $image->ReduceNoise('radius' => 8);
#        $x = $image->Contrast('sharpen'=>1);
#                           'mid-point' => 3,
#                           'white-point' => 56000
#                           );
#        $x = $image->Level('black-point' => 6000,
#                           'mid-point' => 3,
#                           'white-point' => 56000
#                           );
      
        $x = $image->Write(file=>STDOUT, compress=>'JPEG');
        
        
        # $x = $image->Sample(width=>'320', height=>'240');
        # $x = $image->Rotate(degrees=>'90');
        
        # $p = Image::Magick->new;
        # $p->Read($picfile);
        # $p->Set(attribute => value, ...)
        # ($a, ...) = p->Get("attribute", ...)
        # $p->routine(parameter => value, ...)
        # $p->Mogrify("Routine", parameter => value, ...)
        # $p->Write(STDOUT);
    }
    ## BRIGHT
    elsif ($mode eq "bright"){

        {
            use Image::Magick;
            
            print "Content-type: image/jpeg\n\n";

            my($image, $x);
            
            $image = Image::Magick->new;
            $x = $image->Read($picfile);


            $x = $image->Normalize();

            $x = $image->Minify();
#            $x = $image->Minify();
#            $x = $image->Sample(width=>'160', height=>'128');

#            $x = $image->Minify();

#            $x = $image->Despeckle();
#            $x = $image->ReduceNoise();

#            $x = $image->Modulate(brightness=>'100', saturation=>'100', hue=>'100' );



            $x = $image->Write(file=>STDOUT, compress=>'JPEG');

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
    ## FULL
    else{
        ## serve it from the cache if we can
        my $cache_file = "$basePicDir/cache/full/$picID";
        if (! $force && -f "$cache_file"){
            &serve_file($cache_file);
        }else{
            &serve_file($picfile);
        }
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
    
    &tnmc::template::header();
    print "$message";
    &tnmc::template::footer();
}
    


