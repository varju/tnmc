package tnmc::util::date;

use strict;
use warnings;

#use Time::Local;

sub format {
    return &format_date(@_);
}

sub format_date {
    my ($format, $date) = @_;
    return 'never' if !$date;

    # get the date
    $date =~ /^(\d{4})\D?(\d{1,2})\D?(\d{1,2})\D?(\d{1,2})\D?(\d{1,2})\D?(\d{1,2})$/;
    my ($yyyy, $mm, $dd, $h, $m, $s, @date);
    $yyyy = $1;
    $mm   = $2;
    $dd   = $3;
    $h    = $4;
    $m    = $5;
    $s    = $6;
    @date = ($1, $2, $3, $4, $5, $6);

    # do the formatting
    if ($format eq 'numeric') {
        return sprintf("%4.4d/%2.2d/%2.2d %2.2d:%2.2d:%2.2d", @date);
    }
    elsif ($format eq 'mysql') {
        return sprintf("%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d", @date);
    }
    elsif ($format eq 'day_time') {
        my $mon = ('', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mm];
        return sprintf("%s %s, %s:%2.2d", $mon, $dd, $h, $m);
    }
    elsif ($format eq 'full_time') {
        return sprintf("%2.2d:%2.2d:%2.2d", $h, $m, $s);
    }
    elsif ($format eq 'time') {
        return sprintf("%2.2d:%2.2d", $h, $m);
    }
    elsif ($format eq 'short_date') {
        my $mon = ('', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mm];
        return "$mon $dd, $yyyy";
    }
    elsif ($format eq 'short_month_day') {
        my $mon = ('', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mm];
        return "$mon $dd";
    }
    elsif ($format eq 'short_wday') {
        require tnmc::db;
        my $dbh = &tnmc::db::db_connect();

        my $sql = "SELECT DATE_FORMAT(?, '%a %b %e')";
        my $sth = $dbh->prepare($sql);
        $sth->execute($date);
        my ($ret) = $sth->fetchrow_array();
        $sth->finish();
        return $ret;
    }
    elsif ($format eq 'full_date') {
        require tnmc::db;
        my $dbh = &tnmc::db::db_connect();

        my $sql = "SELECT DATE_FORMAT(?, '%W %M %D, %Y')";
        my $sth = $dbh->prepare($sql);
        $sth->execute($date);
        my ($ret) = $sth->fetchrow_array();
        $sth->finish();
        return $ret;
    }
    return $date;
}

sub now {

    my ($sec, $min, $hour, $day, $month, $year) = (localtime(time()))[ 0, 1, 2, 3, 4, 5 ];

    $month = $month + 1;
    $year  = $year + 1900;

    return sprintf("%4.4d\-%2.2d\-%2.2d %2.2d\:%2.2d\:%2.2d", $year, $month, $day, $hour, $min, $sec);

}

return 1;

#### Other Subs from LANGSERVER

sub old_format_date {
    my ($timestamp) = @_;

    return 'Not Available' if (!defined $timestamp);

    my ($year, $month, $day, $hour, $min, $sec) = &convert_date($timestamp);

    my $mon = (
        '',       'January',   'February', 'March',    'April', 'May', 'June', 'July',
        'August', 'September', 'October',  'November', 'December'
    )[$month];

    return sprintf("%s %d, %d %02d:%02d:%02d", $mon, $day, $year, $hour, $min, $sec);
}

sub format_date_fname {
    my ($timestamp) = @_;

    $timestamp = time() if (!defined $timestamp);
    my ($year, $month, $day, $hour, $min, $sec) = &convert_date($timestamp);

    my $mon = ('', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$month];

    return "$mon$day";
}

# This converts either a Unix timestamp (number of seconds after 1970)
# or a mySQL timestamp (YYYYMMDDHHMMSS) to a date array in the order
# year, month, day, hour, minute, second
sub convert_date {
    my ($timestamp) = @_;

    return if (!defined $timestamp);

    my ($year, $month, $day, $hour, $min, $sec) = unpack("a4a2a2a2a2a2", $timestamp);

    if ($sec eq '' ||
        $min eq ''   ||
        $hour eq ''  ||
        $day eq ''   ||
        $month eq '' ||
        $year eq '')
    {
        ($sec, $min, $hour, $day, $month, $year) = (localtime($timestamp))[ 0, 1, 2, 3, 4, 5 ];

        $month = $month + 1;
        $year  = $year + 1900;
    }

    return ($year, $month, $day, $hour, $min, $sec);
}

sub convert_to_epoch {
    my ($timestamp) = @_;

    return 0 if (!defined $timestamp);

    my ($year, $month, $day, $hour, $min, $sec) = unpack("a4a2a2a2a2a2", $timestamp);

    return timelocal($sec, $min, $hour, $day, $month - 1, $year - 1900);
}

sub get_next_tuesday {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

    my $diff = (7 - ($wday - 2)) % 7;

    ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time + $diff * 86400);

    my $dateStr = sprintf("%d/%d/%d", $mon + 1, $mday, $year + 1900);

    return $dateStr;
}

1;
