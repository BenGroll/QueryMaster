package QueryMaster::Components::Row;

use strict;
use warnings;

use Data::Dumper;

use HTML::Template;
use QueryMaster::CosmoShopModel;

my $templatesfolder = getFolder() . "../../../templates";

sub new {
    my $class = shift;
    my $self = {template => HTML::Template->new(filename => "$templatesfolder/components/tablerow.tmpl")};

    bless($self, $class);
}

sub fill {
    my $self = shift;
    my $model = shift or die "No Model supplied for row";

    my $values = $model->{values};
    my @data = ();
    foreach my $value (@$values) {
        push(@data, {CellValue => $value});
    }
    $self->{template}->param(Cells => \@data);
    return $self;
}

sub output {
    my $self = shift;

    return $self->{template}->output();
}

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}
1;