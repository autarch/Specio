package Specio::Library::Structured::Map;

use strict;
use warnings;

our $VERSION = '0.47';

use Carp qw( confess );
use List::Util ();
use Specio::Library::Builtins;
use Specio::TypeChecks qw( does_role );

my $hashref = t('HashRef');

sub parent {$hashref}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _inline {
    $hashref->inline_check( $_[1] );
}

sub _parameterization_args_builder {
    shift;
    my $args = shift;

    for my $k (qw( key value )) {
        does_role(
            $args->{$k},
            'Specio::Constraint::Role::Interface'
            )
            or confess
            qq{The "$k" parameter passed to ->parameterize must be one or more objects which do the Specio::Constraint::Role::Interface role};

        confess
            qq{The "$k" parameter passed to ->parameterize must be an inlinable constraint}
            unless $args->{$k}->can_be_inlined;
    }
    return map { $_ => $args->{$_} } qw( key value );
}

sub _name_builder {
    my $self = shift;
    my $p    = shift;

    ## no critic (Subroutines::ProtectPrivateSubs)
    return
          'Map{ '
        . $self->_name_or_anon( $p->{key} ) . ' => '
        . $self->_name_or_anon( $p->{value} ) . ' }';
}

sub _structured_inline_generator {
    shift;
    my $val  = shift;
    my %args = @_;

    my $code = <<'EOF';
(
    ( %s )
    && ( List::Util::all { %s } keys %%{ %s } )
    && ( List::Util::all { %s } values %%{ %s } )
)
EOF

    return sprintf(
        $code,
        $hashref->_inline_check($val),
        $args{key}->inline_check('$_'),
        $val,
        $args{value}->inline_check('$_'),
        $val,
    );
}

1;

# ABSTRACT: Guts of Map structured type

__END__

=for Pod::Coverage .*

=head1 DESCRIPTION

There are no user facing parts here.
