##################################################################
#	Scott Thompson - scottt@interchange.ubc.ca (nov/98)
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.


&show_bulletins();

################################################################################
sub show_bulletins
{
        my ($bulletins);

        $bulletins = get_general_config('bulletins');

        if (!$bulletins)
        {
	        print qq
                {
			<!-- no bulletins -->
                };
                return;
        }
        else
        {
		# &show_heading ("bulletins");
		print qq
                {
		       <TABLE border="0" cellpadding="0" cellspacing="0">
                        <TR>
                        <TD>$bulletins</TD>
                        </TR>
                        </TABLE>
                        <P>
                };
        }
}



# keepin perl happy...
return 1;
