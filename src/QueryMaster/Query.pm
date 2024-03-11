package QueryMaster::Query;

use strict;
use warnings;

use Data::Dumper;

sub new {
    my $class = shift;

    my (%params) = @_;
    
    bless(\%params, $class);
}

sub all {
    my $class = shift;
    return $class->new();
}

sub completeConditionCount {
    my $self = shift;    

    my %params = %$self;

    my $amountOfConditions = 0;
    my $threshold = 10;

    my @paramnames = keys %params;
    while($amountOfConditions < $threshold) {
        my $index = $amountOfConditions;
        my $concatenator = "concatenator$index";
        my $field = "field$index";
        my $operator = "operator$index";
        my $value ="value$index";
        if(
            grep (/^$concatenator/, @paramnames)
            && grep( /^$field/, @paramnames)
            && grep( /^$operator/, @paramnames)
            && grep( /^$value/, @paramnames)
        ){
            $amountOfConditions += 1;
        } else {
            last;
        }
    }
    return $amountOfConditions;

}

sub lookupTable {
    return {
        distinct => {
            #default
            0 => "*",
            1 => "DISTINCT",
        },
        concatenator => {
            #default
            0 => "WHERE",
            1 => "AND",
            2 => "OR",
        },
        operator => {
            #default
            0 => "LIKE",
            1 => "<",
            2 => ">"
        }
    };
}

## Lookup secure values for distinct, concatenators and operators
sub lookupSecureKeyword {
    my $self = shift;


    # Position: 'Distinct' (only once), 'concatenator' or 'operator'
    my $position = shift or die "No name given for lookup";
    my $value = shift || "0";

    my $lookuptable = $self->lookupTable();


    unless(grep(/^$position/), keys %$lookuptable) {
        die "invalid position";
    }
    my $dataForPosition = $lookuptable->{$position};
    return $dataForPosition->{$value};

}

# Sample query to copy: ?concatenator0=0&field0=id&operator0=1&value0=1
# Query for refresh: ?query[concatenator0]=0&query[field0]=id&query[operator0]=1&query[value0]=1
sub toSql {
    my $self = shift;

    my $conditions = $self->completeConditionCount();
    
    my $statement = "SELECT ";
    # DISTINCT WORKS DIFFERENT THAN I THOUGHT; THIS DOES NOTHING
    $statement .= $self->lookupSecureKeyword("distinct", $self->{distinct});
    $statement .= " FROM TABLENAMEPLCHLDR ";
    for(my $i = 0; $i < $conditions; $i++) {
        $statement .= $self->lookupSecureKeyword("concatenator", $self->{"concatenator$i"}) . " ";
        $statement .= $self->{"field$i"} . " ";
        my $operator = $self->lookupSecureKeyword("operator", $self->{"operator$i"}) . " "; 
        $statement .= $operator;
        $statement .= "? "; # Dont use actual value because its a binding
    }
    chop($statement);
    return "$statement;";
}

sub getBindings {
    my $self = shift;

    my $conditions = $self->completeConditionCount();

    my @bindings = ();
    for (my $i = 0; $i < $conditions; $i++) {
        if($self->{"operator$i"} == 0) {
            $self->{"value$i"} = "%" . $self->{"value$i"} . "%";
            push(@bindings, $self->{"value$i"});
            
        } else {
            push(@bindings, $self->{"value$i"});
        }
    }
    return \@bindings;
}

1;