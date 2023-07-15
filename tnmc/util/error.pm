package tnmc::util::error;

use strict;
use warnings;

#
# module vars
#

use vars qw(@exceptions);

#
# module routines
#

sub throw {
    my ($name, $details) = @_;

    # create an exception hash
    my %ex;
    $ex{'name'} = $name;

    # grab the details if avail
    if (defined $details) {
        $ex{'details'} = $details;
    }

    # get the caller history.
    my @this;
    my $i = 0;
    while (@this = caller($i++)) {
        my %call;
        $call{'package'}  = $this[0];
        $call{'line'}     = $this[2];
        $call{'filename'} = $this[1];

        #ugh (kludge): caller() doesn't quite format the info the way we'd like :P
        my @next = caller($i);
        $call{'subname'} = $next[3];

        push(@{ $ex{'caller'} }, \%call);
    }

    # store some usefull info
    $ex{'sub'} = $ex{'caller'}[0]->{'subname'};

    # tell someone what's going down
    print STDERR "[Throw " . scalar(@exceptions) . "] $ex{'sub'} \"$ex{'name'}\"\n";

    # push the exception onto list
    push @exceptions, \%ex;

    # return undef, for convenience.
    return;
}

sub pass {
    my ($ex) = @_;

    # blindly push the exception back onto list
    push @exceptions, $ex;
}

sub catch {
    my ($name) = @_;

    # nothing to tell
    if (!scalar(@exceptions)) {
        return;
    }

    if ($name) {

        # if the name matches
        if ($name eq $exceptions[ scalar(@exceptions) - 1 ]->{'name'}) {

            # give them the last error
            my $ex = pop @exceptions;
            return $ex;
        }
        else {
            # last error doesn't match
            return;
        }
    }
    else {
        # give them the last error
        my $ex = pop @exceptions;
        return $ex;
    }
}

sub catch_all {

    # give them everything
    my @list = @exceptions;
    @exceptions = ();
    return @list;
}

sub count {

    # tell them if we have error (s)
    return scalar(@exceptions);
}

# this fn should only be used for testing purposes.
sub list {
    my @names = map { $_->{'name'} } @exceptions;
}

1;

