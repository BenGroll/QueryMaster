package QueryMaster::Components::Table;

use strict;
use warnings;

use Data::Dumper;

use QueryMaster::Components::Row;

my $templatesfolder = getFolder() . "../../../templates";

sub new {
    my $class = shift;

    my (%args) = @_;

    $args{template} = HTML::Template->new(filename => "$templatesfolder/components/table.tmpl", vanguard_compatibility_mode => 1);

    bless(\%args, $class);
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
        resultcount => scalar @rowsData,
        pagemaximumreached => scalar @rowsData < $self->{limit}
    );
    return $self;
}

sub output {
    my $self = shift;
    $self->{template}->param(
        headers => $self->headers(),
        tablename => "Table: " . $self->{tablename},
        lastSortName => $self->{orderedBy},
        lastSortOrder => $self->{order},
        tablepage => $self->{page},
        pageminimumreached => $self->{page} == 1 || $self->{page} < 1,
        limit => $self->{limit}
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