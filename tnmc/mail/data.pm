package tnmc::mail::data;

use strict;

use tnmc::config;
use tnmc::db;
use tnmc::user;

use tnmc::mail::prefs::data;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(message_store get_message_list get_message delete_message mail_get_email_address);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub message_store {
    my ($message_ref) = @_;
    my ($sql, $sth);

    my $Id = $$message_ref{'Id'};

    if ($Id) {
        $sql = "DELETE FROM Mail WHERE Id=?";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute($Id);
        $sth->finish();
    }

    $sql = "INSERT INTO Mail (Id, UserId, AddrTo, AddrFrom, Date, ReplyTo, 
                              Subject, Body, Header, Sent)
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($$message_ref{'Id'},
                  $$message_ref{'UserId'},
                  $$message_ref{'AddrTo'},
                  $$message_ref{'AddrFrom'},
                  $$message_ref{'Date'},
                  $$message_ref{'ReplyTo'},
                  $$message_ref{'Subject'},
                  $$message_ref{'Body'},
                  $$message_ref{'Header'},
                  $$message_ref{'Sent'},
                  );

    $sth->finish();
}

sub get_message_list {
    my ($UserId) = @_;
    my ($sql, $sth);
    my @messages;

    $sql = "SELECT Id, DATE_FORMAT(Date, '%Y-%m-%d %r'), AddrTo, AddrFrom, 
                   ReplyTo, Subject, Body, Header, Sent
              FROM Mail WHERE UserId=?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($UserId);

    while (my @row = $sth->fetchrow_array()) {
        my %message;

        $message{Id} = shift @row;
        $message{Date} = shift @row;
        $message{AddrTo} = shift @row;
        $message{AddrFrom} = shift @row;
        $message{ReplyTo} = shift @row;
        $message{Subject} = shift @row;
        $message{Body} = shift @row;
        $message{Header} = shift @row;
        $message{Sent} = shift @row;

        push(@messages,\%message);
    }
    $sth->finish();

    return \@messages;
}

sub get_message {
    my ($UserId, $Id) = @_;
    # note: we use the UserId for security purposes
    
    my ($sql, $sth);
    my %message;

    $sql = "SELECT Id, DATE_FORMAT(Date, '%Y-%m-%d %r'), AddrTo, AddrFrom, 
                   ReplyTo, Subject, Body, Header, Sent
              FROM Mail WHERE UserId=? AND Id=?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($UserId,$Id);

    my @row = $sth->fetchrow_array();
    if (defined @row) {
        $message{Id} = shift @row;
        $message{Date} = shift @row;
        $message{AddrTo} = shift @row;
        $message{AddrFrom} = shift @row;
        $message{ReplyTo} = shift @row;
        $message{Subject} = shift @row;
        $message{Body} = shift @row;
        $message{Header} = shift @row;
        $message{Sent} = shift @row;
    }
    $sth->finish();

    return \%message;
}

sub delete_message {
    my ($UserId, $Id) = @_;
    my ($sql, $sth);

    $sql = "DELETE FROM Mail WHERE Id=? AND UserId=?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($Id,$UserId);
    $sth->finish();
}

sub mail_get_email_address {
    my ($UserId) = @_;
    my (%user,$addr);

    get_user($UserId,\%user);
    my $fullname = $user{fullname};

    my $FromAddr = mail_get_pref($UserId,'FromAddr');
    if ($FromAddr eq 'Prefs') {
        $addr = $user{email};
    }
    else {
        $addr = $user{username} . '@' . $tnmc_maildomain;
    }

    my $email = $fullname . " <" . $addr . ">";
    return $email;
}

1;
