package lib::email;




sub send_email{
    my ($message) = @_;
    my %message = %$message;
    
    my $body = delete($message{'Body'});
    my $to = delete($message{'To:'});
    my $from = delete($message{'From:'});
    my $subject = delete($message{'Subject:'});
    
    open  SENDMAIL, "| /usr/sbin/sendmail -t";
#    open  SENDMAIL, "| cat ";
    print SENDMAIL "To: $to\n";
    print SENDMAIL "From: $from\n";
    print SENDMAIL "Subject: $subject\n";
    foreach my $key (keys %message){
        print SENDMAIL "$key $message{$key}\n";
    }
    print SENDMAIL "\n";
    print SENDMAIL $body;
    close SENDMAIL;
    
}

1;
