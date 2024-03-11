package QueryMaster::CosmoShopRepository;

use strict;
use warnings;

use Data::Dumper;
use QueryMaster::CosmoShopModel;

sub new {
    my $class = shift;

    my @driver_names = DBI->available_drivers;
    my $driver = "mysql";
    my $database = "cs_apps";
    my $dsn = "DBI:$driver:database=$database";
    my $db = DBI->connect($dsn, 'root', 'root') or die $DBI::errstr;
    my $self = {controller => $db, tablename => "cosmoshop"};

    bless($self, $class);
}

sub columns {
    my $self = shift;

    my $db = $self->{controller};

    my $query = "SHOW COLUMNS IN " . $self->{tablename} . ";";
    my $sth = $db->prepare($query);
    $sth->execute();

    my @indexes = ();
    while (my @array = $sth->fetchrow_array) {
        my $columnname = shift(@array);
        push(@indexes, $columnname);
    }
    return \@indexes;
}

sub modelsFromStatementHandler {
    my $self = shift;
    my $sth = shift;

    my $columnnames = $self->columns();

    my @models = ();
    while (my @array = $sth->fetchrow_array) {
        my $model = QueryMaster::CosmoShopModel->new($columnnames, \@array);
        push(@models, $model);
    }
    return \@models;
}

sub all {
    my $self = shift;

    return $self->runQuery(QueryMaster::Query->all());
}

sub matchEverything {
    my $self = shift;
    my $value = shift;

    my $columns = $self->columns();

    my @queries = ();
    foreach my $column (@$columns) {
        ## Query
        my $query = QueryMaster::Query->new(concatenator0 => 0, field0 => $column, operator0 => 0, value0 => $value);
        push(@queries, $query);
    }

    my @results = ();
    foreach my $query (@queries) {
        my $resultsOfThisQuery = $self->runQuery($query);
        push(@results, @$resultsOfThisQuery);
    }



    return $self->onlyIndividuals(\@results);
}

sub onlyIndividuals {
    my $self = shift;
    my $results = shift;

    my @ids = ();
    my @individuals = ();
    foreach my $queryresult (@$results) {
        my $id = $queryresult->attributesAsHash()->{id};
        unless($id ~~ @ids) {
            push(@ids, $id);
            push(@individuals, $queryresult);
        }
    }
    return \@individuals;
}

sub allShopVersions {
    my $self = shift;

    my $models = $self->all();

    my @shopversions = ();
    foreach my $model (@$models) {
        my $shopversion = $model->attributesAsHash()->{shopversion};
        unless(grep {/$shopversion/} @shopversions) {
            push(@shopversions, $shopversion);
        }
    }

    return \@shopversions;
}

sub allShopArten {
    my $self = shift;
    
    my $models = $self->all();

    my @shoparten = ();
    foreach my $model (@$models) {
        my $shopart = $model->attributesAsHash()->{shopart};
        unless(grep {/$shopart/} @shoparten) {
            push(@shoparten, $shopart);
        }
    }

    return \@shoparten;
}

sub runQuery {
    my $self = shift;
    my $query = shift or die ; #QueryMaster::Query object, not Statement

    my $db = $self->{controller};

    my $statement = $query->toSql();
    my $bindings = $query->getBindings();
    my $tablename = $self->{tablename};


    my $sth = $db->prepare($statement =~ s/TABLENAMEPLCHLDR/$tablename/r);
    $sth->execute(@$bindings);

    $self->{lastStatement} = $sth->{Statement};

    return $self->modelsFromStatementHandler($sth);
}

1;