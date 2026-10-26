package tnmc;

use strict qw(vars subs);    # strict refs breaks the lazy autoloader
use warnings;

require tnmc::config;
require tnmc::template;
require tnmc::security::auth;

#
# Usage: "use tnmc;" (saying require may result in 'Name "tnmc::blah"
# used only once: possible typo' messages)
#

# Ignore those annoying what-you-are-doing-is-bad messages.
sub handle_warnings {
    my ($warning) = @_;
    if ($warning =~ /^Use of inherited AUTOLOAD for non-method/) {

        # print STDERR "AUTOLOAD gripe: $warning\n";
    }
    else {
        print STDERR $warning;
    }
}
$SIG{__WARN__} = \&handle_warnings;

# Perl 5.28+ no longer lets plain function calls fall through to
# UNIVERSAL::AUTOLOAD, so give each tnmc package that isn't loaded yet its own
# AUTOLOAD that requires the module.  A module that uses AutoLoader replaces it.
foreach my $file (glob('/tnmc/tnmc/*.pm'), glob('/tnmc/tnmc/*/*.pm')) {
    my $pkg = substr($file, length('/tnmc/'));
    next if $INC{$pkg};    # already loaded, or still compiling
    $pkg =~ s/\.pm$//;
    $pkg =~ s/\//::/g;
    next if $pkg =~ /^tnmc::updater::/;
    next if defined &{"${pkg}::AUTOLOAD"};
    *{"${pkg}::AUTOLOAD"} = \&tnmc::lazyload::AUTOLOAD;
}

package tnmc::lazyload;

use vars qw($AUTOLOAD);

sub AUTOLOAD {
    my $sub = $AUTOLOAD;
    return if $sub =~ /::DESTROY$/;

    $sub =~ /^(.*)::([^:]+)$/;
    my $pkg = $1;
    my $req = $pkg . ".pm";
    $req =~ s/\:\:/\//g;
    require $req;

    # still our stub and no such sub: avoid looping forever
    if (!defined &$sub && \&{"${pkg}::AUTOLOAD"} == \&AUTOLOAD) {
        die "Undefined subroutine &$sub called";
    }
    goto &$sub;
}

# provide a universal AUTOLOAD
package UNIVERSAL;

BEGIN {
    use vars qw($AUTOLOAD);
}

sub AUTOLOAD {
    my $sub = $AUTOLOAD;

    return unless $sub =~ /^tnmc::/;
    return if $sub =~ /::DESTROY$/;
    return if $sub =~ /tnmc::updater::/;

    $sub =~ /^(.*)::([^*]+)/;
    my $req = $1 . ".pm";
    $req =~ s/\:\:/\//g;
    my @vars = @_;
    require $req;

    &$sub(@vars);
}

1;
