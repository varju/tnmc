package tnmc::broadcast::fido;

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

sub sms_send_fido {
    my ($phone, $msg, $junk) = @_;

    ### see if we actually want to send anything.
    if (length($msg) == 0) {
        return 0;    # nope.
    }

    ### get the areacode, if they have one.
    my $areacode = &tnmc::broadcast::util::phone_get_areacode($phone);
    $phone = &tnmc::broadcast::util::phone_get_localnum($phone);

    ### Build the argument string.
    my $SEND = substr($msg, 0, 160);
    my $URL  = 'http://nokia.zimismobile.com/scripts/zimcgic.exe';
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);

    ### Make the Request
    my $req = POST $URL,
      [
        'connection'  => 'smooch',
        'program'     => 'psendcagenmess',
        'template'    => '(AreaCode, PhoneNumber,message,emoticon)',
        'AreaCode'    => $areacode,
        'PhoneNumber' => $phone,
        'message'     => $SEND,
        'emoticon'    => "[TNMC]",
      ];
    $req->content_type('application/x-www-form-urlencoded');
    my $res = $ua->request($req);

    #    print STDERR "====\n\n";
    #    print STDERR $res->as_string();
    return $res;
    return $ua->request($req);
}

sub sms_send_fido_microcell {
    my ($phone, $msg, $junk) = @_;

    ### see if we actually want to send anything.
    if (length($msg) == 0) {
        return 0;    # nope.
    }

    ### get the areacode, if they have one.
    my $areacode = &tnmc::broadcast::util::phone_get_areacode($phone);
    $phone = &tnmc::broadcast::util::phone_get_localnum($phone);

    ### Build the argument string.
    my $SEND = substr($msg, 0, 160);
    my $URL  = 'http://www.fido.ca/NASApp/info/HomeFrame/sendmessage.jsp';
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);

    ### Make the Request
    my $req = POST $URL,
      [
        'phone' => $areacode . $phone,
        'name'  => "tnmc",
        'text'  => $SEND,
      ];
    $req->content_type('application/x-www-form-urlencoded');
    my $res = $ua->request($req);

    #    print STDERR "====\n\n";
    #    print STDERR $res->as_string();
    return $res;
    return $ua->request($req);
}

################################
sub sms_send_fido_tap_zing {
    my ($phone, $msg) = @_;

    ### see if we actually want to send anything.
    if (length($msg) == 0) {
        return 0;    # nope.
    }

    ### get the areacode, if they have one.
    my $areacode = &tnmc::broadcast::util::phone_get_areacode($phone);
    $phone = &tnmc::broadcast::util::phone_get_localnum($phone);

    ### Build the request
    my $SEND = substr($msg, 0, 160);
    my $URL  = "http://www.tapzing.com/WebMsg_Save.cfm";

    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);

    ### Make the Request
    my $req = POST $URL,
      [
        'service' => 'FIDO',
        'PhoneID' => $areacode . $phone,
        'message' => $SEND,
      ];
    $req->content_type('application/x-www-form-urlencoded');

    return $ua->request($req);
}

1;
