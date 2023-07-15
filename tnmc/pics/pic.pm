package tnmc::pics::pic;

use strict;
use warnings;

use AutoLoader 'AUTOLOAD';

use tnmc::config;
use tnmc::db;

#
# module configuration
#
BEGIN {
    use vars qw($pic_data_dir);
    $pic_data_dir = $tnmc::config::tnmc_basepath . '/pics/data/';
}

#
# module routines
#

########################################
sub set_pic {
    my (%pic, $junk) = @_;
    my ($sql, $sth, $return);

    my $dbh = &tnmc::db::db_connect();
    &tnmc::db::db_set_row(\%pic, $dbh, 'Pics', 'picID');
}

########################################
sub del_pic {
    my ($picID) = @_;
    my ($sql, $sth, $return);

    ###############
    ### Delete the pic

    $sql = "DELETE FROM Pics WHERE picID = '$picID'";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    $sth->finish;
}

########################################
sub get_pic {
    my ($picID, $pic_ref, $junk) = @_;

    my $sql = "SELECT * FROM Pics WHERE picID = ?";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql)
      or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($picID);
    my $ref = $sth->fetchrow_hashref() || return;
    $sth->finish;

    %$pic_ref = %$ref;
}

########################################
sub get_pic_url {
    my ($picID, $format, $junk) = @_;
    my %format = @$format;

    my %pic;
    my $pic_url;

    if (($format{mode} eq 'mini') ||
        ($format{mode} eq 'thumb'))
    {

        &get_pic($picID, \%pic);
        if ($pic{typePublic}) {
            $pic_url = "pics/pub/cache/thumb/$picID";
        }
        else {
            $pic_url = "pics/serve_pic.cgi?mode=thumb&picID=$picID";
        }
    }
    elsif (($format{mode} eq 'small') ||
        ($format{mode} eq 'big')  ||
        ($format{mode} eq 'full') ||
        ($format{mode} eq 'raw'))
    {
        &get_pic($picID, \%pic);
        if ($pic{typePublic}) {
            $pic_url = "pics/pub/cache/full/$picID";
        }
        else {
            $pic_url = "pics/serve_pic.cgi?picID=$picID";
        }
    }
    else {
        $pic_url = "pics/serve_pic.cgi?mode=thumb&picID=$picID";
    }

    return $pic_url;

}

########################################
sub list_pics {
    my ($pic_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$pic_list_ref = ();

    $sql = "SELECT picID from Pics $where_clause $by_clause";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()) {
        push(@$pic_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$pic_list_ref);
}

sub get_exif {
    my ($picID) = @_;

    my %pic;
    &get_pic($picID, \%pic);
    my $filename = $pic_data_dir . $pic{filename};

    return &read_exif($filename);
}

sub read_exif {
    my ($filename) = @_;

    my $jhead  = $tnmc::config::tnmc_basepath . '/tnmc/pics/jhead';
    my @result = `$jhead $filename`;
    my %exif;

    foreach my $line (@result) {
        chomp $line;
        my ($key, $val) = split(': ', $line, 2);
        $key =~ s/\s+$//;
        $exif{$key} = $val;
    }
    return \%exif;
}

1;

__END__

#
# autoloaded module routines
#

########################################
sub save_pic {
    my (%pic) = @_;

    &set_pic(%pic);
    &update_cache($pic{picID});
    &update_cache_pub($pic{picID});
}

########################################
sub update_cache {
    my ($picID) = @_;

    use tnmc::util::file;

    my %pic;
    &get_pic($picID, \%pic);
    use Image::Magick;
    my ($image, $x);

    # load in the pic data
    $image = Image::Magick->new;
    $x     = $image->Read("data/$pic{filename}");

    # normalize the image if so desired
    if ($pic{'normalize'}) {
        $x = $image->Normalize();
    }

    # rotate the image as desired
    # to do..

    # full image
    {
        my $dir      = "/tnmc/pics/data/cache/full/";
        my $filename = $dir . $picID;

        open(CACHE, ">$filename");
        $x = $image->Write('file' => *CACHE, 'compress' => 'JPEG');
        close(CACHE);
    }

    # make a thumbnail
    {
        $x = $image->Minify();
        $x = $image->Sample(width => '160', height => '128');

        my $dir      = "/tnmc/pics/data/cache/thumb/";
        my $filename = $dir . $picID;

        open(CACHE, ">$filename");
        $x = $image->Write('file' => *CACHE, 'compress' => 'JPEG');
        close(CACHE);
    }

}

sub update_cache_pub {
    my ($picID) = @_;

    use tnmc::util::file;

    my %pic;
    &get_pic($picID, \%pic);

    my $cache_dir = "/tnmc/pics/data/cache/";
    my $pub_dir   = "/tnmc/pics/pub/cache/";
    my @modes     = ('thumb', 'full');

    # clear existing cached pic
    foreach my $mode (@modes) {
        unlink("$pub_dir$mode\/$picID");
    }

    if ($pic{'typePublic'}) {
        foreach my $mode (@modes) {
            &tnmc::util::file::softlink("$cache_dir$mode\/$picID", "$pub_dir$mode\/$picID");
        }
    }

}

########################################
sub get_file_info {
    my ($picID) = @_;

    return if !$picID;

    my %pic;
    &get_pic($picID, \%pic);

    my $filename = "data\/$pic{filename}";
    return if (!-e $filename);

    use Image::Magick;
    my ($image, $x);

    # load in the pic data
    $image = Image::Magick->new;
    $x     = $image->Read("$filename");

    # grab the height and width
    my ($height, $width) = $image->Get('base_rows', 'base_columns');
    $pic{height} = $height;
    $pic{width}  = $width;

    &set_pic(%pic);
}

sub pic_add {
    my ($details, $FILE, $conf) = @_;

    use tnmc::util::file;
    use tnmc::util::date;
    use tnmc::security::auth;

    my %pic     = %$details;
    my $verbose = $conf->{'verbose'};

    ## exif info
    my $exif = &tnmc::pics::pic::read_exif($FILE);

    # pic: timestamp
    if (!$pic{timestamp} ||
        $pic{timestamp} eq '0000-00-00 00:00:00' ||
        $pic{timestamp} !~ /(....)\-(..)\-(..) (..)\:(..)\:(..)/)
    {
        print("invalid timestamp ($pic{timestamp})... ") if $verbose;
        if ($exif->{'Date/Time'}) {
            $pic{timestamp} = &tnmc::util::date::format_date('mysql', $exif->{'Date/Time'});
            print("set to exif ($pic{timestamp})\n") if $verbose;
        }
        else {
            $pic{timestamp} = &tnmc::util::date::now();
            print("set to now ($pic{timestamp})\n") if $verbose;
        }
    }

    # pic: ownerID
    if (!int($pic{ownerID})) {
        print "no owner ($pic{ownerID} ->" if $verbose;
        $pic{ownerID} = $USERID;
        print " $pic{ownerID}) ($USERID)\n" if $verbose;
    }

    # pic: filename
    if (!$pic{filename}) {
        $pic{timestamp} =~ /(....)\-(..)\-(..) (..)\:(..)\:(..)/;
        my $pic_dir_name  = "$pic{ownerID}/$1/$1-$2-$3/";
        my $pic_file_name = "$4_$5_$6_$FILE";
        $pic_file_name =~ s/^.*[\/\\]//g;    # get rid of the dir stuff
        $pic_file_name =~ s/[\s]/_/g;        # remove spaces
        $pic_file_name =~ s/[^\.\w]/_/g;     # remove strange chars
        $pic{filename} = $pic_dir_name . $pic_file_name;
        print "Generating filename: $pic{filename}\n" if $verbose;
    }

    # pic: picID
    $pic{picID} = 0;

    # pic: user info (rateContent, rateImage, title, description, typePublic)
    $pic{typePublic}  = 1 if (!defined $pic{typePublic});
    $pic{rateContent} = 0 if (!defined $pic{rateContent});

    # test: pic already exists
    if (-e "data\/$pic{filename}") {
        print "error: pic already exists!\n" if $verbose;
        $conf->{'error_str'} = "pic already exists";
        return 0;
    }

    # file: data/dir
    my ($pic_dir, $junk) = &tnmc::util::file::split_filepath($pic{filename});
    print "dir: $pic_data_dir $pic_dir\n" if $verbose;
    `mkdir -p $pic_data_dir/$pic_dir`;

    # file: data/file
    print "from: $FILE\n";
    &tnmc::util::file::copy($FILE, "$pic_data_dir/$pic{filename}");

    #    open (OUTFILE, ">pic_data_dir/$pic{filename}");
    #    binmode(OUTFILE);
    #    binmode($FILE);
    #    my $buffer;
    #    while (my $bytesread = read($FILE, $buffer, 1024)){
    #        print OUTFILE $buffer;
    #    }
    #    close OUTFILE;
    #    print "file saved ($FILE)\n" if $verbose;

    # test: file size is nonzero
    #my @file_status = stat "data/$pic{filename}";
    #if(! $file_status[7]){
    #    `rm -f data/$pic{filename}`;
    #    &errorExit("picture upload unsucessful - no data recieved!");
    #}

    # db: add entry
    print "saving to db...\n" if $verbose;
    &set_pic(%pic);

    # db: get picID
    print "saving to data/ ($pic{filename})\n";
    my $sql = "SELECT picID FROM Pics WHERE filename = ?";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute($pic{filename});
    my ($picID) = $sth->fetchrow_array();
    $sth->finish();
    $pic{picID} = $picID;
    print "picID: $picID\n" if $verbose;
    $conf->{picID} = $picID;

    # test: picID
    if (!$picID) {
        print "error: cannot find picID\n" if $verbose;
        $conf->{'error_str'}      = "can not find picID";
        $conf->{'error_filename'} = $pic{filename};
        return 0;
    }

    # pic: extended info (width, height)
    print "reading file info\n" if $verbose;
    &tnmc::pics::pic::get_file_info($picID);

    # file: process & cache
    print "setting up cache...\n" if $verbose;
    &tnmc::pics::pic::update_cache($picID);
    &tnmc::pics::pic::update_cache_pub($picID);

    # done
    print "pic added.\n" if $verbose;
    return 1;
}

1;
