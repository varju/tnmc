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

