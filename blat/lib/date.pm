package lib::date;

use strict;
use warnings;

use lib::db;

#use Time::Local;

sub list_current_saturdays {

    my $sql = "SELECT DATE_SUB(CURDATE(), INTERVAL 7 + DAYOFWEEK(NOW()) DAY),
                 DATE_SUB(CURDATE(), INTERVAL DAYOFWEEK(NOW()) DAY),
                 DATE_ADD(CURDATE(), INTERVAL 7 - DAYOFWEEK(NOW()) DAY)";
    my $sth = $dbh->prepare($sql);
    $sth->execute() or die "Can't execute: $dbh->errstr\n";
    my ($status_old, $status_start, $status_end) = $sth->fetchrow_array;
    return ($status_old, $status_start, $status_end);
}

sub format_date {
    my ($format, $date) = @_;

    # get the date
    $date =~ /^(\d{4})-?(\d{1,2})-?(\d{1,2}) ?(\d{1,2}):?(\d{1,2}):?(\d{1,2})$/;
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
        return 'never' if !$date;
        return sprintf("%4.4d/%2.2d/%2.2d %2.2d:%2.2d:%2.2d", @date);
    }
    elsif ($format eq 'day_time') {
        return 'never' if !$date;
        my $mon = ('', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mm];
        return sprintf("%s %s, %s:%2.2d", $mon, $dd, $h, $m);
    }
    elsif ($format eq 'full_time') {
        return 'never' if !$date;
        return sprintf("%2.2d:%2.2d:%2.2d", $h, $m, $s);
    }
    elsif ($format eq 'short_date') {
        return 'never' if !$date;
        my $mon = ('', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mm];
        return "$mon $dd, $yyyy";
    }
    elsif ($format eq 'short_month_day') {
        return '......' if (!$date ||
            $mm == 0 ||
            $dd == 0);
        my $mon = ('', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[$mm];
        return "$mon $dd";
    }
    elsif ($format eq 'mdd') {
        return '...' if (!$date ||
            $mm == 0 ||
            $dd == 0);
        my $mon = ('.', 'j', 'f', 'm', 'a', 'm', 'j', 'j', 'a', 's', 'o', 'n', 'd')[$mm];
        return sprintf("%s%2.2d", $mon, $dd);
    }
    elsif ($format eq 'full_date') {
        return 'never' if !$date;
        require lib::db;
        my $dbh = $lib::db::dbh;

        my $sql = "SELECT DATE_FORMAT(?, '%a %b %d %h:%i')";
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

    return "$year\-$month\-$day $hour\:$min\:$sec";

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

1;
