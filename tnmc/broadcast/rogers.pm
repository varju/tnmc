package tnmc::broadcast::rogers;

use strict;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

use tnmc::security::auth;
use tnmc::user;

use tnmc::broadcast::util;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(sms_send_rogers);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub sms_send_rogers {
    my ($phone, $msg) = @_;
    
    ### see if we actually want to send anything.
    if (length($msg) == 0){
        return 0;       # nope.
    }
    
    ### get the areacode, if they have one.
    my $areacode = phone_get_areacode($phone);
    $phone = phone_get_localnum($phone);

    ### Build the argument string.
    my $URL = "http://sabre.cantelatt.com/cgi-bin/sendpcs.cgi";
    my $sender = "TNMC Site";
    
    my $prefix;
    my $suffix;
    
    if ($phone =~ /(\d\d\d)-?(\d\d\d\d)/) {
        $prefix = $1;
        $suffix = $2;
    }
    
    if (!$prefix || !$suffix){ return 0;}
    
    my $SEND = substr($msg, 0, 160);
    
    ### Get a User agent
    my $agent = LWP::UserAgent->new;
    my $ua = new LWP::UserAgent;
    
    ### Make the Request
    my $req = POST $URL,
    [ 'AREA_CODE' => $areacode,
      'PIN1' => $prefix,
      'PIN2' => $suffix,
      'SENDER' => $sender,
      'emapnew--DESC--which' => "ORIG",
      'PAGETEXT1' => $SEND,
      'SIZEBOX' => length($SEND),
      'SIZEBOXW' => count_words($SEND),
      ];

    return $ua->request($req);
}

1;
