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
use tnmc::pics::new;

#############
### Main logic

my $picID = &tnmc::cgi::param(picID);
my %pic;
&tnmc::pics::pic::get_pic($picID, \%pic);

if ($picID && &tnmc::pics::new::auth_access_pic_edit($picID, \%pic)) {

    $pic{typePublic}  = &tnmc::cgi::param(typePublic);
    $pic{title}       = &tnmc::cgi::param(title);
    $pic{description} = &tnmc::cgi::param(description);
    $pic{comments}    = &tnmc::cgi::param(comments);
    $pic{rateImage}   = &tnmc::cgi::param(rateImage);
    $pic{rateContent} = &tnmc::cgi::param(rateContent);
    $pic{normalize}   = &tnmc::cgi::param(normalize);
    $pic{timestamp}   = &tnmc::cgi::param(timestamp);
    $pic{ownerID}     = &tnmc::cgi::param(ownerID);

    &tnmc::pics::pic::save_pic(%pic);
}
$destination = &tnmc::cgi::param(destination) || $ENV{HTTP_REFERER};

print "Location: $destination\n\n";

