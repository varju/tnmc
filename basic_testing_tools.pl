##################################################################
#	Scott Thompson - scottt@css.sfu.ca (aug/99)
#
# Basic Testing Methods
#	print_hash (hash)
#
##################################################################

###################################################################
sub print_hash{
	my (%hash, $junk) = @_;
	my ($key);

	print "<br>";
	foreach $key (sort keys (%hash)){
		print "<b>$key</b>	$hash{$key}<br>\n";
	}

}

return 1;
