package App::Midgen::Role::FindMinVersion;

use v5.10;
use Types::Standard qw( Bool );
use Moo::Role;
requires qw( ppi_document debug );

our $VERSION = '0.27_05';
use English qw( -no_match_vars );
use version;
use constant {TRUE => 1, FALSE => 0,};
use Try::Tiny;
use Data::Printer { caller_info => 1, colored => 1, };

has 'min_ver_fast' =>
  (is => 'lazy', isa => Bool, );# builder => '_build_min_ver_fast',);

sub _build_min_ver_fast {
  my $self = shift;

  try {
    eval "use Perl::MinimumVersion::Fast";
    if ($EVAL_ERROR) {
      use Perl::MinimumVersion;
      return FALSE;
    }
    else {
      return TRUE;
    }
  };
#  return;
}

#######
# find min perl version
######
sub min_version {
  my $self     = shift;
  my $filename = shift;

  my $dist_min_ver = $App::Midgen::Min_Version;
#p $dist_min_ver;
  my $object;
#p $self->min_ver_fast;

  # Create the version checking object
  if ($self->min_ver_fast) {
say 'fmv running fast';
    $object = Perl::MinimumVersion::Fast->new($filename);
  }
  else {
say 'fmv running slow';
    $object = Perl::MinimumVersion->new($self->ppi_document);
  }

  # Find the minimum version
  my $minimum_version = $object->minimum_version;
#p $minimum_version;
  $dist_min_ver
    = version->parse($dist_min_ver) > version->parse($minimum_version)
    ? version->parse($dist_min_ver)->numify
    : version->parse($minimum_version)->numify;

  my $minimum_explicit_version = $object->minimum_explicit_version;
#p $minimum_explicit_version;
  $dist_min_ver
    = version->parse($dist_min_ver) > version->parse($minimum_explicit_version)
    ? version->parse($dist_min_ver)->numify
    : version->parse($minimum_explicit_version)->numify;

  my $minimum_syntax_version = $object->minimum_syntax_version;
#p $minimum_syntax_version;
  $dist_min_ver
    = version->parse($dist_min_ver) > version->parse($minimum_syntax_version)
    ? version->parse($dist_min_ver)->numify
    : version->parse($minimum_syntax_version)->numify;

  warn 'min_version - ' . $dist_min_ver;# if $self->debug;
  $App::Midgen::Min_Version = $dist_min_ver;
  return;
}

no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles::FindMinVersion - used by L<App::Midgen>

=head1 VERSION

version: 0.27_05

=head1 METHODS

=over 4

=item * min_version

Used to find the minimum version of your package by taking a quick look,
in a module or script and updating C<$App::Midgen::Min_Version> accordingly.

=back

=head2 ACCESSORS

=over 4

=item * min_ver_fast

Used as a flag to indicate which of the following is install

  TRUE ->  L<Perl::MinimumVersion::Fast>
  FALSE -> L<Perl::MinimumVersion>

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

