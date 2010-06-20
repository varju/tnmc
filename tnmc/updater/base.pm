package tnmc::updater::base;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
    
use tnmc::general_config;
use tnmc::movies::movie;

sub new
{
    my $self = {};
    $self->{ua} = undef;
    bless($self);
    return $self;
}

sub update
{
    my ($self) = @_;
    die "Abstract\n";
}

sub get_valid_ua
{
    my ($self) = @_;
    if (! $self->{ua}) {
	$self->{ua} = new LWP::UserAgent;
	$self->{ua}->cookie_jar({});
    }
    return $self->{ua};
}

1;
