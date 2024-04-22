#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Foundation::Appify;
use HTML::Template;
use Http::Route;
use JSON;
use QueryMaster::Http::Controllers::Controller;

# Middlewares
sub queryInit {
    my $request = shift;
    my $next = shift;

    $request->{params} = \%{$request->Vars};

    $request->{fullStatement} = "SELECT * FROM cosmoshop";
    my @bindings = ();
    $request->{bindings} = \@bindings;

    return &$next($request);
};

sub queryAttachSearchValue {
    my $request = shift;
    my $next = shift;

    my $searchvalue = $request->{params}->{searchvalue};
    if (!$searchvalue || $searchvalue eq '') {
        return &$next($request);
    }
    my $shoprepo = QueryMaster::CosmoShopRepository->new();
    my $columnnames = $shoprepo->columns();

    my $query = $request->{fullStatement};

    if ($request->{params}->{searchvalue}) {
        $query .= " WHERE (";
        my $i = 0;
        foreach my $columnname (@$columnnames) {
            my $modifiedsearchvalue = "%". $request->{params}->{searchvalue} . "%";
            $query  .= $i == 0 ? $columnname . ' LIKE "' . $modifiedsearchvalue. '"'
                            : " OR " . $columnname . ' LIKE "' . $modifiedsearchvalue. '"';
            # push(@bindings, "%"."$searchvalue"."%");
            $i++;
        }   
        $query  .= " )";
    }
    $request->{fullStatement} = $query;
    return &$next($request);
};

sub queryAttachFilters {
    my $request = shift;
    my $next = shift;

    my $query = $request->{fullStatement};
    my $params = $request->{params};
    my $bindings = $request->{bindings};
    # Filters (AND)
    my $filterparams = {};
    foreach my $key (keys %$params) {
        if( index ($key, 'filter') == 0) {
            my @splitkeyname = split (/\[/, $key);
            @splitkeyname = split(/\]/, @splitkeyname[1]); 
            my $filterkey = @splitkeyname[0];
            $filterparams->{$filterkey} = $params->{$key};
        }
    }
    if(scalar keys(%$filterparams) > 0) {
        if(!$request->{params}->{searchvalue} || $request->{params}->{searchvalue} eq '') {
            $query .= " WHERE (";
        } else {
            $query .= " AND (";
        }
        my $i = 0;
        foreach my $filterkey (keys %$filterparams) {
            my $realarray = decode_json($filterparams->{$filterkey});
            # die Dumper($realarray);
            my $array = "(";
            foreach my $value (@$realarray) {
                push (@$bindings, qq "$value");
                if(substr($array, -1) eq "(") {
                    $array .= " ? ";
                } else {
                    $array .= ", ? ";
                }
                
            }

            $array .= ")";
            $query .= $i == 0 
                    ? " $filterkey IN $array " 
                    : "AND $filterkey IN $array ";
            $i++;
        };
        $query .= ")";
    }

    $request->{fullStatement} = $query;
    return &$next($request);
};


sub querySortAndLimit {
    my $request = shift;
    my $next = shift;
    
    my $params = $request->{params};
    my $query = $request->{fullStatement};
    my $bindings = $request->{bindings};

    if($params->{sortBy} && $params->{sortOrder}) {
        $query .= " ORDER BY " . $params->{sortBy};
        if($params->{sortOrder} eq "ascending") {
            $query .= " ASC";
        } else {
            $query .= " DESC";
        }
    }
    if($params->{limit}) {
        push(@$bindings, 0 + $params->{limit});
        $query .= " LIMIT ?";
        if($params->{page}) {
            push(@$bindings, ($params->{limit} * ($params->{page} - 1)));
            $query .= " OFFSET ?";
        }
    }
    
    $query .= ";";
    $request->{fullStatement} = $query;

    return &$next($request);
};




Http::Route::group({

    middlewares => [

        # Check if the visitor is signed in.
        'Http::Middlewares::Auth',
        
        # TODO: Implement service middleware classes instead of only using
        # TODO: closures.
        \&queryInit,
        \&queryAttachSearchValue,
        \&queryAttachFilters,
        \&querySortAndLimit,
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
        ## Only get a new Table, dont refresh page
        Http::Route::get('/search', sub {

            my $request = shift;
            my $statement = $request->{fullStatement};
            my $shoprepo = QueryMaster::CosmoShopRepository->new();
            my $models = $shoprepo->runStatement($statement, $request->{bindings});

            my $table = QueryMaster::Components::Table->new(
                columnnames => $shoprepo->columns(),
                tablename => $shoprepo->{tablename},
                lastsearch => $request->{searchvalue},
                orderedBy => $request->{params}->{sortBy},
                order => $request->{params}->{sortOrder},
                limit => $request->{params}->{limit},
                page => $request->{params}->{page});
            $table->fillRows($models);

            return $table->output();
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