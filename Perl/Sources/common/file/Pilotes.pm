package file::Pilotes;


use strict;

use LoadDat;

use models::Pilote;

=pod
Charge la base de données de matos, construit un tableau de catégories d'item
renvoie undef si erreur
=cut
use constant COL_TRIGRAMME   => 0;
use constant COL_FONCTION    => 1;
use constant COL_MASSE       => 2;
sub _pilote_to_array {
	my $pilote = shift;
	return [ $pilote->get_trigramme, $pilote->get_fonction, $pilote->get_masse ];
}


sub load {
	my ($base_filename) = @_;
	my $base = LoadDat::load($base_filename);
	
	if (!$base) {
		GenericWin::erreur_msg("Impossible de charger la liste de materiel de $base_filename : ".LoadDat::get_erreur);
		return undef;
	}
	
	
	my @base_categories = ();

	my $obj = $base->[0];
	my @tab_pilotes = ();

	foreach my $ligne (@{$obj->{contenu}}) {
		push @tab_pilotes, models::Pilote->new($ligne[COL_MASSE], 0, $ligne[COL_TRIGRAMME], $ligne[COL_FONCTION]);
	}

	return \@tab_pilotes;
}

sub save {
	my ($file, $pilotes) = @_;
	my @tab = [ { titre => 'pilotes', contenu => map { _pilote_to_array($_) } $pilotes } ];
	LoadDat::save($file, \@tab);
	
}
