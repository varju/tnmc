package tnmc::template;

use strict;

use tnmc::config;
use tnmc::db;
use tnmc::menu;
use tnmc::security::auth;
use tnmc::template::html_orig;
use tnmc::template::html_black;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(header footer show_heading get_font_size);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#


sub header{
    return &tnmc::template::html_orig::header();
}


sub footer{
    return &tnmc::template::html_orig::footer(@_);
}


sub show_heading{
    return &tnmc::template::html_orig::show_heading(@_);
}


sub get_font_size {
    return &tnmc::template::html_orig::get_font_size(@_);
}



1;
