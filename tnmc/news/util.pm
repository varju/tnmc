package tnmc::news::util;

use strict;

use tnmc::db;
use tnmc::general_config;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(get_quick_news get_news set_news_item get_news_item del_news_item);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub get_quick_news {
    my $news_ref = get_news();

    my $default_num = 2;
    my $count = @$news_ref;
    
    if ($count < $default_num) {
        $default_num = $count;
    }

    my @items;
    for (my $i = 0; $i < $default_num; $i++) {
        push(@items,shift(@$news_ref));
    }

    return \@items;
}

sub get_news {
    my @news;

    my $sql = "SELECT n.newsID, p.username, n.value, DATE_FORMAT(n.date, '%b %d, %Y')
                 FROM News as n LEFT JOIN Personal as p USING (userID)
             ORDER BY n.date DESC";

    my $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute();
    while (my @row = $sth->fetchrow_array()) {
        my %news_row;

        $news_row{newsId} = shift @row;
        $news_row{userId} = shift @row;
        $news_row{value} = shift @row;
        $news_row{date} = shift @row;

        push(@news,\%news_row);
    }
    $sth->finish();

    return \@news;
}

sub set_news_item {
    my ($news_ref) = @_;
    my ($sql, $sth);

    my $newsId = $$news_ref{newsId};
    my $userId = $$news_ref{userId};
    my $value = $$news_ref{value};
    my $date = $$news_ref{date};

    if ($newsId) {
        $sql = "DELETE FROM News WHERE newsID=?";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute($newsId);
        $sth->finish();
    }

    if (!$date) {
        # this ensures that mysql gets null for the timestamp
        # and turns it into the current date
        undef $date;
    }

    $sql = "INSERT INTO News (newsID, userID, value, date) VALUES (?, ?, ?, ?)";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($newsId, $userId, $value, $date);
    $sth->finish();
}

sub get_news_item {
    my ($newsId) = @_;

    my $sql = "SELECT n.newsID, n.userID, n.value, n.date
                 FROM News as n
                WHERE n.newsID=?";

    my $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute($newsId);
    my @row = $sth->fetchrow_array();
    $sth->finish();

    my %news_row;
    $news_row{newsId} = shift @row;
    $news_row{userId} = shift @row;
    $news_row{value} = shift @row;
    $news_row{date} = shift @row;

    return \%news_row;
}

sub del_news_item {
    my ($newsId) = @_;

    my $sql = "DELETE FROM News WHERE newsID='$newsId'";
    my $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute();
    $sth->finish();
}

1;
