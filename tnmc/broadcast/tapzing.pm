package tnmc::broadcast::tapzing;

use strict;

use tnmc::security::auth;
use tnmc::user;
use tnmc::broadcast::util;

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

    ### get the areacode, if they have one.
    my $areacode = phone_get_areacode($phone);
    $phone = phone_get_localnum($phone);
   
    ### Build the argument string.
    $msg =~ s/\s/ /;     # Can't put cr's in the subject line
    my $to_email = $areacode . $phone . '@tapzing.com';
    
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
