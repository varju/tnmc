package tnmc;

use strict qw(vars subs); # strict refs breaks the lazy autoloader

require tnmc::config;
require tnmc::template;
require tnmc::security::auth;

# 
# Usage: "use tnmc;" (saying require may result in 'Name "tnmc::blah"
# used only once: possible typo' messages)
#

# Ignore those annoying what-you-are-doing-is-bad messages.
sub handle_warnings{
    my ($warning) = @_;
    if ($warning =~ /^Use of inherited AUTOLOAD for non-method/){
        # print STDERR "AUTOLOAD gripe: $warning\n";
    }
    else{
        print STDERR $warning;
    }
}
$SIG{__WARN__} =  \&handle_warnings;


# provide a universal AUTOLOAD
package UNIVERSAL;

BEGIN {
    use vars qw($AUTOLOAD);
}

sub AUTOLOAD{
    my $sub = $AUTOLOAD;
    
    if ($sub =~ /^tnmc::/){
        
        $sub =~ /^(.*)::([^*]+)/;
        my $req = $1 . ".pm";
        $req =~ s/\:\:/\//g;
        #my $call = $2;
        my @vars = @_;
        require $req;
        &$sub(@vars);
    }
}

1;
