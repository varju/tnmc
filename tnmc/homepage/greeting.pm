package tnmc::homepage::greeting;

use strict;
use warnings;

use tnmc;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub show {
    print &greeting($tnmc::security::auth::USERID{'fullname'});

}

sub greeting {
    my ($fullname) = @_;

    my $hour;
    ($_, $_, $hour) = localtime(time());

    ### this isn't even remotely tidy; but, hey, it's just for fun!
    my @greetings = ("Hello", "Howdy", "G'day", "Hi", "Aloha", "Howdy pardner", "Bonjour", "What are you doing, ",);

    ### Before 6 am.
    if ($hour < 5) {
        push(@greetings, "Top o' the morning to you", "Good morning");
    }
    ### Exactly 6 am.
    elsif ($hour == 6) {
        @greetings = ("Good morning, how's the sunrise today?");
    }
    ### from 7 am till noon
    elsif ($hour < 12) {
        push(@greetings, "Good Morning", "Good Morning", "Good Morning");
    }
    ### From noon 'till 6 pm
    elsif ($hour < 18) {
        push(@greetings, "Good Afternoon", "Good Afternoon", "Good Afternoon");
    }
    ### After 6 pm.
    else {
        push(@greetings, "Good Evening", "Good Evening", "Good Evening");
    }

    my $greeting = @greetings[ int(rand($#greetings + 1)) ];
    my $out      = $greeting;
    $out .= ' ' . $fullname if $fullname;

    #    my $font_size = &tnmc::template::get_font_size();
    return qq{
	<b>$out</b>
    };

    #        <font style="font-size: $font_size;"><b>$out.</b><P>
}

1;
