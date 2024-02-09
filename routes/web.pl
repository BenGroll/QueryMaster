#!/usr/bin/perl

use strict;
use warnings;

use Http::Route;
use HTML::Template;
use QueryMaster::Http::Controllers::Controller;
use QueryMaster::Query;
use Foundation::Appify;

Http::Route::group({

    middlewares => [

        # Check if the visitor is signed in.
        'Http::Middlewares::Auth',
        
        # TODO: Implement service middleware classes instead of only using
        # TODO: closures.
        sub {
            my $request = shift;
            my $next = shift;

            my $params = \%{$request->Vars};
            my $queryparams = {};
            foreach my $key (keys %$params) {
                if (index ($key, 'query') == 0) {
                    my @splitkeyname = split (/\[/, $key);
                    @splitkeyname = split(/\]/, @splitkeyname[1]); 
                    my $querykey = @splitkeyname[0];
                    $queryparams->{$querykey} = $params->{$key}
                }
            }
            if (scalar (keys %$queryparams) > 0) {
                $request->{query} = QueryMaster::Query->new(%$queryparams);
            } else {
                $request->{query} = QueryMaster::Query->all();
            }
            
            return &$next($request); 
        }

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
        Http::Route::get('/query', sub {

            my $request = shift;

            my $queryparams = \%{$request->Vars};
            
            if (scalar (keys %$queryparams) > 0) {
                $request->{query} = QueryMaster::Query->new(%$queryparams);
            } else {
                $request->{query} = QueryMaster::Query->all();
            }
            my $shoprepo = QueryMaster::CosmoShopRepository->new();
            
            my $models = $shoprepo->runQuery($request->{query});

            my $table = QueryMaster::Components::Table->new($shoprepo->columns(), $shoprepo->{tablename}, $request->{query}->fullStatement($shoprepo->{tablename}));
            $table->fillRows($models);

            return $table->output();
        }),
        # Middleware to get the html snippets for ajax
        Http::Route::get('/htmlsnippets', sub {

            my $request = shift;

            # TODO: Implement default controller routing instead of creating
            # TODO: an instance of the controller class.

            my $templatepath = join ('/', splice(@{[split(/\//, __FILE__)]},
                                0, 
                                scalar @{[split(/\//, __FILE__)]} -1)) . "/";
            $templatepath .= "../templates/snippets/singlefilter.tmpl";
            my $template = HTML::Template->new(filename => $templatepath);

            my $params = \%{$request->Vars};

            my $lookuptable = QueryMaster::Query->lookupTable();
            my $operator = $lookuptable->{operator}->{$params->{operator}};
            my $concatenators = $lookuptable->{concatenator};

            my @concatenatorsdata = ();
            foreach my $concat (sort (keys %$concatenators)) {
                push(@concatenatorsdata, {concatenatorid => $concat, concatenator => $concatenators->{$concat}});
            }
            # Remove "Where" since it isnt needed from the first filter onwards
            shift(@concatenatorsdata);
            # die Dumper(@concatenatorsdata);

            $template->param(
                idx  =>     $params->{idx},
                field => $params->{field},
                operator => $operator,
                value => $params->{value},
                concatenators => \@concatenatorsdata

            );

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
