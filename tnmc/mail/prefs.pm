package tnmc::mail::prefs;

use strict;

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(mail_set_pref mail_get_pref);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub mail_set_pref {
    my ($UserId,$Pref) = @_;
    my ($sql, $sth);

    $sql = "DELETE FROM MailPrefs WHERE UserId=? AND Pref=?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($UserId,$Pref);
    $sth->finish();

    $sql = "INSERT INTO MailPrefs (UserId, Pref)
                 VALUES (?, ?)";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($UserId, $Pref);
    $sth->finish();
}

sub mail_get_pref {
    my ($UserId,$Pref) = @_;
    my ($sql, $sth);
    my $Value;

    $sql = "SELECT Value
              FROM MailPrefs
             WHERE UserId=? AND Pref=?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($UserId,$Pref);

    my @row = $sth->fetchrow_array();
    if (defined @row) {
        $Value = shift @row;
    }
    else {
        $Value = undef;
    }
    $sth->finish();

    return $Value;
}

1;
