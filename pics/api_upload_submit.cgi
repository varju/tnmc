#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::cookie;
use tnmc::db;

require 'pics/PICS.pl';

{
    #############
    ### Main logic

    $cgih = new CGI;
    &db_connect();
    &cookie_get();
    print "Content-type: text/plain\n\n";
    

    ## grab the special api params
    $filename = $cgih->param("API_FILENAME");
    $FILE = $filename;
    # print "API filename: $FILE\n";
    
    ## grab the normal image params
    @cols = &db_get_cols_list('Pics');
    foreach $key (@cols){
        $pic{$key} = $cgih->param($key);
    }

    # never overwrite an entry
    $pic{picID} = 0;
    
    # verify timestamp
    &errorExit("no timestamp!") if(!$pic{timestamp} || $pic{timestamp} eq '0000-00-00 00:00:00' || $pic{timestamp} !~ /(....)\-(..)\-(..) (..)\:(..)\:(..)/);

    # determine pic owner
    if (!$pic{ownerID}){
        print "no owner ($pic{ownerID} ->";
        $pic{ownerID} = $USERID;
        print " $pic{ownerID}) ($USERID)\n";
    }
    
    # determine pic filename
    if (!$pic{filename}){
        $pic{timestamp} =~ /(....)\-(..)\-(..) (..)\:(..)\:(..)/;
        my $pic_dir_name = "api/$1/$1-$2-$3/";
        my $pic_file_name = "pic_$1_$2_$3_$4_$5_$6_$FILE";
        $pic_file_name =~ s/^.*[\/\\]//; # get rid of the dir stuff
        $pic_file_name =~ s/[\s]/_/; # remove spaces
#        $pic_file_name =~ s/[^\.\W]/_/; # remove strange chars
        $pic{filename} = $pic_dir_name . $pic_file_name;
        print `mkdir -p data/$pic_dir_name`;
        print "mkdir -p data/$pic_dir_name";
        print "dest file:$pic{filename}\n";
    }
    else{
        my $pic_dir_name = $pic{filename};
        $pic_dir_name =~ s/\/[^\/]+$//; # get rid of the dir stuff
        `mkdir -p data/$pic_dir_name`;
        print "dest dir: $pic_dir_name\n";
    }
    
    # verify filename is okay
    &errorExit("file $pic{filename} already exists!") if(-e "data/$pic{filename}");
    #print "filename: $pic{filename}\n";
    
    # save the file
    open (OUTFILE, ">data/$pic{filename}");
    my $buffer;
    while ($bytesread = read($filename, $buffer, 1024)){
        print OUTFILE $buffer;
    }
    close OUTFILE;
    print "file saved ($FILE)\n";
    
    # verify the file size is nonzero
    @file_status = stat "data/$pic{filename}";
    if(! $file_status[7]){
        `rm -f data/$pic{filename}`;
        &errorExit("picture upload unsucessful - no data recieved!");
    }
    
    # save to the db
    &set_pic(%pic);
    
    
    # get the picID
    my $sql = "SELECT picID FROM Pics WHERE filename = '$pic{filename}'";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    my ($picID) = $sth->fetchrow_array();
    $sth->finish();
    
    $pic{picID} = $picID;
    
    print "db entry saved: $picID\n";
    
    &import_extended_info($picID);
    
    print "extended info loaded\n";
    
    &db_disconnect();
    
    
}


sub errorExit{
    my ($msg) = @_;
    print "Error: $msg\n";
    exit(1);
}

sub import_extended_info{
    
    my ($picID) = @_;
    
    my %pic;
    &get_pic($picID, \%pic);
    use Image::Magick;
    my($image, $x);
    
    # load in the pic data
    $image = Image::Magick->new;
    $x = $image->Read("data/$pic{filename}");
    
    # grab the height and width
    my ($height, $width) = $image->Get('base_rows', 'base_columns');
    $pic{height} = $height;
    $pic{width} = $width;

    
    &set_pic(%pic);
    
    # make a thumbnail
    $x = $image->Sample(width=>'160', height=>'128');
    open (CACHE, ">data/cache/thumb/$picID");
    $x = $image->Write(file=>CACHE, compress=>'JPEG');
    close (CACHE);
    
}    

