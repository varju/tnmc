package tnmc::template;

use strict;

#
# module configuration
#
BEGIN {
    
    use Exporter;
    use vars qw(@ISA @EXPORT @EXPORT_OK $style $AUTOLOAD);
    
    @ISA = qw(Exporter );
    @EXPORT = qw(header footer show_heading get_font_size);
    @EXPORT_OK = qw();
    
    $style = 'html_orig';
}

#
# module routines
#

sub AUTOLOAD {
    # pass the buck onto the template style we're using
    my $sub = $AUTOLOAD;
    $sub =~ s/.*:://; # trim package name
    
    my $req = 'tnmc/template/' . $style . '.pm';
    require $req;
    
    my $call = '&tnmc::template::' . $style . '::' . $sub . '(@_)';
    eval ($call);
}

1;
