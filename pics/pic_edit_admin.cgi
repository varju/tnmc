#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/tnmc';

use tnmc::security::auth;
use tnmc::db;
use tnmc::template;
use tnmc::cgi;

use tnmc::pics::pic;
use tnmc::pics::album;
use tnmc::pics::link;
use tnmc::pics::show;

#############
### Main logic

&header();

$cgih = &tnmc::cgi::get_cgih();

$picID = $cgih->param('picID');
%pic;	
&get_pic($picID, \%pic);

print qq {
    <form action="pic_edit_admin_submit.cgi" method="post">
    <table>
};

foreach $key (keys %pic){
    print qq{	
        <tr><td><b>$key</td>
        <td><input type="text" name="$key" value="$pic{$key}"></td>
        </tr>
    };
}
	
print qq{
    </table>
    <input type="submit" value="Submit">
    </form>
}; 

&footer();
