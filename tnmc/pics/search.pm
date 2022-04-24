package tnmc::pics::search;

use strict;

use tnmc::db;

#
# module configuration
#

#
# module vars
#

#
# module routines
#

sub search_get_piclist_from_nav {
    my ($nav) = @_;

    my $pics = [];
    my %results;

    my $mode = $nav->{'search'};

    if ($mode eq 'date-span') {
        $pics = &search_do_date_span($nav, \%results);
    }
    elsif ($mode eq 'my_unreleased') {
        $pics = &search_do_my_unreleased($nav, \%results);
    }
    elsif ($mode eq 'untitled') {
        $pics = &search_do_untitled($nav, \%results);
    }
    elsif ($mode eq 'text') {
        $pics = &search_do_text($nav, \%results);
    }
    elsif ($mode eq 'user') {
        $pics = &search_do_user($nav, \%results);
    }
    elsif ($mode eq 'test') {
        $pics = &search_do_test($nav . \%results);
    }
    else {
        # don't know this mode.
    }

    return $pics;
}

sub search_do_text {
    my ($nav, $results) = @_;
    my @pics;

    my $dbh = &tnmc::db::db_connect();

    my $sql_accessible = &search_get_accessible_condition();

    ## assemble text sql
    my $text      = $nav->{'search_text'};
    my $text_join = $nav->{'search_text_join'} || 'OR';
    my $sql_text;
    my @sql_text;
    my @sql_word;
    my @words = split(/\s/, $text);
    foreach my $word (@words) {
        next if !$word;
        my $sql_word = "
                      (  (title LIKE ?)
                      OR (description LIKE ?) )
                      ";
        push(@sql_word, $sql_word);

        push(@sql_text, "\%$word\%");
        push(@sql_text, "\%$word\%");
    }
    $sql_text = join($text_join, @sql_word);
    $sql_text = "AND ( $sql_text )";

    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT picID FROM Pics
             WHERE $sql_accessible
                   $sql_text
             ORDER BY timestamp, picID";
    my $sth = $dbh->prepare($sql);
    $sth->execute(@sql_text);

    while (my @row = $sth->fetchrow_array()) {
        push @pics, $row[0];
    }

    return \@pics;
}

sub search_do_date_span {
    my ($nav, $results) = @_;
    my @pics;
    my $dbh = &tnmc::db::db_connect();

    my $sql_accessible = &search_get_accessible_condition();
    my $from           = $nav->{'search_from'};
    my $to             = $nav->{'search_to'};

    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT picID FROM Pics
             WHERE $sql_accessible
               AND (timestamp >= ?)
               AND (timestamp <= ?)
             ORDER BY timestamp, picID";
    my $sth = $dbh->prepare($sql);
    $sth->execute($from, $to);

    while (my @row = $sth->fetchrow_array()) {
        push @pics, $row[0];
    }

    return \@pics;
}

sub search_do_my_unreleased {
    my ($nav, $results) = @_;
    my @pics;
    my $dbh = &tnmc::db::db_connect();

    my $sql_accessible = &search_get_accessible_condition();
    my $USERID         = $tnmc::security::auth::USERID;

    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT picID FROM Pics
             WHERE $sql_accessible
               AND (ownerID = ?)
               AND ( (typePublic != 1)  )
               AND ( (typePublic != 2)  )
             ORDER BY timestamp, picID";
    my $sth = $dbh->prepare($sql);
    $sth->execute($USERID);

    while (my @row = $sth->fetchrow_array()) {
        push @pics, $row[0];
    }

    return \@pics;
}

sub search_do_untitled {
    my ($nav, $results) = @_;
    my @pics;
    my $dbh = &tnmc::db::db_connect();

    my $sql_accessible = &search_get_accessible_condition();
    my $USERID         = $tnmc::security::auth::USERID;

    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT picID FROM Pics
             WHERE $sql_accessible
               AND ((title = '')  OR ( title IS NULL))
             ORDER BY timestamp, picID";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    while (my @row = $sth->fetchrow_array()) {
        push @pics, $row[0];
    }

    return \@pics;
}

sub search_do_test {
    my ($nav) = @_;
    my @pics;

    @pics = (1234, 2345, 3455);

    return \@pics;
}

sub search_do_user {
    my ($nav, $results) = @_;
    my @pics;
    my $dbh = &tnmc::db::db_connect();

    my $sql_accessible = &search_get_accessible_condition();
    my $USERID         = $tnmc::security::auth::USERID;

    # grab the dates where we have something that we're allowed to look at.
    my $sql = "SELECT picID FROM Pics
             WHERE $sql_accessible
               AND (ownerID = ?)
             ORDER BY timestamp, picID";
    my $sth = $dbh->prepare($sql);
    $sth->execute($nav->{'userID'});

    while (my @row = $sth->fetchrow_array()) {
        push @pics, $row[0];
    }

    return \@pics;
}

sub search_get_accessible_condition {
    my $USERID = $tnmc::security::auth::USERID;
    return "((ownerID = '$USERID') OR typePublic >= 1)";
}

return 1;

