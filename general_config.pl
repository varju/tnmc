##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca (nov/98)
#       Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

require 5.004;
use strict;
use DBI;
use CGI;

require 'db_access.pl';

###################################################################
sub get_general_config{
        my ($name, $value_ref, $junk) = @_;
        my ($sql, $sth, @row);

        $sql = "SELECT value from GeneralConfig WHERE name = '$name'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        ($$value_ref, $junk) = $sth->fetchrow_array();
        $sth->finish;

        return $$value_ref;
}

###################################################################
sub set_general_config{
        my ($name, $value, $junk) = @_;
        my ($sql, $sth, @row);

        $sql = "DELETE FROM GeneralConfig WHERE name='$name'";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;

        $sql = "REPLACE INTO GeneralConfig (name, value) VALUES ('$name', " . $dbh_tnmc->quote($value) . ")";
        $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
        $sth->execute;
        $sth->finish;
}



# keepin perl happy...
return 1;
