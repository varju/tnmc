package tnmc::pics::pic;

use strict;

#
# module configuration
#
BEGIN{
    use tnmc::db;
    
    require Exporter;
    require AutoLoader;
    use vars qw(@ISA @EXPORT @EXPORT_OK);
    
    @ISA = qw(Exporter AutoLoader);
    
    @EXPORT = qw(
                 set_pic del_pic get_pic
                 get_pic_url list_pics
                 
                 update_cache update_cache_pub save_pic get_file_info
                 );
    
    @EXPORT_OK = qw();
}

#
# module routines
#


########################################
sub set_pic{
    my (%pic, $junk) = @_;
    my ($sql, $sth, $return);
    
    &db_set_row(\%pic, $dbh_tnmc, 'Pics', 'picID');
}

########################################
sub del_pic{
    my ($picID) = @_;
    my ($sql, $sth, $return);
    
    ###############
    ### Delete the pic
    
    $sql = "DELETE FROM Pics WHERE picID = '$picID'";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    $sth->finish;
}

########################################
sub get_pic{
    my ($picID, $pic_ref, $junk) = @_;
    
    my $sql = "SELECT * FROM Pics WHERE picID = ?";
    my $sth = $dbh_tnmc->prepare($sql)
        or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($picID);
    my $ref = $sth->fetchrow_hashref() || return;
    $sth->finish;
    
    %$pic_ref = %$ref;
}

########################################
sub get_pic_url{
    my ($picID, $format, $junk) = @_;
    my %format = @$format;
    
    my %pic;
    my $pic_url;
    
    if (($format{mode} eq 'mini') ||
        ($format{mode} eq 'thumb')){
        
        &get_pic($picID, \%pic);
        if ($pic{typePublic}){
            $pic_url = "/pics/pub/cache/thumb/$picID";
        }else{
            $pic_url = "/pics/serve_pic.cgi?mode=thumb&picID=$picID";
        }
    }
    elsif (($format{mode} eq 'small') ||
           ($format{mode} eq 'big') ||
           ($format{mode} eq 'full') ||
           ($format{mode} eq 'raw')){
        $pic_url = "/pics/serve_pic.cgi?picID=$picID";
    }else{
        $pic_url = "/pics/serve_pic.cgi?mode=thumb&picID=$picID";
    }
    
    return $pic_url;
    
}

########################################
sub list_pics{
    my ($pic_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);
    
    @$pic_list_ref = ();
    
    $sql = "SELECT picID from Pics $where_clause $by_clause";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$pic_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar(@$pic_list_ref);
}

1;

__END__


#
# autoloaded module routines
#

########################################
sub save_pic{
    my (%pic) = @_;
    
    &set_pic(%pic);
    &update_cache($pic{picID});
    &update_cache_pub($pic{picID});
}

########################################
sub update_cache{
    my ($picID) = @_;
    
    use tnmc::util::file;
    
    my %pic;
    &get_pic($picID, \%pic);
    use Image::Magick;
    my($image, $x);
    
    # load in the pic data
    $image = Image::Magick->new;
    $x = $image->Read("data/$pic{filename}");
    
    # normalize the image if so desired
    if ($pic{'normalize'}){
        $x = $image->Normalize();
    }
    
    # rotate the image as desired
    # to do..
    
    # full image
    {
        my $dir = "/tnmc/pics/data/cache/full/";
        my $filename = $dir . $picID;
        
        open (CACHE, ">$filename");
        $x = $image->Write('file'=>*CACHE, 'compress'=>'JPEG');
        close (CACHE);
    }
    
    # make a thumbnail
    {
        $x = $image->Minify();
        $x = $image->Sample(width=>'160', height=>'128');
        
        my $dir = "/tnmc/pics/data/cache/thumb/";
        my $filename = $dir . $picID;
        
        open (CACHE, ">$filename");
        $x = $image->Write('file'=>*CACHE, 'compress'=>'JPEG');
        close (CACHE);
    }
    
}

sub update_cache_pub{
    my ($picID) = @_;
    
    use tnmc::util::file;
    
    my %pic;
    &get_pic($picID, \%pic);

    
    my $cache_dir = "/tnmc/pics/data/cache/";
    my $pub_dir = "/tnmc/pics/pub/cache/";
    my @modes = ('thumb', 'full');
    
    # clear existing cached pic
    foreach my $mode (@modes){
        unlink("$pub_dir$mode\/$picID");
    }
    
    if ($pic{'typePublic'}){
        foreach my $mode (@modes){
            &tnmc::util::file::softlink
                ( "$cache_dir$mode\/$picID",
                  "$pub_dir$mode\/$picID"
                  );
        }
    }
    
}

########################################
sub get_file_info{
    my ($filename) = @_;
    
    my %pic;
    
    use Image::Magick;
    my($image, $x);
    
    # load in the pic data
    $image = Image::Magick->new;
    $x = $image->Read("data/$filename");
    
    # grab the height and width
    my ($height, $width) = $image->Get('base_rows', 'base_columns');
    $pic{height} = $height;
    $pic{width} = $width;
    
    return \%pic;
}

1;
