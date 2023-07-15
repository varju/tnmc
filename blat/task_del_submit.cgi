#!/usr/bin/perl

##################################################################
#	Scott Thompson
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use warnings;

use task::db;
use task::task;
use task::template;
use task::cgi;

#############
### Main logic

my $id      = $cgih->param('taskID');
my $confirm = $cgih->param('confirm');

if (!$confirm) {
    &header();

    my $task = &task::task::get_task($id);

    print qq{
        <form action="task_del_submit.cgi" method="post">
        <input type="hidden" name="taskID" value="$id">
        <b>Are you SURE that you want to delete this task?</b>
        <p>
        $task->{Title} ($id)
        <p>
        <input type="checkbox" name="confirm" value="1">Yes
        <p>
        <input type="submit" value="Delete">
        </form>
    };

    &footer();
}
else {

    &task::task::del_task($id);
    print "Location: index.cgi\n\n";

}

