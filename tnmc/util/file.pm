package tnmc::util::file;

use strict;
use File::Copy ();

sub split_filepath {
    my ($filepath) = @_;

    my $index = rindex($filepath, '/') + 1;

    return (substr($filepath, 0, $index), substr($filepath, $index));
}

sub send_file {
    my ($filename, $display_name) = @_;

    print "Content-type: application/download\n";
    print "Content-disposition: attachment; filename=$display_name\n\n";

    open(ZIPFH, $filename);
    binmode ZIPFH;
    while (<ZIPFH>) {
        print $_;
    }
    close(ZIPFH);
}

# copied from webct's dbm_dir_util.ph
sub make_directory {
    my ($dir) = @_;

    # does it already exist?
    return 0 if (!defined $dir);
    return 1 if (-d $dir);

    my $err = 0;

    if ($dir =~ /^(.*)\/([^\/]*)$/) {
        my $parent = $1;
        my $child  = $2;

        if (!-d $parent) {
            &make_directory($parent) || $err++;
            return 0 if $err;
        }

        # don't make the directory if $child is ""
        if ($child ne "") {
            mkdir("$parent/$child", 0775) || $err++;
        }
    }
    else {
        mkdir($dir, 0775) || $err++;
    }

    if ($err) {
        return 0;
    }
    else {
        return 1;
    }
}

# copied from webct's dbm_dir_util.ph
sub kill_tree {
    my ($dir) = @_;

    # make sure what we want exists
    return unless $dir;
    return unless -e $dir;

    # allow files to be specified instead of directories
    # also deal with symlinks
    if (-f $dir || -l $dir) {
        unlink($dir);
        return;
    }

    # never assume it's a dir...
    if (!-d $dir) {
        return;
    }

    opendir(DIR, $dir);
    my @filenames = grep(!/^\.\.?$/, readdir(DIR));
    closedir(DIR);

    foreach my $fname (@filenames) {
        my $path = "$dir/$fname";
        if (-d $path) {
            &tnmc::util::file::kill_tree($path);
            rmdir($path);
        }
        else {
            unlink($path);
        }
    }

    rmdir($dir);

    # Note that I don't do error checking for unlink and rmdir
}

sub copy {
    my ($file1, $file2) = @_;

    # make sure that the destination directory exists
    my ($parent) = &split_filepath($file2);

    &make_directory($parent) if (defined $parent);

    my $retval = File::Copy::copy($file1, $file2);

    if (-x $file1) {
        chmod(0775, $file2);
    }

    if ($retval) {
        return 1;
    }
    else {
        return 0;
    }
}

sub move {
    my ($file1, $file2) = @_;

    # make sure that the destination directory exists
    my ($parent) = &split_filepath($file2);

    &make_directory($parent) if (defined $parent);

    my $retval = File::Copy::move($file1, $file2);

    if ($retval) {
        return 1;
    }
    else {
        return 0;
    }
}

sub softlink {
    my ($file1, $file2) = @_;

    # check before doing anything
    return 0 if (-e $file2);
    return 0 if (!-e $file1);

    # make sure that the destination directory exists
    my ($parent) = &split_filepath($file2);
    &make_directory($parent) if (defined $parent);

    # make the softlink
    my @retval = `ln -s $file1  $file2`;

    return -e $file2;
}

sub copytree {
    my ($dir1, $dir2) = @_;

    my @filenames = &list_directory($dir1);

    &make_directory($dir2);

    foreach my $fname (@filenames) {
        if (-d "$dir1/$fname") {
            &copytree("$dir1/$fname", "$dir2/$fname");
        }
        else {
            &copy("$dir1/$fname", "$dir2/$fname") || return 0;
        }
    }

    return 1;
}

sub list_directory {
    my ($dir) = @_;

    opendir(DIR, $dir);
    my @files = readdir DIR;
    closedir(DIR);

    @files = grep { !/^\.+$/ } @files;
    @files = grep { $_ ne 'CVS' } @files;

    return @files;
}

sub list_directory_recursive {
    my ($dir, $curr) = @_;

    $curr = '' if (!$curr);

    my @dirs = &list_directory($dir . $curr);
    my @files;

    foreach my $file (@dirs) {
        if (-d "$dir/$curr$file") {
            push @files, &list_directory_recursive($dir, "$curr$file/");
        }
        else {
            push @files, "$curr$file";
        }
    }
    return @files;
}

1;
