package tnmc::broadcast::rogers;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

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

sub sms_send_rogers {
    my ($phone, $msg) = @_;

    ### see if we actually want to send anything.
    if (length($msg) == 0) {
        return 0;    # nope.
    }

    ### get the areacode, if they have one.
    my $areacode = &tnmc::broadcast::util::phone_get_areacode($phone);
    $phone = &tnmc::broadcast::util::phone_get_localnum($phone);

    ### Build the argument string.
    my $URL = "http://216.129.53.44:8080/cgi-bin/send_sm_rogers.new";

    my $prefix;
    my $suffix;

    if ($phone =~ /(\d\d\d)-?(\d\d\d\d)/) {
        $prefix = $1;
        $suffix = $2;
    }
    return 0 unless $prefix && $suffix;

    my $SEND = substr($msg, 0, 160);

    ### Get a User agent
    my $agent = LWP::UserAgent->new;
    my $ua    = new LWP::UserAgent;

    ### Make the Request
    my $req = POST $URL,
      [
        'area'    => $areacode,
        'num1'    => $prefix,
        'num2'    => $suffix,
        'text'    => $SEND,
        'oldtext' => $SEND,
        'SIZEBOX' => length($SEND),
        'msisdn'  => $areacode . $prefix . $suffix,
      ];

    return $ua->request($req);
}

1;
