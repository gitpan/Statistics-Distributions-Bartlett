package Statistics::Distributions::Bartlett;

#r/ change to Statistics::Distributions::Bartlett?!?

use warnings;
use strict;
use Carp;
use Statistics::Distributions qw/chisqrprob/;
#use Statistics::Descriptive;
use List::Util qw/sum/;
use Math::Cephes qw/:utils/;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(bartlett);

=head1 NAME

Statistics::Distributions::Bartlett - Bartlett's test for equal sample variances.

=cut
=head1 VERSION

This document describes Statistics::Distributions::Bartlett version 0.0.1

=cut
=head1 SYNOPSIS

    use Statistics::Distributions::Bartlett;

    my $a = [qw/ 10 7  20 14 14 12 10 23 17 20 14 13/];
    my $b = [qw/ 11 17 21 11 16 14 17 17 19 21 7  13/];
    my $c = [qw/ 0  1  7  2  3  1  2  1  3  0  1  4/];
    my $d = [qw/ 3  5  12 6 4  3  5  5  5  5  2 4/];
    my $e = [qw/ 3  5  3  5  3  6  1  1  3  2  6 4/];
    my $f = [qw/ 11 9 15 22  15 16 13 10 26 26 24 13 /];

    # Call exported sub routine on ARRAY references of data.
    my $bar = &Statistics::Distributions::Bartlett::bartlett($a,$b,$c,$d,$e,$f);

=cut
=head1 DESCRIPTION

Bartlett test is used to test if k samples have equal variances. Such homogeneity of is assumed by other statistical tests.  
The Bartlett test can be used to verify that assumption. See
http://www.itl.nist.gov/div898/handbook/eda/section3/eda357.htm.

=cut

use version; our $VERSION = qv('0.0.1');

# have a check that all args are numeric in the arrays - i.e. a 1-d equiv of that in MVA
# transpose is always there as we need our arrays to be variable-centric - i.e. rows must be variables and NOT observations!?!

#b bartlett´s univariate uses variance and not SS
sub bartlett {

    #r (    n_total - k ) * ln  ( S_p^2 )  - sum (  n_i-1) * ln  ( S_i^2 )     /   1 + ( 1/(3(k-1))) * ( ( sum ( 1 / (n_i-1) ) - ( 1 / (n_total-k))
    #r S_p^2 = sum ( n_i - 1 ) * S_i^2 / (n_total-k)

    my @groups = @_;
    my $k = scalar @groups;
    croak qq{\nThere must be more than one group} if ($k < 2);
    my $vars = &var(\@groups);
    my $n_total = sum map { scalar @{$_} } @groups;

    #my $SS_p = sum map { print qq{\nss $_->[2] and n $_->[0] and }, ($_->[2]-1) * $_->[0] ;($_->[2]-1) * $_->[0]  } @{$SSs};
    my $var_p = sum  map { ($_->[1]-1) * $_->[0]  } @{$vars};

    $var_p /= ($n_total-$k);
    $var_p = log($var_p);

    #my $SS_sum = sum map { print qq{\nss $_->[2] and n $_->[0] and }, log($_->[0]);($_->[2]-1) * log($_->[0])  } @{$SSs};
    my $var_sum = sum map { ($_->[1]-1) * log($_->[0])  } @{$vars};

    my $n_under = sum map { 1 / ($_->[1] - 1) } @{$vars};
    my $bar_k = ( ( ($n_total-$k) * $var_p ) - $var_sum ) / (1 + ( 1 / ( 3 * ($k-1))) * ( $n_under - ( 1 / ($n_total-$k)) ) ) ;
    my $df = $k -1;
    my $pval = &chisqrprob($df,$bar_k);

    if ( !wantarray ) { print qq{\nK = $bar_k\np_val = $pval\ndf = $df\nk = $k\ntotal n = $n_total}; return; }
    else { return ($bar_k, $pval, $df, $k, $n_total) }

}

sub var { 
    my $groups = shift;
    my $result = [];

    for my $a_ref (@{$groups}) {
        # $stat->count()
        my $n = scalar(@{$a_ref});
        # $stat->sum();
        my $sum = sum @{$a_ref};
        # $stat->mean()
        my $mean = ( $sum / $n ) ;
        my $var = sum map { ($_-$mean)**2  } @{$a_ref};
        $var /= ($n-1);
        push @{$result}, [$var, $n];
    }
    return $result;
}

1; # Magic true value required at end of module

__END__

=head1 DEPENDENCIES

'Statistics::Distributions' => '1.02', 
'Math::Cephes' => '0.47', 
'Carp' => '1.08', 'Perl6::Form' => '0.04',
'List::Util' => '1.19',

=cut
=head1 BUGS

Let me know.

=cut
=head1 AUTHOR

Daniel S. T. Hughes  C<< <dsth@cantab.net> >>

=cut
=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Daniel S. T. Hughes C<< <dsth@cantab.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
=head1 DISCLAIMER OF WARRANTY

Because this software is licensed free of charge, there is no warranty
for the software, to the extent permitted by applicable law. Except when
otherwise stated in writing the copyright holders and/or other parties
provide the software "as is" without warranty of any kind, either
expressed or implied, including, but not limited to, the implied
warranties of merchantability and fitness for a particular purpose. The
entire risk as to the quality and performance of the software is with
you. Should the software prove defective, you assume the cost of all
necessary servicing, repair, or correction.

In no event unless required by applicable law or agreed to in writing
will any copyright holder, or any other party who may modify and/or
redistribute the software as permitted by the above licence, be
liable to you for damages, including any general, special, incidental,
or consequential damages arising out of the use or inability to use
the software (including but not limited to loss of data or data being
rendered inaccurate or losses sustained by you or third parties or a
failure of the software to operate with any other software), even if
such holder or other party has been advised of the possibility of
such damages.
=CUT
