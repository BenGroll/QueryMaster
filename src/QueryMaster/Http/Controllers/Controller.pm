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

    my $sp = servicePath('querymaster');

    app()->pushToStack('scripts', "$sp/scripts/state.js");
    app()->pushToStack('scripts', "$sp/scripts/view.js");
    app()->pushToStack('scripts', "$sp/scripts/query.js");
    app()->pushToStack('styles', {path => "$sp/styles/style1.css", id => "querymaster:style1"});
    app()->pushToStack('styles', {path => "$sp/styles/style2.css", id => "querymaster:style2"});
    my $query = $request->{query};
    my $shoprepo = QueryMaster::CosmoShopRepository->new();
    # # Queried Table on the left
    my $queriedtable = $request->{table} || "Start a query to show results!";

    my $templatesfolder = getFolder() . "../../../../templates";

    #Query Builder
    my $querybuilder = QueryMaster::Components::Querybuilder->new($shoprepo->{lastStatement});
    $querybuilder->dropdownoperators();
    $querybuilder->fillDropdowns($shoprepo->columns());
    # Fill QueryBuilder filters
    $querybuilder->addOptionRow("shopart", $shoprepo->allShopArten());
    $querybuilder->addOptionRow("shopversion", $shoprepo->allShopVersions());

    # Build and fill Master Layout
    my $layout = HTML::Template->new(filename => $templatesfolder . "/layouts/master.tmpl");
    $layout->param(
        querybuilder => $querybuilder->output($request->{filter}),
        queriedtable => $queriedtable->output()
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
