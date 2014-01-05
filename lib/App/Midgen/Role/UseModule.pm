package App::Midgen::Role::UseModule;

use v5.10;
use Moo::Role;
requires qw( ppi_document debug format xtest _process_found_modules develop );

use PPI;
use Data::Printer; # caller_info => 1;
use Try::Tiny;

use constant {BLANK => q{ }, TRUE => 1, FALSE => 0, NONE => q{}, TWO => 2,
	THREE => 3,};


#######
# composed method - _xtests_in_single_quote
#######
sub xtests_use_module {
	my $self = shift;
	my @modules;
	my @version_strings;

#	p $ppi_doc;
	my $module_runtime_include_found = FALSE;

	#test for module_ryntime

	my $includes = $self->ppi_document->find('PPI::Statement::Include');
	if ($includes) {
		foreach my $include (@{$includes}) {
			next if $include->type eq 'no';
			if (not $include->pragma) {
				my $module = $include->module;
#				p $module;
				if ($module eq 'Module::Runtime') {
					$module_runtime_include_found = TRUE;
				}
			}
		}
	}

#	p $module_runtime_include_found;
	return if $module_runtime_include_found eq FALSE;
#	say 'checking for use_module';

#say 'Option 1';
try {
#
# $bi = use_module("Math::BigInt", 1.31)->new("1_234");
#
#PPI::Document
#  PPI::Statement
#    PPI::Token::Symbol  	'$bi'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Operator  	'='
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'use_module'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"Math::BigInt"'
#        PPI::Token::Operator  	','
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Number::Float  	'1.31'
#    PPI::Token::Operator  	'->'
#    PPI::Token::Word  	'new'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Double  	'"1_234"'
#    PPI::Token::Structure  	';'
#  PPI::Token::Whitespace  	'\n'


	my @chunks =

		map  { [$_->schildren] }
#		grep { $_->{children}[4]->content eq 'use_module' }
#		grep { $_->child(4)->literal =~ m{\A(?:use_module|use_package_optimistically)\z} }
#		grep { $_->{children}[4]->content eq 'use_module' || 'use_package_optimistically' }
		grep { $_->{children}[4]->content =~ m{\A(?:use_module|use_package_optimistically)\z} }



		grep { $_->child(4)->isa('PPI::Token::Word') }

	    grep { $_->child(2)->content eq '=' }
	    grep { $_->child(2)->isa('PPI::Token::Operator') }

		grep { $_->child(0)->isa('PPI::Token::Symbol') }

		@{$self->ppi_document->find('PPI::Statement') || []}; # need for pps remove in midgen -> || {}

#	p @chunks;

	foreach my $hunk (@chunks) {

#		p $hunk;

		# looking for use Module::Runtime ...;
		if (grep { $_->isa('PPI::Structure::List') } @$hunk) {

#			say 'found Module::Runtime';

			# hack for List
			my @hunkdata = @$hunk;

			foreach my $ppi_sl (@hunkdata) {
				if ($ppi_sl->isa('PPI::Structure::List')) {
#					p $ppi_sl;
					foreach my $ppi_se (@{$ppi_sl->{children}}) {
						if ($ppi_se->isa('PPI::Statement::Expression')) {
							foreach my $element (@{$ppi_se->{children}}) {
								if ( $element->isa('PPI::Token::Quote::Single')
									|| $element->isa('PPI::Token::Quote::Double'))
								{
									my $module = $element;
									$module =~ s/^['|"]//;
									$module =~ s/['|"]$//;
									if ($module =~ m/\A[A-Z]/) {
										push @modules, $module;
									}
								}

							}
						}
					}
				}
			}
		}
	}
};

#say 'Option 2';
try{
#	say 'lets check for require use_module';
#
# return use_module(\'App::SCS::PageSet\')->new(
# base_dir => $self->share_dir->catdir(\'pages\'),
# plugin_config => $self->page_plugin_config,
# );
#
#PPI::Document
#  PPI::Statement::Break
#    PPI::Token::Word  	'return'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'use_module'
#    PPI::Structure::List  	( ... )
#      PPI::Statement::Expression
#        PPI::Token::Quote::Single  	''App::SCS::PageSet''
#    PPI::Token::Operator  	'->'
#    PPI::Token::Word  	'new'
#    PPI::Structure::List  	( ... )
#      PPI::Token::Whitespace  	'\n'
#      PPI::Token::Whitespace  	'    '
#      PPI::Statement::Expression
#        PPI::Token::Word  	'base_dir'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Operator  	'=>'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Symbol  	'$self'
#        PPI::Token::Operator  	'->'
#        PPI::Token::Word  	'share_dir'
#        PPI::Token::Operator  	'->'
#        PPI::Token::Word  	'catdir'
#        PPI::Structure::List  	( ... )
#          PPI::Statement::Expression
#            PPI::Token::Quote::Single  	''pages''
#        PPI::Token::Operator  	','
#        PPI::Token::Whitespace  	'\n'
#        PPI::Token::Whitespace  	'    '
#        PPI::Token::Word  	'plugin_config'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Operator  	'=>'
#        PPI::Token::Whitespace  	' '
#        PPI::Token::Symbol  	'$self'
#        PPI::Token::Operator  	'->'
#        PPI::Token::Word  	'page_plugin_config'
#        PPI::Token::Operator  	','
#      PPI::Token::Whitespace  	'\n'
#      PPI::Token::Whitespace  	'  '
#    PPI::Token::Structure  	';'



	my @chunks =

		map  { [$_->schildren] }
		grep { $_->{children}[2]->content eq 'use_module' || 'use_package_optimistically' }
#		grep { $_->child(2)->literal =~ m{\A(?:use_module|use_package_optimistically)\z} }
#		grep { $_->{children}[2]->content =~ m{\A(?:use_module|use_package_optimistically)\z} }

		grep { $_->child(2)->isa('PPI::Token::Word') }

	    grep { $_->child(0)->content =~ m{\A(?:return)\z} }
		grep { $_->child(0)->isa('PPI::Token::Word') }

		@{$self->ppi_document->find('PPI::Statement::Break') || []};

#	p @chunks;

	foreach my $hunk (@chunks) {

#		p $hunk;

		# looking for use Module::Runtime ...;
		if (grep { $_->isa('PPI::Structure::List') } @$hunk) {

#			say 'found Module::Runtime';

			# hack for List
			my @hunkdata = @$hunk;

			foreach my $ppi_sl (@hunkdata) {
				if ($ppi_sl->isa('PPI::Structure::List')) {
#					p $ppi_sl;
					foreach my $ppi_se (@{$ppi_sl->{children}}) {
						if ($ppi_se->isa('PPI::Statement::Expression')) {
							foreach my $element (@{$ppi_se->{children}}) {
								if ( $element->isa('PPI::Token::Quote::Single')
									|| $element->isa('PPI::Token::Quote::Double'))
								{
									my $module = $element;
									$module =~ s/^['|"]//;
									$module =~ s/['|"]$//;
									if ($module =~ m/\A[A-Z]/) {
										push @modules, $module;
									}
								}

							}
						}
					}
				}
			}
		}
	}
};

	p @modules;#         if $self->debug;
	p @version_strings if $self->debug;

	# if we found a module, process it with the correct catogery
	if ( scalar @modules > 0 ) {

#		if ( $self->format =~ /cpanfile|metajson/ ) {
#			if ( $self->xtest eq 'test_requires' ) {
#				$self->_process_found_modules( 'test_requires', \@modules );
#			} elsif ( $self->develop && $self->xtest eq 'test_develop' ) {
#				$self->_process_found_modules( 'test_develop', \@modules );
#			}
#		} else {
			$self->_process_found_modules( 'requires', \@modules );
#		}
	}



#	foreach (0 .. $#modules) {
#		$req->add_minimum($modules[$_] => 0);
#	}
#	p @modules;
	return;
}


#######
# composed method test for include Module::Runtime
#######
sub _is_module_runtime {
	my ($self, $doc) = @_;
	my $module_runtime_include_found = FALSE;
	p $doc;

#PPI::Document
#  PPI::Statement::Include
#    PPI::Token::Word  	'use'
#    PPI::Token::Whitespace  	' '
#    PPI::Token::Word  	'Module::Runtime'

	try {
		my $includes = $doc->find('PPI::Statement::Include');
		if ($includes) {
			foreach my $include (@{$includes}) {
				next if $include->type eq 'no';
				if (not $include->pragma) {
					my $module = $include->module;
					p $module;
					if ($module eq 'Module::Runtime') {
						$module_runtime_include_found = TRUE;
					}
				}
			}
		}
	};
	p $module_runtime_include_found;
	return $module_runtime_include_found;

}

no Moo::Role;

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Midgen::Roles::UseModule - extra checks for test files, looking
for methods in use_ok in BEGIN blocks, used by L<App::Midgen>

=head1 VERSION

version: 0.26

=head1 DESCRIPTION

This scanner will look for the following formats or variations there in,
inside BEGIN blocks in test files:

=begin :list

* use_module( 'Fred::BloggsOne', '1.01' );

* use_module( "Fred::BloggsTwo", "2.02" );

* use_module( 'Fred::BloggsThree', 3.03 );

=end :list

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

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
