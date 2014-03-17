package App::Midgen::Role::FindMinVersion;

use constant {TWO => 2, TRUE => 1, FALSE => 0,};

use Types::Standard qw( Bool );
use Moo::Role;
requires qw( ppi_document debug experimental verbose );

our $VERSION = '0.31_01';
$VERSION = eval $VERSION;    ## no critic

use Perl::MinimumVersion;
use Try::Tiny;
use Term::ANSIColor qw( :constants colored colorstrip );
use version;

has 'mro_skip' => (
	is => 'rwp',
	isa => Bool,
	lazy => 1,
	default => sub { 0; },
);


#######
# find min perl version - pmv
######
sub min_version {
	my $self     = shift;
	my $filename = shift;
	$filename =~ s{^/}{};

	my $dist_min_ver = $App::Midgen::Min_Version;
	my $object;

	try {
		$object = Perl::MinimumVersion->new($self->ppi_document);
	};

	# Find the minimum version
	try {
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($object->minimum_version)
			? version->parse($dist_min_ver)
			: version->parse($object->minimum_version);
	};

	try {
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($object->minimum_explicit_version)
			? version->parse($dist_min_ver)
			: version->parse($object->minimum_explicit_version);
	};

	try {
		$dist_min_ver
			= version->parse($dist_min_ver)
			> version->parse($object->minimum_syntax_version)
			? version->parse($dist_min_ver)
			: version->parse($object->minimum_syntax_version);
	};

	try {
		my $blame = $object->minimum_syntax_reason->element->content;

		if ($blame =~ m/\bmro[\s|;]/) {
			$self->_set_mro_skip(TRUE);
			print BRIGHT_BLACK
				. 'Info: PMV blame = '
				. WHITE
				. $blame
				. BRIGHT_BLACK
				. ' -> 5.010 in '
				. $filename
				. ' # -x to skip'
				. CLEAR . "\n";
		}
	};

	if ($self->{mro_skip} && $self->{experimental}) {
		print BRIGHT_BLACK
			. 'Warning: PMV blame = '
			. RED . 'mro'
			. BRIGHT_BLACK . ' -> '
			. 'skipping pmv for this file ^^'
			. CLEAR . "\n";
		$self->_set_mro_skip(FALSE);
		return;
	}
	else {
		print "min_version - $dist_min_ver\n" if ($self->{verbose} == TWO);
		$App::Midgen::Min_Version = version->parse($dist_min_ver)->numify;
	}

	return;
}

no Moo::Role;

1;


__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::FindMinVersion - used by L<App::Midgen>

=head1 VERSION

version: 0.31_01

=head1 METHODS

=over 4

=item * min_version

Used to find the minimum version of your package by taking a quick look,
in a module or script and updating C<$App::Midgen::Min_Version> accordingly.

=back

=head1 AUTHOR

See L<App::Midgen>

=head2 CONTRIBUTORS

See L<App::Midgen>

=head1 COPYRIGHT

See L<App::Midgen>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

