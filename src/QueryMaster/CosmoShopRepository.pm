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

    my $query = "SHOW COLUMNS FROM cosmoshop;" ;
    my $sth = $db->prepare($query);
    $sth->execute();

    my @indexes = ();
    while (my @column = $sth->fetchrow_array) {
        push(@indexes, shift(@column));
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

    return $self->runStatement("SELECT * FROM cosmoshop;");
}

sub allFromColumn {
    my $self = shift;
    my $columnname = shift or die "no column name";
    return $self->runStatementNoModels("SELECT DISTINCT $columnname FROM cosmoshop");
}

sub runStatementNoModels {
    my $self = shift;
    my $query = shift;
    my $bindings = shift;

    my $db = $self->{controller};
    my $tablename = $self->{tablename};
    my $sth = $db->prepare($query);
    $sth->execute();

    my @results = ();
    while (my @array = $sth->fetchrow_array) {
        push(@results, shift (@array));
    }
    
    return \@results;
}

sub runStatement {
    my $self = shift;
    my $query = shift;
    my $bindings = shift;


    my $db = $self->{controller};
    my $tablename = $self->{tablename};
    my $sth = $db->prepare($query);
    
    $sth->execute(@$bindings) or die $DBI::errstr;

    # die Dumper($sth->fetchrow_array);

    return $self->modelsFromStatementHandler($sth);

}


1;