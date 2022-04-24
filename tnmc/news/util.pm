package tnmc::news::util;

use strict;

use tnmc::db;
use tnmc::general_config;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub get_quick_news {
    my $news_ref = get_todays_news();

    my $default_num = 2;
    my $count       = @$news_ref;

    if ($count < $default_num) {
        $default_num = $count;
    }

    my @items;
    for (my $i = 0 ; $i < $default_num ; $i++) {
        push(@items, shift(@$news_ref));
    }

    return \@items;
}

sub get_todays_news {
    my @news;

    my $sql = "SELECT n.newsID, p.username, n.value, DATE_FORMAT(n.date, '%b %d, %Y'),
                      DATE_FORMAT(n.expires, '%b %d, %Y')
                 FROM News as n LEFT JOIN Personal as p USING (userID)
                WHERE (n.expires >= NOW() || n.expires=0)
                  AND (n.date <= NOW())
             ORDER BY n.date DESC";

    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute();
    while (my @row = $sth->fetchrow_array()) {
        my %news_row;

        $news_row{newsId}  = shift @row;
        $news_row{userId}  = shift @row;
        $news_row{value}   = shift @row;
        $news_row{date}    = shift @row;
        $news_row{expires} = shift @row;

        push(@news, \%news_row);
    }
    $sth->finish();

    return \@news;
}

sub get_news {
    my @news;

    my $sql = "SELECT n.newsID, p.username, n.value, DATE_FORMAT(n.date, '%b %d, %Y'),
                      DATE_FORMAT(n.expires, '%b %d, %Y')
                 FROM News as n LEFT JOIN Personal as p USING (userID)
             ORDER BY n.date DESC";

    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute();
    while (my @row = $sth->fetchrow_array()) {
        my %news_row;

        $news_row{newsId}  = shift @row;
        $news_row{userId}  = shift @row;
        $news_row{value}   = shift @row;
        $news_row{date}    = shift @row;
        $news_row{expires} = shift @row;

        push(@news, \%news_row);
    }
    $sth->finish();

    return \@news;
}

sub set_news_item {
    my ($news_ref) = @_;
    my ($sql, $sth);

    my $newsId  = $$news_ref{newsId};
    my $userId  = $$news_ref{userId};
    my $value   = $$news_ref{value};
    my $date    = $$news_ref{date};
    my $expires = $$news_ref{expires};

    my $dbh = &tnmc::db::db_connect();

    if ($newsId) {
        $sql = "DELETE FROM News WHERE newsID=?";
        $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
        $sth->execute($newsId);
        $sth->finish();
    }

    if (!$date) {

        # this ensures that mysql gets null for the timestamp
        # and turns it into the current date
        undef $date;
    }

    if (!$expires) {
        $expires = &news_default_expiry();
    }

    $sql = "INSERT INTO News (newsID, userID, value, date, expires) 
                 VALUES (?, ?, ?, ?, ?)";
    $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($newsId, $userId, $value, $date, $expires);
    $sth->finish();
}

sub get_news_item {
    my ($newsId) = @_;

    my $sql = "SELECT n.newsID, n.userID, n.value, n.date, n.expires
                 FROM News as n
                WHERE n.newsID=?";

    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($newsId);
    my @row = $sth->fetchrow_array();
    $sth->finish();

    my %news_row;
    $news_row{newsId}  = shift @row;
    $news_row{userId}  = shift @row;
    $news_row{value}   = shift @row;
    $news_row{date}    = shift @row;
    $news_row{expires} = shift @row;

    return \%news_row;
}

sub del_news_item {
    my ($newsId) = @_;

    my $sql = "DELETE FROM News WHERE newsID='$newsId'";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute();
    $sth->finish();
}

sub news_default_expiry {

    # figure out today's date
    my ($sec, $min, $hour, $day, $mon, $yr) = localtime();
    $mon++;
    $yr += 1900;

    # now figure out the expiry
    $day += 7;

    my $timestamp = sprintf("%04d%02d%02d%02d%02d%02d", $yr, $mon, $day, $hour, $min, $sec);

    return $timestamp;
}

1;
