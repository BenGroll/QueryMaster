package QueryMaster::Components::Querybuilder;

use strict;
use warnings;

use Data::Dumper;
use JSON;

sub new {
    my $class = shift;
    my $lastStatement = shift;    

    my @emptyarray = ();

    my $self = {
        templatesfolder => getFolder() . "../../../templates",
        template => HTML::Template->new(filename => getFolder() . "../../../templates/components/querybuilder.tmpl", vanguard_compatibility_mode => 1),
        lastStatement => $lastStatement,
        options => \@emptyarray,
    };
    bless($self, $class);
}

sub addOptionRow {
    my $self = shift;
    my $title = shift;
    my $values = shift;

    my @boxdata = ();
    foreach my $value (@$values) {
        my $data = {boxvalue => $value, parametername => $title};
        push(@boxdata, $data);
    }
    my $options = $self->{options};
    push(@$options, \@boxdata);
    $self->{options} = $options;
    return $self;
}

sub output {
    my $self = shift;
    my $filter = shift;

    my $repo = QueryMaster::CosmoShopRepository->new();
    foreach my $column (@$filter) {
        my $models = $repo->allFromColumn($column);
        if(scalar @$models > 0) {
            $self->addOptionRow($column, $models);
        }
    }
    my $options = $self->{options};
    my $optionsCheckBoxes = ();
    my @paramnames = ();
    foreach my $option (@$options) {
        my $data = ();
        foreach my $value (@$option) {
            push(@$data, {optionvalue => $value->{boxvalue}})
        }
        push(@paramnames, $option->[0]->{parametername});

        my $template = HTML::Template->new(filename => $self->{templatesfolder} . "/snippets/collapsible.tmpl" , vanguard_compatibility_mode => 1);
    
        $template->param(
            "parametername" => $option->[0]->{parametername},
            "options" => $data
        );
        push(@$optionsCheckBoxes, {option => $template->output()});
    }
    $self->{template}->param(
        optionsCheckBoxes => $optionsCheckBoxes,
        filters => encode_json(\@paramnames)
    );

    return $self->{template}->output();
}

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}

1;
