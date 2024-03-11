package QueryMaster::QueryFilter;

use strict;
use warnings;

use Data::Dumper;

sub new {
    my $class = shift;
    
    my (%params) = @_;
    
    bless(\%params, $class);
}

sub applyTo {
    my $self = shift;
    my $models = shift || ();

    my @filtered = ();
    foreach my $model (@$models) {
        my $allowed = 1;
        my $attributes = $model->attributesAsHash();
        foreach my $filter (keys %$self) {
            my @allowedvalues = $self->{$filter};
            unless($attributes->{$filter} ~~ @allowedvalues) {
                $allowed = 0;
                last;
            }
        }
        if($allowed) {push(@filtered, $model);}
    }
    return \@filtered;
}
1;