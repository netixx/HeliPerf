package file::Pilotes;


use strict;

use LoadDat;

use models::Categorie;
use models::Item;
use models::MainItem;
use calcul::Id;

=pod
Charge la base de données de matos, construit un tableau de catégories d'item
renvoie undef si erreur
=cut
use constant COL_TRIGRAMME   => 0;
use constant COL_FONCTION    => 1;
use constant COL_MASSE       => 2;


sub load {
	my ($base_filename) = @_;
	my $base = LoadDat::load($base_filename);
	
	if (!$base) {
		GenericWin::erreur_msg("Impossible de charger la liste de materiel de $base_filename : ".LoadDat::get_erreur);
		return undef;
	}
	
	
	my @base_categories = ();

	#foreach my $obj (@$base) {
	{
		my $obj = $base->[0];
		my @tab_pilotes = ();

		foreach my $ligne (@{$obj->{contenu}}) {
			push @tab_pilotes, { TRIGRAMME => $ligne[COL_TRIGRAMME],
				FONCTION => $ligne[COL_FONCTION],
				MASSE => $ligne[COL_MASSE] };

		}
		return \@tab_pilotes;
		
	}
}
