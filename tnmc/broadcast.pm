package tnmc::broadcast;

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

@EXPORT = qw(smsBroadcast
             smsShout
             sms_send_fido
             sms_send_fido_tap_zing
             sms_send_telus
             sms_send_tapzing
             sms_send_rogers
             sms_send_vstream
             );

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

##################################################################
#       Scott Thompson - fido, tapzing, generic stuff
#       Jeff Steinbok  - telus, vstream
#       Alex Varju     - rogers
##################################################################

# &sms_send_fido   ('7281655', "this is a test");
# &sms_send_rogers ('8891066', "alex, call me if you get this. - scott");
# &sms_send_telus  ('2908598', "karen, call me if you get this. - scott (728-1655)");
# &smsShout(1, "sms Shout test number 1");

################################
sub smsBroadcast{

        my ($userListRef, $msg, $maxPackets, $junk) = @_;

    my ($user);
    foreach $user (@$userListRef){
        smsShout($user, $msg, $maxPackets, $junk);
    }
    
}

################################
sub smsShout{
    
        my ($userID, $msg, $maxPackets, $junk) = @_;
    my (%user, $sender);
    
    ### Do we have a user?
    if (!$userID){ return 0;}
    
    ### Do we have a message?
    if ($msg eq ''){ return 0;}
    
    ### Get the user info from the db
    &get_user($userID, \%user);

    ### Get the sender info
    if ($USERID){
        $sender = uc($USERID{username});
    }else{
        $sender = 'TNMC';
    }
    $msg = "$sender: $msg";
    
    #
    # Now we run through each provider.
    #
    
    ### Fido
    if (  ( ($user{phoneTextMail} eq 'Fido') || ($user{phoneTextMail} eq 'all') )
       && ($user{phoneFido}) ){

        &sms_send_fido($user{phoneFido}, $msg);
    }

    ### Telus
    if (  ( ($user{phoneTextMail} eq 'Telus') || ($user{phoneTextMail} eq 'all') )
       && ($user{phoneTelus}) ){
        
        &sms_send_tapzing($user{phoneTelus}, $msg);
    }

    ### Rogers
    if (  ( ($user{phoneTextMail} eq 'Rogers') || ($user{phoneTextMail} eq 'all') )
       && ($user{phoneRogers}) ){
        
        &sms_send_rogers($user{phoneRogers}, $msg);
    }

    ### Vstream
    if (  ( ($user{phoneTextMail} eq 'Vstream') || ($user{phoneTextMail} eq 'all') )
       && ($user{phoneVstream}) ){
        
        &sms_send_vstream($user{phoneVstream}, $msg);
    }
}

################################
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
    # $SEND =~ s/(\W)/'%' . sprintf "%2.2X",  unpack('c',"$1")/eg; 
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

################################
sub sms_send_telus{

        my ($phone, $msg, $junk) = @_;

        ### see if we actually want to send anything.
        if (length($msg) == 0){
                return 0;       # nope.
        }

        ### Build the argument string.
        my $SEND = substr($msg, 0, 150);
        my $args = 'tr=Send&page_name=Phnximg&Name=&PIN=604'.$phone.'&From=TNMC&ReplyTo=&Subject=&Message=' . $SEND . '&total=' . length($SEND);

        ### Get a User agent
        my $ua = new LWP::UserAgent;
        $ua->agent("AgentName/01 " . $ua->agent);

        ### Make the Request
        my $req = new HTTP::Request GET => 'http://img.bctm.com/cgi-bin/img.dll';
        $req->content_type('application/x-www-form-urlencoded');
        $req->content($args);

    print  $ua->request($req)->as_string;
        return $ua->request($req);
}

################################
sub sms_send_tapzing{

        my ($phone, $msg, $junk) = @_;

        ### see if we actually want to send anything.
        if (length($msg) == 0){
                return 0;       # nope.
        }

        ### Build the argument string.
    $msg =~ s/\s/ /;     # Can't put cr's in the subject line
    my $to_email = '604' . $phone . '@tapzing.com';

        open(SENDMAIL, "| /usr/sbin/sendmail $to_email");
        print SENDMAIL "From: TNMC <scottt\@interchange.ubc.ca>\n";
        print SENDMAIL "To: $to_email\n";
        print SENDMAIL "Subject: $msg\n";
        print SENDMAIL "\n";
        
        print SENDMAIL "$msg";

        close SENDMAIL;

        return 1;
}

################################
sub sms_send_rogers{

        my ($phone, $msg, $junk) = @_;

        ### see if we actually want to send anything.
        if (length($msg) == 0){
                return 0;       # nope.
        }

        ### Build the argument string.
    my $URL = "http://sabre.cantelatt.com/cgi-bin/sendpcs.cgi";
    my $sender = "TNMC Site";
    my $areacode = "604";

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
          'PAGETEXT1' => $SEND,
          'emapnew--DESC--which' => "ORIG"
        ];
    return $ua->request($req);
}

################################
sub sms_send_vstream{

        my ($phone, $msg, $junk) = @_;
        my $areacode;
        my $start;

    ### get the areacode, if they have one.
    $phone =~ s/\D//g;
    #    $phone =~ s/(...)//;
    #    my $areacode = $1;

        ### see if we actually want to send anything.
        if (length($msg) <= $start){
                return 0;       # nope.
        }

    ### Set from to something
    my $From = "TNMC";

        ### Build the argument string.
        my $SEND = substr($msg, 0, 160);
    $SEND =~ s/(\W)/'%' . sprintf "%2.2X",  unpack('c',"$1")/eg;
        my $args = 'txtNum0='.$areacode.$phone.'&From='.$From.'&Message=' . $SEND . '&totSubscriber=1';


        ### Get a User agent
        my $ua = new LWP::UserAgent;
        $ua->agent("AgentName/01 " . $ua->agent);

        ### Make the Request
        my $req = new HTTP::Request POST => 'http://www.voicestream.com/messagecenter/rtsValidate.asp';
        $req->content_type('application/x-www-form-urlencoded');
        $req->content($args);

        return $ua->request($req);

}

1;
