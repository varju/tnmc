package tnmc::template::wml;

use strict;

use tnmc::config;
use tnmc::security::auth;
use tnmc::db;

#
# module configuration
#

#
# module vars
#

#
# module routines
#


######################################################################

sub show_card{
    my ($name, $title, $body) = @_;

    # be efficient, strip unneccessary whitespace
    $body =~ s/\s+/ /g;
    
    # remove scary chars (HACK)
    $body =~ s/\&/\&amp;/g;
    
    print qq{<card id="$name" title="$title">$body</card>\n};
}


sub wml_header{
    print "Content-type: text/vnd.wap.wml\n";
    print "Connection: Close\n";
    print "Pragma: no-cache\n";
    print "\n";

    print qq{<?xml version="1.0"?>\n};
    print qq{<!DOCTYPE wml PUBLIC "-//WAPFORUM//DTD WML 1.1//EN" "http://www.tnmc.ca/wml/">\n};
    print qq{<wml>\n};

    print qq{
        <template>
            <do type="unknown" label="TNMC Home">
                <go href="http://www.tnmc.ca/wap/"/>
            </do>
            <do type="prev">
                <prev/>
            </do>
        </template>
    };

    
}

sub wml_footer{
    print "</wml>\n";
    print "\n";
}



1;
