# $Id: Makefile.PL,v 1.2 2002/05/28 21:58:55 petdance Exp $
use strict;
use ExtUtils::MakeMaker;
use File::Find;

find( \&filecheck, "." );

sub filecheck {
	unlink if /~$/;	# Remove any vi backup files
	die "Aborting: Swapfile $_ found" if /\.swp$/;
}

&WriteMakefile(
	NAME		=> 'Apache::Lint',
	DISTNAME	=> 'Apache-Lint',
	VERSION_FROM	=> 'Lint.pm',
	ABSTRACT_FROM	=> 'Lint.pm',
	AUTHOR		=> 'Andy Lester <andy@petdance.com>',

	PM => {
		'Lint.pm' => '$(INST_LIBDIR)/Apache/Lint.pm',
		},
	PREREQ_PM	=> {
		'HTML::Lint'	=> '0.93',
		},
	dist => {
		COMPRESS => 'gzip -9f', 
		SUFFIX => 'gz',
		},
	);

