# $Id: Makefile.PL,v 1.3 2002/05/31 20:56:54 petdance Exp $
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

	PREREQ_PM	=> {
		'HTML::Lint'	=> '0.94',
		},
	dist => {
		COMPRESS => 'gzip -9f', 
		SUFFIX => 'gz',
		},
	);

