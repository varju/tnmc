package tnmc::message;

use strict;

#
# module configuration
#
use tnmc::db;
use tnmc::mail::send;

#
# module routines
#

#message_msg:
#msgID
#convID
#date
#from
#to
#subject
#body
#prev_msgID
#
#message_conv:
#convID
#subject
#msg_expire_time
#display_format



### msg: basic access
sub get_msg{
    my ($ID) = @_;

    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT * from MessageMsg WHERE msgID = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($ID);
    my $hash = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hash;
}

sub set_msg{
    my ($hash) = @_;

    # don't allow anonymous posting
    return unless $$hash{sender};

    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ', ', @key_list);
    my $ref_list = join ( ', ', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $dbh = &tnmc::db::db_connect();
    my $sql = "REPLACE INTO MessageMsg ($key_list) VALUES($ref_list)";
    my $sth = $dbh->do($sql, undef, @var_list);
    
}

#sub del_msg

### conv: basic access
#sub get_conv
sub get_conv{
    my ($ID) = @_;
    
    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT * from MessageConv WHERE convID = ?";
    my $sth = $dbh->do($sql, undef, $ID);
    my $hash = $sth->fetchrow_hashref();
    $sth->finish;
    
    return $hash;
}

sub set_conv{
    my ($hash) = @_;
    
    my @key_list = sort( keys(%$hash) );
    my $key_list = join ( ',', @key_list);
    my $ref_list = join ( ',', (map {sprintf '?'} @key_list) );
    my @var_list = map {$hash->{$_}} @key_list;
    
    # save to the db
    my $dbh = &tnmc::db::db_connect();
    my $sql = "REPLACE INTO MessageConv ($key_list) VALUES($ref_list)";
    my $sth = $dbh->do($sql, undef, @var_list);
    $sth->finish;
}

#sub del_conv

sub conv_get_msg_list{
    my ($convID) = @_;
    
    my @list;
    
    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT msgID from MessageMsg
                WHERE convID = ? 
                  AND (date_posted > date_sub(NOW(), INTERVAL 4320 MINUTE))
             ORDER BY date_posted";
    my $sth = $dbh->prepare($sql);
    $sth->execute($convID);
    while (my @row = $sth->fetchrow_array()){
        push (@list, $row[0]);
    }
    $sth->finish;
    
    return @list;
}

### msg: display-related

### conv: display-related
sub show_conv{
    my ($convID) = @_;
    
    require tnmc::template;
    require tnmc::security::auth;
    require tnmc::util::date;

    ## setup
    
    # get msg list
    my @msg_list = conv_get_msg_list($convID);
    
    ## display
    
    #show msgs
    print qq{<table width="100%" cellpadding=0 cellspacing=0 border=0>};
    print qq{<tr><th colspan=3>Messages</th></tr>};
    foreach my $msgID (@msg_list){
	my $msg = &get_msg($msgID);
	my $user = &tnmc::user::get_user_cache($msg->{sender});
	my $date = &tnmc::util::date::format_date("day_time", $msg->{date_posted});
	print qq{
	    <tr valign="top">
		<td nowrap>$user->{username}&nbsp;</td>
		<td>$msg->{'body'}</td>
		<td nowrap>$date</td>
	    </tr>
	    };
    }

    # show add msg
    if ($tnmc::security::auth::USERID) {
        print qq{
	<tr valign="top"><td>
<script>
var submitting = 0;
function doSubmit() {
    var ff = document.forms.msg_form;
    if (ff.body.value == '') {
        return;
    }
    if (submitting++) {
        return;
    }
    ff.submit();
}
</script>
	<form name="msg_form" action="message/msg_post.cgi" method="post" onsubmit="doSubmit(); return false;">
	    <input type="hidden" name="convID" value="$convID">
	    <b>$tnmc::security::auth::USERID{username}&nbsp;</b>
		</td><td nowrap>
	       <input type="text" size="40" name="body">
	    <input type="submit" value="post msg" onclick="doSubmit();">
	    </form>
		</td></tr>
		
	</table>
	};
    }
    
}

sub forward_external
{
    my ($hash) = @_;

    # don't allow anonymous posting
    return unless $$hash{sender};

    my @users;
    my @to_addrs;
    &tnmc::user::list_users(\@users, "WHERE groupDead != '1' && forwardWebMessages = 1");
    foreach my $userID (@users)
    {
	my $recip = &tnmc::user::get_user_cache($userID);
	push(@to_addrs, $recip->{'email'});
    }
    my $to_email = join(' ', @to_addrs);

    my $subject = 'TNMC: Forwarded web message';
    my $sender = &tnmc::user::get_user_cache($hash->{sender});
    my $sendername = $sender->{'username'};
    my $body = sprintf("%s says:\n\n%s\n", $sendername, $hash->{'body'});

    my @nights = &tnmc::movies::night::list_future_nights();
    my $threadid = 'tnmc-night-' . @nights[0];

    my %headers =
	( 'Bcc' => $to_email,
	  'From' => "$sendername <no-such-address\@tnmc.ca>",
	  'Subject' => $subject,
          'Reply-To' => $tnmc::config::tnmc_email,
	  'In-Reply-To' => $threadid,
	  'Precedence' => 'List',
	  );
    &tnmc::mail::send::message_send(\%headers, $body);
}

1;
