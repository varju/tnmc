package tnmc::security::reset;

use strict;
use warnings;

use Digest::SHA qw(sha256_hex);

use tnmc::db;
use tnmc::util::random;

#
# one-time password reset links; only a hash of each token is stored
#

#
# module routines
#

sub create_token {

    # usage: my $token = &create_token($userID, $hours);
    my ($userID, $hours) = @_;

    my $token = &tnmc::util::random::hex_string(32);

    my $dbh = &tnmc::db::db_connect();
    my $sql = "INSERT INTO PasswordResets (tokenHash, userID, created, expires, used)
               VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? HOUR), 0)";
    $dbh->do($sql, undef, sha256_hex($token), $userID, $hours) or die "Can't save reset token: " . $dbh->errstr;

    return $token;
}

sub count_recent_tokens {

    # usage: my $count = &count_recent_tokens($userID, $minutes);
    my ($userID, $minutes) = @_;

    my $dbh = &tnmc::db::db_connect();
    my $sql = "SELECT COUNT(*) FROM PasswordResets WHERE userID = ? AND created > DATE_SUB(NOW(), INTERVAL ? MINUTE)";
    my ($count) = $dbh->selectrow_array($sql, undef, $userID, $minutes);

    return $count || 0;
}

sub check_token {

    # usage: my $userID = &check_token($token);  # 0 if unknown, used or expired
    my ($token) = @_;

    return 0 if !defined $token || $token !~ /^[0-9a-f]{64}$/;

    my $dbh      = &tnmc::db::db_connect();
    my $sql      = "SELECT userID FROM PasswordResets WHERE tokenHash = ? AND used = 0 AND expires > NOW()";
    my ($userID) = $dbh->selectrow_array($sql, undef, sha256_hex($token));

    return $userID || 0;
}

sub use_token {

    # usage: my $userID = &use_token($token);  # 0 if unknown, used or expired
    my ($token) = @_;

    my $userID = &check_token($token);
    return 0 if !$userID;

    # only one request can mark it used
    my $dbh  = &tnmc::db::db_connect();
    my $sql  = "UPDATE PasswordResets SET used = 1 WHERE tokenHash = ? AND used = 0 AND expires > NOW()";
    my $rows = $dbh->do($sql, undef, sha256_hex($token));

    return ($rows && $rows == 1) ? $userID : 0;
}

1;
