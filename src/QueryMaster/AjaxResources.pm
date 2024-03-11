package QueryMaster::AjaxResources;

use strict;
use warnings;

use JSON;
use Data::Dumper;
use QueryMaster::CosmoShopRepository;


sub new {
    my $class = shift;

    bless({}, $class);
}

sub shopversions {
    my $self = shift;

    my $repo = QueryMaster::CosmoShopRepository->new();

    my $shopversions = $repo->allShopVersions();

    return encode_json($shopversions);
}

sub shoparten {
    my $self = shift;

    my $repo = QueryMaster::CosmoShopRepository->new();

    my $shoparten = $repo->allShopArten();

    return encode_json($shoparten);
}

1;