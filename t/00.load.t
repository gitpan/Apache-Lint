# $Id: 00.load.t,v 1.1.1.1 2002/02/26 17:45:39 petdance Exp $

BEGIN { $| = 1; print "1..1\n"; }
END   { print "not ok 1\n" unless $loaded; }

use Apache::Lint;
$loaded = 1;
print "ok\n";

