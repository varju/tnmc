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

$cgih = &tnmc::cgi::get_cgih();
	
my $picID = $cgih->param(picID);
my %pic;

&get_pic($picID, \%pic);

if ($picID && &auth_access_pic_edit($picID, \%pic)){
    
    $pic{typePublic} = $cgih->param(typePublic);
    $pic{title} = $cgih->param(title);
    $pic{description} = $cgih->param(description);
    $pic{comments} = $cgih->param(comments);
    $pic{rateImage} = $cgih->param(rateImage);
    $pic{rateContent} = $cgih->param(rateContent);
    $pic{normalize} = $cgih->param(normalize);
    $pic{timestamp} = $cgih->param(timestamp);
    $pic{ownerID} = $cgih->param(ownerID);
    
    &save_pic(%pic);
}
$destination = $cgih->param(destination) || $ENV{HTTP_REFERER};

print "Location: $destination\n\n";

