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

Version 0.01

=head1 TODO

Almost everything is a TODO.  This version barely runs at all, but I want to get it out there.

=over 4

=item * Fix it so the HTML::Lint::Errors get loaded properly.

=back

=cut

our $VERSION = '0.01';
our $DEBUG = 1;

use mod_perl 1.21;
use Apache;
use Apache::Constants qw( OK DECLINED );
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

    my $is_html = ( $r->content_type =~ m!text/html!i );
    $is_html = 1;

    if ( $is_html ) {
	$log->info( "\tPassing thru HTML::Lint" );
	local $/;
	my $html = <$fh>;

	print $html; 

        my $lint = new HTML::Lint;
	$lint->newfile( $r->uri );
        $lint->parse( $html );
	$lint->eof;

	for my $error ( $lint->errors() ) {
	    $log->warn( $error->as_string() );
	}
    } else {
	$log->info("\trequest is not for an html document ",
               "(Apache::Filter) - skipping...")
	    if $Apache::Lint::DEBUG;

	print while <$fh>;
	# we can't ever return DECLINED when using Apache::Filter
	$status = OK;
    }

    #$r->send_http_header($r->content_type);
    $log->info("Exiting Apache::Lint");

    return $status;
}

sub handlerx {
    my $r = shift;
    $r = $r->filter_register;
    my $log = $r->server->log;

    $log->info("Using Apache::Lint");

    unless ($r->content_type =~ m!text/html!i) {
	$log->info("\trequest is not for an html document - skipping...")
	    if $Apache::Lint::DEBUG;
	$r->headers_out->set( "Lint-status" => "skipped" );
	return DECLINED;
    }
    
    my $fh;
    my $status;
    ($fh, $status) = $r->filter_input;

    unless ( $status == OK ) {
	$log->info( "Exiting because status = $status" );
	return $status;
    }

    $r->headers_out->set( "Lint-status" => "touched" );

    # Slurp the file.
    my $html = do {local $/; <$fh>};
    print $html;
    return OK;
}

=pod
sub randomcrapforholding {
    my $lint = new HTML::Lint;
    $lint->newfile( $r->uri );
    $lint->parse( $html );
    $lint->eof;

    my $nerrors = scalar $lint->errors();
    
    for my $error ( $lint->errors() ) {
	$log->info( $error->as_string() );
    }

    $log->info( "Done linting", localtime );

    $r->headers_out->set( "Lint-status" => "$nerrors errors" );

    $r->send_http_header('text/html');
    my $phase = "gronk";
    $r->headers_out->set( "Lint-$phase" => $phase );
    print $html;

    return OK;
}
=cut

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
