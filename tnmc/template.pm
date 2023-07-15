package tnmc::template;

use strict;
use warnings;

#
# module configuration
#
BEGIN {
    use tnmc::security::auth;
    use vars qw($style $AUTOLOAD);
}

#
# module routines
#

sub set_template {
    my ($template) = @_;
    $style = $template;
}

sub get_template {
    if (!$style) {
        &tnmc::security::auth::authenticate();
        $style = $tnmc::security::auth::USERID{template_html} || 'html_orig';
    }
    return $style;
}

sub list_templates {
    my @styles = qw(
      html_orig
      html_orig_v2
      html_black
      html_2003
      html_blat
      html_monkeys
      html_nuts
    );
    return @styles;
}

sub AUTOLOAD {

    # pass the buck onto the template style we're using
    my $sub = $AUTOLOAD;
    $sub =~ s/.*:://;    # trim package name

    my $style = &get_template();
    my $req   = 'tnmc/template/' . $style . '.pm';
    require $req;

    my $call = '&tnmc::template::' . $style . '::' . $sub . '(@_)';
    eval($call);
}

1;
