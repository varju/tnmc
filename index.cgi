#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@interchange.ubc.ca
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';


use tnmc::db;
use tnmc::template;
use tnmc::security::auth;
use tnmc::news::template;
use tnmc::templates::movies;
use tnmc::templates::user;

# set up the random number generator
srand;

#############
### Main logic

&db_connect();
&header();

print &greeting($USERID{'fullname'});

news_print_quick();
show_movies();

&footer();

show_user_homepage();

&db_disconnect();



##########################################################
#### Sub Procedures
##########################################################

sub greeting
{
    my ($fullname) = @_;

    my $hour;
    ($_,$_,$hour) = localtime(time());

    ### this isn't even remotely tidy; but, hey, it's just for fun!
    my @greetings = (
                     "Hello",
                     "Howdy",
                     "G'day",
                     "G'day mate",
                     "Aloha",
                     "Howdy pardner"
                     );

    ### Before 6 am.
    if ($hour < 5) {
        push(@greetings,
             "Top o' the morning to you",
             "Good morning");
    }
    ### Exactly 6 am.
    elsif ($hour == 6) {
        @greetings = ("Good morning, how's the sunrise today?");
    }
    ### from 7 am till noon
    elsif ($hour < 12) {
        push(@greetings,
             "Good Morning", 
             "Good Morning",
             "Good Morning");
    }
    ### From noon 'till 6 pm
    elsif ($hour < 18) {
        push(@greetings,
             "Good Afternoon",
             "Good Afternoon",
             "Good Afternoon");
    }
    ### After 6 pm.
    else {
        push(@greetings, 
             "Good Evening",
             "Good Evening",
             "Good Evening");
    }
    
    my $greeting = @greetings[int(rand ($#greetings + 1) ) ]; 
    my $out = $greeting;
    $out .= ' ' . $fullname if $fullname;

    my $font_size = get_font_size();
    return qq{
        <font style="font-size: $font_size;"><b>$out.</b><P>
    };
}

##########################################################
#### The end.
##########################################################
