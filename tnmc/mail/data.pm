package tnmc::mail::data;

use strict;

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(message_store);
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

    $sql = "INSERT INTO Mail (Id, UserId, AddrTo, AddrFrom, Date, ReplyTo, Body, Header)
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($$message_ref{'Id'},
                  $$message_ref{'UserId'},
                  $$message_ref{'AddrTo'},
                  $$message_ref{'AddrFrom'},
                  $$message_ref{'Date'},
                  $$message_ref{'ReplyTo'},
                  $$message_ref{'Body'},
                  $$message_ref{'Header'});

    $sth->finish();
}

1;
