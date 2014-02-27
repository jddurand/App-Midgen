package App::Midgen::Role::Output::MIdsl;

use Moo::Role;
requires qw( no_index verbose );

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.29_09';
$VERSION = eval $VERSION;    ## no critic

use English qw( -no_match_vars );    # Avoids reg-ex performance penalty
local $OUTPUT_AUTOFLUSH = 1;

use Term::ANSIColor qw( :constants colored );
use constant {NONE => q{},};
use File::Spec;

#######
# header_dsl
#######
sub header_dsl {
	my $self         = shift;
	my $package_name = shift || NONE; # was shift // NONE -> defined $a ? $a : $b
	my $mi_ver       = shift || NONE; # defined shift ? shift : NONE - don't work as per perl5100delta.pod

	$package_name =~ s{::}{/}g;

	print "\nuse inc::Module::Install::DSL "
		. colored($mi_ver, 'yellow') . ";\n";
	if ($package_name ne NONE) {
		print "all_from lib/$package_name.pm\n";
		print "requires_from lib/$package_name.pm\n";
	}

	print "\n";
	return;
}
#######
# body_dsl
#######
sub body_dsl {
	my $self         = shift;
	my $title        = shift;
	my $required_ref = shift || return;

	print 'perl_version ' . $App::Midgen::Min_Version . "\n"
		if $title eq 'requires';
	print "\n";

	my $pm_length = 0;
	foreach my $module_name (sort keys %{$required_ref}) {
		if (length $module_name > $pm_length) {
			$pm_length = length $module_name;
		}
	}

	foreach my $module_name (sort keys %{$required_ref}) {

		if ($module_name =~ /^Win32/sxm) {
			printf "%s %-*s %s %s\n", $title, $pm_length, $module_name,
				$required_ref->{$module_name}, colored('if win32', 'bright_green');
		}
		else {
			printf "%s %-*s %s\n", $title, $pm_length, $module_name,
				$required_ref->{$module_name};
		}
	}
	return;
}
#######
# footer_dsl
#######
sub footer_dsl {
	my $self = shift;
	my $package_name = shift || NONE;
	$package_name =~ s{::}{-}g;

	if ($self->verbose > 0) {
		print BRIGHT_BLACK "\n";
		print "homepage    https://github.com/.../$package_name\n";
		print "bugtracker  https://github.com/.../$package_name/issues\n";
		print "repository  git://github.com/.../$package_name.git\n";
		print CLEAR "\n";
	}
	if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'share')) {
		print "install_share\n\n";
	}

	if (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'script')) {
		print "install_script ...\n\n";
	}
	elsif (defined -d File::Spec->catdir($App::Midgen::Working_Dir, 'bin')) {
		print "install_script bin/...\n\n";
	}

	my @no_index = $self->no_index;
	if (@no_index) {
		print "no_index directory qw{ @no_index }\n\n";
	}

	return;
}

no Moo;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Role::Output::MIdsl Output Format - Module::Install::DSL,
used by L<App::Midgen>

=head1 VERSION

version: 0.29_09

=head1 DESCRIPTION

The output format uses colour to add visualization of module version number
types, be that mcpan, dual-life or added distribution.

=head1 METHODS

=over 4

=item * header_dsl

=item * body_dsl

=item * footer_dsl

=back

=head1 DEPENDENCIES

L<Term::ANSIColor>

=head1 SEE ALSO

L<App::Midgen>

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
