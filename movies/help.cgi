#!/usr/bin/perl
        
##################################################################
#       Scott Thompson - scottt@css.sfu.ca (nov/99)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::template;

#############
### Main logic

&header();

&show_heading("Here's how the database bits map to the movie status:");
    
print qq{
    <pre><p>
            seen    showing    new    
    coming soon    0    0    1    
    just released    0    1    1
    showing        0    1    0
    not showing    0    0    0
    seen        1    -    -    
    </pre>
};

&footer();

