use inc::Module::Install;

name           ( 'Class-Handle'                );
abstract       ( 'Introspection-handle objects for classes' );
author         ( 'Adam Kennedy <cpan@ali.as>'  );
version_from   ( 'lib/Class/Handle.pm'         );
requires       ( 'perl'             => '5.005' );
requires       ( 'Class::ISA'       => 0       );
requires       ( 'Class::Inspector' => '1.12'  );
build_requires ( 'File::Spec'       => '0.80'  );
build_requires ( 'Test::More'       => '0.47'  );
auto_install   (                               );

&WriteAll;
