package tnmc::broadcast::tapzing;

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

@EXPORT = qw(sms_send_tapzing);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

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

1;
