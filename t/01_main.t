#!/usr/bin/perl

# Formal testing for Class::Inspector

# Do all the tests on ourself, since we know we will be loaded.

use strict;
use lib '../../modules'; # Development testing
use lib '../lib';           # Installation testing
use UNIVERSAL 'isa';
use Test::More tests => 36;

# Set up any needed globals
use vars qw{$loaded $ch $bad};
BEGIN {
	$loaded = 0;
	$| = 1;

	# To make maintaining this a little faster,
	# $ci is defined as Class::Inspector, and
	# $bad for a class we know doesn't exist.
	$ch = 'Class::Handle';
	$bad = 'Class::Handle::Nonexistant';
}





# Check their perl version
BEGIN {
	ok( $] >= 5.005, "Your perl is new enough" );
}





# Does the module load
END { ok( 0, 'Loads' ) unless $loaded; }
use Class::Handle;
$loaded = 1;
ok( 1, 'Loads' );





# Check the good/bad class name code
ok( $ch->new( $ch ), 'Constructor allows known valid' );
ok( $ch->new( $bad ), 'Constructor allows  correctly formatted, but not installed' );
ok( $ch->new( 'A::B::C::D::E' ), 'Constructor allows  long classes' );
ok( $ch->new( '::' ), 'Constructor allows main' );
ok( $ch->new( '::Blah' ), 'Constructor allows main aliased' );
ok( ! $ch->new(), 'Constructor fails for missing class' );
ok( ! $ch->new( '4teen' ), 'Constructor fails for number starting class' );
ok( ! $ch->new( 'Blah::%f' ), 'Constructor catches bad characters' );





# Create a dummy class for the remainder of the test
package Class::Handle::Dummy;

use strict;
use base 'Class::Handle';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '12.34';
}

sub dummy1 { 1; }
sub dummy2 { 2; }
sub dummy3 { 3; }

package main;





# Check a newly returned object
my $handle = $ch->new( 'Class::Handle::Dummy' );
ok( isa( $handle, 'HASH' ), 'New object is a hash reference' );
ok( isa( $handle, 'Class::Handle' ), 'New object is correctly blessed' );
ok( (scalar keys %$handle == 1), 'Object contains only one key' );
ok( exists $handle->{name}, "The key is named correctly" );
ok( $handle->{name} eq 'Class::Handle::Dummy', "The contents of the key is correct" );
ok( $handle->name eq 'Class::Handle::Dummy', "->name returns class name" );





# Check the UNIVERSAL related methods
is( $ch->VERSION, $Class::Handle::VERSION, '->VERSION in static context returns Class::Handle version' );
ok( $handle->VERSION eq '12.34', '->VERSION in object context returns handle classes version' );
ok( $ch->isa( 'UNIVERSAL' ), 'Static ->isa works' );
ok( $handle->isa( 'Class::Handle::Dummy' ), 'Object ->isa works' );
ok( $ch->can( 'new' ), 'Static ->can works' );
ok( $handle->can( 'dummy1' ), 'Object ->can works' );





# Check the Class::Inspector related methods
my $ci = Class::Handle->new( 'Class::Inspector' );
my $bad = Class::Handle->new( 'Class::Handle::Nonexistant' );

ok( $ci->loaded, "->loaded detects loaded" );
ok( ! $bad->loaded, "->loaded detects not loaded" );
my $filename = $ci->filename;
is( $filename, File::Spec->catfile( 'Class', 'Inspector.pm' ), "->filename works correctly" );
ok( $INC{$filename} eq $ci->loaded_filename,
	"->loaded_filename works" );
ok( $INC{$filename} eq $ci->resolved_filename,
	"->resolved_filename works" );
ok( $ci->installed, "->installed detects installed" );
ok( ! $bad->installed, "->installed detects not installed" );
my $functions = $ci->functions;
ok( (isa( $functions, 'ARRAY' )
	and $functions->[0] eq '_class'
	and scalar @$functions == 14),
	"->functions works correctly" );
ok( ! $bad->functions, "->functions fails correctly" );
$functions = $ci->function_refs;
ok( (isa( $functions, 'ARRAY' )
	and ref $functions->[0]
	and isa( $functions->[0], 'CODE' )
	and scalar @$functions == 14),
	"->function_refs works correctly" );
ok( ! $bad->function_refs, "->function_refs fails correctly" );
ok( $ci->function_exists( 'installed' ),
	"->function_exists detects function that exists" );
ok( ! $ci->function_exists('nsfladf' ),
	"->function_exists fails for bad function" );
ok( ! $ci->function_exists,
	"->function_exists fails for missing function" );





# Tests for Class::ISA related methods
