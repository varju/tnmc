#!/usr/bin/perl

##################################################################
#    Scott Thompson - scottt@css.sfu.ca 
#    Jeff Steinbok  - steinbok@interchange.ubc.ca
##################################################################
### Opening Stuff. Modules and all that. nothin' much interesting.

use DBI;
use CGI;

use lib '/usr/local/apache/tnmc';
use tnmc;

    #############
    ### Main logic
    
    &header();
    &db_connect();
    
    $cgih = new CGI;
    $groupID = $cgih->param('groupID');
    
    &show_group_selector($groupID);
    &show_edit_group($groupID);

     &db_disconnect();
    &footer();

##########################################################
#### sub procedures.
##########################################################


#########################################
sub show_group_selector{

    my ($group) = @_;

    my @groups = ();

    my $sql = "EXPLAIN Personal";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    while (my ($field, $junk) = $sth->fetchrow_array()){
        if ($field =~ s/^group//){
            push (@groups, $field);
        }
    }
    
    print qq{
        <form action="/admin/groups.cgi" method="post">
        <select name="groupID" defaultoption="$group" onChange="form.submit();">
    };
    

    foreach $groupID (@groups){
        if ($group eq $groupID){
            print qq{        <option value="$groupID" selected>$groupID\n};
        }else{
            print qq{        <option value="$groupID">$groupID\n};
        }
    }
    print qq{
        </select>
        </form>
    };
}
#########################################
sub show_edit_group{

    my ($group) = @_;

    return (1) if (!$group);

    my (@users, %user, $userID, $key);
    my @ranks = ('0', '1');


    &list_users(\@users, '', 'ORDER BY username');
    get_user($users[0], \%user);

    my $sql = "SELECT DISTINCT group$group FROM Personal ORDER BY group$group";
    my $sth = $dbh_tnmc->prepare($sql);
    $sth->execute();
    while (my @row = $sth->fetchrow_array()){
        next if ($row[0] == 1);
        next if ($row[0] == 0);
        push (@ranks, $row[0]);
    }

    &show_heading("Group Administration: $group");
    print qq{
        <form action="/admin/groups_change_submit.cgi" method="post">
        <input type="hidden" name="group" value="$group">
                <table cellspacing="0" cellpadding="1" border="0">
    };

    my $count = 0;
        foreach $userID (@users){
        if (! ($count++ % 20)){
    
            print qq{
                <tr>    <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
                    <th>&nbsp;</th>
                    <th>&nbsp;&nbsp;</th>
            };
            foreach my $rank (@ranks){
                print qq{
                    <th>$rank&nbsp;&nbsp;&nbsp;</th>
                };
            }
            print qq{
                    <td><input type="submit" value="submit"></td>
                    </tr>
            };
        }
                get_user($userID, \%user);
        print qq{
            <tr>    <td>$userID</td>
                <td><b>$user{username}</b></td>
                <td></td>
        };
        foreach my $rank (@ranks){
            my $sel = '';
            if ($user{"group$group"} == $rank){
                $sel = 'checked';
            }
            print qq{
                <td><input type="radio" name="USER$userID" value="$rank" $sel></td>
            };
        }
        print qq{
                <td>$user{fullname}</td>
                </tr>
        };
        }

        print qq{
                </table>
        </form>
        };
}

##########################################################
#### The end.
##########################################################


