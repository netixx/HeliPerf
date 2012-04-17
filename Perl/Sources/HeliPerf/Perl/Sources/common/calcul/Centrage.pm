package calcul::Centrage;

use strict;

sub ajoute_masse {
	my ($bras1, $masse1, $bras2, $masse2) = @_;
	my $masse = $masse1 + $masse2;
	return (0, 0) if ($masse == 0);
	my $bras = ($bras1 * $masse1 + $bras2 * $masse2) / $masse; 
	return ($bras, $masse);
}


sub enleve_masse {
	my ($bras1, $masse1, $bras2, $masse2) = @_;
	return ajoute_masse ($bras1, $masse1, $bras2, -$masse2);
}

sub rafraichir_masse {
	my ($bras1, $masse1, $ancienbras, $ancienmasse, $nouveaubras, $nouveaumasse) = @_;
	return ajoute_masse (enleve_masse($bras1, $masse1, $ancienbras, $ancienmasse),
		$nouveaubras, $nouveaumasse);
}

1;
