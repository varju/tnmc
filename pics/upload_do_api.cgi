#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::cgi;

use tnmc::pics::pic;
use tnmc::util::temp;
use tnmc::db;
use tnmc::util::file;

#############
### Main logic

print "Content-type: text/plain\n\n";
&do_upload_api();

#
# subs
#

sub do_upload_api{    
    
    my $cgih = &tnmc::cgi::get_cgih();
    
    ## grab the special upload params
    my $filename = $cgih->param("UPLOAD_FILENAME");
    my $FILE = $filename;
    print "UPLOAD filename: $FILE \n";
    
    ## store pic to a temp file
    print "getting file\n";
    my $temp_dir = &tnmc::util::temp::get_dir();
    my $file = $temp_dir . $FILE;
    my ($temp_sub_dir, $junk) = &tnmc::util::file::split_filepath($file);
    &tnmc::util::file::make_directory($temp_sub_dir);
    open (OUTFILE, ">$file");
    binmode(OUTFILE);
    binmode($FILE);
    my $buffer;
    while (my $bytesread = read($FILE, $buffer, 1024)){
        print OUTFILE $buffer;
    }
    close OUTFILE;
    
    print "checking upload\n";
    ## grab the normal image params
    my %pic;
    foreach my $key (&db_get_cols_list('Pics')){
        $pic{$key} = $cgih->param($key);
        print "$key - $pic{$key}\n";
    }
    
    # non-overridable info
    
    
    # test: ownerID
    $pic{ownerID} = int($pic{ownerID});
    if (!$pic{ownerID}){
        print "Error: invalid owner\n";
        return 0;
    }
    
    # add the pic
    print "adding pic...\n";
    my %conf = ('verbose' => 1);
    
    my $result = &tnmc::pics::pic::pic_add(\%pic, $file, \%conf);
    
    # clean up
    &tnmc::util::temp::kill_dir($temp_dir);
    
    if ($result){
        my $picID = $conf{picID};
        print "Upload Successfull\nid: $picID\n";
        return 1;
    }
    else{
        print "Upload failed\n";
        print "$conf{error_str}";
        return 0;
    }
}

