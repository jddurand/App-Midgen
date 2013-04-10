package App::Midgen::Roles;

use v5.10;
use Moo::Role;
use MooX::Types::MooseLike::Base qw(:all);

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.21_01';
use Carp;

#######
# cmd line options
#######

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

has 'dual_life' => (
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

has 'experimental' => (
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

has 'format' => (
	is  => 'ro',
	isa => sub {
		my $format = { dsl => 1, mi => 1, build => 1, dzil => 1, dist => 1, cpanfile => 1, };
		croak 'not a supported output format' unless defined $format->{ $_[0] };
		return;
	},
	default  => 'dsl',
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

has 'zero' => (
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

has 'quiet' => (
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

has 'numify' => (
	is   => 'rw',
	isa  => Bool,
	default => sub { 
		0;
	},
	lazy => 1,
);

#has 'distribution_name' => (
#	is   => 'rw',
#	isa  => Str,
#	lazy => 1,
#);

has 'package_names' => (
	is   => 'rw',
	isa  => ArrayRef,
	default => sub { [] },
	lazy => 1,
);

#has 'package_requires' => (
#	is   => 'rw',
#	isa  => HashRef,
#	default => sub { {} },
#	lazy => 1,
#);

#has 'test_requires' => (
#	is   => 'rw',
#	isa  => HashRef,
#	lazy => 1,
#);

#has 'modules' => (
#	is   => 'rw',
#	isa  => HashRef,
#	lazy => 1,
#);

#has 'recommends' => (
#	is   => 'rw',
#	isa  => HashRef,
#	lazy => 1,
#);

#has 'test_develop' => (
#	is   => 'rw',
#	isa  => HashRef,
#	lazy => 1,
#);

has 'found_twins' => (
	is      => 'rw',
	isa     => Bool,
	lazy    => 1,
	default => sub {
		0;
	},
);

has 'mcpan' => (
	is   => 'rw',
	isa  => InstanceOf [ 'MetaCPAN::API', ],
	lazy => 1,
	builder => '_build_mcpan',
	handles => [ qw( module release ) ],
);

sub _build_mcpan {
	my $self = shift;
	MetaCPAN::API->new();
}

has 'scanner' => (
	is   => 'rw',
	isa  => InstanceOf [ 'Perl::PrereqScanner', ],
	lazy => 1,
	builder => '_build_scanner',
	handles => [ qw( scan_ppi_document ) ],
);

sub _build_scanner {
	my $self = shift;
	Perl::PrereqScanner->new();
}

#has 'ppi_document' => (
#	is   => 'rw',
#	isa  => InstanceOf [ 'PPI::Document', ],
#	lazy => 1,
#);

has 'xtest' => (
	is => 'rw',
	isa => Str,
	lazy => 1,
	default => sub {
		'test_requires';
	},
);

has 'develop' => (
	is => 'ro',
	isa => Bool,
	lazy => 1,
	builder => '_develop',
);

sub _develop {
	my $self = shift;
#	return 'running builder';
	if ( $self->{experimental} && $self->{format} eq 'cfile' ){
		return 1;
	} else {
		return 0;
	}
}

no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles - Package Options and Attributes used by L<App::Midgen>

=head1 VERSION

This document describes App::Midgen::Roles version: 0.21_01

=head1 METHODS

none as such, but we do have

=head2 OPTIONS

=over 4

=item * core

=item * debug

=item * dual_life

=item * experimental

=item * format

=item * verbose

=item * zero

=back

for more info see L<midgen>

=head2 ACCESSORS

=over 4

=item * found_twins

Used as a flag to re-run noisy children after discovery of twins

=item * mcpan

accessor to MetaCPAN::API object

=item * output

accessor to App::Midgen::Output object

=item * package_name

Our best guess as to this packages name

=item * package_names

Some package names we found along the way

=item * ppi_document

I encapsulated this and got a nifty speed increase

=item * recommends

Some where to store recommend modules and version info in

=item * requires

Some where to store required modules and version info in

=item * scanner

accessor to Perl::PrereqScanner object

=item * test_requires

Some where to store test_required modules and version info in


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
