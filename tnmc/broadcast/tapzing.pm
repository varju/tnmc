package tnmc::broadcast::tapzing;

use strict;

use tnmc::mail::send;
use tnmc::security::auth;
use tnmc::user;
use tnmc::broadcast::util;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub sms_send_tapzing {
    my ($phone, $msg, $junk) = @_;

    ### see if we actually want to send anything.
    if (length($msg) == 0) {
        return 0;    # nope.
    }

    ### get the areacode, if they have one.
    my $areacode = &tnmc::broadcast::util::phone_get_areacode($phone);
    $phone = &tnmc::broadcast::util::phone_get_localnum($phone);

    ### Build the argument string.
    $msg =~ s/\s/ /;    # Can't put cr's in the subject line
    my $to_email = $areacode . $phone . '@tapzing.com';

    my %headers = (
        'To'      => $to_email,
        'From'    => $tnmc::config::tnmc_webserver_email,
        'Subject' => $msg,
    );
    &tnmc::mail::send::message_send(\%headers, $msg);

    return 1;
}

1;
