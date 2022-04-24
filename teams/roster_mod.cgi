#!/usr/bin/perl

use lib '/tnmc';
use tnmc;

require tnmc::teams::roster;

#
# common variables
#

&tnmc::teams::htmlTemplate::change_template();

my $status = \@tnmc::teams::roster::status;

my @status_options =
  map { { "key" => $_, "val" => $_ } } @$status;

my %form_conf =    ## config for edit/create
  (
    ".form" => {
        "action" => $script_name,
    },
    ".default" => { "type" => "text" },
    "teamID"   => { "type" => "hidden" },
    "answers"  => { "type" => "hidden" },
    "gender"   => {
        "type"    => "select",
        "options" => [ { "key" => "M", "val" => "Boy" }, { "key" => "F", "val" => "Girl" } ]
    },
    "is_admin" => {
        "type"    => "radio",
        "options" => [ { "key" => "1", "val" => "Yes" }, { "key" => "0", "val" => "No" } ]
    },
    "status" => {
        "type"    => "select",
        "options" => \@status_options
    },
  );

my $script_name = "teams/roster_mod.cgi";

#
# Actions
#

my $ACTION = lc(&tnmc::cgi::param("ACTION"));

if ($ACTION eq 'add') {
    &action_add();
}
elsif ($ACTION eq 'addsubmit') {
    &action_add_submit();
}
elsif ($ACTION eq 'edit') {
    &action_edit();
}
elsif ($ACTION eq 'editsubmit') {
    &action_edit_submit();
}
elsif ($ACTION eq 'del') {
    &action_del();
}
elsif ($ACTION eq 'delsubmit') {
    &action_del_submit();
}
else {
    &action_add();
}

#
# Action Subs
#

sub action_add {

    require tnmc::user;

    # setup new
    my $hash   = &tnmc::teams::roster::new_roster();
    my $teamID = &tnmc::cgi::param("teamID");

    $hash->{teamID}   = $teamID;
    $hash->{is_admin} = 0;

    # form config
    $form_conf{'.form'}->{'heading'} = "Add Player";
    $form_conf{'.form'}->{'ACTION'}  = "AddSubmit";
    $form_conf{'.form'}->{'submit'}  = "Save";

    # username list
    my $userlist = &tnmc::user::get_user_list();

    my @userid_options =
      map { { "key" => $userlist->{$_}, "val" => $_ } } (sort keys %$userlist);
    $form_conf{'userID'} = {
        "type"    => "select",
        "options" => \@userid_options
      },

      # show the page
      &tnmc::template::header();

    &tnmc::forms::forms::edit_item_show_form($hash, \%form_conf);

    &tnmc::template::footer();
}

sub action_add_submit {

    # recieve form
    my $hash = &tnmc::teams::roster::new_roster();
    &tnmc::forms::forms::edit_item_recieve_form($hash);

    # save data
    &tnmc::teams::roster::set_roster($hash);

    # redirect user
    print "Location: team.cgi?teamID=$hash->{teamID}\n\n";
}

sub action_edit {
    require tnmc::teams::team;
    require tnmc::user;

    # load data
    my $userID = &tnmc::cgi::param("userID");
    my $teamID = &tnmc::cgi::param("teamID");
    my $hash   = &tnmc::teams::roster::get_roster($teamID, $userID);

    my $team = &tnmc::teams::team::get_team($teamID);
    my $user = &tnmc::user::get_user($userID);

    # form config
    $form_conf{'.form'}->{'heading'} = "Edit Roster (player: $user->{username} -- team: $team->{name})";
    $form_conf{'.form'}->{'ACTION'}  = "EditSubmit";
    $form_conf{'.form'}->{'submit'}  = "Save Changes";

    # userid
    $form_conf{'userID'} = { "type" => "hidden" };

    # show the page
    &tnmc::template::header();

    &tnmc::forms::forms::edit_item_show_form($hash, \%form_conf);

    if (&tnmc::teams::team::USERID_is_admin($teamID)) {
        print qq{
	    <form action="$script_name" method="post">
	    <input type="hidden" name="teamID" value="$teamID">
	    <input type="hidden" name="userID" value="$userID">
	    <input type="hidden" name="ACTION" value="DelSubmit">
	    <input type="submit" value="Delete From Roster">
	    </from>
	    <p>
	};
    }

    &tnmc::template::footer();
}

sub action_edit_submit {

    # recieve form
    my $hash = &tnmc::teams::roster::new_roster();
    &tnmc::forms::forms::edit_item_recieve_form($hash);

    # save data
    &tnmc::teams::roster::set_roster($hash);

    # redirect user
    print "Location: team.cgi?teamID=$hash->{teamID}\n\n";
}

sub action_del_submit {

    require tnmc::cgi;

    # recieve form
    my $teamID = &tnmc::cgi::param("teamID");
    my $userID = &tnmc::cgi::param("userID");

    # save data
    &tnmc::teams::roster::remove_roster($teamID, $userID);

    # redirect user
    print "Location: team.cgi?teamID=$teamID\n\n";
}

