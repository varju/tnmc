package tnmc::util::ip;

use strict;

#
# module routines
#

sub get_hostname {
    my ($ip) = @_;
    my $name = '';
    
    return if (!$ip);
    
    my @nslookup = `nslookup $ip`;
    
    foreach my $line (@nslookup){
        if ($line =~ /Name\:\s+(.*)$/){
            $name = $1;
            chomp $name;
        }
    }
    return $name;
}
    
1;

