#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Foundation::Appify;
use HTML::Template;
use Http::Route;
use JSON;
use QueryMaster::AjaxResources;
use QueryMaster::Http::Controllers::Controller;
use QueryMaster::Query;
use QueryMaster::QueryFilter;

our $buildQueryFromParams = sub {
    my $request = shift;
    my $next = shift;
    
    my $params = \%{$request->Vars};
    my $queryparams = {};
    my $filterparams = {};
    foreach my $key (keys %$params) {
        if (index ($key, 'query') == 0) {
            my @splitkeyname = split (/\[/, $key);
            @splitkeyname = split(/\]/, @splitkeyname[1]); 
            my $querykey = @splitkeyname[0];
            $queryparams->{$querykey} = $params->{$key}
        }
        if( index ($key, 'filter') == 0) {
            my @splitkeyname = split (/\[/, $key);
            @splitkeyname = split(/\]/, @splitkeyname[1]); 
            my $filterkey = @splitkeyname[0];
            $filterparams->{$filterkey} = decode_json($params->{$key});
        }
    }

    if (scalar (keys %$queryparams) > 0) {            
        $request->{query} = QueryMaster::Query->new(%$queryparams);
    } 
    
    $request->{filter} = QueryMaster::QueryFilter->new(%$filterparams); 
    
    return &$next($request); 
};

our $executeQueryOrSearch = sub {
    my $request = shift;
    my $next = shift;

    my $shoprepo = QueryMaster::CosmoShopRepository->new();

    my $models;
    if($request->{query}) {
        $models = $shoprepo->runQuery($request->{query});
    } else {
        my $params = \%{$request->Vars};
        # die $params->{searchvalue};
        if(exists $params->{searchvalue}) {
            $models = $shoprepo->matchEverything($params->{searchvalue});
            $request->{searchstring} = $params->{searchvalue};
        } else {
            $models = $shoprepo->runQuery(QueryMaster::Query->all());
        }
    }

    $request->{models} = $models;

    return &$next($request);
};

our $buildTableAndApplyFilter = sub {
    my $request = shift;
    my $next = shift;
    
    # Apply filter to model list
    my $models = $request->{filter}->applyTo($request->{models});

    my $shoprepo = QueryMaster::CosmoShopRepository->new();
    $request->{shoprepo} = $shoprepo;
            
    my $table = QueryMaster::Components::Table->new($shoprepo->columns(), $shoprepo->{tablename}, $request->{searchstring});
    $table->fillRows($models);

    $request->{table} = $table;

    return &$next($request);
};


Http::Route::group({

    middlewares => [

        # Check if the visitor is signed in.
        'Http::Middlewares::Auth',
        
        # TODO: Implement service middleware classes instead of only using
        # TODO: closures.
        $buildQueryFromParams,
        $executeQueryOrSearch,
        $buildTableAndApplyFilter

    ],

}, sub {

    # Routes within this scope require the visitor to be signed in.

    Http::Route::group({

        # The prefix of the http route.
        prefix => '/apps/querymaster',

        # The prefix of the route name.
        as => 'apps.querymaster.',

    }, sub {
        
        Http::Route::get('/', sub {

            my $request = shift;

            

            # TODO: Implement default controller routing instead of creating
            # TODO: an instance of the controller class.

            return QueryMaster::Http::Controllers::Controller->new()->welcome(
                $request,
            );

        }),
        # Not currently in use, ajax-duplicate of '/'
        # Used to fetch only a table for a query, not the whole site
        Http::Route::get('/query', sub {

            my $request = shift;


            return $request->{table}->output();
        }),
        Http::Route::get('/search', sub {

            my $request = shift;
            
            my $models = $request->{filter}->applyTo($request->{models});

            my $table = QueryMaster::Components::Table->new($request->{shoprepo}->columns(), $request->{shoprepo}->{tablename}, $request->{searchstring});
            $table->fillRows($models);

            return $table->output();
        }),
        # Used to get raw json data via ajax. Other routes return HTML
        # Example call: '/ajax?resource=allShopVersions'
        Http::Route::get('/ajax', sub {

            my $request = shift;

            my $queryparams = \%{$request->Vars};

            my $resource = $queryparams->{resource};

            my $ajaxresources = QueryMaster::AjaxResources->new();

            return $ajaxresources->$resource();
        }),

        # Middleware to get the html snippets for ajax
        Http::Route::get('/htmlsnippets', sub {

            my $request = shift;

            # TODO: Implement default controller routing instead of creating
            # TODO: an instance of the controller class.

            my $params = \%{$request->Vars};

            my $templatename = $params->{template};


            my $templatepath = join ('/', splice(@{[split(/\//, __FILE__)]},
                                0, 
                                scalar @{[split(/\//, __FILE__)]} -1)) . "/";
            $templatepath .= "../templates/snippets/$templatename.tmpl";
            my $template = HTML::Template->new(filename => $templatepath);

            # my $params = \%{$request->Vars};

            # my $lookuptable = QueryMaster::Query->lookupTable();
            # my $operator = $lookuptable->{operator}->{$params->{operator}};

            # $template->param(
            #     idx  =>     $params->{idx},
            #     field => $params->{field},
            #     operator => $operator,
            #     value => $params->{value},
            # );

            return $template->output();
        }),

        Http::Route::get('/messages/{id}', sub {

            my $request = shift;

            return QueryMaster::Http::Controllers::Controller->new()->showMessage(
                $request,
            );

        }),

        Http::Route::group({

            # The prefix of the http route.
            prefix => '/admin',

            # The prefix of the route name.
            as => 'admin.',

            middlewares => [

                sub {
                    my $request = shift;
                    my $next = shift;
                    
                    unless (user()->isQueryMasterAdmin()) {
                        abort('Unauthorized.', 403);
                    }

                    return &$next($request); 
                },

            ],

        }, sub {
            
            Http::Route::get('/', sub {

                my $request = shift;

                return QueryMaster::Http::Controllers::Controller->new()->dashboard(
                    $request,
                );

            }),

        });
        

    });


});