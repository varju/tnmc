#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
use tnmc::movies::movie;
use tnmc::movies::night;
use tnmc::movies::attend;

{

	#############
	### Main logic

	&db_connect();
	&header();

#	&show_movies();
#	&show_add_movie_form();



	$next = &get_next_night();
	&get_night($next, \%next);
	print qq{Next? <a href="night_edit_admin.cgi?nightID=$next{nightID}">$next{date}</a>};

        print "<hr>";

	my @nights;
        list_nights(\@nights, "", "ORDER BY date DESC");
        
        foreach $nightID (@nights){
            my %night;
            get_night ($nightID, \%night);
            print qq{
                <a href="night_edit_admin.cgi?nightID=$nightID">$night{date}</a>
                ($nightID)<br>
            };
        }
        
	&footer();
	&db_disconnect();


}

############################################################
sub list_nights{
    my ($night_list_ref, $where_clause, $by_clause, $junk) = @_;
    my (@row, $sql, $sth);

    @$night_list_ref = ();

    $sql = "SELECT nightID from MovieNights $where_clause $by_clause";
    $sth = $dbh_tnmc->prepare($sql) or die "Can't prepare $sql:$dbh_tnmc->errstr\n";
    $sth->execute;
    while (@row = $sth->fetchrow_array()){
        push (@$night_list_ref, $row[0]);
    }
    $sth->finish;

    return scalar @$night_list_ref;
}


##################################################################
sub show_night
{
	my ($nightID, $junk) = @_;	
	my (@cols, $night, %night, $key);
	
	if ($nightID)
	{ 
        	&get_night($nightID, \%night);

print $nightID;

		print qq 
		{
			<table>
		};
	
		foreach $key (sort(keys(%night)))
        	{
			print qq 
			{	
				<tr valign=top><td><B>$key</B></td>
				    <td>$night{$key}</td>
				</tr>
			};
        	}

		print qq
		{
			</table>
		}; 
	}
}
	

##########################################################
#### The end.
##########################################################

