package tnmc::movies::attendance;

use strict;

use tnmc::db;
use tnmc::movies::night;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);
@EXPORT = qw(set_attendance get_attendance get_user_attendance_hash get_night_attendance_hash show_my_attendance_chooser);
@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub set_attendance{
    my ($ref, $junk) = @_;
    
    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    
    my @keys = sort keys %$ref;
    
    my $key_list = join (',', @keys);
    my $ref_list = join (',', (map {sprintf '?'} @keys));
    my @var_list = map {$ref->{$_}} @keys;
    
    # save to the db
    my $sql = "REPLACE INTO MovieNightAttendance ($key_list) VALUES($ref_list)";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute(@var_list) or return 0;
    
    $sth->finish;
}

sub get_attendance{
    my ($userID, $nightID, $row_ref) = @_;
    
    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    
    # fetch from the db
    my $sql = "SELECT * from MovieNightAttendance WHERE userID = ? AND nightID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($userID, $nightID) or return();
    my $row = $sth->fetchrow_hashref();
    $sth->finish;
    if ($row){
        %{$row_ref} = %{$row};
    }
}

sub get_user_attendance_hash{
    my ($userID) = @_;
    
    my %hash;
    
    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    
    # fetch from the db
    my $sql = "SELECT nightID, type from MovieNightAttendance WHERE userID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($userID);
    
    while (my @row = $sth->fetchrow_array()){
        $hash{$row[0]} = $row[1];
    }
    $sth->finish;
    
    # return the data
    return \%hash;
}

sub get_night_attendance_hash{
    my ($nightID) = @_;
    
    my %hash;
    
    # make sure we have a handle
    my $dbh = &tnmc::db::db_connect();
    
    # fetch from the db
    my $sql = "SELECT userID, type from MovieNightAttendance WHERE nightID = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($nightID);
    
    while (my @row = $sth->fetchrow_array()){
        $hash{$row[0]} = $row[1];
    }
    $sth->finish;
    
    # return the data
    return \%hash;
}


sub show_my_attendance_chooser{
    
    my ($userID) = @_;
    
    # get the list of nights
    my @nights = &tnmc::movies::night::list_future_nights();
    
    # Get User's attendance
    my %attendance;
    
    # print some opening crap
    print qq{
    <table border=0 cellpadding=1 cellspacing=0 width="100%">
        <tr bgcolor="cccccc">
        <td norwrap>
        <form action="/movies/night_attendance_submit.cgi" method="post">
        <input type="hidden" name="userID" value="$userID">&nbsp;&nbsp;
        </td>
        <td align="center"><b>Default</td>
        <td>&nbsp;&nbsp;</td>
    };
    
    foreach my $nightID (@nights){
        my %night;
        &get_night($nightID, \%night);
        my $sql = "SELECT DATE_FORMAT(?, '%b %D')";
        my $sth = $dbh_tnmc->prepare($sql);
        $sth->execute($night{'date'});
        my ($show_date) = $sth->fetchrow_array();
        $sth->finish();
        
        print qq{
            <td align="center"><font color="888888"><b>$show_date&nbsp;</td>
            <td>&nbsp;&nbsp;</td>
        };
    }
    
    print qq{
        <td>&nbsp;&nbsp;</td>
        <td>&nbsp;&nbsp;</td>
            </tr>
        <tr>
        <td></td>
            <td valign="top"><font size="-1">
                <select name="movieAttendDefault">
                <option value="$attendance{movieDefault}">$attendance{movieDefault}
        <option value="$attendance{movieDefault}">----
                <option>yes
                <option>no
                </select></font>
                </td>
                <td></td>
        };
    
    foreach my $nightID (@nights){
        my %attendance;
        &get_attendance($userID, $nightID, \%attendance);
        
        my $sel_yes     = ($attendance{'type'} eq '1')? 'selected' : '';
        my $sel_no      = ($attendance{'type'} eq '-1')? 'selected' : '';
        my $sel_default = (! ($sel_yes || $sel_no))? 'selected' : '';
        
        print qq{
            <td valign="top"><font size="-1">
                <select name="night_$nightID">
                <option value="" $sel_default>
                <option value="">default
                <option value="1" $sel_yes>yes
                <option value="-1" $sel_no>no
                </select>
            </td>
            <td></td>
        };
    }
    
    print qq{
    <td valign="top"><font size="-1"><input type="submit" value="Set Attendance"></form></td>
    </tr>
    </table>
    };
}

1;
