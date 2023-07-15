package tnmc::pics::random;

use strict;
use warnings;

#
# module configuration
#
BEGIN {
    use tnmc::db;
    use tnmc::pics::pic;
}

#
# module routines
#

sub show_random_pic {
    my ($offset) = @_;

    my $sql = "SELECT DATE_FORMAT(NOW(), '%m%j%H%i')";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($seed) = $sth->fetchrow_array();
    $seed = int($seed / 10);
    my $picID = &get_random_pic($seed, $offset);

    my %pic;
    &tnmc::pics::pic::get_pic($picID, \%pic);

    my $pic_img = &tnmc::pics::pic::get_pic_url($picID, [ 'mode' => 'thumb' ]);
    $pic{description} &&= " ($pic{description})";
    my $date = $pic{timestamp};
    $date =~ s/\s.*//;
    my $pic_url =
      "pics/search_slide.cgi?search=date-span&search_from=$date+00%3A00&search_to=$date+23%3A59%3A59&picID=$picID";
    print qq{
        <a href="$pic_url"><img src="$pic_img" width="80" height="64" border="0" alt="$pic{title}$pic{description}"></a>
    };

}

# to-do: make this function cache stuff in the general config table
sub get_random_pic {
    my ($seed, $offset) = @_;

    my $sql = "SELECT count(*) FROM Pics WHERE typePublic >= 1";
    my $dbh = &tnmc::db::db_connect();
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($count_pics) = $sth->fetchrow_array();

    if ($seed) {
        srand($seed);
    }
    my $index;
    $offset++;
    while ($offset--) {
        $index = int(rand(999999999)) % $count_pics;
    }

    $sql = "SELECT picID FROM Pics WHERE typePublic >= 1 LIMIT $index, 1";
    my $dbh = &tnmc::db::db_connect();
    $sth = $dbh->prepare($sql);
    $sth->execute();
    my ($picID) = $sth->fetchrow_array();

    return $picID;
}

1;
