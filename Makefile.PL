require 5.000;
use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Class::Handle',
	'VERSION_FROM' => 'lib/Class/Handle.pm',
	'PREREQ_PM'    => {
		'Test::More'       => 0,
		'Class::ISA'       => 0,
		'Class::Inspector' => 0.2,
	},
	($] >= 5.005) ? (
		'AUTHOR'     => 'Adam Kennedy (cpan@ali.as)',
		'ABSTRACT'   => "Supply object methods to classes",
	) : (),
);
