package tnmc::broadcast::fido;

use strict;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

use tnmc::cookie;
use tnmc::user;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(sms_send_fido sms_send_fido_tap_zing);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub sms_send_fido{
    my ($phone, $msg, $junk) = @_;
    
    ### see if we actually want to send anything.
    if (length($msg) == 0){
        return 0;       # nope.
    }
    
    ### get the areacode, if they have one.
    my $areacode = phone_get_areacode($phone);
    $phone = phone_get_localnum($phone);

    ### Build the argument string.
    my $SEND = substr($msg, 0, 160);
    my $URL = 'http://fido.globewebs.com/cgi-fido/sms.cgi';
    
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);
    
    ### Make the Request
    my $req = POST $URL,
    [ 'areacode' => $areacode,
      'address' => $phone,
      'message' => $SEND,
      'total' => length($SEND),
      ];
    $req->content_type('application/x-www-form-urlencoded');

    return $ua->request($req);
}

################################
sub sms_send_fido_tap_zing {
    my ($phone, $msg) = @_;
    
    ### see if we actually want to send anything.
    if (length($msg) == 0){
        return 0;       # nope.
    }
    
    ### get the areacode, if they have one.
    my $areacode = phone_get_areacode($phone);
    $phone = phone_get_localnum($phone);

    ### Build the request
    my $SEND = substr($msg, 0, 160);
    my $URL = "http://www.tapzing.com/WebMsg_Save.cfm";
    
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);
    
    ### Make the Request
    my $req = POST $URL,
    [ 'service' => 'FIDO',
      'PhoneID' => $areacode . $phone,
      'message' => $SEND,
      ];
    $req->content_type('application/x-www-form-urlencoded');

    return $ua->request($req);
}

1;
