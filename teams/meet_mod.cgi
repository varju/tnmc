#!/usr/bin/perl

use lib '/tnmc';
use tnmc

require tnmc::teams::meet;

#
# common variables
#

&tnmc::teams::htmlTemplate::change_template();

my $types = \@tnmc::teams::meet::types;

my @type_options = 
    map { {"key" => $_, "val" => $_} }
         @$types;

my %form_conf =  ## config for edit/create
    (
     ".form" => {
	 "action" => $script_name,
	 },
     ".default" => {"type" => "text"},
     "teamID" => {"type" => "hidden"},
     "meetID" => {"type" => "hidden"},
     "type" => {"type" => "select",
		"options" => \@type_options},
     );

my $script_name = "teams/meet_mod.cgi";

#
# Actions
#

my $ACTION = lc( &tnmc::cgi::param("ACTION"));


if ($ACTION eq 'add'){
    &action_add();
}
elsif ($ACTION eq 'addsubmit'){
    &action_add_submit();
}
elsif ($ACTION eq 'edit'){
    &action_edit();
}
elsif ($ACTION eq 'editsubmit'){
    &action_edit_submit();
}
elsif ($ACTION eq 'del'){
    &action_del();
}
elsif ($ACTION eq 'delsubmit'){
    &action_del_submit();
}
else{
    &action_add();
}

#
# Action Subs
#


sub action_add{

    require tnmc::util::date;
    
    # setup new
    my $hash = &tnmc::teams::meet::new_meet();
    my $teamID = &tnmc::cgi::param("teamID");
    
    $hash->{teamID} = $teamID;
    $hash->{minFemale} = 5;
    $hash->{minMale} = 6;
    $hash->{minTotal} = 11;
    $hash->{minMale} = 6;
    $hash->{date} = &tnmc::util::date::now();
    
    # extra param: _default_attendance
    $hash->{_default_attendance} = '';
    $form_conf{'_default_attendance'} = {
	"type" => "select",
	"options" => [{"key" => "", "val" => "No Default"},
		      {"key" => "yes", "val" => "Yes"},
		      {"key" => "late", "val" => "Late"},
		      {"key" => "early", "val" => "Leave Early"},
		      {"key" => "maybe", "val" => "Maybe"},
		      {"key" => "no", "val" => "No"},
		      {"key" => "undef", "val" => "--"}
		      ],
    };
    
    # form config
    $form_conf{'.form'}->{'heading'} = "Add Meet";
    $form_conf{'.form'}->{'ACTION'} = "AddSubmit";
    $form_conf{'.form'}->{'submit'} = "Save";
    
    # show the page
    &tnmc::template::header();
    
    &tnmc::forms::forms::edit_item_show_form($hash, \%form_conf);
    
    &tnmc::template::footer();
}

sub action_add_submit{
    
    # recieve form
    my $hash = &tnmc::teams::meet::new_meet();
    &tnmc::forms::forms::edit_item_recieve_form($hash);
    
    # save data
    my $ID = &tnmc::teams::meet::add_meet($hash);
    my $teamID = $hash->{teamID};
    
    # extra param: _default_attendance
    my $default_attendance = &tnmc::cgi::param("_default_attendance");
    if ($default_attendance && $default_attendance ne ''){
	
	my $attendance = &tnmc::teams::attendance::new_attendance();
	$attendance->{'meetID'} = $ID;
	$attendance->{'type'} = $default_attendance;
	
	my @players = &tnmc::teams::roster::list_users_by_status($teamID, 'Player');
	    print STDERR " u: $userID\n";
	foreach $userID (@players){
	    print STDERR " u: $userID\n";
	    $attendance->{'userID'} = $userID;
	    &tnmc::teams::attendance::set_attendance($attendance);
	}
	
    }
    
    # redirect user
    print "Location: team.cgi?teamID=$hash->{teamID}\n\n";
}

sub action_edit{
    
    # load data
    my $ID = &tnmc::cgi::param("meetID");
    my $hash = &tnmc::teams::meet::get_meet($ID);
    
    # form config
    $form_conf{'.form'}->{'heading'} = "Edit Meet";
    $form_conf{'.form'}->{'ACTION'} = "EditSubmit";
    $form_conf{'.form'}->{'submit'} = "Save Changes";
    
    # show the page
    &tnmc::template::header();
    
    &tnmc::forms::forms::edit_item_show_form($hash, \%form_conf);
    
    if (&tnmc::teams::team::USERID_is_admin($hash->{teamID})){
	print qq{
	
	    <form action="$script_name" method="post">
	    <input type="hidden" name="meetID" value="$ID">
	    <input type="hidden" name="ACTION" value="DelSubmit">
	    <input type="submit" value="Delete Meet">
	    </form>
	    <p>
	
	};
    }
    
    &tnmc::template::footer();
}

sub action_edit_submit{
    
    # recieve form
    my $hash = &tnmc::teams::meet::new_meet();
    &tnmc::forms::forms::edit_item_recieve_form($hash);
    
    # save data
    &tnmc::teams::meet::set_meet($hash);
    
    # redirect user
    print "Location: team.cgi?teamID=$hash->{teamID}\n\n";
}

sub action_del{
    
    require tnmc::teams::template;
    
    # load data
    my $ID = &tnmc::cgi::param("meetID");
    
    # show the page
    &tnmc::template::header();
    
    print qq{
	
	<form action="$script_name" method="post">
	<input type="hidden" name="meetID" value="$ID">
	<input type="hidden" name="ACTION" value="DelSubmit">
	<input type="submit" value="Delete Meet">
	</form>
	<p>
	
    };
    
    &tnmc::teams::template::show_meet($ID);
    
    &tnmc::template::footer();
}

sub action_del_submit{
    
    require tnmc::cgi;
    
    # recieve form
    my $ID = &tnmc::cgi::param("meetID");
    
    # save data
    &tnmc::teams::meet::remove_meet($ID);
    
    # redirect user
    print "Location: index.cgi\n\n";
    
}




