package App::Midgen::Role::UseOk;

use v5.10;
use Moo::Role;

use Data::Printer { caller_info => 1, colored => 1, };

# Load time and dependencies negate execution time
# use namespace::clean -except => 'meta';

our $VERSION = '0.21_08';
use constant { BLANK => q{ }, NONE => q{}, TWO => 2, THREE => 3, };


#######
# composed method - _xtests_in_single_quote
#######
sub xtests_use_ok {
	my $self = shift;

	#PPI::Document
	#  PPI::Statement::Scheduled
	#    PPI::Token::Word  	'BEGIN'
	#    PPI::Token::Whitespace  	' '
	#    PPI::Structure::Block  	{ ... }
	#      PPI::Token::Whitespace  	'\n'
	#      PPI::Token::Whitespace  	'\t'
	#      PPI::Statement
	#        PPI::Token::Word  	'use_ok'
	#        PPI::Structure::List  	( ... )
	#          PPI::Token::Whitespace  	' '
	#          PPI::Statement::Expression
	#            PPI::Token::Quote::Single  	''Term::ReadKey''
	#            PPI::Token::Operator  	','
	#            PPI::Token::Whitespace  	' '
	#            PPI::Token::Quote::Single  	''2.30''

	my @modules;
	my @version_strings;
	my @chunks =

		map { [ $_->schildren ] }
		grep { $_->child(0)->literal =~ m{\A(?:BEGIN)\z} }
		grep { $_->child(0)->isa('PPI::Token::Word') }
		@{ $self->ppi_document->find('PPI::Statement::Scheduled') || [] };

	foreach my $hunk (@chunks) {

		# looking for use_ok { 'Term::ReadKey' => '2.30' };
		if ( grep { $_->isa('PPI::Structure::Block') } @$hunk ) {

			# hack for List
			my @hunkdata = @$hunk;

			foreach my $ppi_sb (@hunkdata) {
				if ( $ppi_sb->isa('PPI::Structure::Block') ) {
					foreach my $ppi_s ( @{ $ppi_sb->{children} } ) {
						if ( $ppi_s->isa('PPI::Statement') ) {
							p $ppi_s if $self->debug;
							if ( $ppi_s->{children}[0]->content eq 'use_ok' ) {
								my $ppi_sl = $ppi_s->{children}[1];
								foreach my $ppi_se ( @{ $ppi_sl->{children} } ) {
									if ( $ppi_se->isa('PPI::Statement::Expression') ) {
										foreach my $element ( @{ $ppi_se->{children} } ) {
											if (   $element->isa('PPI::Token::Quote::Single')
												|| $element->isa('PPI::Token::Quote::Double') )
											{

												my $module = $element;
#												p $module;
												$module =~ s/^['|"]//;
												$module =~ s/['|"]$//;
												if ( $module =~ m/\A[A-Z]/ ) {
													say 'found module - ' . $module if $self->debug;
													push @modules, $module;
												}

											}


#											if (   $element->isa('PPI::Token::Number::Float')
#												|| $element->isa('PPI::Token::Quote::Single')
#												|| $element->isa('PPI::Token::Quote::Double') )
#											{
#												my $version_string = $element;
#
#												$version_string =~ s/^['|"]//;
#												$version_string =~ s/['|"]$//;
#												next if $version_string !~ m/\A[\d|v]/;
#												if ( $version_string =~ m/\A[\d|v]/ ) {
#
#													push @version_strings, $version_string;
#													say 'found version_string - ' . $version_string
#														if $self->debug;
#												}
#											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}

	p @modules         if $self->debug;
	p @version_strings if $self->debug;

	# if we found a module, process it with the correct catogery
	if ( scalar @modules > 0 ) {

		if ( $self->format eq 'cpanfile' ) {
			# $self->xtest eq 'test_requires' -> t/
			# $self->xtest eq 'test_develop' -> xt/
			if ( $self->xtest eq 'test_requires' ) {
				$self->_process_found_modules( 'test_requires', \@modules );
			} elsif ( $self->develop && $self->xtest eq 'test_develop' ) {
				$self->_process_found_modules( 'test_develop', \@modules );
			}
		} else {
			$self->_process_found_modules( 'test_requires', \@modules );
		}
	}
	return;
}

no Moo::Role;

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Midgen::Roles::UseOk - extra checks for test files, looking
for methods in use_ok in BEGIN blocks, used by L<App::Midgen>

=head1 VERSION

version: 0.21_08

=head1 METHODS

=over 4

=item * xtests_use_ok 

Checking for the following, extracting module name only.

 BEGIN {
   use_ok( 'Term::ReadKey', '2.30' );
   use_ok( 'Term::ReadLine', '1.10' );
   use_ok( 'Fred::BloggsOne', '1.01' );
   use_ok( "Fred::BloggsTwo", "2.02" );
   use_ok( 'Fred::BloggsThree', 3.03 );
 }

Used to check files in t/ and xt/ directories.

=back

=head1 AUTHOR

See L<App::Midgen>

=head2 CONTRIBUTORS

See L<App::Midgen>

=head1 COPYRIGHT

See L<App::Midgen>

=head1 LICENSE

See L<App::Midgen>

=cut
