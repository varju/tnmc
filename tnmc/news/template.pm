package tnmc::news::template;

use strict;

use tnmc::security::auth;
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
    news_print($news_ref, 2, 0, 0);
}

sub news_print {
    my ($news_ref, $max, $edit_links, $print_expiry) = @_;

    my $count = @$news_ref;
    if ($max == 0) {
        $max = $count;
    }
    elsif ($count > $max) {
        $count = $max;
    }

    my $i = 0;
    foreach my $news_row (@$news_ref) {
        my $newsId = $$news_row{newsId};
        my $userId = $$news_row{userId};
        my $value = $$news_row{value};
        my $date = $$news_row{date};
        my $expires = $$news_row{expires};
        
        print "<p>$date\n";
        if ($print_expiry && $expires) {
            print " (until $expires)\n";
        }
        print "<p>$value\n";
        print "<p>-<i>$userId</i>\n";
        print "<br clear=\"all\">\n";

        if ($edit_links && $USERID{groupAdmin}) {
            print "<p><a href='edit_news.cgi?newsId=$newsId'>edit</a>\n";
            print " <a href='delete_news.cgi?newsId=$newsId'>delete</a>\n";
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
    my ($news_ref) = @_;

    my $newsId = $$news_ref{newsId};
    my $userId = $$news_ref{userId};
    my $date = $$news_ref{date};
    my $value = $$news_ref{value};
    my $expires = $$news_ref{expires};

    my $userlist = &tnmc::user::get_user_list("WHERE groupAdmin='1'");

    print qq{
<form action="edit_news_submit.cgi" method="post">
<table>
  <tr>
    <td><b>Date</b></td>
    <td><input type="text" name="date" value="$date" size="14" maxlength="14"></td>
  </tr>
  <tr>
    <td><b>Expires</b></td>
    <td><input type="text" name="expires" value="$expires" size="14" maxlength="14"></td>
  </tr>
  <tr>
    <td><b>User</b></td>
    <td><select name="userId">
};
    
    foreach my $key (sort keys %$userlist) {
        print "<option value='$$userlist{$key}'";
        print " selected" if $$userlist{$key} == $userId;
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

<input type="hidden" name="newsId" value="$newsId">
<input type="image" border=0 src="/template/submit.gif" alt="Submit Changes">
</form>
};
}
1;
