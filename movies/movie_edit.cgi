#!/usr/bin/perl

##################################################################
#       Scott Thompson - scottt@interchange.ubc.ca
#	Jeff Steinbok - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use lib '/usr/local/apache/tnmc/';
use tnmc;
require 'MOVIES.pl';

	#############
	### Main logic

	&header();

	%movie;	
	$cgih = new CGI;
	$movieID = $cgih->param('movieID');
	
	&db_connect();
       	&get_movie($movieID, \%movie);
	&db_disconnect();

	if ($movie{statusSeen}){
		$checkboxSeen = 'CHECKED';
	}else{
		$checkboxNotSeen = 'CHECKED';
	}

	if ($movie{statusShowing}){
		$checkboxShowing = 'CHECKED';
	}else{
		$checkboxNotShowing = 'CHECKED';
	}

	if ($movie{statusNew}){
		$checkboxNew = 'CHECKED';
	}else{
		$checkboxNotNew = 'CHECKED';
	}

	print qq{
		<form action="movie_edit_submit.cgi" method="post">
		<input type="hidden" name="movieID" value="$movieID">
		<table>

		<tr valign=top>
			<td><b>Title</b></td>
			<td><input type="text" size="40" name="title" value="$movie{title}"></td>
		</tr>

		<tr valign=top>
			<td><b>Type</b></td>
			<td><input type="text" size="40" name="type" value="$movie{type}"></td>
		</tr>

		<tr valign=top>
			<td><b>Rating</b></td>
			<td><input type="text" size="4" name="rating" value="$movie{rating}"></td>
		</tr>

		<tr valign=top>
			<td><b>Description</b></td>
			<td><textarea cols="50" rows="4" wrap="virtual" name="description">$movie{description}</textarea></td>
		</tr>

		<tr valign=top>
			<td><b>Status</b></td>
			<td>
				<input type="radio" name="statusNew" value="1" $checkboxNew>Y
				<input type="radio" name="statusNew" value="0" $checkboxNotNew>N &nbsp; <b>New</b><br>
				<input type="radio" name="statusShowing" value="1" $checkboxShowing>Y
				<input type="radio" name="statusShowing" value="0" $checkboxNotShowing>N &nbsp; <b>Showing</b><br>
				<input type="radio" name="statusSeen" value="1" $checkboxSeen>Y
				<input type="radio" name="statusSeen" value="0" $checkboxNotSeen>N &nbsp <b>Seen</b><br>
			</td>
		</tr>


		<tr valign=top>
			<td><b>MyBC ID</b></td>
			<td><input type="text" size="10" name="mybcID" value="$movie{mybcID}"></td>
		</tr>


		</table>
		<input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
		</form>
	}; 
	

	&footer();
