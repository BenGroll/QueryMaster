package QueryMaster::Http::Controllers::Controller;

use strict;
use warnings;

use Data::Dumper;
# Load src/QueryMaster directory to look for Modules
use lib join ('/', splice(@{[split(/\//, __FILE__)]}, 0, scalar @{[split(/\//, __FILE__)]} -1)) . '/../../';
use Foundation::Appify;
use HTML::Template;

use QueryMaster::Components::Table;
use QueryMaster::Components::Querybuilder;
use QueryMaster::CosmoShopRepository;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub welcome {
    my $self = shift;
    my $request = shift;

    app()->pushToStack('scripts', servicePath('querymaster') . '/script.js');

    my $query = $request->{query};
    my $shoprepo = QueryMaster::CosmoShopRepository->new();

    # Unqueried Table on the left
    my $allModels = $shoprepo->all();
    my $fulltable = QueryMaster::Components::Table->new($shoprepo->columns, "Full Table", "SELECT * FROM " . $shoprepo->{tablename} . ";");
    $fulltable->fillRows($allModels);

    # # Queried Table on the left
    my $queriedtable = "Start a query to show results!";
    if($query) {
        my $queryresults = $shoprepo->runQuery($query);
        $queriedtable = QueryMaster::Components::Table->new($shoprepo->columns, "Queried Table", $query->fullStatement($shoprepo->{tablename}));
        $queriedtable->fillRows($queryresults);
        $queriedtable = $queriedtable->output();
    }

    my $templatesfolder = getFolder() . "../../../../templates";

    #Query Builder
    my $querybuilder = QueryMaster::Components::Querybuilder->new();
    $querybuilder->dropdownoperators();
    $querybuilder->fillDropdowns($shoprepo->columns());

    # Build and fill Master Layout
    my $layout = HTML::Template->new(filename => $templatesfolder . "/layouts/master.tmpl");
    $layout->param(
        querybuilder => $querybuilder->output(),
        unqueriedtable => $fulltable->output(),
        queriedtable => $queriedtable
    );

    my $template = &_::template('querymaster::welcome', {
        email => user()->get('email'),
        content => $layout->output(),
    });
    return $template->output();
}

sub dashboard {
    my $self = shift;
    my $request = shift;

    # TODO: Do something useful.

    app()->pushToStack('scripts', servicePath('querymaster') . '/script.js');

    my $template = &_::template('querymaster::dashboard', {
        #
    });

    return $template->output();
}

sub showMessage {
    my $self = shift;
    my $request = shift;

    # TODO: Do something useful.

    return $self->welcome($request);
}

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}
1;
