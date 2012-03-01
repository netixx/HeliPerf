# package ErreurMod;
=pod
@description
	génère des erreurs spécifiques aux objets
	transmet l'erreur d'un package a un autre
	les modules objets héritent de celui la
=cut

my $erreur;
sub get_erreur {
	return $erreur;
}

sub set_erreur {
  my ($class, $err) = @_;
	$erreur = $err;
}

1;
