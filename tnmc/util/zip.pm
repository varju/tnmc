package tnmc::util::zip;

use strict;

use tnmc::util::file;

#
# module routines
#

sub extract {
    my ($zipfile, $directory) = @_;

    my @files_list;

    open(PH, "unzip $zipfile -d $directory |");
    binmode PH;
    while (my $line = <PH>) {
        next if ($line !~ /inflating:\s+$directory(.*[^\s])\s+$/);

        push (@files_list, $1);
    }
    close (PH);

    return \@files_list;
}

sub create {
    my ($directory, $zip_filename) = @_;

    # make sure that the destination directory exists
    my ($parent) = &tnmc::util::file::split_filepath($zip_filename);

    &tnmc::util::file::make_directory($parent) if (defined $parent);
 
    `cd $directory; zip -r $zip_filename .`;
    
    return 1;
}

sub tar {
    my ($directory, $zip_filename) = @_;

    # make sure that the destination directory exists
    my ($parent) = &tnmc::util::file::split_filepath($zip_filename);

    &tnmc::util::file::make_directory($parent) if (defined $parent);

    `cd $directory; tar cvhzf $zip_filename *`;
    
    return 1;
}
    
1;

