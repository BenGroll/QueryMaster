package QueryMaster::Components::Querybuilder;

use strict;
use warnings;

use Data::Dumper;
use QueryMaster::Query;

sub new {
    my $class = shift;
    

    my $templatesfolder = getFolder() . "../../../templates";

    my $self = {template => HTML::Template->new(filename => "$templatesfolder/components/querybuilder.tmpl")};
    bless($self, $class);
}

sub dropdownoperators {
    my $self = shift;
    
    my $lookuptable = QueryMaster::Query->lookupTable();
    my $operators = $lookuptable->{operator};
    
    my @operatorsdata = ();
    foreach my $operatorid (keys %$operators) {
        push(@operatorsdata, {
            operatorid => $operatorid,
            operator => $operators->{$operatorid}
        });
    }
    # die Dumper($operators->{0});
    # die Dumper(@operatorsdata);
    return \@operatorsdata;
}

sub dropdownfields {
    my $self = shift;
    my $fields = shift or die "No fields provided";

    my @fieldsdata = ();
    foreach my $field (@$fields) {
        push(@fieldsdata, {fieldname => $field});
    }
    return \@fieldsdata;
}

sub fillDropdowns {
    my $self = shift;
    my $fields = shift;

    $self->{template}->param(
        operators => $self->dropdownoperators(),
        fields => $self->dropdownfields($fields)
    );
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