#!/usr/bin/perl

##################################################################
#    Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use strict;
use lib '/tnmc';

use tnmc::config;
use tnmc::db;
use tnmc::template;

#############
### Main logic

&tnmc::db::db_connect();

&tnmc::template::header();

&tnmc::template::show_heading("site info");

print qq 
{    <TABLE>

        <TR>
        <TD VALIGN=TOP><B>Hosting:</B></TD>
        <TD>$ENV{'HTTP_HOST'} is hosted by Alex. <br>
            It was previously on <a href="http://steinbok.lvwr.com">steinbok.lvwr.com</a> <BR>
        </TR>

        <TR>
        <TD VALIGN=TOP><B>Site & DB Design:</B></TD>
        <TD>Scott</TD>
        </TR>

        <TR>
        <TD VALIGN=TOP><B>Implementation & Development:</B></TD>
        <TD>Jeff, Scott & Alex</TD>
        </TR>

        <TR>
        <TD VALIGN=TOP><B>Contributed Code:</B></TD>
        <TD>Grant</TD>
        </TR>

        <TR>
        <TD VALIGN=TOP><B>Contributed Opinions:</B></TD>
        <TD>Grant, Dave, Kate, Bel</TD>
        </TR>

        <TR>
        <TD VALIGN=TOP><B>Browsers Supported:</B></TD>
        <TD>    
            Netscape 4+ on a pc<br>
            Netscape 4+ on unix<br>
            Macs are unreliable at best<br>
            Explorer might work<br>
            ....or it might not.<br>
            </TD>
        </TR>

        <TR>
        <TD VALIGN=TOP><B>Techie Stuff:</B></TD>
        <TD>    The site is written in perl, is served by an
            Apache web server, and interfaces with a mySQL
            database. The whole she-bang is running on a FreeBSD box.
            
        </TR>

        <TR>
        <TD VALIGN=TOP><B>Stats:</B></TD>
        <TD>
        };

my @file_status = stat("/tnmc/source/tnmc.tar.gz");
use POSIX qw(strftime);
my $flastmod = strftime "%b %e, %Y", gmtime $file_status[9];

print qq{
            over 30,000 lines of perl code!<br>
            </TD>
        </TR>

     
        <TR>
        <TD valign="top" nowrap><B><a href="source/tnmc.tar.gz">Download Source Code</a></b><br>
            (as of $flastmod)<br>
        </TD>
        <TD>
            <b>TNMC<i>Online</i> is open source! :)</b>
            <p>
            If you want to use the code, please send
            an email to scottt @ interchange.ubc.ca


            <pre>
Copyright (C) 1999-2000  Scott Thompson, Jeff Steinbok and the rest of TNMC

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
<a href="http://www.fsf.org/copyleft/gpl.html#SEC3">GNU General Public License</a> for more details.
            </pre>
        </TD>
        </TR>

        </TABLE>
        <P>
};    

&tnmc::template::footer();

&tnmc::db::db_disconnect();
