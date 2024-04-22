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

    app()->pushToStack('styles', {path => "$sp/styles/global.css", id => "querymaster:global"});
    app()->pushToStack('styles', {path => "$sp/styles/layout.css", id => "querymaster:layout"});
    app()->pushToStack('styles', {path => "$sp/styles/loading.css", id => "querymaster:loading"});
    app()->pushToStack('styles', {path => "$sp/styles/querybuilder.css", id => "querymaster:querybuilder"});
    app()->pushToStack('styles', {path => "$sp/styles/table.css", id => "querymaster:table"});
    app()->pushToStack('scripts', "$sp/scripts/view.js");
    app()->pushToStack('scripts', "$sp/scripts/query.js");

    my $conf = app()->getServiceConfig('querymaster', 'app.pl');

    my $query = $request->{fullStatement} ;

    my $shoprepo = QueryMaster::CosmoShopRepository->new();
    
    my $models = $shoprepo->runStatement($query, $request->{bindings});
    # Create table outline and carry over the last query's parameters
    my $table = QueryMaster::Components::Table->new(
        columnnames => $shoprepo->columns(),
        tablename => $shoprepo->{tablename},
        lastsearch => $request->{searchvalue},
        orderedBy => $request->{params}->{sortBy},
        order => $request->{params}->{sortOrder},
        limit => $request->{params}->{limit},
        page => $request->{params}->{page});

    $table->fillRows($models);
    
    #Query Builder
    my $querybuilder = QueryMaster::Components::Querybuilder->new($shoprepo->{lastStatement}, $conf->{filterColumns});

    # Build and fill Master Layout
    my $templatesfolder = getFolder() . "../../../../templates";
    my $layout = HTML::Template->new(filename => $templatesfolder . "/layouts/master.tmpl", vanguard_compatibility_mode => 1);
    $layout->param(
        querybuilder => $querybuilder->output($conf->{filterColumns}),
        queriedtable => $table->output()
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
