package App::Midgen::Role::Heuristics;

our $VERSION = '0.31_05';
$VERSION = eval $VERSION;    ## no critic

use constant {TRUE => 1, FALSE => 0,};

use Types::Standard qw( Bool );
use Moo::Role;
requires qw( debug meta2 );

use Try::Tiny;
use Data::Printer {caller_info => 1, colored => 1,};
use Term::ANSIColor qw( :constants colored colorstrip );


#######
# correct incorrectly cast modules as RuntimeRecommends and re-cast as RuntimeRequires
# recast_to_runtimerequires
#######
sub recast_to_runtimerequires {
	my $self           = shift;
	my $requires_ref   = shift || return;
	my $recommends_ref = shift || return;

	#extract module names to check from RuntimeRecommends bucket
	my @runtime_recommends;
	foreach my $current_recommends (sort keys %{$recommends_ref}) {
		push @runtime_recommends, $current_recommends;
	}

	foreach my $module (@runtime_recommends) {

		#2nd part of mro - MRO::Compat catch
		if ( $module eq 'MRO::Compat' and  $self->meta2 == FALSE ) {

			print "recasting - $module\n" if $self->debug;

			# add to RuntimeRequires bucket
			$requires_ref->{$module} = $recommends_ref->{$module};

			# delete from RuntimeRecommends bucket
			delete $recommends_ref->{$module};

			# update modules bucket
			$self->{modules}{$module}{prereqs} = 'RuntimeRequires';
		}

		# an ode to negitave logic :)
		try {
			unless ($self->{modules}{$module}{dual_life}
				or $self->{modules}{$module}{corelist} == 1
				or $self->{modules}{$module}{version} eq '!mcpan'
				or $self->{modules}{$module}{count} == 1)
			{
				if ($self->_rc_requires($module, $self->{modules}{$module}{infiles}))
				{

					# add to RuntimeRequires bucket
					$requires_ref->{$module} = $recommends_ref->{$module};

					# delete from RuntimeRecommends bucket
					delete $recommends_ref->{$module};

					# update modules bucket
					$self->{modules}{$module}{prereqs} = 'RuntimeRequires';

					print BRIGHT_BLACK
						. 'Info: re-cast module '
						. $module
						. ' to RuntimeRequires'
						. CLEAR . "\n";
					p $self->{modules}{$module} if $self->debug;
				}
			}
		};
	}

	return;
}

## this may help for future hacking
#    [0] "/lib/Module/Install/Admin/Metadata.pm",
#    [1] 0,
#    [2] "Perl::PrereqScanner",
#    [3] "RuntimeRequires"


#######
# composed method _rc_requires
#######
sub _rc_requires {
	my $self = shift;
	my ($module, $infile) = @_;

	foreach my $index (0 .. $#{$infile}) {

		# next if in a test dir
		next if $infile->[$index][0] =~ m/\A\/x?t/;

		# ignore RuntimeRecommends
		next if $infile->[$index][3] eq 'RuntimeRecommends';

		# find RuntimeRequires which are not from same file
		if ($infile->[$index][3] eq 'RuntimeRequires'
			and ($infile->[$index][0] ne $infile->[$index - 1][0]))
		{
			p $module if $self->debug;
			p $infile->[$index] if $self->debug;

			# found
			return TRUE;
		}
	}

	return FALSE;
}



#######
# correct incorrectly cast modules as TestSuggests and re-cast as TestRequires
# recast_to_testrequires
#######
sub recast_to_testrequires {
	my $self           = shift;
	my $requires_ref   = shift || return;
	my $suggests_ref = shift || return;

	#extract module names to check from RuntimeRecommends bucket
	my @test_suggests;
	foreach my $current_suggests (sort keys %{$suggests_ref}) {
		push @test_suggests, $current_suggests;
	}

	foreach my $module (@test_suggests) {

		# an ode to negitave logic :)
		try {
			unless ($self->{modules}{$module}{dual_life}
				or $self->{modules}{$module}{corelist} == 1
				or $self->{modules}{$module}{version} eq '!mcpan'
				or $self->{modules}{$module}{count} == 1)
			{
				if ($self->_rc_tests($module, $self->{modules}{$module}{infiles})) {

					# add to RuntimeRequires bucket
					$requires_ref->{$module} = $suggests_ref->{$module};

					# delete from RuntimeRecommends bucket
					delete $suggests_ref->{$module};

					# update modules bucket
					$self->{modules}{$module}{prereqs} = 'TestRequires';

					print BRIGHT_BLACK
						. 'Info: re-cast module '
						. $module
						. ' to TestRequires'
						. CLEAR . "\n";
					p $self->{modules}{$module} if $self->debug;
				}
			}
		};
	}

	return;
}

## this may help for future hacking
#    [0] "/lib/Module/Install/Admin/Metadata.pm",
#    [1] 0,
#    [2] "Perl::PrereqScanner",
#    [3] "RuntimeRequires"


#######
# composed method _rc_requires
#######
sub _rc_tests {
	my $self = shift;
	my ($module, $infile) = @_;

	foreach my $index (0 .. $#{$infile}) {

		# next if in a test dir
		next if $infile->[$index][0] !~ m/\At/;

		# ignore RuntimeRecommends
		next if $infile->[$index][3] eq 'TestSuggests';

		# find RuntimeRequires which are not from same file
		if ($infile->[$index][3] eq 'TestRequires'
			and ($infile->[$index][0] ne $infile->[$index - 1][0]))
		{
			p $module if $self->debug;
			p $infile->[$index] if $self->debug;

			# found
			return TRUE;
		}
	}

	return FALSE;
}




no Moo::Role;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::Heuristics - used by L<App::Midgen>

=head1 VERSION

version: 0.31_05

=head1 METHODS

=over 4

=item * recast_to_runtimerequires

Correct incorrectly cast modules as RuntimeRecommends and re-cast as RuntimeRequires

=item * recast_to_testrequires

Correct incorrectly cast modules as TestSuggests and re-cast as TestRequires

=item * run

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










