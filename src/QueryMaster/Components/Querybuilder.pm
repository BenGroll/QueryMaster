package QueryMaster::Components::Querybuilder;

use strict;
use warnings;

use Data::Dumper;
use QueryMaster::Query;
use JSON;

sub new {
    my $class = shift;
    my $lastStatement = shift;
    

    my $templatesfolder = getFolder() . "../../../templates";

    my @emptyarray = ();

    my $self = {
        templatesfolder => $templatesfolder,
        template => HTML::Template->new(filename => "$templatesfolder/components/querybuilder.tmpl"),
        lastStatement => $lastStatement,
        options => \@emptyarray  
    };
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

    # bypass
    return $self;

    $self->{template}->param(
        operators => $self->dropdownoperators(),
        fields => $self->dropdownfields($fields)
    );
    return $self;
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

    my @emptyarray = ();

    my $options = $self->{options};

    my $totalfiltercheckboxesdata = {};

    my @optionsdata = ();
    foreach my $option (@$options) {
        my $optionname = $option->[0]->{'parametername'};
        my $thisFilterActiveInPreviousSite = exists $filter->{$optionname} ? 'checked' : '';

        my $title = $option->[0]->{parametername};
        my $template = HTML::Template->new(filename => $self->{templatesfolder} . "/snippets/collapsible.tmpl");
        my @dataforjson = ();
        my @thisparamcheckboxesdata = ();
        foreach my $checkbox (@$option) {
            my $selected = 0;
            if($thisFilterActiveInPreviousSite && ($checkbox->{boxvalue} ~~ $filter->{$optionname})) {
                $selected = "selected";
            }
            my $data = {
                optionvalue => $checkbox->{boxvalue},
                selected => $selected
            };
            push(@thisparamcheckboxesdata, $data);
            push(@dataforjson, $checkbox->{boxvalue});
        }
        $totalfiltercheckboxesdata->{$title} = \@dataforjson;
        $template->param(
            parametername => $title,
            options => \@thisparamcheckboxesdata,
            # filterchecked => $thisFilterActiveInPreviousSite
        );
        push(@optionsdata, {option => $template->output()});
    }
    

    $self->{template}->param(
        # ranstatement => $self->{ranstatement},
        optionsCheckboxes => \@optionsdata,
        filtercheckboxesdata => encode_json($totalfiltercheckboxesdata)
    );

    return $self->{template}->output();
}

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}

1;