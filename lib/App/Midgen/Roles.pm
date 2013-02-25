package App::Midgen::Roles;

use v5.10;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);

our $VERSION = '0.12';
use English qw( -no_match_vars ); # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Carp;

#######
# cmd line options
#######

has 'base_parent' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'core' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'debug' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'mojo' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'noisy_children' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'output_format' => (
	is  => 'ro',
	isa => sub {
		my $format = { dsl => 1, mi => 1, build => 1, dzil => 1, dist => 1 };
		croak 'not a supported output format' unless defined $format->{ $_[0] };
		return;
	},
	default => sub {
		'dsl';
	},
	required => 1,
);

has 'padre' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'verbose' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

has 'twins' => (
	is  => 'ro',
	isa => sub {
		croak "$_[0] this is not a Bool"
			unless is_Bool( $_[0] );
	},
	default => sub {
		0;
	},
	required => 1,
);

#######
# some encapsulated attributes
#######

has 'package_name' => (
	is  => 'rw',
	isa => Str,
);

has 'package_names' => (
	is  => 'rw',
	isa => ArrayRef,
);

has 'requires' => (
	is  => 'rw',
	isa => HashRef,
);

has 'test_requires' => (
	is  => 'rw',
	isa => HashRef,
);

has 'recommends' => (
	is  => 'rw',
	isa => HashRef,
);

has 'found_twins' => (
	is      => 'rw',
	isa     => Bool,
	lazy    => 1,
	default => sub {
		0;
	},
	required => 1,
);


1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles - Package Options and Attributes used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Roles version: 0.12

=head1 METHODS

=head2 OPTIONS

=over 4

=item * base_parent

=item * core

=item * debug

=item * mojo

=item * noisy_children

=item * output_format

=item * padre

=item * twins

=item * verbose

=back

for more info see L<midgen>

=head2 ACCESSORS

=over 4

=item * found_twins

Used as a flag to re-run noisy children after descovery of twins

=item * package_name

Our best guess as to this packages name

=item * package_names

Some package names we found along the way

=item * requires

Some where to store required modules and version info in

=item * test_requires

Some where to store test_required modules and version info in

=item * recommends

Some where to store recommend modules and version info in

=back

=head1 SEE ALSO

L<App::Midgen>,

=head1 AUTHOR

See L<App::Midgen>

=head2 CONTRIBUTORS

See L<App::Midgen>

=head1 COPYRIGHT

See L<App::Midgen>

=head1 LICENSE

See L<App::Midgen>

=cut