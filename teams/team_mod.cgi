#!/usr/bin/perl

use lib '/tnmc';
use tnmc;

require tnmc::teams::team;

#
# common variables
#

&tnmc::teams::htmlTemplate::change_template();

my $sports = \%tnmc::teams::team::sports;
my @sport_options = 
    map { {"key" => $_, "val" => $sports->{$_}} }
        sort{$sports->{$a} cmp $sports->{$b} } ( keys %$sports);

my @templates = &tnmc::template::list_templates();
my @template_options = 
    map { {"key" => $_, "val" => $_} }
        sort (@templates);

my %form_conf =  ## config for edit/create
    (
     ".form" => {
	 "action" => $script_name,
	 },
     ".default" => {"type" => "text"},
     "teamID" => {"type" => "hidden"},
     "captainID" => {"type" => "hidden"},
     "htmlTemplate" => {"type" => "select",
		    "options" => \@template_options},
     "questions" => {"type" => "hidden"},
     "sport" => {"type" => "select",
		 "options" => \@sport_options },
     "description" => {"type" => "textarea"},
     "EventURL" => {"type" => "text"},
     "DateExpires" => {"type" => "text"},
     );

my $script_name = "teams/team_mod.cgi";

#
# Actions
#

my $ACTION = lc( &tnmc::cgi::param("ACTION"));

if ($ACTION eq 'list'){
    &action_list();
}
elsif ($ACTION eq 'add'){
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

sub action_list{

    &tnmc::template::header();
    
    my @teams = &tnmc::teams::team::list_teams();
    &show_list_teams(@teams);
    
    print @teams;
    print qq{
	<p>
	[<a href="$script_name?ACTION=add">Add Team</a>]
    };
    
    &tnmc::template::footer();
}

sub show_list_teams{
    my @list = @_;
    require tnmc::util::date;
    
    print qq{
	<table>
	<tr>
	<th>Title</th>
	<th>Action</th>
	</tr>
    };
    foreach my $ID (@list){
	my $hash = &tnmc::teams::team::get_team($ID);
	
	print qq{
	    <tr valign="top">
	    <td>$hash->{title}</td>
	    <td nowrap>
	    [<a href="$script_name?teamID=$ID&ACTION=edit">Edit</a>]
	    [<a href="$script_name?teamID=$ID&ACTION=del">Del</a>]
	    </td>
	    </tr>
	};
    }
    
    print qq{
	</table>
    };
}



sub action_add{
    
    # setup new event
    my $hash = &tnmc::teams::team::new_team();
    
    $hash->{captainID} = $tnmc::security::auth::USERID;
    $hash->{htmlTemplate} = &tnmc::template::get_template();
    
    # form config
    $form_conf{'.form'}->{'heading'} = "Add Team";
    $form_conf{'.form'}->{'ACTION'} = "AddSubmit";
    $form_conf{'.form'}->{'submit'} = "Save";

    # show the page
    &tnmc::template::header();
    
    &tnmc::forms::forms::edit_item_show_form($hash, \%form_conf);
    
    &tnmc::template::footer();
}

sub action_add_submit{
    
    # recieve form
    my $hash = &tnmc::teams::team::new_team();
    &tnmc::forms::forms::edit_item_recieve_form($hash);

    # save data
    my $ID = &tnmc::teams::team::add_team($hash);
    
    # redirect user
    print "Location: index.cgi\n\n";
}

sub action_edit{
    
    # load data
    my $ID = &tnmc::cgi::param("teamID");
    my $hash = &tnmc::teams::team::get_team($ID);
    
    # form config
    $form_conf{'.form'}->{'heading'} = "Edit Team";
    $form_conf{'.form'}->{'ACTION'} = "EditSubmit";
    $form_conf{'.form'}->{'submit'} = "Save Changes";
    
    # show the page
    &tnmc::template::header();
    
    &tnmc::forms::forms::edit_item_show_form($hash, \%form_conf);
    
    &tnmc::template::footer();
}

sub action_edit_submit{
    
    # recieve form
    my $hash = &tnmc::teams::team::new_team();
    &tnmc::forms::forms::edit_item_recieve_form($hash);
    
    # save data
    &tnmc::teams::team::set_team($hash);
    
    # redirect user
    print "Location: index.cgi\n\n";
}

sub action_del{
    
    require tnmc::teams::template;
    
    # load data
    my $ID = &tnmc::cgi::param("teamID");
    
    # show the page
    &tnmc::template::header();
    
    print qq{
	
	<form action="$script_name" method="post">
	<input type="hidden" name="teamID" value="$ID">
	<input type="hidden" name="ACTION" value="DelSubmit">
	<input type="submit" value="Delete Team">
	</form>
	<p>
	
    };
    
    &tnmc::teams::template::show_team($ID);
    
    &tnmc::template::footer();
}

sub action_del_submit{
    
    require tnmc::cgi;
    
    # recieve form
    my $ID = &tnmc::cgi::param("teamID");
    
    # save data
    &tnmc::teams::team::remove_team($ID);
    
    # redirect user
    print "Location: index.cgi\n\n";
    
}




