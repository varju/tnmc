#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use warnings;

use lib "/scottt/htdocs/tasks/";

use task::db;
use task::user;
use task::template;
use task::cgi;

#############
### Main logic

print "Content-Type: text/html; charset=utf-8\n\n";

#&header();

my $username = $cgih->param('Username');

&add_user($username);

#&footer();

sub add_user {
    my ($username) = @_;

    if (!$username) {
        print "Error: No username<br>\n";
        return 0;
    }

    print "Checking for existing user<br>\n";

    # fetch from the db
    my $sql = "SELECT UserID FROM Users WHERE Username = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($username);
    my ($userid) = $sth->fetchrow_array();
    $sth->finish;
    if ($userid) {
        print "Error: User already exists.<br>\n";
        return 0;
    }

    print "Adding User ($username) to db...<br>\n";
    my %user = (
        'Username'     => $username,
        'PrefFontSize' => 1,
        'UserID'       => 0,
    );

    &task::user::set_user(\%user);

    print "Adding User to .htpasswd....<br>\n";
    open(PASSWD, ">>/scottt/htdocs/tasks/.htpasswd");
    print PASSWD $username, ":\n";
    close PASSWD;

    print "Done.<br>\n";
    print "<br>\n";
    print "<a href=\"\/tasks\/\">Login<\/a> (no password needed)<br>\n";

}

