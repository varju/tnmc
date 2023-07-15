package tnmc::forms::forms;

use strict;
use warnings;

#
# module configuration
#

#
# module routines
#

# Note: I'm not totally sure about the organization of this form
# thing. Some decisions need to be made as to where it's responsibility
# begins and ends.
#
# My initial perception, is that  it should take an item (and some conf)
# and return the changed item. (conceptually, like asking the user a
# question... or like saving it to the user and then reading it back
# again after changes.
#
# This raises questions about where validity-checking is to be done. It
# would be nice to handle it with the forms module, but that could be
# unreasonably messy. Perhaps a forms::validity module
#

sub edit_item_recieve_form {
    my ($item) = @_;

    require tnmc::cgi;

    foreach my $key (keys %$item) {
        $item->{$key} = &tnmc::cgi::param($key);
    }

}

sub edit_item_show_form {
    my ($item, $conf) = @_;

    print qq{
	<b>$conf->{'.form'}->{heading}</b><br>

	<table>
	<form method="post" action="$conf->{'.form'}->{action}">
	    <input type="hidden" name="ACTION" value="$conf->{'.form'}->{ACTION}">
    };

    foreach my $key (sort keys %$item) {

        my $key_conf = $conf->{$key};
        if (!$key_conf) {
            $key_conf = $conf->{".default"};
        }

        ## hidden
        if ($key_conf->{type} eq 'hidden') {
            print qq{<input type="hidden" name="$key" value="$item->{$key}">};
            next;
        }

        ## setup config
        my $width = 40;

        # form element
        my $form_element;
        if ($key_conf->{type} eq 'textarea') {
            my $cols = $width - 5;
            my $rows = (length($item->{$key}) / $cols) + 1;    #note: doesn't deal with /n's
            $rows         = 3  if ($rows < 3);                 # enforce minimum rows
            $rows         = 15 if ($rows > 15);                # enforce maximum rows
            $form_element = qq{<textarea name="$key" cols="$cols" rows="$rows">$item->{$key}</textarea>};
        }
        elsif ($key_conf->{type} eq 'select') {
            my $options = $key_conf->{options};
            $form_element = qq{<select name="$key">};
            foreach my $option (@$options) {
                my $selected = ($option->{key} eq $item->{$key}) ? "selected" : "";
                $form_element .= qq{<option $selected value="$option->{key}">$option->{val}</option>};
            }
            $form_element .= qq{</select>};
        }
        elsif ($key_conf->{type} eq 'radio') {
            my $options = $key_conf->{options};
            foreach my $option (@$options) {
                my $checked = ($option->{key} eq $item->{$key}) ? "checked" : "";
                $form_element .= qq{<input type="radio" name="$key" $checked value="$option->{key}">$option->{val} };
            }
        }
        else {
            $form_element = qq{<input size="$width" type="text" name="$key" value="$item->{$key}">};
        }

        print qq{
	    <tr>
	    <td>$key</td>
	    <td>$form_element</td>
	    </tr>
	};

    }
    print qq{
	<tr><td colspan="2">
	    <input type="submit" value="$conf->{'.form'}->{submit}">
	    </td></tr>
	</form>
	</table>
    };

}

1;
