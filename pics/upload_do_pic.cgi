#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';
use strict;
use tnmc::template;
use tnmc::db;
use tnmc::cgi;

use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::link;
use tnmc::pics::show;
use tnmc::util::date;
use tnmc::security::auth;

#############
### Main logic


&header();
&do_upload_pic();
&footer();

#
# subs
#

sub do_upload_pic{    
    
    my $cgih = &tnmc::cgi::get_cgih();
    
    print "<pre>\n";
    
    ## grab the special upload params
    my $filename = $cgih->param("UPLOAD_FILENAME");
    my $FILE = $filename;
    print "UPLOAD filename: $FILE \n";
    
    ## grab the normal image params
    my %pic;
    foreach my $key (&db_get_cols_list('Pics')){
        $pic{$key} = $cgih->param($key);
    }
    
    # non-overridable info
    $pic{ownerID} = $USERID;
    
    my %conf = ('verbose' => 1);
    
    my $result = &tnmc::pics::pic::pic_add(\%pic, $FILE, \%conf);
    print "</pre>\n";
    
    if ($result){
        my $picID = $conf{picID};
        print "<b>Upload Successfull</b><br>id: $picID<br>\n";
        print "<a href=\"pic_edit.cgi?picID=$picID\">Continue</a><br>\n";
    }
    else{
        print "<b>Upload failed</b><br>\n";
        print "$conf{error_str}<br>";
    }
}
