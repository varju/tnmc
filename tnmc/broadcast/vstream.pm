package tnmc::broadcast::vstream;

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

@EXPORT = qw(sms_send_vstream);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub sms_send_vstream{
    my ($phone, $msg, $junk) = @_;
    my $areacode;
    my $start;
    
    ### get the areacode, if they have one.
    $phone =~ s/\D//g;

    ### see if we actually want to send anything.
    if (length($msg) <= $start){
        return 0;       # nope.
    }
    
    ### Set from to something
    my $From = "TNMC";
    
    ### Build the argument string.
    my $SEND = substr($msg, 0, 160);
    $SEND =~ s/(\W)/'%' . sprintf "%2.2X",  unpack('c',"$1")/eg;
    my $URL = 'http://www.voicestream.com/messagecenter/rtsValidate.asp';
    
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);
    
    ### Make the Request
    my $req = POST $URL,
    [ 'txtNum0' => $areacode.$phone,
      'From' => $From,
      'Message' => $SEND,
      'totSubscriber' => '1',
      ];
    $req->content_type('application/x-www-form-urlencoded');

    return $ua->request($req);
}

1;
