#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

require 'pics/PICS.pl';

{
    #############
    ### Main logic

    my $PIC_DATA_DIR = 'data';
    my %IMAGES;

    @PATHS = ($PIC_DATA_DIR);

    ## sift through the data directory.
    foreach $path (@PATHS) {

        ## if it's a directory
        if (-d $path) {

            next if ($path =~ /\/\.$/);
            next if ($path =~ /\/\.\.$/);

            opendir(CURR_DIR, $path);
            @curr_listing = readdir(CURR_DIR);
            closedir(CURR_DIR);

            foreach $file (sort @curr_listing) {

                ## breadth-first
                push(@PATHS, "$path/$file");

                ## depth first (i think)
                # unshift (@PATHS, $file);
            }
            next;
        }

        ## Filename patterns that we don't like go here.
        next if ($path =~ /\.htaccess$/);

        ## otherwise, assume it's an image :)
        {
            ## get the filename that we want
            my $filename = $path;
            $filename =~ s/\Q$PIC_DATA_DIR//;
            $IMAGES{$path}->{filename} = $filename;

            ## try to get the dir name (dir_stamp)
            $filename =~ /\/(\d\d\d\d-\d\d-\d\d)\//;
            my $dir_stamp = $1;

            ## try to get the timestamp
            use POSIX qw(strftime);
            my @file_status = stat("$path");
            my $file_stamp  = strftime "%Y-%m-%d %H:%M:%S ", localtime $file_status[9];

            if ($dir_stamp eq substr($file_stamp, 0, 10)) {
                $timestamp = $file_stamp;
            }
            else {
                if ($dir_stamp) {
                    $timestamp = $dir_stamp;
                }
                else {
                    $timestamp = '';

                    # $timestamp = $file_stamp;
                }
            }
            $IMAGES{$path}->{timestamp} = $timestamp;

            ## Set the other defaults
            $IMAGES{$path}->{picID}      = '0';
            $IMAGES{$path}->{ownerID}    = '1';
            $IMAGES{$path}->{typePublic} = '0';

        }
    }

    &db_connect();

    foreach my $path (sort keys %IMAGES) {

        # skip pics that are already in the db..
        my $sql = "SELECT picID FROM Pics WHERE filename = '$IMAGES{$path}->{filename}'";
        my $sth = $dbh_tnmc->prepare($sql);
        $sth->execute();
        if ($sth->fetchrow_array()) {
            next;
        }

        %pic = %{ $IMAGES{$path} };

        print "ADD: $pic{filename}\n";
        &set_pic(%pic);

    }

    #    &get_pic($picID, \%pic);
    &db_disconnect();

}

