package file::Profils;

use strict;

use LoadDat;

use models::Profil;

=pod
Charge la base de données de carburant, construit un tableau de {masse => , bras =>
=cut

#use constant COL_VOLUME => 0;
use constant COL_MASSE  => 0;
use constant COL_BRAS   => 1;

use constant SECTION_NAME => 'profils';

use utf8;
use ErreurMod;

sub load {
	my ($base_filename) = @_;
	my $base = LoadDat::load($base_filename);
	
	if (!$base) {
		set_erreur ("Impossible de charger les donnés carburant de $base_filename : ".LoadDat::get_erreur);
		return undef;
	}
	
	if ($#$base < 0) {
		set_erreur ("Impossible de charger les donnés carburant de $base_filename : ".LoadDat::get_erreur);
		return undef;
	}
	
	
	my @tab_profils = ();
	
	foreach my $ligne (@{$base->[0]->{contenu}}) {
		my $nom = shift @$ligne;
		push @tab_profils, models::Profil->new($nom, $ligne);
	}

	
	return \@tab_profils; 

}

sub save {
	my ($base_filename, $profils) = @_;

	my @tab = map {[$_->get_nom, @{$_->get_ids}]} @$profils;
	my $base = [ { titre => SECTION_NAME, contenu => \@tab}];
	LoadDat::save($base_filename, $base);

}
1;
