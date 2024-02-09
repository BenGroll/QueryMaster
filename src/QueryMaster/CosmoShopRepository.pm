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

sub runQuery {
    my $self = shift;
    my $query = shift or die ; #QueryMaster::Query object, not Statement

    my $db = $self->{controller};

    # These arone subroutine in query (more efficient, less readable)
    # Sub returns (statement, binding1, binding2 ...)
    # my @querydata = $query->runnable();  
    # my $statement = shift(@querydata);
    # my @bindings = @querydata;

    my $statement = $query->toSql();
    my $bindings = $query->getBindings();
    my $tablename = $self->{tablename};

    my $sth = $db->prepare($statement =~ s/TABLENAMEPLCHLDR/$tablename/r);
    $sth->execute(@$bindings);


    return $self->modelsFromStatementHandler($sth);
}

1;