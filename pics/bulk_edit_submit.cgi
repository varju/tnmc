#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;

use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::link;

#############
### Main logic

&do_bulk_edit();

#
# subs
#

sub do_bulk_edit{

    &tnmc::template::header();
    
    &tnmc::template::show_heading("Bulk edit - save changes");
    my $destination = &tnmc::cgi::param(destination);
    print "<p><a href=\"$destination\">continue</a><br><br>\n\n";
    
    # grab the cgi info into a big 2-d hash
    my @params = &tnmc::cgi::param();
    
    ## do all the pic changes
    my %PICS;
    foreach $param (@params){
        next unless($param =~ /^PIC(\d+)_(.*)$/);
        my $picID = $1;
        my $field = $2;
        
        if(! defined $PICS{$picID}){
            my %pic;
            &tnmc::pics::pic::get_pic($picID, \%pic);
            $PICS{$picID} = \%pic;
        }
        $PICS{$picID}->{$field} = &tnmc::cgi::param($param);
    }
    
    ## do all the link changes and deletions
    my %LINKS;
    foreach $param (@params){
        next unless($param =~ /^LINK(\d+)_(.*)$/);
        my $linkID = $1;
        my $field = $2;
        my $value = &tnmc::cgi::param($param);
        
        ## 'delete-link'
        if (!$value && $linkID){
            &tnmc::pics::link::del_link_by_linkID($linkID)
            }
        ## 'edit-link'
        elsif ($value && $linkID){
            if(! defined $LINKS{$linkID}){
                my $link =  &tnmc::pics::link::get_link_by_linkID($linkID);
                $LINKS{$linkID} = $link;
            }
            $LINKS{$linkID}->{$field} = $value;
        }
    }
    
    ## do all the link insertions
    foreach $param (@params){
        next unless($param =~ /^NEWLINK(\d+)_(.*)$/);
        my $picID = $1;
        my $field = $2;
        my $value = &tnmc::cgi::param($param);
        
        ## unused 'new-link'
        if (!$value){
            next;
        }
        ## 'new-link'
        elsif ($value && !$linkID){
            my $albumID = $value;
            &tnmc::pics::link::add_link($picID, $albumID)
            }
    }
    
    my $debug = 0;
    if ($debug){
        # user output
        print $moo;
        &tnmc::template::show_heading("pics");
        foreach $picID (keys(%PICS)){
            print  %{$PICS{$picID}};
            print "<p>";
        }
        &tnmc::template::show_heading("links");
        foreach $key (keys(%LINKS)){
            print  %{$LINKS{$key}};
            print "<p>";
        }
    }
    
    &tnmc::template::footer();
    
    ## save all the pics to the db
    foreach $picID (keys(%PICS)){
        &tnmc::pics::pic::set_pic( %{$PICS{$picID}} );
        &tnmc::pics::pic::update_cache_pub($picID);
    }
    
    ## save all the links to the db
    foreach $linkID (keys(%LINKS)){
        &tnmc::pics::link::update_link( $LINKS{$linkID} );
    }
    
    # goodbye 
    
    
}
