package tnmc::news::template;

use strict;

use tnmc::cookie;
use tnmc::user;

use tnmc::news::util;

#
# module configuration
#

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);

@ISA = qw(Exporter);

@EXPORT = qw(news_print_quick news_print news_edit);

@EXPORT_OK = qw();

#
# module vars
#

#
# module routines
#

sub news_print_quick {
    my $news_ref = get_quick_news();
    news_print($news_ref, 2, 0);
}

sub news_print {
    my ($news_ref, $max, $edit_links) = @_;

    my $count = @$news_ref;
    if ($max == 0) {
        $max = $count;
    }
    elsif ($count > $max) {
        $count = $max;
    }

    my $i = 0;
    foreach my $news_row (@$news_ref) {
        my $newsid = $$news_row{id};
        my $user = $$news_row{user};
        my $value = $$news_row{value};
        my $date = $$news_row{date};
        
        print "<p>$date\n";
        print "<p>$value\n";
        print "<p>-<i>$user</i>\n";

        if ($edit_links && $USERID{groupAdmin}) {
            print "<p><a href='edit_news.cgi?newsid=$newsid'>edit</a>\n";
            print " <a href='delete_news.cgi?newsid=$newsid'>delete</a>\n";
        }
        
        if (++$i < $count) {
            print "<hr noshade>\n";
        }
        
        if ($i == $max) {
            return;
        }
    }

    print "<p>\n";
}

sub news_edit {
    my ($newsid,$userid,$date,$value) = @_;

    my $userlist = get_user_list();

    print qq{
<form action="edit_news_submit.cgi" method="post">
<table>
  <tr>
    <td><b>Date</b></td>
    <td><input type="text" name="date" value="$date" size="14" maxlength="14"></td>
  </tr>
  <tr>
    <td><b>User</b></td>
    <td><select name="userid">
};
    
    foreach my $key (sort keys %$userlist) {
        print "<option value='$$userlist{$key}'";
        print " selected" if $$userlist{$key} == $userid;
        print ">$key\n";
    }

    print qq{
    </select></td>
  </tr>
  <tr>
    <td valign=top><b>Text</b></td>
    <td><textarea cols=40 rows=15 wrap=virtual name="value">$value</textarea></td>
  </tr>
</table>
<p>

<input type="hidden" name="newsid" value="$newsid">
<input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
</form>
};
}
1;
