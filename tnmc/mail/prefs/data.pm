package tnmc::mail::prefs::data;

use strict;

use tnmc::db;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(mail_set_pref mail_get_pref mail_get_all_prefs mail_set_all_prefs);
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

    return $Value || '';
}

sub mail_get_all_prefs {
    my ($UserId) = @_;
    my ($sql, $sth);
    my %prefs;

    $sql = "SELECT Pref, Value
              FROM MailPrefs
             WHERE UserId=?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($UserId);

    while (my @row = $sth->fetchrow_array()) {
        my $Pref = shift @row;
        my $Value = shift @row;

        $prefs{$Pref} = $Value;
    }
    $sth->finish();

    return \%prefs;
}

sub mail_set_all_prefs {
    my ($UserId, $prefs_ref) = @_;
    my ($sql,$sth);

    $sql = "DELETE FROM MailPrefs WHERE UserId=?";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($UserId);
    $sth->finish();


    $sql = "INSERT INTO MailPrefs (UserId, Pref, Value)
                 VALUES (?, ?, ?)";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    
    foreach my $key (keys %$prefs_ref) {
        $sth->execute($UserId, $key, $$prefs_ref{$key});
    }

    $sth->finish();
}

1;
