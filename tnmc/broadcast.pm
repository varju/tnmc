package tnmc::broadcast;

use strict;

use AutoLoader 'AUTOLOAD';

#
# module configuration
#

1;

__END__

#
# autoload module routines
#

##################################################################
#       Scott Thompson - fido, tapzing, generic stuff
#       Jeff Steinbok  - telus, vstream
#       Alex Varju     - rogers
##################################################################

sub smsBroadcast{
    my ($userListRef, $msg, $maxPackets, $junk) = @_;
    
    my ($user);
    foreach $user (@$userListRef){
        smsShout($user, $msg, $maxPackets, $junk);
    }
}

sub smsShout{
    use tnmc::config;
    use tnmc::security::auth;
    use tnmc::user;
    
    use tnmc::broadcast::fido;
    use tnmc::broadcast::telus;
    use tnmc::broadcast::rogers;
    use tnmc::broadcast::vstream;
    use tnmc::broadcast::tapzing;
    
    my ($userID, $msg, $maxPackets, $junk) = @_;
    my (%user, $sender);
    
    ### Do we have a user?
    if (!$userID){ return 0;}
    
    ### Do we have a message?
    if ($msg eq ''){ return 0;}
    
    ### Get the user info from the db
    &tnmc::user::get_user($userID, \%user);
    
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
    if (($user{phoneTextMail} eq 'Fido' || $user{phoneTextMail} eq 'all')
        && $user{phoneFido})
    {
        &tnmc::broadcast::fido::sms_send_fido($user{phoneFido}, $msg);
    }

    ### Telus
    if (($user{phoneTextMail} eq 'Telus' || $user{phoneTextMail} eq 'all')
        && $user{phoneTelus})
    {
        &tnmc::broadcast::tapzing::sms_send_tapzing($user{phoneTelus}, $msg);
    }

    ### Rogers
    if (($user{phoneTextMail} eq 'Rogers' || $user{phoneTextMail} eq 'all')
        && $user{phoneRogers})
    {
        &tnmc::broadcast::rogers::sms_send_rogers($user{phoneRogers}, $msg);
    }

    ### Vstream
    if (($user{phoneTextMail} eq 'Vstream' || $user{phoneTextMail} eq 'all')
        && $user{phoneVstream})
    {
        &tnmc::broadcast::vstream::sms_send_vstream($user{phoneVstream}, $msg);
    }
}

sub sms_admin_notify {
    my ($msg) = @_;

    if (!$tnmc_debug_mode) {
        smsShout(1, $msg);
    }
}

1;
