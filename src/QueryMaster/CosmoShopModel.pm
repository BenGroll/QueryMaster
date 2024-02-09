package QueryMaster::CosmoShopModel;

sub new {
    my $class = shift;
    my $attributes = shift or die "No Attributes given for Shopmodel!";
    my $values = shift or die "No Values given for Shopmodel!";

    my $self = {attributes => $attributes, values => $values};
    bless($self, $class);

    return $self;
}

sub attributesAsHash {
    my $self = shift;

    my $attributes = $self->{attributes};

    my $hash = {};
    for(my $i = 0; $i < scalar @$attributes; $i++) {
        $hash->{$attributes->[$i]} = $self->{values}->[$i];
    }
    return $hash;
}

1;