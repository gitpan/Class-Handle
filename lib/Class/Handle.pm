package Class::Handle;

# Provides a friendly interface to classes

# See Pod at end for full docs.

use 5.005;
use strict;
use UNIVERSAL ();
use Class::ISA ();
use Class::Inspector ();

# Set the version
use vars qw{$VERSION};
BEGIN {
	$VERSION = '1.02';
}





#####################################################################
# Constructor

# Create the new Class object
sub new {
	my $class = ref $_[0] ? ref shift : shift;

	# Get and check the class name
	my $name = shift or return undef;
	$name = 'main' if $name eq '::';
	$name =~ s/^::/main::/;
	return undef unless $name =~ /^[a-z]\w*((?:'|::)\w+)*$/io;

	# Create and return the object
	bless { name => $name }, $class;
}

# Get the class name back out
sub name { $_[0]->{name} }





#####################################################################
# UNIVERSAL Methods

# Get the class version.
# Returns the version if available.
# Returns undef if no version defined or class not loaded.
sub VERSION {
	my $either = shift;

	# In the special case that someone wants to know OUR version,
	# let them find it out as normal. Otherwise, return the VERSION
	# for the class we point to.
	ref $either
		? UNIVERSAL::VERSION( $either->{name} )
		: UNIVERSAL::VERSION( $either );
}

# Pass through the "isa" method as above
sub isa {
	my $either = shift;
	my $isa = shift or return undef;

	# In the special case that someone wants to know an isa for
	# OUR version, let them find it out as normal. Otherwise, return
	# the isa for the class we point to.
	ref $either
		? UNIVERSAL::isa( $either->{name}, $isa )
		: UNIVERSAL::isa( $either, $isa );
}

# Pass throug the "can" method as above
sub can {
	my $either = shift;
	my $can = shift or return undef;

	# In the special case that someone wants to know a "cab" for
	# OUR versoin, let them find it out as normal. Otherwise, return
	# the can for the class we point to.
	ref $either
		? UNIVERSAL::can( $either->{name}, $can )
		: UNIVERSAL::can( $either, $can );
}





#####################################################################
# Class::Inspector methods

# Is the class installed
sub installed {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->installed( $self->{name} );
}

# Is the class loaded
sub loaded {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->loaded( $self->{name} );
}

# Get the base filename
sub filename {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->filename( $self->{name} );
}

# Get the resolved filename
sub resolved_filename {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->resolved_filename( $self->{name} );
}

# Get the loaded filename
sub loaded_filename {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->loaded_filename( $self->{name} );
}

# Get the functions for a loaded class
sub functions {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->functions( $self->{name} );
}

# Get the functions ( as CODE refs ) for a loaded class
sub function_refs {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->function_refs( $self->{name} );
}

# Is a particular function defined for a class
sub function_exists {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->function_exists( $self->{name}, @_ );
}

# Get the methods for a class
sub methods {
	my $self = ref $_[0] ? shift : return undef;
	Class::Inspector->methods( $self->{name}, @_ );
}





#####################################################################
# Class::ISA Methods

# Get the super_path for a class
sub super_path {
	my $self = ref $_[0] ? shift : return undef;
	Class::ISA::super_path( $self->{name} );
}

# Get the super path including outself
sub self_and_super_path {
	my $self = ref $_[0] ? shift : return undef;
	Class::ISA::self_and_super_path( $self->{name} );
}

# Extra method that ALSO includes UNIVERSAL
sub full_super_path {
	my $self = ref $_[0] ? shift : return ();
	Class::ISA::self_and_super_path( $self->{name} ), 'UNIVERSAL';
}






#####################################################################
# Task Methods

# These methods are specific to Class::Handle and provide simpler
# interfaces to common tasks.

# Run-time load a class, as if it were a C<use>, including import.
# Roughly equivalent to require $name; $name->import;
sub load {
	my $self = shift or return undef;

	# Shortcut if the class is already loaded
	return 1 if Class::Inspector->loaded( $self->{name} );

	# Get the resolved file name
	my $filename = $self->resolve_filename() or return undef;

	# Load the class
	require $filename or return undef;

	# Do we need to call an import method?
	my $import = $self->can( 'import' ) or return 1;

	# Go to the import
	goto &{$import};
}

1;

__END__

=pod

=head1 NAME

Class::Handle - Create objects that are handles to Classes

=head1 SYNOPSIS

  # Create a class handle
  use Class::Handle;
  my $class = Class::Handle->new( 'Foo::Class' );
  my $name = $class->name;
  
  # UNIVERSAL type methods
  $class->VERSION();
  $class->isa( 'Foo:Bar' );
  $class->can( 'blah' );
  
  # Class::Inspector type methods
  $class->installed();
  $class->loaded();
  $class->filename();
  $class->resolved_filename();
  $class->functions();
  $class->function_refs();
  $class->function_exists( 'function' );
  $class->methods( 'public', 'full' );
  
  # Class::ISA type methods
  $class->super_path();
  $class->self_and_super_path();
  $class->full_super_path();
  
  # Loading and unloading
  $class->load();

=head1 DESCRIPTION

Class related functionality in Perl is broken up into a variety of different
modules. Class::Handle attempts to provide a convenient object wrapper around
the various different types of functions that can be performed on a class.

Please note that this is an initial non-production quality release, and should
be used as such. Functionality and API are subject to change without notice.

Currently, Class::Handle provies what is effectively a combined API from
C<UNIVERSAL>, C<Class::ISA> and C<Class::Inspector> for obtaining information
about a Class, and some additional task methods, such as C<load> to common
tasks relating to classes.

=head1 UNIVERSAL API

To ensure we maintain compliance with other classes that rely on
methods provided by C<UNIVERSAL>, Class::Handle acts in the normal way when
something like C<Class::Handle->VERSION> is called. That is, it returns the
version of Class::Handle itself. When C<UNIVERSAL> methods are called on
an instantiation the method is changed to act on the class we have a handle
to. For example, the two following statements are equivalent.

  # Getting the version directly
  print Foo::Bar->VERSION;
  
  # Getting the version via Class::Handle
  my $class = Class::Handle->new( 'Foo::Bar' );
  print $class->VERSION;

This also applies to the C<isa> and C<can> methods.

=head1 METHODS

=head2 new $class

The C<new> constructor will create a new handle to a class or unknown
existance or status. That is, it won't check that the class actually exists
at this time. It WILL however check to make sure that your class name is legal.

  Returns a new Class::Handle object on success
  Returns undef if the class name is illegal

=head2 name

The c<name> method returns the name of the class as original specified in
the constructor.

=head2 VERSION

Find the version for the class. Does not check that the class is loaded ( at
this time ). Returns the version on success. Returns undef if the class does
not defined a C<$VERSION>, or the class is not loaded.

=head2 isa $class

Checks to see if the class is a subclass of another class. Does not check that
the class is loaded ( at this time ). Returns true/false as for
C<UNIVERSAL::isa>

=head2 can $method

Checks to see if a particular method is defined for the class. Returns a
C<CODE> ref to the function is the method is available. Returns false if the
class does not have that method available.

=head2 installed

Checks to see if a particular class is installed on the machine, or at least
that the class is available to perl. In this case, "class" really means
"module". This methods cannot detect a class that is not a module. ( Has it's
own file ). Returns true if the class is installed and available. Returns
false otherwise.

=head2 loaded

Checks to see if a class is loaded. In this case, "class" does NOT mean
"module". The C<loaded> method will return true for classes that do not have
their own file.

For example, if a module C<Foo> contains the classes C<Foo>, C<Foo::Bar> and
C<Foo::Buffy>, the C<loaded> method will return true for all of the classes.

Returns true if the class is loaded. Returns false otherwise.

=head2 filename

Returns the base filename for a class. For example, for the class
C<Foo::Bar>, C<loaded> would return C<"Foo/Bar.pm">. The C<filename> method
is platform neutral, it should always return the filename in the correct
format for your platform.

=head2 resolved_filename @extra_paths

The C<resolved_filename> will attempt to find the real file on your system
that will be used when a class is loaded. If additional paths are provided
as argument, they will be tried first, before the contents of the @INC array.
If a file cannot be found to match the class, returns false.

=head2 loaded_filename

If the class is loaded, returns the name of the file that it was originally
loaded from. Returns false if the class is not loaded, or did not have it's own
file.

=head2 functions

Returns a list of the names of all the functions in the classes immediate
namespace. Note that this is not the METHODS of the class, just the functions.
Returns a reference to an array of the function names on success. Returns undef
on error or if the class is not loaded.

=head2 function_refs

Returns a list of references to all the functions in the classes immediate
namespace. Returns a reference to an array of CODE refs of the functions on
success. Returns undef on error or if the class is not loaded.

=head2 function_exists $function

Checks to see if the function exists in the class. Note that this is as a
function, not as a method. To see if a method exists for a class, use the
C<can> method in UNIVERSAL, and hence to every other class. Returns 1 if
the function exists. Returns 0 if the function does not exist. Returns
undef on error, or if the class is not loaded.

=head2 methods @options

Attempts to find the methods available to the class. This includes everything
in the classes super path up to, but NOT including, UNIVERSAL. Returns a
reference to an array of the names of all the available methods on success.
Returns undef if the class is not loaded.

Any provided options are passed through, and alter the response in the same
way as for the options to C<Class::Inspector->methods()>, that is, 'public',
'private', 'full' and 'expanded', and combinations thereof.

=head2 super_path

The C<super_path> method is a straight pass through to the
C<Class::ISA::super_path> function. Returns an ordered list of
class names, with no duplicates. The list does NOT include the class itself,
or the UNIVERSAL class.

=head2 self_and_super_path

As above, but includes ourself at the beginning of the path. Directly
passes through to Class::ISA.

=head2 full_super_path

The C<full_super_path> method is an additional method not in C<Class::ISA>.
It returns as for C<super_path>, except that it also contains BOTH the
class itself, and C<UNIVERSAL>. This full list is more technically accurate,
but less commonly used, and as such isn't available from Class::ISA itself.

=head1 BUGS

No known bugs. Additional feature requests are being taken.

=head1 SUPPORT

Bugs should be reported via the CPAN bug tracking system

http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class%3A%3AHandle

For other inquiries, contact the author

=head1 AUTHOR

        Adam Kennedy
        cpan@ali.as
        http://ali.as/

=head1 SEE ALSO

C<UNIVERSAL>, C<Class::ISA>, and C<Class::Inspector>, which provide most
of the functionality for this class.

=head1 COPYRIGHT

Copyright (c) 2002-2003 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
