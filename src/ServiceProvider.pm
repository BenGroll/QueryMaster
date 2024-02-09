package QueryMaster::ServiceProvider;

use parent qw(
    Foundation::ServiceProvider
);

use strict;
use warnings;

use Foundation::Appify;

# The parent service provider handles the default behaviour.
# Add additional functionality in here.

sub register {
    my $self = shift;

    $self->SUPER::register();

    # Extend the user model with the method "isQueryMasterAdmin". This method can be
    # called without it having to actually exist. Instead the closure below will
    # be executed.
    macro('Models::User', 'isQueryMasterAdmin', sub {
        return 0;
    });

    # Catch the event in case a password is about to be validated.
    app()->subscribe('Foundation::Events::ValidatingPassword', sub {

        my $event = shift;

        unless ($event->password() eq $event->passwordConfirmation()) {

            # Example of what to do in case password mismatch:
            #
            # abort('Wow, what a password.', 422);

        }

        return;

    });

    # Catch the event in case a user signed up successfully.
    app()->subscribe('Foundation::Events::Users::Registered', sub {

        my $event = shift;

        my $id = $event->user()->id();

        # Do something with or to the user like sending an email.

        return;

    });

    # Catch the event in case a user signed in successfully.
    app()->subscribe('Foundation::Events::Users::Authenticated', sub {

        my $event = shift;

        my $id = $event->user()->id();

        # Do something with or to the user like tracking their sign in count.

        return;

    });
}

# Alter the name of the service displayed within the service bar.
sub gateway {
    my $self = shift;

    my $gateway = $self->SUPER::gateway();

    $gateway->{name} = lc $gateway->{name};

    return $gateway;
}

1;
