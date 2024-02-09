package QueryMaster::Components::Table;

use strict;
use warnings;

use Data::Dumper;

use QueryMaster::Components::Row;

my $templatesfolder = getFolder() . "../../../templates";

sub new {
    my $class = shift;
    my $columnnames = shift or die "No Columnname-List specified;";
    my $tablename = shift or die "No Tablename specified";
    my $ranstatement = shift;

    my $self = {
        template => HTML::Template->new(filename => "$templatesfolder/components/table.tmpl"),
        columnnames => $columnnames,
        statement => $ranstatement,
        tablename => $tablename
        };
    bless($self, $class);
}

sub fillRows {
    my $self = shift;
    my $models = shift or die "No List of Models provided";

    my @rowsData = ();
    foreach my $model (@$models) {
        my $row = QueryMaster::Components::Row->new();
        $row->fill($model);
        my $rowData = {row => $row->output()};
        push(@rowsData, $rowData);
    }
    $self->{template}->param(
        rows => \@rowsData,
        resultcount => scalar @rowsData
    );
    return $self;
}

sub output {
    my $self = shift;

    $self->{template}->param(
        headers => $self->headers(),
        ranstatement => $self->{statement},
        tablename => $self->{tablename},
    );
    return $self->{template}->output();
}

sub headers {
    my $self = shift;

    my $columns = $self->{columnnames};

    my @headers = ();
    foreach my $column (@$columns) {
        push(@headers, {HName => $column});
    }
    
    return \@headers;
}

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}
1;