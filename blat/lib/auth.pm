package task::auth;

use strict;

#
# module configuration
#

BEGIN{
    use task::db;
    use Exporter ();
    use vars qw(@ISA @EXPORT $USERID $USERNAME);
    
    @ISA = qw(Exporter);
    
    @EXPORT = qw($USERID $USERNAME);
    
}

#
# module routines
#

sub get_userid{
    my $loginid = $ENV{REMOTE_USER};

    # fetch from the db
    my $sql = "SELECT UserID FROM Users WHERE Username = ?";
    my $sth = $dbh->prepare($sql) or die "Can't prepare $sql:$dbh->errstr\n";
    $sth->execute($loginid);
    my ($userid) = $sth->fetchrow_array();
    $sth->finish;
    
    return ($userid, $loginid);
}

BEGIN{
    
    ($USERID, $USERNAME) = &get_userid();
}

1;
