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
    
    my ($areacode);
    
    ### see if we actually want to send anything.
    if (length($msg) == 0){
        return 0;       # nope.
    }
    
    ### get the areacode, if they have one.
    $phone =~ s/\D//g;
    if (length($phone) == 9){
        $phone =! s/(...)//;
        $areacode = $1;
    }else{
        $areacode = '604';
    }
    
    ### Build the argument string.
    my $SEND = substr($msg, 0, 160);
    my $args = 'areacode=' . $areacode . '&address='.$phone.'&message=' . $SEND . '&total=' . length($SEND);
    
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);
    
    ### Make the Request
    my $req = new HTTP::Request POST => 'http://fido.globewebs.com/cgi-fido/sms.cgi';
    $req->content_type('application/x-www-form-urlencoded');
    $req->content($args);
    return $ua->request($req);
}

################################
sub sms_send_fido_tap_zing{
    
    my ($phone, $msg, $junk) = @_;
    
    ### see if we actually want to send anything.
    if (length($msg) == 0){
        return 0;       # nope.
    }
    
    ### Build the request
    my $SEND = substr($msg, 0, 160);
    my $URL = "http://www.tapzing.com/WebMsg_Save.cfm";
    my $areacode = '604';
    my $args = "service=FIDO&PhoneID=$areacode$phone&message=$SEND";
    
    ### Get a User agent
    my $ua = new LWP::UserAgent;
    $ua->agent("AgentName/01 " . $ua->agent);
    
    ### Make the Request
    my $req = new HTTP::Request POST => $URL;
    $req->content_type('application/x-www-form-urlencoded');
    $req->content($args);
    return $ua->request($req);
}

1;
