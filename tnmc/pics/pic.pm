package tnmc::pics::pic;

use strict;

use tnmc::security::auth;
use tnmc::db;
use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(
             set_pic del_pic get_pic
             update_cache save_pic get_file_info
             get_pic_url list_pics
             );

@EXPORT_OK = qw();

#
# module vars
#

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
    my ($condition);

    $condition = "(picID = '$picID')";
    &db_get_row($pic_ref, $dbh_tnmc, 'Pics', $condition);
}

########################################
sub save_pic{
    my (%pic) = @_;
    
    &set_pic(%pic);
    &update_cache($pic{picID});
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
        &tnmc::util::file::make_directory($dir);
        
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
        &tnmc::util::file::make_directory($dir);
        
        my $filename = $dir . $picID;
        
        open (CACHE, ">$filename");
        $x = $image->Write('file'=>*CACHE, 'compress'=>'JPEG');
        close (CACHE);
        
        # to do..
        if ($pic{'typePublic'}){
            # save a thumbnail to the pub dir
        }else{
            
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
