##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca         
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

	############################
	### Do the date stuff.
	open (DATE, "/bin/date |");
	while (<DATE>) {
	    chop;
	    $today = $_;
	}
	close (DATE);
	
	if ($USERID != 1){

		open (LOG, '>>user/log/splash.log');
		print LOG "$today\t$ENV{REMOTE_ADDR}";
		print LOG "\t$USERID";
		print LOG "\t$USERID{username}";
		
		print LOG "\n";
		close (LOG);
	}


##########################################################
#### The end.
##########################################################
return 1;
