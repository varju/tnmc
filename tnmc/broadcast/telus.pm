package tnmc::broadcast::telus;

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

@EXPORT = qw(sms_send_telus);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub sms_send_telus {
    my ($phone, $msg, $junk) = @_;
    
    ### see if we actually want to send anything.
    if (length($msg) == 0){
        return 0;       # nope.
    }
    
    ### Build the argument string.
    my $SEND = substr($msg, 0, 150);
    my $URL  = 'http://img.bctm.com/cgi-bin/img.dll';
    
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);
    
    ### Make the Request
    my $req = POST $URL,
    [ 'tr' => 'Send',
      'page_name' => 'Phnximg',
      'Name' => '',
      'PIN' => '604'.$phone,
      'From' => 'TNMC',
      'ReplyTo' => '',
      'Subject' => '',
      'Message' => $SEND,
      'total' => length($SEND),
      ];
    $req->content_type('application/x-www-form-urlencoded');

    return $ua->request($req);
}

1;
