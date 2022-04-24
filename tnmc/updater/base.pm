package tnmc::updater::base;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

use tnmc::general_config;
use tnmc::movies::movie;

sub new {
    my $self = {};
    $self->{ua} = undef;
    bless($self);
    return $self;
}

sub get_label {
    my ($self) = @_;
    die "Abstract\n";
}

sub get_type {
    my ($self) = @_;
    die "Abstract\n";
}

sub update {
    my ($self) = @_;

    print "Content-type: text/html\n\n<pre>\n";

    my $theatres  = $self->get_theatres();
    my $showtimes = $self->get_showtimes($theatres);

    print "\n\n";
    print "***********************************************************\n";
    print "****               Update the Database                 ****\n";
    print "***********************************************************\n";
    print "\n\n";

    #print "- reset statusShowing\n";
    $self->reset_status_showing();

    ## del old showtimes
    #print "- delete old showtimes\n";
    &tnmc::movies::showtimes::del_all_showtimes();

    ## update movies
    #print "- update showtimes\n";
    foreach my $theatreID (keys %$showtimes) {
        $self->process_theatre($theatreID, $showtimes->{$theatreID});
    }

    ### update the movie caches
    #print "- update movie caches\n";
    &tnmc::movies::night::update_all_cache_movieIDs();

    #print "- disconnect\n";
    &tnmc::db::db_disconnect();

    #print "- done\n";
}

sub get_theatres {
    my ($self) = @_;

    my $label = $self->get_label();
    print "***********************************************************\n";
    print "****           $label: Get The Theatre List\n";
    print "***********************************************************\n";
    print "\n\n";

    my $type     = $self->get_type();
    my @theatres = &tnmc::movies::theatres::list_theatres("WHERE $type != ''");
    print join " ", @theatres;
    print "\n\n";

    return \@theatres;
}

sub get_showtimes {
    my ($self, $theatres) = @_;

    my $label = $self->get_label();
    print "***********************************************************\n";
    print "****           $label: Get The Showtimes              ****\n";
    print "***********************************************************\n";
    print "\n\n";

    my $type = $self->get_type();
    my %SHOWTIMES;
    foreach my $theatreID (@$theatres) {
        my $theatre = &tnmc::movies::theatres::get_theatre($theatreID);
        print "Theatre: $theatre->{name}\n";

        my $showtimes = $self->get_theatre_showtimes($theatre->{$type});
        foreach my $listing (@$showtimes) {
            print $listing->{$type}, "   ", $listing->{title}, "    ", $listing->{page}, "\n";
        }

        $SHOWTIMES{$theatreID} = $showtimes;

    }

    return \%SHOWTIMES;
}

sub get_theatre_showtimes {
    my ($self, $type_id) = @_;
    die "Abstract\n";
}

sub reset_status_showing {
    my ($self) = @_;
    my $dbh    = &tnmc::db::db_connect();
    my $sql    = "UPDATE Movies SET statusShowing = '0', theatres = ''";
    my $sth    = $dbh->prepare($sql);
    $sth->execute();
    $sth->finish();
}

sub process_theatre {
    my ($self, $theatreID, $listings) = @_;
    die "Abstract\n";
}

sub get_valid_ua {
    my ($self) = @_;
    if (!$self->{ua}) {
        $self->{ua} = new LWP::UserAgent;
        $self->{ua}->cookie_jar({});
    }
    return $self->{ua};
}

sub add_showtime {
    my ($self, $theatreID, $movieID) = @_;

    my $showtimes = &tnmc::movies::showtimes::new_showtimes();
    $showtimes->{theatreID} = $theatreID;
    $showtimes->{movieID}   = $movieID;
    &tnmc::movies::showtimes::set_showtimes($showtimes);
}

sub get_or_create_movie {
    my ($self, $listing) = @_;

    my $type    = $self->get_type();
    my $type_id = $listing->{$type};
    my $movie   = &tnmc::movies::movie::get_movie_by_type($type, $type_id);
    if ($movie->{movieID}) {
        print "($type ", $movie->{movieID}, ")";
        return $movie;
    }

    my $title   = $listing->{title};
    my $movieID = &tnmc::movies::movie::get_movieid_by_title($title);
    if ($movieID) {
        print "(title $movieID)";
        return &tnmc::movies::movie::get_movie($movieID);
    }

    ## add new movie
    $movie          = &tnmc::movies::movie::new_movie();
    $movie->{title} = $title;
    $movie->{$type} = $type_id;

    $movie->{statusBanned}  = 0;
    $movie->{statusNew}     = 1;
    $movie->{statusShowing} = 0;
    $movie->{statusSeen}    = 0;

    $movieID = &tnmc::movies::movie::add_movie($movie);
    print "(new $movieID)";
    return &tnmc::movies::movie::get_movie($movieID);
}

1;
