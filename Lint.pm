package Apache::Lint;

use warnings;
use strict;

=head1 NAME

Apache::Lint - Apache wrapper around HTML::Lint

=head1 SYNOPSIS

Apache::Lint passes all your mod_perl-generated code through the HTML::Lint module,
and spits out the resulting errors into.

	<Files *.pl>
		SetHandler      perl-script
		PerlHandler	Apache::RegistryFilter Apache::Lint
		Options		+ExecCGI
		PerlSetVar	Filter On
	</Files>

XXX Put in sample code into httpd.conf

=head1 VERSION

Version 0.02

    $Id: Lint.pm,v 1.3 2002/05/31 21:30:55 petdance Exp $

=cut

our $VERSION = '0.02';

=head1 CAVEATS

EVERYTHING that gets passed thru Apache::Lint gets forced to text/html, because
Apache::RegistryFilter eats the content-type. :-(

=head1 TODO

Almost everything is a TODO.  This version barely runs at all, but I want to get it out there.

=over 4

=item * Fix it so the HTML::Lint::Errors get loaded properly.

=back

=cut

our $DEBUG = 1;

use mod_perl 1.21;
use Apache;
use Apache::Constants qw( OK );
use Apache::File;
use Apache::Log;
use HTML::Lint;

sub handler {
    my $r = shift;
    $r = $r->filter_register;

    my $log    = $r->server->log;

    $log->info("Using Apache::Lint");

    # Get any output from previous filters in the chain.
    (my $fh, my $status) = $r->filter_input;

    unless ($status == OK) {
	$log->warn("\tApache::Filter returned $status");
	$log->info("Exiting Apache::Lint");
	return $status;
    }

    my $type = $r->content_type;
    $type = 'text/html';
    my $is_html = ( $r->content_type =~ m!text/html!i );

    $r->send_http_header( $type );
    local $/ = undef;
    my $output = <$fh>;
    $r->print( $output );

    if ( $is_html ) {
	$log->info( "\tPassing thru HTML::Lint" );

        my $lint = new HTML::Lint;
	$lint->newfile( $r->uri );
        $lint->parse( $output );
	$lint->eof;

	for my $error ( $lint->errors() ) {
	    $log->warn( $error->as_string() );
	}
    } else {
	$log->info("\trequest is not for an html document ", "(Apache::Filter) - skipping...")
	    if $Apache::Lint::DEBUG;
    }

    $log->info("Exiting Apache::Lint");

    return $status;
}

1;

__END__

=head1 SEE ALSO

L<HTML::Lint>, L<Apache::Filter>

=head1 TODO

=over 4

=item * Make it work

=back

=head1 LICENSE

This code may be distributed under the same terms as Perl itself.

Please note that these modules are not products of or supported by the
employers of the various contributors to the code.

=head1 AUTHOR

Andy Lester, E<lt>andy@petdance.comE<gt>

=cut
